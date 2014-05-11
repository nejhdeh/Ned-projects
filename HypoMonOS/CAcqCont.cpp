/***************************************************************************
    File:           CAcqCont.cpp
    Class:          CAcqCont
    Base Class:     CHypoMonOS
    Created:        Mon Apr 02 2012
    Author:         Nejhdeh Ghevondian
    Copyright:      (C) 2012 by AiMedics Pty. Ltd.
    Email:          nejhdeh@AiMedics.com

    Description:    The header file for the CAcqCont class for controlling the
                    acquisition within the HypoMonOS system.
 ***************************************************************************/
#include "CAcqCont.h"
#include "CCommsCont.h"
#include "CProcessCont.h"
#include "CTimeUtils.h"
#include "CAcqError.h"
#include "CUtilsError.h"
#include "CVectorStorage.h"

//static declerations
CAcqCont::ACQ_INFO CAcqCont::acqInfo;
WORD CAcqCont::ECG_HEADER[4] = {0xFFFF,0xFFFF,0x0000,0x0000};

/***************************************************************************
    Function:       CAcqCont()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        Provides the default constructor for CAcqCont
***************************************************************************/
CAcqCont::CAcqCont()
{

}
/***************************************************************************
    Function:       CAcqCont()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        Provides the default constructor for CAcqCont
***************************************************************************/
CAcqCont::CAcqCont(int semID, int shMemID)
{
    //initialise the ID
    acqInfo.detectQT = false;
    acqInfo.QTSearch = false;

}
/***************************************************************************
    Function:       ~CAcqCont()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        Provides the destructor for CAcqCont
***************************************************************************/
CAcqCont::~CAcqCont()
{
    //detach the IDs
 /*   CProcessCont::DeleteSharedMem(ecgAcqInfo.shMemId);
    CProcessCont::DeleteSharedMem(ecgAcqInfo.addShMemId);
    CProcessCont::DeleteSemaphore(ecgAcqInfo.semId);  */


}
/***************************************************************************
    Function:       Init()
    Created:        02/04/12
    Parameters:     non
    Return:         non - throw exception if error
    Purpose:        The initialisation function for the CAcqCont class.
    Note:           For clarification only, the shared buffer size of acq cont.
                    is same as that of the serial shared buffer
    Note:           polymorphised from base class
***************************************************************************/
void CAcqCont::Init()
{
    CProcessCont procCont;

    int localShMemId=0;     //for init. purposes

    try {
    //init semaphores & shared memory - for acq cont  x2 just in case
    if((acqInfo.sharedBuf = (short int*)procCont.InitSemaphore(&CProcessCont::pProcInfo.semId.acq_semId,
        &CProcessCont::pProcInfo.shMemId.acq_shMemId, 2*(NO_OF_BANKS*ADC_SAMPLE_SIZE))) == NULL)
        throw CAcqError("Acq",INIT_SEMAPHORE_ERROR, errno);

    //now create additional shared memory segments approx 3 x of NO_ADC_SAMPLES (could increase)
    if((localShMemId = shmget(IPC_PRIVATE,(4*ADDBUF_BANKSIZE),IPC_CREAT|SHM_R|SHM_W)) == ERROR)
        throw CAcqError("Acq",INIT_SEMAPHORE_ERROR, errno);

    //mapping to memory - identified by the shared memory ID
    if((acqInfo.addSharedBuf = static_cast<int*>(shmat(localShMemId,AUTO_ALLOCATE,NO_FLAG))) == (void*)ERROR)
        throw CAcqError("Acq",INIT_SHARE_MEM_ERROR, errno);

    //init further shared memory, particularly for the floating data such as temperatures, VBAT, On_Chest etc.
    if((acqInfo.tempVBatBuf = (double*)procCont.InitSemaphore(&CProcessCont::pProcInfo.semId.acq_semId,
        &CProcessCont::pProcInfo.shMemId.acq_shMemId, 7)) == NULL)
            throw CAcqError("Acq",INIT_SEMAPHORE_ERROR, errno);

    //init further shared memory, particularly for data id
    if((acqInfo.idData = (DWORD*)procCont.InitSemaphore(&CProcessCont::pProcInfo.semId.acq_semId,
        &CProcessCont::pProcInfo.shMemId.acq_shMemId, 1)) == NULL)
            throw CAcqError("Acq",INIT_SEMAPHORE_ERROR, errno);

    //init further shared memory, particularly for data id
    for (int i=0; i<NUM_HEADER_INFO; i++)
    if((acqInfo.headerInfo[i] = (char*)procCont.InitSemaphore(&CProcessCont::pProcInfo.semId.acq_semId,
        &CProcessCont::pProcInfo.shMemId.acq_shMemId, 20)) == NULL)
            throw CAcqError("Acq",INIT_SEMAPHORE_ERROR, errno);


    for (int i=0; i<NUM_VECTORS; i++)
    {
        //raw paramters shared memory allocation
        if((acqInfo.paramArray[i] = (double*)procCont.InitSemaphore(&CProcessCont::pProcInfo.semId.acq_semId,
        &CProcessCont::pProcInfo.shMemId.acq_shMemId, MAX_PARAM_SIZE)) == NULL)
            throw CAcqError("Acq",INIT_SEMAPHORE_ERROR, errno);

        //normalised parameters shared memory
        if((acqInfo.normParamArray[i] = (double*)procCont.InitSemaphore(&CProcessCont::pProcInfo.semId.acq_semId,
        &CProcessCont::pProcInfo.shMemId.acq_shMemId, 3)) == NULL)           //size should really be MAX_PARAM_SIZE
            throw CAcqError("Acq",INIT_SEMAPHORE_ERROR, errno);

        //smooth parameters shared memory
        if((acqInfo.smoothParamArray[i] = (double*)procCont.InitSemaphore(&CProcessCont::pProcInfo.semId.acq_semId,
        &CProcessCont::pProcInfo.shMemId.acq_shMemId, 3)) == NULL)          //size should really be MAX_PARAM_SIZE
            throw CAcqError("Acq",INIT_SEMAPHORE_ERROR, errno);
    }

    //output detection shared memory
    for (int i=0; i<= OUTPUT_VECTOR; i++)
        if((acqInfo.detectArray[i] = (WORD*)procCont.InitSemaphore(&CProcessCont::pProcInfo.semId.acq_semId,
        &CProcessCont::pProcInfo.shMemId.acq_shMemId, 3)) == NULL)          //size should really be MAX_PARAM_SIZE
            throw CAcqError("Acq",INIT_SEMAPHORE_ERROR, errno);

     //init signal handler for process termination
    if(initSignalHndlr() == ERROR)
        throw CAcqError("Acq",SIGNAL_ACTION_ERROR, errno);


    }catch (CExceptionHndlr& excpHndlr){

            excpHndlr.HandleError();
    }



    //initialise patient no. (could have also done it in AcqProcessHndlr())
    acqInfo.sharedBuf[BANK42+PATIENT_NO_ADDR] = DEFAULT_PATIENT_NO;
    acqInfo.sharedBuf[BANK42+PACKET_COUNT] = 0;
}
/***************************************************************************
    Function:       initSignalHndlr()
    Created:        02/04/12
    Parameters:     non
    Return:         non- throw exception if error
    Purpose:        To initialise the signal handlr functionality for
                    this class
***************************************************************************/
STATUS CAcqCont::initSignalHndlr()
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
            throw CAcqError("Acq", SIGNAL_ACTION_ERROR,errno);

        //initialise block
        if(sigemptyset(&blockset) == ERROR)
            throw CAcqError("Acq", SIGNAL_ACTION_ERROR,errno);

        //inform OS to block further SIGUSR1 while in handler
        if(sigaddset(&blockset, SIGUSR1|SIGTERM) == ERROR)
            throw CAcqError("Acq", SIGNAL_ACTION_ERROR,errno);

        }catch (CExceptionHndlr& excpHndlr){

            throw CAcqError("Acq", SIGNAL_ACTION_ERROR,errno);
            return ERROR;
        }
    return OK;
}
/***************************************************************************
    Function:       IdentifyData()
    Created:        02/04/12
    Parameters:     x - the current raw input data buffer
                    bufLen - the lenght of buffer in words
    Return:         non
    Purpose:        Function identifies the individual parameters
                    within the raw stream, including ECG skin impednace.
                    Stores results in particular bank in ADC bits
***************************************************************************/
void CAcqCont::IdentifyData(short int* x, const int bufLen)
{
    WORD data,ecgCount=0;
    for(int n=0; n<bufLen; n++)
    {
        *acqInfo.idData = x[n] & 0xF000;
        data = x[n] & 0x0FFF;

        switch(*acqInfo.idData)
        {
            case SKIN_Z_R_AC:
                acqInfo.sharedBuf[BANK42 + AC_SKIN_Z_R] = data;
                break;

            case SKIN_Z_0_AC:
                acqInfo.sharedBuf[BANK42 + AC_SKIN_Z_0] = data;
                break;

            case SKIN_Z_G0_AC:
                acqInfo.sharedBuf[BANK42 + AC_SKIN_Z_G0] = data;
                CalcACSkinImp(*acqInfo.idData);
                break;

            case ON_CHEST_VOLTAGE:
                acqInfo.sharedBuf[BANK42 + ON_CHEST_ADC] = data;
                CalcOnChest();
                break;

            case VBAT:
                acqInfo.sharedBuf[BANK42 + VBAT_ADC] = data;
                CalcVBat();
                break;

            case ECG:
                acqInfo.sharedBuf[ecgCount++ + BANK8] = data;
                break;

            case TEMPERATURE1:
                acqInfo.sharedBuf[BANK42 + TEMPERATURE1_ADC] = data;
                CalcTemperature(*acqInfo.idData);
                break;

            case TEMPERATURE2:
                acqInfo.sharedBuf[BANK42 + TEMPERATURE2_ADC] = data;
                CalcTemperature(*acqInfo.idData);
                break;

            case XMOTION:
                acqInfo.sharedBuf[BANK42+X_MOTION] = data;
                break;

            case YMOTION:
                acqInfo.sharedBuf[BANK42+Y_MOTION] = data;
                break;

            case ZMOTION:
                acqInfo.sharedBuf[BANK42+Z_MOTION] = data;
                break;

            case SKIN_RES_I1_TEST:
                acqInfo.sharedBuf[BANK42 + DC_I1] = data;
                break;

            case SKIN_RES_I1:
                acqInfo.sharedBuf[BANK42 + DC_SKIN_RES_I1] = data;
                CalcDCSkinImp(*acqInfo.idData);
                break;

            case TRANSMITTER_ID:
                acqInfo.sharedBuf[BANK42 + TRANSMITTER_ID_ADC] = data;

                break;
        }
    }
}
/***************************************************************************
    Function:       CalcLPF()
    Created:        02/04/12
    Parameters:     x - the current (unfiltered) input buffer
                    bufLen - the lenght of buffer in words
    Return:         non
    Purpose:        LPF function according to the following function:
                    y(n) = 2*y(n-1) - y(n-2) + x(n) - 2*x(n-6) + x(n-12)
                    fcutt=11Hz, gain=36
***************************************************************************/
void CAcqCont::CalcLPF(short int* x, const int bufLen)
{
    int lpfMem[ADC_SAMPLE_SIZE+LPF_TRAIL];
    static int localMem1, localMem2;

    //restore values from previous
    lpfMem[0] = localMem2;
    lpfMem[1] = localMem1;

    for(int n=LPF_TRAIL; n<bufLen+LPF_TRAIL; n++)
    {
        lpfMem[n] =  2*lpfMem[n-1] - lpfMem[n-2] + x[BANK24+n-LPF_TRAIL] - 2*x[BANK24+n-6-LPF_TRAIL] + x[BANK24+n-12-LPF_TRAIL];

        //now store in bank11- first reduce dynamic range (partial devide) to avoid casting
        x[BANK16 + n-LPF_TRAIL] = static_cast<short int>(lpfMem[n] >> LPF_GAIN);

    }

    //keep histoy by saving the last 2 values from stream
    localMem2 = lpfMem[bufLen + LPF_TRAIL-2];
    localMem1 = lpfMem[bufLen + LPF_TRAIL-1];
}

