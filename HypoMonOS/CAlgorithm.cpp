/***************************************************************************
    File:           CAlgorithm.cpp
    Class:          CAlgorithm
    Base Class:     CHypoMonOS
    Created:        Wed Apr 04 2012
    Author:         Nejhdeh Ghevondian
    Copyright:      (C) 2012 by AiMedics Pty. Ltd.
    Email:          nejhdeh@AiMedics.com

    Description:    The implementation file for the CAlgorithm class for controlling the
                    algorithm within the HypoMonOS system.
 ***************************************************************************/
#include "CAlgorithm.h"
#include "CProcessCont.h"
#include "CTimeUtils.h"
#include "CAlgoError.h"
#include "CVectorStorage.h"
#include "CAlgoDefs.h"
#include "FuzzyRules.h"

//static declerations
double CAlgorithm::sigma;
double CAlgorithm::coeff[20];
WORD   CAlgorithm::rowNum = 0;
/***************************************************************************
    Function:       CAlgorithm()
    Created:        04/04/12
    Parameters:     non
    Return:         non
    Purpose:        Provides the default constructor for CAlgorithm
***************************************************************************/
CAlgorithm::CAlgorithm()
{

}
/***************************************************************************
    Function:       ~CAlgorithm()
    Created:        04/04/12
    Parameters:     non
    Return:         non
    Purpose:        Provides the destructor for CAlgorithm
***************************************************************************/
CAlgorithm::~CAlgorithm()
{

}
/***************************************************************************
    Function:       Init()
    Created:        04/04/12
    Parameters:     non
    Return:         non - throw exception if error
    Purpose:        The initialisation function for the CAlgorithm class.
    Note:           polymorphised from base class
***************************************************************************/
void CAlgorithm::Init ()
{
    CProcessCont procCont;

    //set the algorithm parameters
    sigma = SIGMA;

    frame = 0;

    //calculate coefficients
    //first calc the number of coefficients needed
    numOfCoeff = (WORD)ceil(6*sigma);
    calcCoefficients(numOfCoeff);

    //init signal handler for process termination
    if(initSignalHndlr() == ERROR)
        throw CAlgoError(errno);

    //init semaphores & shared memory
    procCont.InitSemaphore(&CProcessCont::pProcInfo.semId.algorithm_semId,
    &CProcessCont::pProcInfo.shMemId.algorithm_shMemId, 2);

}

