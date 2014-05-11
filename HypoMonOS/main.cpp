/***************************************************************************
    File:           main.cpp  -  description
    Created:        Mon Apr  2 13:20:20 EST 2012
    Author:         Nejhdeh Ghevondian
    copyright:      (C) 2012 AiMedics Pty Ltd
    Email:          nejhdeh@AiMedics.com
    Description:    This is the main entry point for the HypoMonOS system.
                    It is the only function not to be associated with any
                    class.
****************************************************************************/

#include "main.h"

int main()
{


    //call controller operations dynamically thru inherited class tree
    CHypoMonOS* pUtils       =  new CUtils();                           //utility operations
    CHypoMonOS* pTimeUtils   =  new CTimeUtils();
    CHypoMonOS* pLcdCont     =  new CLcdCont();                         //LCD cont. operations
    CHypoMonOS* pKeyPadCont  =  new CKeyPadCont(NULL_FD, NULL_FD);      //Keypad cont. operations
    CHypoMonOS* pCommsCont   =  new CCommsCont(COM1_NAME,COM2_NAME);    //communications operations
    CHypoMonOS* pCommandCont =  new CCommandCont(NULL_ID,NULL_ID);      //command cont. functions
    CHypoMonOS* pAcqCont     =  new CAcqCont(NULL_ID, NULL_ID);         //Acquisition operations
    CHypoMonOS* pProcContInit=  new CProcessCont(NULL_ID, NULL_ID);     //process controller functions
    CHypoMonOS* pFileStorage =  new CFileStorage();                     //file storage functions
    CProcessCont* pProcCont  =  new CProcessCont((CProcessCont&)*pProcContInit);  //copy object
    CAlgorithm* pAlgorithm   =  new CAlgorithm();                       //algorithm controller
    CVectorStorage<double>* pStoreCont = new CVectorStorage<double>(EMPTY_VECTOR); //Storage operations

    try{
        /*Initialise all controllers
        ****************************/
        //Utilities controller
        pUtils->Init();
        delete pUtils;

        //time controller
        pTimeUtils->Init();

        //LCD controller
        pLcdCont->Init();
        delete pLcdCont;

        //KeyPad controller
        pKeyPadCont->Init();

        //Comms controller
        pCommsCont->Init();
        delete pCommsCont;

        //acquisition controller
        pAcqCont->Init();
        delete pAcqCont;

        //Process controller
        pProcContInit->Init();
        delete pProcContInit;

        //Storage controller called through vector storage
        pStoreCont->Init();
        delete pStoreCont;

        //File controller
        pFileStorage->Init();
        delete pFileStorage;

        //command controller
        pCommandCont->Init();
        delete pCommandCont;

        //Algorithm controller
        pAlgorithm->Init();
        delete pAlgorithm;


        /*Process Controller - daemon
        *****************************/
        pProcCont->ProcessController();
        delete pProcCont;


    }catch(CExceptionHndlr& exceptHndlr)
    {
        if(pUtils)
            delete pUtils;
        if(pLcdCont)
            delete pLcdCont;
        if(pCommsCont)
            delete pCommsCont;
        if(pAcqCont)
            delete pAcqCont;
        if(pProcContInit)
            delete pProcContInit;
        if(pStoreCont)
            delete pStoreCont;
        if(pFileStorage)
            delete pFileStorage;
        if(pCommandCont)
            delete pCommandCont;
        if(pAlgorithm)
            delete pAlgorithm;
        if(pProcCont)
            delete pProcCont;

        //handle the error - using the exception hierarchy
        exceptHndlr.HandleError();
    }

    return EXIT_SUCCESS;
}