/***************************************************************************
    Function:       CalcHPF()
    Created:        02/04/12
    Parameters:     x - the current (unfiltered or filtered) input buffer
                    bufLen - the lenght of buffer in words
    Return:         non
    Purpose:        HPF function according to the following function:
                    y(n) = 32*x(n-16) - y(n-1) - x(n) + x(n-32)
                    fcutt=5Hz, gain=32
***************************************************************************/
void CAcqCont::CalcHPF(short int* x, const int bufLen)
{
    const int HPF_TRAIL1 = 3;
    long double y[ADC_SAMPLE_SIZE+HPF_TRAIL1];

    //static int localMem= 0;
    static long double localMem[] = {0.0,0.0,0.0,0.0};

    y[0] = localMem[0];
    y[1] = localMem[1];
    y[2] = localMem[2];

    const long double a2 = -2.9937168173;
    const long double a3 =  2.9874533582;
    const long double a4 = -0.9937365100;

    const long double b1 =  0.9968633357;
    const long double b2 = -2.9905900071;
    const long double b3 =  2.9905900071;
    const long double b4 = -0.9968633357;



    for(int n=HPF_TRAIL1; n<bufLen+HPF_TRAIL1; n++)
    {
        y[n] = b1*x[BANK8+n-HPF_TRAIL1] + b2*x[BANK8+n-HPF_TRAIL1-1] + b3*x[BANK8+n-HPF_TRAIL1-2] + b4*x[BANK8+n-HPF_TRAIL1-3]
               - (a2*y[n-1] + a3*y[n-2] + a4*y[n-3]);

        x[BANK24+n-HPF_TRAIL1] = static_cast<short int>(y[n]);
    }

    localMem[0] = y[bufLen + HPF_TRAIL1 - 3];
    localMem[1] = y[bufLen + HPF_TRAIL1 - 2];
    localMem[2] = y[bufLen + HPF_TRAIL1 - 1];
}
/***************************************************************************
    Function:       CalcDerv()
    Created:        02/04/12
    Parameters:     x - the current (either filtered or unfiltered) input buffer
                    bufLen - the lenght of buffer in words
    Return:         non
    Purpose:        Derivative function according to the following function:
                    1st derivative: y(n) = x(n+1) - x(n-1)
                    2nd derivative: y(n) = x(n+2) - 2*x(n) + x(n+2)
***************************************************************************/
void CAcqCont::CalcDerv(short int* x, const int bufLen)
{
    double firstDerv, secdDerv, derv;

    //now calculate the derivative output given the stream
    for(int n=DERV_HISTORY; n<bufLen + DERV_HISTORY; n++)
    {
        //calc first derivative
        firstDerv = x[BANK15+n + 1]  + 2*x[BANK15 +n +2] - 2*x[BANK15+n-2] - x[BANK15+n - 1];

        //calc second derivative
        secdDerv = x[BANK15 +n +2] - 2*x[BANK15+n] + x[BANK15+n-2];

        //index into total derivative
        derv = 1.3*firstDerv + 1.1*secdDerv;

        //also store into output - but dont take absolute value
        x[BANK40+ n-DERV_HISTORY] = static_cast<short int>(derv);

        //now combine
        x[BANK32+ n-DERV_HISTORY]  = static_cast<short int>(fabs(derv));
    }
}
/***************************************************************************
    Function:       CalcMovAvg()
    Created:        02/04/12
    Parameters:     x - the current (either filtered or unfiltered) input buffer
                    bufLen - the lenght of buffer in words
    Return:         non
    Purpose:        To provive a moving average window, with approx. width
                    of the QRS complex using
                    y(n) = 1/N[x(n-(N-1)) + x(n-(N-2) + ... + x(n)]
***************************************************************************/
void CAcqCont::CalcMovAvg(short int* x, const int bufLen)
{
    CUtils utils;
    DWORD windowSum=0;

    for(int n=0; n<bufLen; n++)
    {
        //obtain the sum per window
        windowSum =  static_cast<DWORD>(utils.Sum<DWORD>(x+BANK31 +n,ADC_SAMPLE_SIZE)/ADC_SAMPLE_SIZE);
        x[BANK55+n] = static_cast<short int>(windowSum);
    }
}
/***************************************************************************
    Function:       CalcHanning()
    Created:        02/04/12
    Parameters:     x - the current (either filtered or unfiltered) input buffer
                    bufLen - the lenght of buffer in words
    Return:         non
    Purpose:        To provive a hanning window, with approx
                    y(n) = 1/4[x(n) + 2*x(n-1) + x(n-2)]
***************************************************************************/
void CAcqCont::CalcHanning(short int* x, const int bufLen)
{
    for(int n=0; n<bufLen; n++)
        x[BANK12+n] =  (x[BANK17 + n] + 2*x[BANK17+n-1] + x[BANK17+n-2]) >> 2;
}
/***************************************************************************
    Function:       DetectQRS()
    Created:        02/04/12
    Parameters:     x - the current (either filtered or unfiltered) input buffer
                    bufLen - the lenght of buffer in words
    Return:         TRUE if detected, otherwise FALSE
    Purpose:        To detect QRS complex based on the following:
                    Primary threshold   = PRIM_THRESH * max(x)
                    Secondary threshold = SECD_THRESH * max(x)

                    if x(i) > Primary threshold AND x(i),..x(i+6) > Secondary threshold
                    then QRS detected
***************************************************************************/
bool CAcqCont::DetectQRS(short int* x, const int bufLen)
{
    WORD localPeak=0;
    static double noisePeak=0,primThresh=0, RR=0;
    bool detectGoodRR = false;
    static WORD wndOffset=0, currentHR=0, currentRR=0, numQRSMissed=0;

    //calculate the local maximum for this current session stream
    localPeak = CUtils::Max<short int>(x+BANK32+wndOffset, (const int)bufLen);

    acqInfo.sharedBuf[BANK42+QRS_DET_SAMPLE_NO] += wndOffset;

    //now test condition for signal peak
    for(int n=wndOffset; n<bufLen; n++, acqInfo.sharedBuf[BANK42+QRS_DET_SAMPLE_NO]++)
        if((x[n+BANK32] >= primThresh))
        {
            //calc the RR interval
            RR = CalcR_R((acqInfo.sharedBuf[BANK42+QRS_DET_SAMPLE_NO]*ADC_SAMPLING_RATE),&detectGoodRR);

            if(detectGoodRR)
            {
                //update to a new ecg peak
                acqInfo.ecgPeak = 0.125*localPeak + 0.875*acqInfo.ecgPeak;

                primThresh = noisePeak + 0.25*(acqInfo.ecgPeak-noisePeak);

                //the remainder in the frame to add for next time
                acqInfo.sharedBuf[BANK42+QRS_DET_SAMPLE_NO] = ADC_SAMPLE_SIZE-1 - n;

                //store location of find & init. for QT
                acqInfo.detectedQRSPos = n + wndOffset;
                acqInfo.sharedBuf[BANK42+QT_DET_SAMPLE_NO] = QT_MIN_WIDTH;

                //since detected add minimum for next time
                wndOffset = QRS_MIN_OFFSET;

                currentHR = (short int)(rint(HEARTRATE_NOMINAL/RR));
                currentRR = (short int)(rint(RR*1000));

                //perform another level if checking prior to storing value
                if((acqInfo.sharedBuf[BANK42+FRAME_COUNT] > 0) && (acqInfo.sharedBuf[BANK42+FRAME_SAMPLES] > 1))
                {
                    if((currentHR >= 0.75*acqInfo.sharedBuf[BANK42+AVG_HR_ADDR])&&(currentHR <= 1.25*acqInfo.sharedBuf[BANK42+AVG_HR_ADDR]))
                    {
                        acqInfo.sharedBuf[BANK45 + acqInfo.sharedBuf[BANK42+QRS_COUNT]] = currentHR;
                        acqInfo.sharedBuf[BANK42+QRS_COUNT]++;
                    }
                }

                //update the HR value
                acqInfo.sharedBuf[BANK42+AVG_HR_ADDR] =  currentHR;

                //Also store the correct RR interval for QT calcs in msecs
                acqInfo.sharedBuf[BANK42+AVG_RR_ADDR] = currentRR;

                numQRSMissed = 0;
                return true;
            }

        }

    //did not find ECG, hence update the noise level & threshold
    noisePeak = 0.125*localPeak + 0.875*noisePeak;

    //must also update the threshhold level
    numQRSMissed++;
    if(numQRSMissed < NUM_MISSED_QRS_LIMIT)
        primThresh = noisePeak + 0.15*(acqInfo.ecgPeak-noisePeak);
    else
        primThresh = 0.5*noisePeak;

    //don't add any offsets
    wndOffset = 0;

    return false;


}
/***************************************************************************
    Function:       CalcR_R()
    Created:        02/04/12
    Parameters:     currentRR - The current RR interval
                    detectGoodRR - to indicate whether correct RR detected
    Return:         the average RR interval
    Purpose:        To obtain the RR interval between each QRS complex
***************************************************************************/
double CAcqCont::CalcR_R(const double currentRR, bool* detectGoodRR)
{
    static double avgRR = 0, prevAvg=0;
    static double selAvgRR=0;
    static double RR_history[RR_HISTORY] = {RR_NOMINAL,RR_NOMINAL,RR_NOMINAL,RR_NOMINAL,RR_NOMINAL};
    static double selRR_history[RR_HISTORY] = {RR_NOMINAL,RR_NOMINAL,RR_NOMINAL,RR_NOMINAL,RR_NOMINAL};

    CUtils* pCUtils = new CUtils;

    //check for valid RR interval - if within range update stream else dont.
    if((currentRR >= RR_MAX_LLIMIT) && (currentRR <= RR_MAX_ULIMIT))
    {
        if((currentRR >= RR_LLIMIT_INDEX*avgRR) && (currentRR <= RR_ULIMIT_INDEX*avgRR))
        {

            //push stream down by one
            pCUtils->MemMove(selRR_history,RR_HISTORY);

            //store the selected RR into tail of stream
            selRR_history[RR_HISTORY-SINGLE_BYTE] = currentRR;

            //calculate average RR interval
            selAvgRR = pCUtils->Sum<double>(selRR_history,RR_HISTORY)/RR_HISTORY;

            if((currentRR >= GOOD_RR_LLIMIT_INDEX*prevAvg) && (currentRR <= GOOD_RR_ULIMIT_INDEX*prevAvg))
                *detectGoodRR = true;
            else
                *detectGoodRR = false;
        }

        //either way update the average
        pCUtils->MemMove(RR_history,RR_HISTORY);

        //store history of RR - irrespective of value
        RR_history[RR_HISTORY-SINGLE_BYTE] = currentRR;

        //calculate average RR interval
        avgRR = pCUtils->Sum<double>(RR_history,RR_HISTORY)/RR_HISTORY;
    }

    prevAvg = selAvgRR;

    delete pCUtils;

    return currentRR;
}
/***************************************************************************
    Function:       CalcQT()
    Created:        02/04/12
    Parameters:     x - the current derivative data
                    bufLen - the lenght of buffer in words
    Return:         TRUE if detected, otherwise FALSE
    Purpose:        To obtain the QT interval between each QRS complex and T wave
    Note:           The T wave end routine is used
***************************************************************************/
bool CAcqCont::CalcQT(short int* x, const int bufLen)
{
    int localPeak, wndCount=0, QTc=0, dT_dtMin=0, dT_dtCount=0, secDerv=0;
    double currentQT=0;
    static double TwavePeak=0, TwaveThresh=0, localQTc=0;
    static BYTE offsetCount=0;
    short int dT_dt[50];


    //calculate the T wave peak minimum (since negative slope) for this current session stream
    localPeak = CUtils::Min<short int>(x, (const int)bufLen);

    //ensure that the find is negative & correct size of peak
    if((localPeak < 0) && (fabs(localPeak) < 0.5*acqInfo.ecgPeak))
    {
        //now test condition for signal peak - make sure on proper profile
        for(int n=0; n<bufLen-1; n++, acqInfo.sharedBuf[BANK42+QT_DET_SAMPLE_NO]++)
            if((x[n] < TwaveThresh) && (x[n] < x[n+1]))
            {
                while((x[n+wndCount] <= 0) && (x[n+wndCount] < x[n+wndCount+TTAIL_MIN_OFFSET]))
                {
                    dT_dt[wndCount] =  x[n+wndCount];
                    wndCount++;
                }

                //now analyse the tail of the Twave (differential)
                //find the greates change occurring within the tail end of the Twave
                for(int i=TTAIL_MIN_OFFSET; i<wndCount-TTAIL_MIN_OFFSET; i++)
                {
                    secDerv = dT_dt[i] - dT_dt[i+TTAIL_MIN_OFFSET];

                    //observe the 2nd drivative (step change)
                    if(secDerv <= dT_dtMin)
                    {
                        dT_dtMin = secDerv;
                        dT_dtCount++;
                    }
                }

                //update count
                dT_dtCount += TTAIL_MIN_OFFSET;

                //calc how many samples
                //note: must saubtract QT_COMP_FACTOR since the end of T wave preceeeds the derv.
                currentQT = (acqInfo.sharedBuf[BANK42+QT_DET_SAMPLE_NO] + dT_dtCount + offsetCount + QT_COMP_FACTOR) * ADC_SAMPLING_RATE;


                //calc the corrected QTc interval
                localQTc = sqrt(acqInfo.sharedBuf[BANK42+AVG_RR_ADDR]);
                localQTc = (currentQT/localQTc) * 31622.78;

                 //check for valid range
                if(checkQTc(localQTc))
                {
                    //store the peak & update thresholds
                    TwavePeak = 0.125*localPeak + 0.875*TwavePeak;
                    TwaveThresh = 0.15*TwavePeak;

                    //inform system QT found & no need for new search until new QRS
                    acqInfo.sharedBuf[BANK42+QT_SEARCH] = FALSE;

                    QTc = static_cast<short int>(rint(localQTc));

                    //perform another level if checking prior to storing value
                    if((acqInfo.sharedBuf[BANK42+FRAME_COUNT] > 0) && (acqInfo.sharedBuf[BANK42+FRAME_SAMPLES] > 2))
                    {
                        if((QTc >= 0.75*acqInfo.sharedBuf[BANK42+AVG_QT_ADDR])&&(QTc <= 1.25*acqInfo.sharedBuf[BANK42+AVG_QT_ADDR]))
                        {
                            //store in buffer to average at end of frames
                            acqInfo.sharedBuf[BANK46 + acqInfo.sharedBuf[BANK42+QT_COUNT]] = QTc;
                            acqInfo.sharedBuf[BANK42+QT_COUNT]++;
                        }
                    }

                    //store value in global & in buffer
                    acqInfo.sharedBuf[BANK42+AVG_QT_ADDR] = QTc;

                    offsetCount = 0;

                    return true;
                }

            }
    }
    else
        //add further offset for next time
        offsetCount = bufLen;

    //and maybe required to do new search
    acqInfo.sharedBuf[BANK42+QT_SEARCH] = TRUE;

    return false;
}

