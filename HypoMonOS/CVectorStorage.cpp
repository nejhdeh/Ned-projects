/***************************************************************************
    File:           CVectorStorage.cpp
    Class:          CVectorStorage
    Base class:     CParamStorage, CDataStorage
    Created:        Apr 02 2012
    Author:         Nejhdeh Ghevondian
    Copyright:      (C) 2012 by AiMedics Pty. Ltd.
    Email:          nejhdeh@AiMedics.com

    Description:    This file provides the implementation for all operations
                    on template-based vector primarily for data storage
                    operations
    Note:           This file is not directly involved in the project file
                    system, since it uses template class definitions.
 ***************************************************************************/
#ifndef CVECTORSTORAGE_CPP
#define CUTILSTEMPLATE_CPP


template <class T> vector<vector <T> > CVectorStorage<T>::storage;

/***************************************************************************
    Function:       CVectorStorage()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        Provides the defualt constructor for CVectorStorage
***************************************************************************/
template <class T> CVectorStorage<T>::CVectorStorage()
{
}
/***************************************************************************
    Function:       CVectorStorage()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        Provides another constructor for CVectorStorage
***************************************************************************/
template <class T> CVectorStorage<T>::CVectorStorage(const int size):vectorSize(size)
{

}
/***************************************************************************
    Function:       ~CVectorStorage()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        Provides the destrcutore for CVectorStorage
***************************************************************************/
template <class T> CVectorStorage<T>::~CVectorStorage()
{

}
/***************************************************************************
    Function:       Init()
    Created:        02/04/12
    Parameters:     non
    Return:         non
    Purpose:        Provides the initialisation function for the vector class
***************************************************************************/
template <class T> void CVectorStorage<T>::Init()
{
    CProcessCont procCont;

    //allocate correct size of fundamental vectors
    storage.resize(NUM_VECTORS);
   // paramData.resize(NUM_VECTORS);

    //assign a pre-defined size to each individual vector
    //(this will obvisouly grow in size for each sub-vector)
    for (int vec=0; vec <NUM_VECTORS; vec++)
    {
        storage[vec].resize(vectorSize, static_cast<T>(NULL));
    //    paramData[vec].resize(vectorSize, static_cast<DWORD>(NULL));
    }

    //check for size allocation - first sub-vector will be suffice
    if(storage[FRAME_VECTOR].size() != vectorSize)
        throw CStorageError(STORAGE_RESIZE_ERROR);

    //init semaphores & shared memory
    procCont.InitSemaphore(&CProcessCont::pProcInfo.semId.vectorStore_semId,
    &CProcessCont::pProcInfo.shMemId.vectorStore_shMemId, 2);

}
/***************************************************************************
    Function:       Push()
    Created:        02/04/12
    Parameters:     whichVector - form which vector to push item onto
                    item - the item to be pushed onto vector
    Return:         non - throws exception if error
    Purpose:        Provides a more robust push operation for vector::push_back
***************************************************************************/
template <class T> void CVectorStorage<T>::Push(const BYTE whichVector, const T item)
{
    //push item to end of stack (inherant in vectors)
    storage[whichVector].push_back(item);

}
/***************************************************************************
    Function:       Pop()
    Created:        02/04/12
    Parameters:     whichVector - from which vector to pop item from
    Return:         non - throws exception if error
    Purpose:        Provides a more robust pop operation for vector::pop_back
***************************************************************************/
template <class T> T CVectorStorage<T>::Pop(const BYTE whichVector)
{
    //pop the an item from back of vector
    return storage[whichVector].pop_back();
}
/***************************************************************************
    Function:       Access()
    Created:        02/04/12
    Parameters:     whichVector - from which vector to access an element
    Return:         The vlaue of element required
    Purpose:        To access an element within a particular vector
***************************************************************************/
template <class T> T CVectorStorage<T>::Access(const BYTE whichVector, DWORD index)
{
    //check valid range
 //   if(index > storage[whichVector].size())
  //      index = storage[whichVector].size();

    return storage[whichVector].back();
}

