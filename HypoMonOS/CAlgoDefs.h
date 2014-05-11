/***************************************************************************
    File:           	CAlgoDefs.h
    Class:
    Base Class:
    Created:        	Mon Apr 02 2012
    Author:         	Nejhdeh Ghevondian
    Copyright:      (C) 2012 by AiMedics Pty. Ltd.
    Email:          	nejhdeh@AiMedics.com

    Description:    Defines some constants for the CAlgorithm class
***************************************************************************/
#ifndef CALGODEFS_H
#define CALGODEFS_H

#define SIGMA               3.0
#define NUM_COEFF_CUTOFF    12
#define BURN_IN             NUM_COEFF_CUTOFF
#define HYPO_THRESHOLD      2.25

#define NORM_WINDOW         4

#define EUGLY               0
#define HYPO                1

#define HR_MF               4
#define QT_MF               4
#define SI_MF               4


//Algorithm #2 defines - Fuzzy
#define HEART_RATE          0
#define QTc                 1
#define SKIN_IMPEDANCE      2

//heart rate membership function limits
/**************************************/
//NORMAL
#define N_HR_a          0.0
#define N_HR_b          1.0
#define N_HR_c          1.10

//ABOVE NORMAL
#define AN_HR_a         N_HR_b
#define AN_HR_b         N_HR_c
#define AN_HR_c         1.15

//HIGH
#define H_HR_a          AN_HR_b
#define H_HR_b          AN_HR_c
#define H_HR_c          1.25

//VERY HIGH
#define VH_HR_a         H_HR_b
#define VH_HR_b         H_HR_c


//QTc membership function limits
/********************************/
//NORMAL
#define N_QT_a          0.0
#define N_QT_b          1.0
#define N_QT_c          1.10

//ABOVE NORMAL
#define AN_QT_a         N_QT_b
#define AN_QT_b         N_QT_c
#define AN_QT_c         1.15

//HIGH
#define H_QT_a          AN_QT_b
#define H_QT_b          AN_QT_c
#define H_QT_c          1.25

//VERY HIGH
#define VH_QT_a         H_QT_b
#define VH_QT_b         H_QT_c


//Skin impedance membership function limits
/******************************************/
//NORMAL
#define VL_SI_a         0.0
#define VL_SI_b         0.85
#define VL_SI_c         0.9

//ABOVE NORMAL
#define L_SI_a          VL_SI_b
#define L_SI_b          VL_SI_c
#define L_SI_c          0.95

//HIGH
#define BN_SI_a         L_SI_b
#define BN_SI_b         L_SI_c
#define BN_SI_c         1.0

//VERY HIGH
#define N_SI_a          BN_SI_b
#define N_SI_b          BN_SI_c
#define N_SI_c          2

//fuzzy variables
#define NO_VARIABLE     10
#define NORMAL          0
#define ABOVE_NORMAL    1
#define HIGH            2
#define VERY_HIGH       3
#define VERY_LOW        4
#define LOW             5
#define BELOW_NORMAL    6

#endif