/***************************************************************************
    Function:       checkQTc()
    Created:        02/04/12
    Parameters:     currentQTc - The current measured QTc interval
    Return:         indicate whether correct QTc is detected
    Purpose:        To check the range of the QTc interval (in msecs.)
***************************************************************************/
bool CAcqCont::checkQTc(const double currentQTc)
{
    static double avgQTc = 0, prevAvgQTc=0;
    static double QT_history[QT_HISTORY] = {QT_NOMINAL,QT_NOMINAL,QT_NOMINAL,QT_NOMINAL,QT_NOMINAL};
    bool QTcStatus = false;

    CUtils* pCUtils = new CUtils;

    //first check for valid QTc interval - if within range update stream else dont.
    if((currentQTc >= QT_LLIMIT) && (currentQTc <= QT_ULIMIT))
    {
        //update the average
        pCUtils->MemMove(QT_history,QT_HISTORY);

        //store history of QT - irrespective of value
        QT_history[QT_HISTORY-SINGLE_BYTE] = currentQTc;

        //calculate average QTc interval
        avgQTc = pCUtils->Sum<double>(QT_history,QT_HISTORY)/QT_HISTORY;

        //now perform stringent test
        if((currentQTc >= QT_LLIMIT_INDEX*prevAvgQTc) && (currentQTc <= QT_ULIMIT_INDEX*prevAvgQTc))
            QTcStatus = true;
    }

    //update for next time
    prevAvgQTc = avgQTc;

    if(pCUtils)
        delete pCUtils;

    return QTcStatus;
}