/***************************************************************************
    Function:       initSignalHndlr()
    Created:        04/04/12
    Parameters:     non
    Return:         non - throw exception if error
    Purpose:        To initialise the signal handlr functionality for
                    this class
***************************************************************************/
STATUS CAlgorithm::initSignalHndlr()
{
 struct sigaction action;
    sigset_t blockset;

    try{
        //set up the signal handlers
        action.sa_mask = blockset;
        action.sa_flags = SA_SIGINFO;
        action.sa_sigaction = &signalHndlr;

        //inform OS of the handler
        if(sigaction(SIGUSR1|SIGTERM, &action, NULL) == ERROR)
            throw CAlgoError(errno);

        //initialise block
        if(sigemptyset(&blockset) == ERROR)
            throw CAlgoError(errno);

        //inform OS to block further SIGUSR1 while in handler
        if(sigaddset(&blockset, SIGUSR1|SIGTERM) == ERROR)
            throw CAlgoError(errno);

        }catch (CExceptionHndlr& excpHndlr){
            //handle the error
            excpHndlr.HandleError();
            return ERROR;
        }
    return OK;
}
/***************************************************************************
    Function:       signalHndlr()
    Created:        04/04/12
    Parameters:     non
    Return:         OK if sucessful, otherwise ERROR
    Purpose:        The CAlgorithm class signal handler function
                    Used to terimnate the current CAlgorithm process
***************************************************************************/
void CAlgorithm::signalHndlr(const int sigNum, siginfo_t* info, void* extra)
{
    if(sigNum == SIGTERM)
    {
        //perform proper cleanup process
    //    printf("CAlgorithm performing cleanup process . . .\n");

        //now kill myself
        kill(getpid(),SIGKILL);
    }
}
/***************************************************************************
    Function:       normalise()
    Created:        04/04/12
    Parameters:     baselineBegin - where to start the normalisation process
                    baselineCount - how many points to normalise
                    writeFile - writing to file
    Return:         non - throw exception if error
    Purpose:        To normalise the parameter data array upto the point
                    where the user is requested (by FRAME_COUNT).
***************************************************************************/
void CAlgorithm::normalise(const WORD baselineBegin, const WORD baselineCount, const bool writeFile)
{
    char writeStr[100] = {""};
    FILE* pNormParamFd = fopen(CFileStorage::file_info.normParamFileStr,"a");
    double localSum=0, meanQT = 0, diffSqr=0, qtSD=0;
    static bool doStat = false;

    //load parameter array into normalised array
    for (UINT n=baselineBegin; n<baselineCount; n++)
    {
        //update vectors
        CAcqCont::acqInfo.normParamArray[FRAME_VECTOR][n] = CAcqCont::acqInfo.paramArray[FRAME_VECTOR][n];
        CAcqCont::acqInfo.normParamArray[HR_VECTOR][n] = (double)CAcqCont::acqInfo.paramArray[HR_VECTOR][n]/CAcqCont::acqInfo.sharedBuf[BANK42+HR_NORM_INDEX];
        CAcqCont::acqInfo.normParamArray[QT_VECTOR][n] = (double)CAcqCont::acqInfo.paramArray[QT_VECTOR][n]/CAcqCont::acqInfo.sharedBuf[BANK42+QT_NORM_INDEX];
        CAcqCont::acqInfo.normParamArray[AC_SI_VECTOR][n] = (double)CAcqCont::acqInfo.paramArray[AC_SI_VECTOR][n]/CAcqCont::acqInfo.sharedBuf[BANK42+SI_NORM_INDEX];

        //write to file if necessary
        if(writeFile)
        {
            //now format the string & write results to file
            sprintf(writeStr, "%5d%8.3f%8.3f%8.3f", n,
                (double)CAcqCont::acqInfo.normParamArray[HR_VECTOR][n],    //normalised heart rate
                (double)CAcqCont::acqInfo.normParamArray[QT_VECTOR][n],    //normalised interval
                (double)CAcqCont::acqInfo.normParamArray[AC_SI_VECTOR][n]);   //normalised skim imp. gain 1

            fwrite(writeStr,SINGLE_BYTE, strlen(writeStr),pNormParamFd);

            if(doStat == false)
            {
                sprintf(writeStr, "\n");
                fwrite(writeStr,SINGLE_BYTE, strlen(writeStr),pNormParamFd);
            }
        }
    }

    //sd
    if(baselineCount > NORM_WINDOW)
    {
        for (DWORD i=(baselineCount-NORM_WINDOW); i< baselineCount; i++)
            localSum += CAcqCont::acqInfo.normParamArray[QT_VECTOR][i];

        meanQT  = localSum/NORM_WINDOW;

        localSum=0;

        for (DWORD i=(baselineCount-NORM_WINDOW); i< baselineCount; i++)
        {
            diffSqr = (CAcqCont::acqInfo.normParamArray[QT_VECTOR][i] - meanQT) * (CAcqCont::acqInfo.normParamArray[QT_VECTOR][i] - meanQT);
            localSum += diffSqr;
        }

        qtSD = sqrt(localSum)/NORM_WINDOW;

        //now format the string & write results to file
        sprintf(writeStr, "%8.3f%8.3f\n", meanQT, qtSD);
        fwrite(writeStr,SINGLE_BYTE, strlen(writeStr),pNormParamFd);

        doStat = true;
    }


    fclose(pNormParamFd);

}