/***************************************************************************
    Function:       storeHndlr()
    Created:        02/04/12
    Parameters:     non
    Return:         non - throws exception if error
    Purpose:        Provides the storeage controller handler function as a
                    child process
***************************************************************************/
template <class T> STATUS CVectorStorage<T>::storeHndlr()
{
    DWORD localSysTime=0;
    WORD  localMem=0, rowNum=0;
    BYTE flagStatus = 0x00;
    char localStr[50] = {};
    char localTimeStr[20] = {};
    FILE* pRawHRFd;
    FILE* pRawQTFd;
    FILE* pEcgTextFd;

    FOREVER
    {
        //wait for semaphore to be available - by the acquisition process
        CProcessCont::LockSemaphore(CProcessCont::pProcInfo.semId.vectorStore_semId,SEM_FULL);

        localSysTime = 0;

        //Obtain the time & the system time & write results to the storage vector
        CUtils::ByteToDword((BYTE*)CTimeUtils::timeInfo.systemTime, &localSysTime,4);
        strncpy(localTimeStr,(char*)(CTimeUtils::timeInfo.systemTime + DATE_ONLY_STR_LEN + 5), TIME_ONLY_STR_LEN);

        // Write raw heart rate, QTc and skin imp. data
        /**********************************************/
        //check to see if in current acquisition frame
        if(CAcqCont::acqInfo.sharedBuf[BANK42+FRAME_TIMEOUT] == TRUE)
        {
            //inform of current frame count
            rowNum = CAcqCont::acqInfo.sharedBuf[BANK42+FRAME_COUNT];

            //open the raw files
            pRawHRFd = fopen(CFileStorage::file_info.rawHRFileStr,"a");

            for (int i=0; i< CAcqCont::acqInfo.sharedBuf[BANK42+QRS_COUNT]; i++)
            {
                sprintf(localStr, "%5d%8d\n", rowNum, (DWORD)CAcqCont::acqInfo.sharedBuf[BANK45+i]);
                fwrite(localStr,SINGLE_BYTE, strlen(localStr),pRawHRFd);
            }
            fclose(pRawHRFd);

            //do similar to QTc data
            /***********************/
            pRawQTFd = fopen(CFileStorage::file_info.rawQTFileStr,"a");

            for (int i=0; i< CAcqCont::acqInfo.sharedBuf[BANK42+QT_COUNT]; i++)
            {
                sprintf(localStr, "%5d%8d\n", rowNum, (DWORD)CAcqCont::acqInfo.sharedBuf[BANK46+i]);
                fwrite(localStr,SINGLE_BYTE, strlen(localStr),pRawQTFd);
            }
            fclose(pRawQTFd);

            //prepare to write ecg header
            CUtils::ByteToWord((BYTE*)CTimeUtils::timeInfo.systemTime, (WORD*)(CAcqCont::ECG_HEADER+2),4);
            //swap the time bytes
            localMem = CAcqCont::ECG_HEADER[2];
            CAcqCont::ECG_HEADER[2] = CAcqCont::ECG_HEADER[3];
            CAcqCont::ECG_HEADER[3] = localMem;

            //also write to the ecg text file & similarly to the
            //open this file locally only (note: decrementing FRAME_COUNT by one since this is for previous frame
            pEcgTextFd = fopen(CFileStorage::file_info.ecgFileStr,"a");

            sprintf(localStr, "Frame: %d  Time: %s  System Time: %d\n",rowNum,(DWORD)localTimeStr,(DWORD)localSysTime);
            fwrite(localStr,SINGLE_BYTE, strlen(localStr),pEcgTextFd);

             //also the actual ECG trip for that frame
            for(int i=0; i<8*ADC_SAMPLE_SIZE; i++)
            {
                //Raw ECG
                sprintf(localStr, "%5d\n", CAcqCont::acqInfo.sharedBuf[BANK1 + i]);
                fwrite(localStr,SINGLE_BYTE, strlen(localStr),pEcgTextFd);
             }

            fclose(pEcgTextFd);

            //Write to param & norm files
            /****************************/

            memset(localStr,0,sizeof(localStr));

            //now format the string & write results to file
            sprintf(localStr, "%5d%12s%8.0f%8.0f%8.0f%8.0f%8.2f%8.2f%8.0f%8.0f%8.0f\n", rowNum, (DWORD)localTimeStr,
                CAcqCont::acqInfo.paramArray[HR_VECTOR][rowNum],
                CAcqCont::acqInfo.paramArray[QT_VECTOR][rowNum],
                CAcqCont::acqInfo.paramArray[AC_SI_VECTOR][rowNum],
                CAcqCont::acqInfo.paramArray[DC_SI_VECTOR][rowNum],
                CAcqCont::acqInfo.paramArray[TEMP1_VECTOR][rowNum],
                CAcqCont::acqInfo.paramArray[TEMP2_VECTOR][rowNum],
                CAcqCont::acqInfo.paramArray[X_MOTION_VECTOR][rowNum],
                CAcqCont::acqInfo.paramArray[Y_MOTION_VECTOR][rowNum],
                CAcqCont::acqInfo.paramArray[Z_MOTION_VECTOR][rowNum]);


            //write to raw parameter file
            CFileStorage::WriteFile(CFileStorage::file_info.paramFileStr,(char*)localStr,strlen(localStr),SINGLE_BYTE);

            //now format the string & write the flag results to file
            sprintf(localStr, "%5d%12s%8d%8d%8d%8d%8d%8d%8d%8.2f\n", rowNum, (DWORD)localTimeStr,
                CAcqCont::acqInfo.sharedBuf[BANK42+HR_DETECT],
                CAcqCont::acqInfo.sharedBuf[BANK42+QT_DETECT],
                CAcqCont::acqInfo.sharedBuf[BANK42+SI_AC_DETECT],
                CAcqCont::acqInfo.sharedBuf[BANK42+SI_DC_DETECT],
                CAcqCont::acqInfo.sharedBuf[BANK42+TEMP1_DETECT],
                CAcqCont::acqInfo.sharedBuf[BANK42+TEMP2_DETECT],
                CAcqCont::acqInfo.sharedBuf[BANK42+PACKET_COUNT],
                CAcqCont::acqInfo.tempVBatBuf[ON_CHEST_VALUE]);


            //write to flag data
            CFileStorage::WriteFile(CFileStorage::file_info.flagFileStr,(char*)localStr,strlen(localStr),SINGLE_BYTE);

            //write raw skin impedance values
            /********************************/
            sprintf(localStr, "%5d%12s%8.0f%8.0f\n", rowNum, (DWORD)localTimeStr,
                CAcqCont::acqInfo.paramArray[AC_SI_VECTOR][rowNum],
                CAcqCont::acqInfo.paramArray[DC_SI_VECTOR][rowNum]);


            //write to raw skin imp. file
            CFileStorage::WriteFile(CFileStorage::file_info.rawSIFileStr,(char*)localStr,strlen(localStr),SINGLE_BYTE);

            //write VBAT values
            /******************/
            sprintf(localStr, "%5d%12s%8.2f\n", rowNum, (DWORD)localTimeStr, CAcqCont::acqInfo.tempVBatBuf[VBAT_VALUE]);

            //write to file
            CFileStorage::WriteFile(CFileStorage::file_info.vBatFileStr,(char*)localStr,strlen(localStr),SINGLE_BYTE);

            //re-initialise
            CAcqCont::acqInfo.sharedBuf[BANK42+FRAME_SAMPLES] = 0;

            //prior to initialising obtain total packet count & summarise the flag byte
            CAcqCont::acqInfo.sharedBuf[BANK42+TOTAL_PACKET_COUNT] = CAcqCont::acqInfo.sharedBuf[BANK42+PACKET_COUNT];

            if(CAcqCont::acqInfo.sharedBuf[BANK42+TOTAL_PACKET_COUNT] >= 7488)
                CAcqCont::acqInfo.sharedBuf[BANK42+FULL_RF_PACKET] = TRUE;
            else
                CAcqCont::acqInfo.sharedBuf[BANK42+FULL_RF_PACKET] = FALSE;

            //packetise all the falg errors of each parameter into single byte
            CAcqCont::acqInfo.sharedBuf[BANK42+FLAG_STATUS] = 0x00;

            for (int i=0; i<8; i++)
            {
                flagStatus = CAcqCont::acqInfo.sharedBuf[BANK42+HR_DETECT + i];
                flagStatus <<= i;
                CAcqCont::acqInfo.sharedBuf[BANK42+FLAG_STATUS] |= flagStatus;
            }

            CAcqCont::acqInfo.sharedBuf[BANK42+PACKET_COUNT] = 0;

            CAcqCont::acqInfo.sharedBuf[BANK42+QRS_COUNT] = 0;
            CAcqCont::acqInfo.sharedBuf[BANK42+QT_COUNT] = 0;
            CAcqCont::acqInfo.sharedBuf[BANK42+HR_DETECT] = 0;
            CAcqCont::acqInfo.sharedBuf[BANK42+QT_DETECT] = 0;
            CAcqCont::acqInfo.sharedBuf[BANK42+SI_AC_DETECT] = 0;
            CAcqCont::acqInfo.sharedBuf[BANK42+SI_DC_DETECT] = 0;
            CAcqCont::acqInfo.sharedBuf[BANK42+TEMP1_DETECT] = 0;
            CAcqCont::acqInfo.sharedBuf[BANK42+TEMP2_DETECT] = 0;

            //also inform system not to perform QT search at begining of next frame until QRS find
            CAcqCont::acqInfo.sharedBuf[BANK42+QT_SEARCH] = FALSE;

            //perform hypoglycaemia detection (also performs the normalising & smoothing functions)
            /**************************************************************************************/
         //   CProcessCont::UnlockSemaphore(CProcessCont::pProcInfo.semId.algorithm_semId,SEM_FULL);

            //increment the frame, notifying completion of process
            CAcqCont::acqInfo.sharedBuf[BANK42+FRAME_COUNT]++;

            //The TCPIP
            CProcessCont::UnlockSemaphore(CProcessCont::pProcInfo.semId.tcp_semId,SEM_FULL);
        }
    }
    return OK;
}

#endif