/***************************************************************************
    Function:       CalcTemperature()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        To calculate the temperature from the thermostor values
    Note:           See lab book for formulas
***************************************************************************/
void CAcqCont::CalcTemperature(const DWORD channel)
{
    double Vad=0, varLog = 0;

    if(channel == TEMPERATURE1)         //calc temperature 1
    {
        if((acqInfo.sharedBuf[BANK42 + TEMPERATURE1_ADC] > 500) && (acqInfo.sharedBuf[BANK42 + TEMPERATURE1_ADC] < 1500))
        {
            Vad = static_cast<double>(acqInfo.sharedBuf[BANK42 + TEMPERATURE1_ADC] * ADC_TO_VOLTAGE);

            varLog = log(1300 * (3/Vad - 1));

            acqInfo.tempVBatBuf[TEMP1_VALUE] = (1 / (A_STEIN + B_STEIN*varLog + C_STEIN*pow(varLog,3))) - KELVIN - TEMP1_CORRECT;

            //register a detect
            acqInfo.sharedBuf[BANK42 + TEMP1_DETECT] = TRUE;

            //range check
            if(acqInfo.tempVBatBuf[TEMP1_VALUE] > TEMP_UPPER_LIMIT)
            {
                acqInfo.tempVBatBuf[TEMP1_VALUE] = TEMP_UPPER_LIMIT;
                acqInfo.sharedBuf[BANK42 + TEMP1_DETECT] = 0;
            }

            if(acqInfo.tempVBatBuf[TEMP1_VALUE] < TEMP_LOWER_LIMIT)
            {
                acqInfo.tempVBatBuf[TEMP1_VALUE] = TEMP_LOWER_LIMIT;
                acqInfo.sharedBuf[BANK42 + TEMP1_DETECT] = 0;
            }
        }
        else
        {
            acqInfo.sharedBuf[BANK42 + TEMP1_DETECT] = 0;

            //and provide an arbitary value
            acqInfo.tempVBatBuf[TEMP1_VALUE] = (double)TEMP_ERROR_VALUE;
        }
    }

    else if(channel == TEMPERATURE2)   //calc temperature 2
    {
        if((acqInfo.sharedBuf[BANK42 + TEMPERATURE2_ADC] > 500) && (acqInfo.sharedBuf[BANK42 + TEMPERATURE2_ADC] < 1500))
        {

            Vad = static_cast<double>(acqInfo.sharedBuf[BANK42 + TEMPERATURE2_ADC] * ADC_TO_VOLTAGE);

            varLog = log(1300 * (3/Vad - 1));

            acqInfo.tempVBatBuf[TEMP2_VALUE] = (1 / (A_STEIN + B_STEIN*varLog + C_STEIN*pow(varLog,3))) - KELVIN - TEMP2_CORRECT;

            acqInfo.sharedBuf[BANK42 + TEMP2_DETECT] = TRUE;

            //range check
            if(acqInfo.tempVBatBuf[TEMP2_VALUE] > TEMP_UPPER_LIMIT)
            {
                acqInfo.tempVBatBuf[TEMP2_VALUE] = TEMP_UPPER_LIMIT;
                acqInfo.sharedBuf[BANK42 + TEMP2_DETECT] = 0;
            }

            if(acqInfo.tempVBatBuf[TEMP2_VALUE] < TEMP_LOWER_LIMIT)
            {
                acqInfo.tempVBatBuf[TEMP2_VALUE] = TEMP_LOWER_LIMIT;
                acqInfo.sharedBuf[BANK42 + TEMP2_DETECT] = 0;
            }

        }
        else
        {
            acqInfo.sharedBuf[BANK42 + TEMP2_DETECT] = 0;
            //and provide an arbitary value
            acqInfo.tempVBatBuf[TEMP2_VALUE] = (double)TEMP_ERROR_VALUE;
        }
    }

}

