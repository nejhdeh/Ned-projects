/***************************************************************************
    File:           FuzzyRules.h
    Class:
    Base Class:
    Created:        Mon Apr 02 2012
    Author:         Nejhdeh Ghevondian
    Copyright:      (C) 2012 by AiMedics Pty. Ltd.
    Email:          nejhdeh@AiMedics.com

    Description:    Provides the fuzzy rulebase for the fuzzy inference algorithm
***************************************************************************/

#ifndef FUZZYRULE_H
#define FUZZYRULE_H

const BYTE rule[HR_MF][QT_MF] = {   {EUGLY,  EUGLY,  EUGLY,  EUGLY},
                                    {EUGLY,  EUGLY,  EUGLY,  HYPO},
                                    {EUGLY,  EUGLY,  HYPO,   HYPO},
                                    {EUGLY,  HYPO,   HYPO,   HYPO}};
#endif