/***************************************************************************
    Function:       calcCoefficients()
    Created:        04/04/12
    Parameters:     coeffLength - the length of the coefficients
    Return:         non - throw exception if error
    Purpose:        To calculate the coefficients of the smoother function
***************************************************************************/
void CAlgorithm::calcCoefficients(const WORD coeffLength)
{
    double w[coeffLength];
    double sumW=0, sumWX=0, sumWXX=0, TXX=0;

    //calculate the weights vector
    for(int n=0;n<coeffLength;n++)
    {
        w[n] = exp(-0.5 * pow(n/sigma,2));
        sumW += w[n];
        sumWX += w[n]*n;
        sumWXX+= w[n]*n*n;
    }

    TXX = sumWXX - sumWX*sumWX/sumW;

    //now calc the weights
    for(int n=0;n<coeffLength;n++)
        coeff[n] = w[n]/(sumW*TXX) * (sumWXX - n*sumWX);

}

/***************************************************************************
    Function:       smooth()
    Created:        04/04/12
    Parameters:     smoothHistory - number of data pints used in window
                    writeFile - writing to file
    Return:         non - throw exception if error
    Purpose:        To smooth the normalised values, in order to reduce noise
***************************************************************************/
void CAlgorithm::smooth(const WORD begin, const WORD end, const bool writeFile)
{
    char writeStr[100] = {""};
    FILE* pSmoothParamFd = fopen(CFileStorage::file_info.smoothParamFileStr,"a");


    //load parameter array into the smooth array
    for (UINT n=begin; n<end; n++)
    {
        //update the frame vector irrespective
        CAcqCont::acqInfo.smoothParamArray[FRAME_VECTOR][n] = CAcqCont::acqInfo.paramArray[FRAME_VECTOR][n];

        //check for burn-in window
        if(begin < (BURN_IN-1))
        {
            //update vectors
            CAcqCont::acqInfo.smoothParamArray[HR_VECTOR][n] = (double)CAcqCont::acqInfo.normParamArray[HR_VECTOR][n];
            CAcqCont::acqInfo.smoothParamArray[QT_VECTOR][n] = (double)CAcqCont::acqInfo.normParamArray[QT_VECTOR][n];
            CAcqCont::acqInfo.smoothParamArray[AC_SI_VECTOR][n] = (double)CAcqCont::acqInfo.normParamArray[AC_SI_VECTOR][n];
        }
        else    //must smooth
        {
            //first set the falg to inform 'burn-in' performed
            if(CAcqCont::acqInfo.sharedBuf[BANK42+BURNED_IN] == FALSE)
                CAcqCont::acqInfo.sharedBuf[BANK42+BURNED_IN] = TRUE;

            //calculate the smooth variable for the 'ith' point
            for (int i=0; i<NUM_COEFF_CUTOFF; i++)
            {
                CAcqCont::acqInfo.smoothParamArray[HR_VECTOR][n] += coeff[i] * CAcqCont::acqInfo.normParamArray[HR_VECTOR][n-i];
                CAcqCont::acqInfo.smoothParamArray[QT_VECTOR][n] += coeff[i] * CAcqCont::acqInfo.normParamArray[QT_VECTOR][n-i];
                CAcqCont::acqInfo.smoothParamArray[AC_SI_VECTOR][n] += coeff[i] * CAcqCont::acqInfo.normParamArray[AC_SI_VECTOR][n-i];
            }
        }

        //write to file if necessary
        if(writeFile)
        {
            //now format the string & write results to file
            sprintf(writeStr, "%5d%8.3f%8.3f%8.3f\n", n,
                (double)CAcqCont::acqInfo.smoothParamArray[HR_VECTOR][n],
                (double)CAcqCont::acqInfo.smoothParamArray[QT_VECTOR][n],
                (double)CAcqCont::acqInfo.smoothParamArray[AC_SI_VECTOR][n]);

            fwrite(writeStr,SINGLE_BYTE, strlen(writeStr),pSmoothParamFd);
        }
    }
    fclose(pSmoothParamFd);
}
/***************************************************************************
    Function:       detectHypoOne()
    Created:        04/04/12
    Parameters:     non
    Return:         non - throw exception if error
    Purpose:        the actual detection algorithm - N#1
***************************************************************************/
bool CAlgorithm::detectHypoOne()
{
    char writeStr[100] = {""};
    double measuredThresh = 0;

    //first open file to write results
    FILE* pOutputFd = fopen(CFileStorage::file_info.outputOneFileStr,"a");

    //load the current frame number
    int currentFrame = CAcqCont::acqInfo.sharedBuf[BANK42+FRAME_COUNT];

    measuredThresh =CAcqCont::acqInfo.smoothParamArray[HR_VECTOR][currentFrame]+CAcqCont::acqInfo.smoothParamArray[QT_VECTOR][currentFrame];


    //check to see if above combined threshold
    if(measuredThresh > HYPO_THRESHOLD)
        sprintf(writeStr, "%5d%8s\n", currentFrame, "hypo");
    else
        sprintf(writeStr, "%5d%8s\n", currentFrame, "eugly");

    //now write results to the file
    fwrite(writeStr,SINGLE_BYTE, strlen(writeStr),pOutputFd);

    fclose(pOutputFd);

    return true;
}