/***************************************************************************
    Function:       CalcDCSkinImp()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        To calculate the DC skin resistance
    Note:           See lab book for formulas
***************************************************************************/
void CAcqCont::CalcDCSkinImp(const DWORD channel)
{
    //calc DC resistance using current#1 & current#2
    /***********************************************/
    if(channel == SKIN_RES_I1)
    {
        if(acqInfo.sharedBuf[BANK42 + DC_I1] > 0)
        {
            acqInfo.addSharedBuf[BANK1_ADDBUF] =  static_cast<DWORD>((acqInfo.sharedBuf[BANK42 + DC_SKIN_RES_I1]*TEST_RES_DC)
                                                                        /acqInfo.sharedBuf[BANK42 + DC_I1]);
            //keep track of skin imp. count
            acqInfo.sharedBuf[BANK42 + SI_DC_DETECT] = TRUE;
        }
        else
            acqInfo.sharedBuf[BANK42 + SI_DC_DETECT] = 0;
    }

/*    else if(channel == SKIN_RES_I2)
        if(acqInfo.sharedBuf[BANK42 + DC_I2] > 0)
            acqInfo.addSharedBuf[BANK2_ADDBUF] =  static_cast<DWORD>((acqInfo.sharedBuf[BANK42 + DC_SKIN_RES_I2]*TEST_RES_DC)
                                                                        /acqInfo.sharedBuf[BANK42 + DC_I2]);  */
}
/***************************************************************************
    Function:       CalcACSkinImp()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        To calculate the AC skin resistance
    Note:           See lab book for formulas
***************************************************************************/
void CAcqCont::CalcACSkinImp(const DWORD channel)
{
     //AC Resistance measurements
    /***************************/

    if(channel == SKIN_Z_G0_AC)
    {
        if(acqInfo.sharedBuf[BANK42 + AC_SKIN_Z_R] > 0)
        {
            acqInfo.addSharedBuf[BANK3_ADDBUF] = static_cast<DWORD>((acqInfo.sharedBuf[BANK42 + AC_SKIN_Z_G0]*TEST_RES_AC)
                                                                            /acqInfo.sharedBuf[BANK42 + AC_SKIN_Z_R]);
            //keep track of skin imp. count
            acqInfo.sharedBuf[BANK42 + SI_AC_DETECT] = TRUE;
        }
        else
            acqInfo.sharedBuf[BANK42 + SI_AC_DETECT] = 0;
    }

/*    else if(channel == SKIN_Z_G6_AC)
        if(acqInfo.sharedBuf[BANK42 + AC_SKIN_Z_R] > 0)
            acqInfo.addSharedBuf[BANK4_ADDBUF] = static_cast<DWORD>((acqInfo.sharedBuf[BANK42 + AC_SKIN_Z_G6]*TEST_RES_AC)
                                                                            /acqInfo.sharedBuf[BANK42 + AC_SKIN_Z_R]);  */


}
/***************************************************************************
    Function:       CalcVBat()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        To calculate the battery voltage
    Note:           See lab book for formulas
***************************************************************************/
void CAcqCont::CalcVBat()
{
    acqInfo.tempVBatBuf[VBAT_VALUE] = static_cast<double>(acqInfo.sharedBuf[BANK42+VBAT_ADC] * ADC_TO_VOLTAGE);

}

/***************************************************************************
    Function:       CalcOnChest()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        To calculate the on chest voltage
    Note:           See lab book for formulas
***************************************************************************/
void CAcqCont::CalcOnChest()
{
    acqInfo.tempVBatBuf[ON_CHEST_VALUE] = static_cast<double>(acqInfo.sharedBuf[BANK42+ON_CHEST_ADC] * ADC_TO_VOLTAGE);

}
/***************************************************************************
    Function:       signalHndlr()
    Created:        02/04/12
    Parameters:     non
    Return:         OK if sucessful, otherwise ERROR
    Purpose:        The CAcqCont class signal handler function
                    Used to terimnate the current CCommsCont process
***************************************************************************/
void CAcqCont::signalHndlr(const int sigNum, siginfo_t* info, void* extra)
{
    if(sigNum == SIGTERM)
    {

        //now kill myself
        kill(getpid(),SIGKILL);
    }
}

/***************************************************************************
    Function:       UpdateParameters()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        Updates the parameter values and puts them in vector form
                    for further analysis, algorithms and file writes.
***************************************************************************/

void CAcqCont::UpdateParameters()
{
    static WORD localHR=0, localQT = 0;
    WORD QRSSamples=0, QTSamples=0, rowNum=0, n=0;
    double sampleAvg = 0;

    CUtils* pUtils = new CUtils;

    //inform the end of frame flags
    acqInfo.sharedBuf[BANK42+FRAME_TIMEOUT] = TRUE;

    //re-zero packet size & update the frame count
    acqInfo.sharedBuf[BANK42+QRS_DET_SAMPLE_NO] = 0;
    acqInfo.sharedBuf[BANK42+TRUE_AVG_HR_ADDR] = 0;
    acqInfo.sharedBuf[BANK42+TRUE_AVG_HR_FILT_ADDR] = 0;
    acqInfo.sharedBuf[BANK42+TRUE_AVG_QT_ADDR] = 0;
    acqInfo.sharedBuf[BANK42+TRUE_AVG_QT_FILT_ADDR] = 0;
    acqInfo.addSharedBuf[BANK2+TRUE_AVG_SI_ADDR] = 0;


    //check for detection of QRS and other parameter during this frame
    if(acqInfo.sharedBuf[BANK42+FRAME_SAMPLES] >= 1)
    {
        //assign current frame sample count
        QRSSamples = acqInfo.sharedBuf[BANK42+QRS_COUNT];
        QTSamples = acqInfo.sharedBuf[BANK42+QT_COUNT];

        //calc paramter averages & rate of change
        //must examine outliers within the frame
        //HR
        if(QRSSamples > 0)
        {
            //first obtain average, irrespective of what measured
            sampleAvg = pUtils->Sum<WORD>(acqInfo.sharedBuf+BANK45,QRSSamples)/QRSSamples;

            //process thru the loop examining large deviations from average
            for(int i=0; i<QRSSamples; i++)
            {
                if(fabs((acqInfo.sharedBuf[BANK45 + i] - sampleAvg)/sampleAvg) <= SAMPLE_OUTLIER_INDEX)
                {
                    acqInfo.sharedBuf[BANK56 + n] = CAcqCont::acqInfo.sharedBuf[BANK45 + i];
                    n++;
                }
            }
            //ensure at least one sample processed, probably redundant
            if(n < 1)
                for(int i=0; i<QRSSamples; i++)
                    acqInfo.sharedBuf[BANK56+i] = acqInfo.sharedBuf[BANK45+i];

            //now process the filtered heart rate samples array
            /**************************************************/
            acqInfo.sharedBuf[BANK42+TRUE_AVG_HR_FILT_ADDR] = (WORD)rint(pUtils->Sum<WORD>(acqInfo.sharedBuf+BANK56,n)/n);
            acqInfo.sharedBuf[BANK42+QRS_COUNT_FILTERED] = n;

            //prepare to write to file
            acqInfo.sharedBuf[BANK42+TRUE_AVG_HR_ADDR] = (WORD)rint(pUtils->Sum<WORD>(acqInfo.sharedBuf+BANK45,QRSSamples)/QRSSamples);
            localHR = acqInfo.sharedBuf[BANK42+TRUE_AVG_HR_ADDR];

            //and register a true detect
            acqInfo.sharedBuf[BANK42 + HR_DETECT] = TRUE;
        }


        n=0;

        //QT
        if(QTSamples > 0)
        {

            //first obtain average, irrespective of what measured
            sampleAvg = pUtils->Sum<WORD>(acqInfo.sharedBuf+BANK46,QTSamples)/QTSamples;

            //process thru the loop examining large deviations from average
            for(int i=0; i<QTSamples; i++)
            {
               if(fabs((acqInfo.sharedBuf[BANK46 + i] - sampleAvg)/sampleAvg) <= SAMPLE_OUTLIER_INDEX)
               {
                    acqInfo.sharedBuf[BANK57 + n] = acqInfo.sharedBuf[BANK46 + i];
                    n++;
               }
            }
            //ensure at least one sample processed, probably redundant
            if(n <1)
            for(int i=0; i<QTSamples; i++)
                    acqInfo.sharedBuf[BANK57+i] = acqInfo.sharedBuf[BANK46+i];

            //now process the filtered QT samples array
            /**************************************************/
            acqInfo.sharedBuf[BANK42+TRUE_AVG_QT_FILT_ADDR] = (WORD)rint(pUtils->Sum<WORD>(acqInfo.sharedBuf+BANK57,n)/n);
            acqInfo.sharedBuf[BANK42+QT_COUNT_FILTERED] = n;

            //prepare to write to file
            acqInfo.sharedBuf[BANK42+TRUE_AVG_QT_ADDR] = (WORD)rint(pUtils->Sum<WORD>(acqInfo.sharedBuf+BANK46,QTSamples)/QTSamples);
            localQT = acqInfo.sharedBuf[BANK42+TRUE_AVG_QT_ADDR];

            //and register a true detect
            acqInfo.sharedBuf[BANK42 + QT_DETECT] = TRUE;
        }
    }

    //now perform range check to see any parameters fall outside bounderies
    rowNum = acqInfo.sharedBuf[BANK42+FRAME_COUNT];
    acqInfo.paramArray[FRAME_VECTOR][rowNum] = rowNum;

    //first update the raw parameter arrays for writing, algorithms etc
    acqInfo.paramArray[HR_VECTOR][rowNum] = acqInfo.sharedBuf[BANK42+TRUE_AVG_HR_FILT_ADDR];
    acqInfo.paramArray[QT_VECTOR][rowNum] = acqInfo.sharedBuf[BANK42+TRUE_AVG_QT_FILT_ADDR];
    acqInfo.paramArray[AC_SI_VECTOR][rowNum] = acqInfo.addSharedBuf[BANK3_ADDBUF];
    acqInfo.paramArray[DC_SI_VECTOR][rowNum] = acqInfo.addSharedBuf[BANK1_ADDBUF];
    acqInfo.paramArray[X_MOTION_VECTOR][rowNum] = acqInfo.sharedBuf[BANK42 + X_MOTION];
    acqInfo.paramArray[Y_MOTION_VECTOR][rowNum] = acqInfo.sharedBuf[BANK42 + Y_MOTION];
    acqInfo.paramArray[Z_MOTION_VECTOR][rowNum] = acqInfo.sharedBuf[BANK42 + Z_MOTION];
    acqInfo.paramArray[TEMP1_VECTOR][rowNum] = acqInfo.tempVBatBuf[TEMP1_VALUE];
    acqInfo.paramArray[TEMP2_VECTOR][rowNum] = acqInfo.tempVBatBuf[TEMP2_VALUE];

    if(rowNum >=1)
    {
        //if frame 1 then also replace frame 0 with the value
        if(rowNum == 1)
        {
            //check for values in heart rate
            if(acqInfo.paramArray[HR_VECTOR][rowNum] == 0)
                acqInfo.paramArray[HR_VECTOR][rowNum] = HEARTRATE_NOMINAL;

            acqInfo.paramArray[HR_VECTOR][rowNum - 1] = acqInfo.paramArray[HR_VECTOR][rowNum];

            //check for values in QTc
            if(acqInfo.paramArray[QT_VECTOR][rowNum] == 0)
                acqInfo.paramArray[QT_VECTOR][rowNum] = QT_NOMINAL;

            acqInfo.paramArray[QT_VECTOR][rowNum - 1] = acqInfo.paramArray[QT_VECTOR][rowNum];
        }
        else
        {
            //any other time is 0 then replace with revious value
            if(acqInfo.paramArray[HR_VECTOR][rowNum] == 0)
            {
                acqInfo.paramArray[HR_VECTOR][rowNum] = acqInfo.paramArray[HR_VECTOR][rowNum - 1];
                //and register a false detect
                acqInfo.sharedBuf[BANK42 + HR_DETECT] = 0;
            }

            if(acqInfo.paramArray[QT_VECTOR][rowNum] == 0)
            {
                acqInfo.paramArray[QT_VECTOR][rowNum] = acqInfo.paramArray[QT_VECTOR][rowNum - 1];
                //and register a flase detect
                acqInfo.sharedBuf[BANK42 + QT_DETECT] = 0;
            }

        }
    }

    //incase memory leak
    delete pUtils;
}