/***************************************************************************
    Function:       detectHypoTwo()
    Created:        04/04/12
    Parameters:     non
    Return:         non - throw exception if error
    Purpose:        the actual detection algorithm - N#2
***************************************************************************/
bool CAlgorithm::detectHypoTwo()
{
 /*   char writeStr[100] = {""};
    double outFuzzyHR[2] = {0,0};
    double outFuzzyQT[2] = {0,0};
    double outFuzzySI[2] = {0,0};
    double fireStrength[4] = {0,0,0,0};
    BYTE fuzzyVarHR[2] = {NO_VARIABLE,NO_VARIABLE};
    BYTE fuzzyVarQT[2] = {NO_VARIABLE,NO_VARIABLE};
    BYTE fuzzyVarSI[2] = {NO_VARIABLE,NO_VARIABLE};
    BYTE count=0;
    BYTE whichRules[4] = {0,0,0,0};
    double maxFire = 0;

    //first open file to write results
    FILE* pOutputFd = fopen(CFileStorage::file_info.outputTwoFileStr,"a");

    //load the current frame number
    frame = CAcqCont::acqInfo.sharedBuf[BANK42+FRAME_COUNT];
    CAcqCont::acqInfo.detectArray[FRAME_VECTOR][rowNum] = frame;

    //Fuzzify
    //-------
    //obtain the output form each fuzzy variable
    fuzzify(outFuzzyHR,fuzzyVarHR,CAcqCont::acqInfo.smoothParamArray[HR_VECTOR][frame],HEART_RATE);
    fuzzify(outFuzzyQT,fuzzyVarQT,CAcqCont::acqInfo.smoothParamArray[QT_VECTOR][frame],QTc);
    fuzzify(outFuzzySI,fuzzyVarSI,CAcqCont::acqInfo.smoothParamArray[AC_SI_VECTOR][frame],SKIN_IMPEDANCE);

    //calc MIN operator - firing strength & also perform rule identification
    //----------------------------------------------------------------------
    for (int i=0; i<2; i++)
        for (int j=0; j<2; j++, count++)
        {
            if(outFuzzyHR[i] < outFuzzyQT[j])
                fireStrength[count] = outFuzzyHR[i];
            else
                fireStrength[count] = outFuzzyQT[j];

            whichRules[count] = rule[fuzzyVarHR[i]][fuzzyVarQT[j]];
        }

    count=0;
    //calc MAX operator
    //-----------------
    for (int i=0; i< 4; i++)
        if(fireStrength[i] > maxFire)
        {
            maxFire = fireStrength[i];
            count = i;
        }

    //identification
    //--------------
    if((CAcqCont::acqInfo.detectArray[OUTPUT_VECTOR][rowNum] = whichRules[count]) == HYPO)
    {
        //HYPO
        CAcqCont::acqInfo.sharedBuf[BANK42+DETECTED_HYPO] = TRUE;
        CCommandCont::commandInfo.command[SECD_COMMAND] = HYPO_DETECTED;

        sprintf(writeStr, "%5d%8s\n", frame, "hypo");
    }
    else
    {
        //EUGLY
        CAcqCont::acqInfo.sharedBuf[BANK42+DETECTED_HYPO] = FALSE;

        sprintf(writeStr, "%5d%8s\n", frame, "eugly");
    }

    //increment for next time
    rowNum++;

    //now write results to the file
    fwrite(writeStr,SINGLE_BYTE, strlen(writeStr),pOutputFd);

    fclose(pOutputFd);     */

    return true;
}

/***************************************************************************
    Function:       fuzzify()
    Created:        04/04/12
    Parameters:     input - the input crisp parameter
    Return:         non
    Purpose:        The output the fuzzified value according to the input
***************************************************************************/
void CAlgorithm::fuzzify(double* outFuzzy, BYTE* fuzzyVariable, const double input, const BYTE whichParameter)
{
    switch(whichParameter)
    {
        case HEART_RATE:
            if(input <= N_HR_b)
            {
                outFuzzy[0] = 1;
                outFuzzy[1] = 0;

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = NORMAL;
                fuzzyVariable[1] = NO_VARIABLE;
            }
            else if((input > N_HR_b) && (input <= N_HR_c))
            {
                outFuzzy[0] = (N_HR_c - input)/(N_HR_c - N_HR_b);
                outFuzzy[1] = (input - AN_HR_a)/(AN_HR_b - AN_HR_a);

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = NORMAL;
                fuzzyVariable[1] = ABOVE_NORMAL;

            }
            else if((input > AN_HR_b) && (input <= AN_HR_c))
            {
                outFuzzy[0] = (AN_HR_c - input)/(AN_HR_c - AN_HR_b);
                outFuzzy[1] = (input - H_HR_a)/(H_HR_b - H_HR_a);

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = ABOVE_NORMAL;
                fuzzyVariable[1] = HIGH;
            }
            else if((input > H_HR_b) && (input <= H_HR_c))
            {
                outFuzzy[0] = (H_HR_c - input)/(H_HR_c - H_HR_b);
                outFuzzy[1] = (input - VH_HR_a)/(VH_HR_b - VH_HR_a);

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = HIGH;
                fuzzyVariable[1] = VERY_HIGH;
            }
            else
            {
                outFuzzy[0] = 0;
                outFuzzy[1] = 1;

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = NO_VARIABLE;
                fuzzyVariable[1] = VERY_HIGH;
            }

            break;

        case QTc:
            if(input <= N_QT_b)
            {
                outFuzzy[0] = 1;
                outFuzzy[1] = 0;

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = NORMAL;
                fuzzyVariable[1] = NO_VARIABLE;
            }
            else if((input > N_QT_b) && (input <= N_QT_c))
            {
                outFuzzy[0] = (N_QT_c - input)/(N_QT_c - N_QT_b);
                outFuzzy[1] = (input - AN_QT_a)/(AN_QT_b - AN_QT_a);

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = NORMAL;
                fuzzyVariable[1] = ABOVE_NORMAL;
            }
            else if((input > AN_QT_b) && (input <= AN_QT_c))
            {
                outFuzzy[0] = (AN_QT_c - input)/(AN_QT_c - AN_QT_b);
                outFuzzy[1] = (input - H_QT_a)/(H_QT_b - H_QT_a);

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = ABOVE_NORMAL;
                fuzzyVariable[1] = HIGH;
            }
            else if((input > H_QT_b) && (input <= H_QT_c))
            {
                outFuzzy[0] = (H_QT_c - input)/(H_QT_c - H_QT_b);
                outFuzzy[1] = (input - VH_QT_a)/(VH_QT_b - VH_QT_a);

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = HIGH;
                fuzzyVariable[1] = VERY_HIGH;
            }
            else
            {
                outFuzzy[0] = 0;
                outFuzzy[1] = 1;

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = NO_VARIABLE;
                fuzzyVariable[1] = VERY_HIGH;
            }

            break;

        case SKIN_IMPEDANCE:
            if(input <= VL_SI_b)
            {
                outFuzzy[0] = 1;
                outFuzzy[1] = 0;

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = VERY_LOW;
                fuzzyVariable[1] = NO_VARIABLE;
            }
            else if((input > VL_SI_b) && (input <= VL_SI_c))
            {
                outFuzzy[0] = (VL_SI_c - input)/(VL_SI_c - VL_SI_b);
                outFuzzy[1] = (input - L_SI_a)/(L_SI_b - L_SI_a);

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = VERY_LOW;
                fuzzyVariable[1] = LOW;
            }
            else if((input > L_SI_b) && (input <= L_SI_c))
            {
                outFuzzy[0] = (L_SI_c - input)/(L_SI_c - L_SI_b);
                outFuzzy[1] = (input - BN_SI_a)/(BN_SI_b - BN_SI_a);

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = LOW;
                fuzzyVariable[1] = BELOW_NORMAL;
            }
            else if((input > BN_SI_b) && (input <= BN_SI_c))
            {
                outFuzzy[0] = (BN_SI_c - input)/(BN_SI_c - BN_SI_b);
                outFuzzy[1] = (input - N_SI_a)/(N_SI_b - N_SI_a);

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = BELOW_NORMAL;
                fuzzyVariable[1] = NORMAL;
            }
            else
            {
                outFuzzy[0] = 0;
                outFuzzy[1] = 1;

                //allocate the fuzzy linguistic variable
                fuzzyVariable[0] = NO_VARIABLE;
                fuzzyVariable[1] = NORMAL;
            }

            break;
    }
}