/***************************************************************************
    Function:       SendParameters()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        Send the calculated parameters to the HypomonView

    Note:           It has an option to send via the serial or the
                    TCP/IP port
***************************************************************************/
void CAcqCont::SendParameters()
{
    WORD rowNum=0;
    DWORD param[12];

    try
    {
        //re-initialise the comm port
        CCommsCont::CloseCommPort(COM1);
        CCommsCont::OpenCommPort(COM1,"r+b");

        //obtain the current frame number
        rowNum = acqInfo.sharedBuf[BANK42+FRAME_COUNT];

        //incorporate the header ID with each parameter
        param[0] = (DWORD)acqInfo.sharedBuf[BANK42+FRAME_COUNT] | FRAME_ID;
        param[1] = (DWORD)acqInfo.paramArray[HR_VECTOR][rowNum] | HEART_RATE_ID;
        param[2] = (DWORD)acqInfo.paramArray[QT_VECTOR][rowNum] | QT_ID;

        param[3] = (DWORD)acqInfo.paramArray[AC_SI_VECTOR][rowNum] | SKIN_AC_ID;
        param[4] = (DWORD)acqInfo.paramArray[DC_SI_VECTOR][rowNum] | SKIN_DC_ID;
        param[5] = (DWORD)(acqInfo.paramArray[TEMP1_VECTOR][rowNum]*100) | TEMP1_ID;
        param[6] = (DWORD)(acqInfo.paramArray[TEMP2_VECTOR][rowNum]*100) | TEMP2_ID;
        param[7] = (DWORD)acqInfo.paramArray[X_MOTION_VECTOR][rowNum] | XMOTION_ID;
        param[8] = (DWORD)acqInfo.paramArray[Y_MOTION_VECTOR][rowNum] | YMOTION_ID;
        param[9] = (DWORD)acqInfo.paramArray[Z_MOTION_VECTOR][rowNum] | ZMOTION_ID;


        //load into the comms buffer
        CUtils::DwordToByte((DWORD*)param, CCommsCont::pCommPort[COM1].buffer, 10);

        //ensure open port stream & send
        if(CCommsCont::pCommPort[COM1].fd != INVALID_FD)
            write(CCommsCont::pCommPort[COM1].fd, CCommsCont::pCommPort[COM1].buffer, 40);

    }catch (CExceptionHndlr& excpHndlr){

        throw CAcqError("Acq", ACQ_SEND_PARAM_ERROR,errno);

    }
}