/***************************************************************************
    Function:       algorithmHndlr()
    Created:        04/04/12
    Parameters:     non
    Return:         OK if sucessful, otherwise ERROR
    Purpose:        The algorithm procerss handler function
    Note:           A daemon process. Use shared memory allocation to process
                    data to and from each process.
***************************************************************************/
STATUS CAlgorithm::algorithmHndlr()
{
    WORD rowNum=0;

    FOREVER
    {
        //wait for semaphore to be available - by the acquisition process
        CProcessCont::LockSemaphore(CProcessCont::pProcInfo.semId.algorithm_semId,SEM_FULL);

        //just to make sure
        if(CAcqCont::acqInfo.sharedBuf[BANK42+FRAME_TIMEOUT] == TRUE)
        {
            rowNum = CAcqCont::acqInfo.sharedBuf[BANK42+FRAME_COUNT];

            //only do normalisation if requested by user
            if(CAcqCont::acqInfo.sharedBuf[BANK42+NORMALISED] == TRUE)
            {
                CAlgorithm::normalise(rowNum,rowNum+1,true);
                CAlgorithm::smooth(rowNum,rowNum+1,true);

                //check for 'burn-in'
                if(CAcqCont::acqInfo.sharedBuf[BANK42+BURNED_IN] == TRUE)
                {
                    detectHypoOne();
                    detectHypoTwo();
                }
            }

             //increment the frame, notifying completion of process
            CAcqCont::acqInfo.sharedBuf[BANK42+FRAME_COUNT]++;
        }

        //now unlock the sempahore - releasing its resource
        CProcessCont::UnlockSemaphore(CProcessCont::pProcInfo.semId.algorithm_semId,SEM_EMPTY);


    }

    return OK;
}