/***************************************************************************
    Function:       AcqProcessHndlr()
    Created:        02/04/12
    Parameters:     non
    Return:         OK if sucessful, otherwise ERROR
    Purpose:        The ECG filter acquisition procerss handler function
    Note:           A daemon process. Use shared memory allocation to process
                    data to and from each process.
***************************************************************************/
STATUS CAcqCont::AcqProcessHndlr()
{
    static WORD QTwindowOffset=QT_MIN_WIDTH, numQTSearch=1;
    CUtils* pUtils = new CTimeUtils;

    acqInfo.sharedBuf[BANK42+FRAME_TIMEOUT]  = TRUE;
    acqInfo.sharedBuf[BANK42+FRAME_COUNTDOWN] = FRAME_TIMEOUT_PERIOD;
    acqInfo.sharedBuf[BANK42+QRS_DET_SAMPLE_NO] = 0;
    acqInfo.sharedBuf[BANK42+QT_DET_SAMPLE_NO] = 0;
    acqInfo.sharedBuf[BANK42+QRS_COUNT] = 0;
    acqInfo.sharedBuf[BANK42 + TRANSMITTER_ID_ADC] = 1;


    acqInfo.sharedBuf[BANK42+FRAME_SAMPLES] = 0;
    acqInfo.sharedBuf[BANK42+NORMALISED]  = FALSE;
    acqInfo.sharedBuf[BANK42+BURNED_IN] = FALSE;
    acqInfo.sharedBuf[BANK42+DETECTED_HYPO] = FALSE;
    acqInfo.sharedBuf[BANK42+QT_SEARCH] = FALSE;
    acqInfo.sharedBuf[BANK42+BEEP_MUTE] = FALSE;


    //init the normalisation index incase of zero-divide
    acqInfo.sharedBuf[BANK42+HR_NORM_INDEX] = HEARTRATE_NOMINAL;   //real value will be calculated
    acqInfo.sharedBuf[BANK42+QT_NORM_INDEX] = QT_NOMINAL;
    acqInfo.sharedBuf[BANK42+SI_NORM_INDEX] = 3000;
    acqInfo.sharedBuf[BANK42+BASELINE_COUNT] = 1;


    FOREVER
    {
        //wait for semaphore to be available - by the sending process (COM1 read)
        CProcessCont::LockSemaphore(CProcessCont::pProcInfo.semId.com1_semId,SEM_FULL);

        //keep history of some of the following banks
        //keep ECG history: BANK 8 - BANK 2 -> BANK 1
        memmove(acqInfo.sharedBuf+BANK1, acqInfo.sharedBuf+BANK2,SEPT_BANK);

        //keep LPF history: BANK 16 - BANK 10 -> BANK 9
        memmove(acqInfo.sharedBuf+BANK9, acqInfo.sharedBuf+BANK10,SEPT_BANK);

        //keep HPF history: BANK 24 - BANK 18 -> BANK 17
        memmove(acqInfo.sharedBuf+BANK17, acqInfo.sharedBuf+BANK18,SEPT_BANK);

        //keep dy/dx history: BANK 32 - BANK 26 -> BANK 25
        memmove(acqInfo.sharedBuf+BANK25,acqInfo.sharedBuf+BANK26,SEPT_BANK);

        //keep dy/dx (raw) history: BANK 40 - BANK 34 -> BANK 33
        memmove(acqInfo.sharedBuf+BANK33,acqInfo.sharedBuf+BANK34,SEPT_BANK);

        //keep moving avergae history: BANK 55 - BANK 49 -> BANK 48
        memmove(acqInfo.sharedBuf+BANK48,acqInfo.sharedBuf+BANK49,SEPT_BANK);

        //identify individual data packets into particular banks
        IdentifyData(acqInfo.sharedBuf+BANK44, ADC_SAMPLE_SIZE);

        //calculate HPF - obtain data from Raw ECG (BANK 8) & store in BANK 24 (HPF n)
        CalcHPF(acqInfo.sharedBuf, ADC_SAMPLE_SIZE);

        //calculate LPF - obtain data from HPF n (BANK 24) & store in BANK 16 (LPF n)
        CalcLPF(acqInfo.sharedBuf, ADC_SAMPLE_SIZE);

        //calculate dy/dx - obtain data from LPF n (BANK 16) & store in bank32 (dy/dx n)
        CalcDerv(acqInfo.sharedBuf, ADC_SAMPLE_SIZE);

        //calculate moving average using output from dy/dx (BANK 32)
        CalcMovAvg(acqInfo.sharedBuf, ADC_SAMPLE_SIZE);

        //Calculate Heart rate & QTc interval
        /************************************/
        //calculate QT interval if required (from BANK 40 (dy/dx)
        if(acqInfo.sharedBuf[BANK42+QT_SEARCH] == TRUE ) //&& (acqInfo.sharedBuf[BANK42+FRAME_SAMPLES] > 1))
        {
            if(numQTSearch <=1)
                CalcQT(acqInfo.sharedBuf+BANK40 + (QTwindowOffset - ADC_SAMPLE_SIZE) ,2*ADC_SAMPLE_SIZE - QTwindowOffset);
            else
                CalcQT(acqInfo.sharedBuf+BANK40, ADC_SAMPLE_SIZE);

            numQTSearch++;
        }

        //check for QRS detect & calc QT interval
        if(DetectQRS(acqInfo.sharedBuf, ADC_SAMPLE_SIZE))
        {
            //inform system of sample count within a given frame
            acqInfo.sharedBuf[BANK42+FRAME_SAMPLES]++;

            //skip first 2 samples, since must stabilise
            if(acqInfo.sharedBuf[BANK42+FRAME_SAMPLES] > 1)
            {

                //beep - only for the first 15 frames
                if(acqInfo.sharedBuf[BANK42+FRAME_COUNT] < 15)
                    pUtils->Beep(1000,5);

                //calc QT depending on position of find
                if((QTwindowOffset = acqInfo.detectedQRSPos + QT_MIN_WIDTH) < ADC_SAMPLE_SIZE)
                    CalcQT(acqInfo.sharedBuf+BANK40+QTwindowOffset,(ADC_SAMPLE_SIZE-QTwindowOffset));
                else
                {
                    acqInfo.sharedBuf[BANK42+QT_SEARCH] = TRUE;
                    numQTSearch = 1;
                }
            }
        }

        //now unlock the sempahore - releasing its resource to receiving serial function of COM1
        CProcessCont::UnlockSemaphore(CProcessCont::pProcInfo.semId.com1_semId,SEM_EMPTY);


    }
    return OK;
}

