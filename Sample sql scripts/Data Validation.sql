/* -- Validation Testing */
Use HypoMonClinical
-- Patient Table
-- Duplicate patient?
SELECT DOB,DOD ,Gender, COUNT(*) TotalCount
FROM Patient
GROUP BY DOB,DOD ,Gender
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC 

-- Gender
-- Gender is empty
SELECT PatientIndex,Gender FROM Patient WHERE Gender is null
-- Histrogram of Gender
SELECT Gender, Count(Gender) FROM Patient GROUP BY Gender ORDER BY Gender

-- Gender that is other than 0 or 1
SELECT PatientIndex,Gender FROM Patient WHERE Gender <0 or Gender >1

-- DOB
-- DOB is empty
SELECT PatientIndex,DOB FROM Patient WHERE DOB is null

-- StudyStart-DOB < 10 and StudyStart-DOB > 25
SELECT StudySessionData.StudySessionID, StudySessionData.PatientIndex ,DateDiff(YEAR,Patient.DOB, StudySessionData.StudyStart) as Age FROM Patient FULL JOIN StudySessionData ON Patient.PatientIndex=StudySessionData.PatientIndex WHERE DateDiff(YEAR,Patient.DOB, StudySessionData.StudyStart) <10 OR DateDiff(YEAR,Patient.DOB, StudySessionData.StudyStart) >25

-- DOB > DOD
SELECT PatientIndex, DOB, DOD FROM Patient WHERE DOB > DOD

-- DOB > StudyStart
SELECT * FROM Patient FULL JOIN StudySessionData ON Patient.PatientIndex=StudySessionData.PatientIndex WHERE Patient.DOB > StudySessionData.StudyStart

-- DOD
---------
-- DOD is empty
SELECT PatientIndex,DOD FROM Patient WHERE DOD is null

-- DOD > StudyStart
SELECT * FROM Patient FULL JOIN StudySessionData ON Patient.PatientIndex=StudySessionData.PatientIndex WHERE Patient.DOD > StudySessionData.StudyStart



-- StudySessionData Table
--------------------------------
-- Duplicate StudySessionID
SELECT StudySessionID,  COUNT(*) TotalCount
FROM StudySessionData
GROUP BY StudySessionID
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC 

-- StudyStart
-------------------
-- StudyStart is empty
SELECT StudySessionID, StudyStart FROM StudySessionData WHERE StudyStart is null

-- StudyStart, DischargeTime, ArrivalTime, PreDinnerBGLTime, LightOutTime has different timezone
SELECT StudySessionID, StudyStart, DischargeTime, ArrivalTime, PreDinnerBGLTime, LightOutTime FROM StudySessionData WHERE (datepart(tz,StudyStart) != datepart(tz,DischargeTime)) OR (datepart(tz,StudyStart) != datepart(tz,ArrivalTime)) OR (datepart(tz,StudyStart) != datepart(tz,PreDinnerBGLTime)) OR (datepart(tz,StudyStart) != datepart(tz,LightOutTime))

-- StudyStart < StudyDate
SELECT StudySessionID, StudyStart, StudyDate FROM StudySessionData WHERE StudyStart < StudyDate

-- StudyStart > DischargeTime
SELECT StudySessionID, StudyStart, DischargeTime FROM StudySessionData WHERE StudyStart > DischargeTime

-- StudyStart < ArrivalTime
SELECT StudySessionID, StudyStart, ArrivalTime FROM StudySessionData WHERE Cast(StudyStart as datetime) < Cast(ArrivalTime as datetime)



-- StudyDate
-------------------
-- StudyDate is empty
SELECT StudySessionID, StudyDate FROM StudySessionData WHERE StudyDate is null


-- ArrivalTime
-------------------
-- ArrivalTime is empty
SELECT StudySessionID, ArrivalTime FROM StudySessionData WHERE ArrivalTime is null


-- ArrivalBGL
-------------------
-- ArrivalBGL is empty
SELECT StudySessionID, ArrivalBGL FROM StudySessionData WHERE ArrivalBGL is null

-- Histrogram of Arrival BGL
SELECT ArrivalBGL, Count(ArrivalBGL) FROM StudySessionData GROUP BY ArrivalBGL ORDER BY ArrivalBGL

-- (ArrivalBGL < 4 OR ArrivalBGL > 25) AND ExclusionReason != 3
SELECT StudySessionID, ArrivalBGL, ExclusionReason FROM StudySessionData WHERE (ArrivalBGL < 4 OR ArrivalBGL > 25) AND ExclusionReason != 3


-- ChestSize
-------------------
-- (ChestSize < 50 OR ChestSize > 120) AND ChestSize is not Null
SELECT StudySessionID, ChestSize FROM StudySessionData WHERE (ChestSize < 50 OR ChestSize > 120) AND ChestSize is not Null
-- Histrogram of ChestSize
SELECT ChestSize, Count(ChestSize) FROM StudySessionData GROUP BY ChestSize ORDER BY ChestSize
-- Chest Size < 0
SELECT StudySessionID, ChestSize FROM StudySessionData WHERE ChestSize <0
-- Weight
-------------------
-- Weight is Null
SELECT StudySessionID, Weight FROM StudySessionData WHERE Weight is Null
-- (Weight < 20 OR Weight > 200) AND Weight is not Null
SELECT StudySessionID, Weight FROM StudySessionData WHERE (Weight < 20 OR Weight > 200) AND Weight is not Null
-- Histrogram of Weight
SELECT Weight, Count(Weight) FROM StudySessionData GROUP BY Weight ORDER BY Weight

-- Height
--------------------
-- Height is Null
SELECT StudySessionID, Height FROM StudySessionData WHERE Height is Null
-- (Height < 100 OR Height > 200) AND Height is not Null
SELECT StudySessionID, Height FROM StudySessionData WHERE (Height < 100 OR Height > 200) AND Height is not Null
-- Histrogram of Height
SELECT Height, Count(Height) FROM StudySessionData GROUP BY Height ORDER BY Height

-- HbA1c
-------------------
-- HbA1c is empty
SELECT StudySessionID, HbA1c FROM StudySessionData WHERE HbA1c is Null
-- (HbA1c < 6 OR HbA1c > 15) AND HbA1c=-1 AND HbA1c is not empty
SELECT StudySessionID, HbA1c FROM StudySessionData WHERE (HbA1c < 6 OR HbA1c > 15) AND HbA1c!=-1 AND HbA1c is not Null

-- HbA1cDate
-------------------
-- HbA1cDate is empty
SELECT StudySessionID, HbA1cDate FROM StudySessionData WHERE HbA1cDate is null

-- HbA1cDate > DischargeTime
SELECT StudySessionID, HbA1cDate, DischargeTime, DateDiff(HOUR,HbA1cDate, DischargeTime) FROM StudySessionData WHERE DateDiff(HOUR,HbA1cDate, Cast(DischargeTime as datetime))< 0

-- PreDinnerBGL
-------------------
-- (PreDinnerBGL < 2.5 OR PreDinnerBGL > 25) AND PreDinnerBGL is not Null
SELECT StudySessionID, PreDinnerBGL FROM StudySessionData WHERE (PreDinnerBGL < 2.5 OR PreDinnerBGL > 25) AND PreDinnerBGL is not Null

-- PreDinnerBGLTime
-------------------
-- PreDinnerBGLTime is empty
SELECT StudySessionID, PreDinnerBGLTime FROM StudySessionData WHERE PreDinnerBGLTime is null

-- LightOutTime
-------------------
-- LightOutTime is empty
SELECT StudySessionID, LightOutTime FROM StudySessionData WHERE LightOutTime is null

-- HypoScore
-------------------
-- (HypoScore < 0 OR HypoScore > 10) AND HypoScore is Null
SELECT StudySessionID, HypoScore FROM StudySessionData WHERE (HypoScore < 0 OR HypoScore > 10) OR HypoScore is Null
-- Histrogram of HypoScore
SELECT HypoScore, Count(HypoScore) FROM StudySessionData GROUP BY HypoScore ORDER BY HypoScore

-- DischargeTime
-------------------
-- DischargeTime is empty
SELECT StudySessionID, DischargeTime FROM StudySessionData WHERE DischargeTime is null

-- DischargeBGL
-------------------
-- (DischargeBGL < 4 OR DischargeBGL > 25) AND DischargeBGL!=-1 AND DischargeBGL is not Null
SELECT StudySessionID, DischargeBGL FROM StudySessionData WHERE (DischargeBGL < 4 OR DischargeBGL > 25) AND DischargeBGL!=-1 AND DischargeBGL is not Null

-- TimeZone
-------------------
-- TimeZone is Null
SELECT StudySessionID, TimeZone FROM StudySessionData WHERE TimeZone is Null

-- TimeZone different from the timezone of Other Times OR Timezone is Null
SELECT StudySessionID, TimeZone, StudyStart FROM StudySessionData WHERE (DATEPART(tz,StudyStart) != TimeZone) OR TimeZone is null


-- StudySessionEndTime
-------------------
-- 


-- Allergies
-------------------
-- 


-- Regime
-------------------
-- 


-- ConsentFormCompleted
-------------------
-- ConsentFormCompleted <0 OR ConsentFormCompleted > 1 OR ConsentFormCompleted is null
SELECT StudySessionID, ConsentFormCompleted FROM StudySessionData WHERE ConsentFormCompleted <0 OR ConsentFormCompleted > 1 OR ConsentFormCompleted is null


-- ExclusionReason
-------------------
-- ExclusionReason < 0 OR ExclusionReason > 13 OR ExclusionReason is null
SELECT StudySessionID, ExclusionReason FROM StudySessionData WHERE ExclusionReason < 0 OR ExclusionReason > 13 OR ExclusionReason is null


-- Enrolled
-------------------
-- Enrolled < 0 OR Enrolled > 1 OR Enrolled is null
SELECT StudySessionID, Enrolled FROM StudySessionData WHERE Enrolled < 0 OR Enrolled > 1 OR Enrolled is null
-- Histrogram of Enrolled
SELECT Enrolled, Count(Enrolled) FROM StudySessionData GROUP BY Enrolled ORDER BY Enrolled

-- ReasonForNonEnrolment
-------------------
-- Enrolled = 0 AND ReasonForNonEnrolment is null
SELECT StudySessionID, Enrolled, ReasonForNonEnrolment FROM StudySessionData WHERE Enrolled = 0 AND ReasonForNonEnrolment is null


-- PostStudyStartExclusion1
-------------------
-- (PostStudyStartExclusion1 < 0 OR PostStudyStartExclusion1 > 4) OR PostStudyStartExclusion1 is null
SELECT StudySessionID, PostStudyStartExclusion1 FROM StudySessionData WHERE (PostStudyStartExclusion1 < 0 OR PostStudyStartExclusion1 > 4) OR PostStudyStartExclusion1 is null


-- PostStudyStartExclusionComment
-------------------
-- (PostStudyStartExclusion1>=1 AND PostStudyStartExclusion1<=4) AND PostStudyStartExclusionComment is null
SELECT StudySessionID, PostStudyStartExclusion1, PostStudyStartExclusionComment FROM StudySessionData WHERE (PostStudyStartExclusion1>=1 AND PostStudyStartExclusion1<=4) AND PostStudyStartExclusionComment is null


-- SkinCondition
-------------------
-- (SkinCondition<1 OR SkinCondition>5) OR SkinCondition is null
SELECT StudySessionID, SkinCondition FROM StudySessionData WHERE (SkinCondition<1 OR SkinCondition>5) OR SkinCondition is null
-- Histrogram of SkinCondition
SELECT SkinCondition, Count(SkinCondition) FROM StudySessionData GROUP BY SkinCondition ORDER BY SkinCondition

-- SkinConditionComment
-------------------
-- 


-- ReportedAdverseEvent
-------------------
-- (ReportedAdverseEvent<1 OR ReportedAdverseEvent>5) OR ReportedAdverseEvent is null
SELECT StudySessionID, ReportedAdverseEvent FROM StudySessionData WHERE (ReportedAdverseEvent<0 OR ReportedAdverseEvent>1) OR ReportedAdverseEvent is null


-- ComfortScore
-------------------
-- (ComfortScore<1 OR ComfortScore>5) OR ComfortScore is null
SELECT StudySessionID, ComfortScore FROM StudySessionData WHERE (ComfortScore<1 OR ComfortScore>5) OR ComfortScore is null
-- Histrogram of ComfortScore
SELECT ComfortScore, Count(ComfortScore) FROM StudySessionData GROUP BY ComfortScore ORDER BY ComfortScore

-- BGLDeviceType
-------------------
--

--------------------
-- Rebootcount
-------------------
--

--------------------
-- ParticipantComment
-------------------
--

--------------------
-- State
-------------------
-- (State<0 OR State>6) OR State is null
SELECT StudySessionID, State FROM StudySessionData WHERE (State<0 OR State>6) OR State is null


-- ModificationReason
-------------------
-- ModificationReason is null
SELECT StudySessionID, ModificationReason FROM StudySessionData WHERE ModificationReason is null


-- Comment
-------------------
-- Comment is null
SELECT StudySessionID, Comment FROM StudySessionData WHERE Comment is null


--------------------------------
-- CycleStatus Table
--------------------------------
-- Looking for duplicates
SELECT StudySessionID,CycleID,  COUNT(*) TotalCount
FROM CycleStatus
GROUP BY StudySessionID,CycleID
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC 

--------------------
-- EndCycleTime
-------------------
-- EndCycleTime is null
SELECT StudySessionID, EndCycleTime FROM CycleStatus WHERE EndCycleTime is null

-- First cycle EndCycleTime of each studysessionID > EndCycleTime of each studysessionID
SELECT CycleStatus.StudySessionID,CycleStatus.CycleID,CycleStatus.EndCycleTime, FirstCycleTime.EndCycleTime as FirstStartTime FROM CycleStatus INNER JOIN
(SELECT StudySessionID, EndCycleTime FROM CycleStatus WHERE CycleID=0) as FirstCycleTime
ON CycleStatus.StudySessionID = FirstCycleTime.StudySessionID WHERE FirstCycleTime.EndCycleTime > CycleStatus.EndCycleTime

-- Check timezone is the same the first cycle time
SELECT CycleStatus.StudySessionID,CycleStatus.CycleID,CycleStatus.EndCycleTime, FirstTimezone.Timezone as FirstStartTime FROM CycleStatus INNER JOIN
(SELECT StudySessionID, Datepart(TZ, CycleStatus.EndCycleTime) as Timezone FROM CycleStatus WHERE CycleID=0) as FirstTimezone
ON CycleStatus.StudySessionID = FirstTimezone.StudySessionID WHERE FirstTimezone.Timezone != Datepart(TZ, CycleStatus.EndCycleTime)

-- CycleID
-------------------
-- CycleID is null
SELECT StudySessionID,  CycleID FROM CycleStatus WHERE CycleID is null

-- CycleID < 0
SELECT StudySessionID,  CycleID FROM CycleStatus WHERE CycleID < 0

-- CycleStatus
-------------------
-- CycleStatus is null
SELECT StudySessionID,  CycleID, CycleStatus FROM CycleStatus WHERE CycleStatus is null

-- AlarmStatus
-------------------
-- AlarmStatus is null
SELECT StudySessionID, CycleID, AlarmStatus FROM CycleStatus WHERE AlarmStatus is null

-- TotalRxPackets
-------------------
-- CycleTotalRxPacketsStatus is null
SELECT StudySessionID,  CycleID, TotalRxPackets FROM CycleStatus WHERE TotalRxPackets is null

-- MissedRxPackets
-------------------
-- MissedRxPackets is null
SELECT StudySessionID,  CycleID, MissedRxPackets FROM CycleStatus WHERE MissedRxPackets is null

-- TotalTxPackets
-------------------
-- TotalTxPackets is null
SELECT StudySessionID, CycleID, TotalTxPackets FROM CycleStatus WHERE TotalTxPackets is null

-- MissedTxPackets
-------------------
-- MissedTxPackets is null
SELECT StudySessionID,  CycleID, MissedTxPackets FROM CycleStatus WHERE MissedTxPackets is null

-- CurrentRssi
-------------------
-- CurrentRssi is null
SELECT StudySessionID,  CycleID, CurrentRssi FROM CycleStatus WHERE CurrentRssi is null

-- CurrentReportedRssi
-------------------
-- CurrentReportedRssi is null
SELECT StudySessionID,  CycleID, CurrentReportedRssi FROM CycleStatus WHERE CurrentReportedRssi is null

-- AvgHR
-------------------
-- AvgHR is null
SELECT StudySessionID,  CycleID, AvgHR FROM CycleStatus WHERE AvgHR is null

-- AvgHR is the same as the derived HR query
SELECT * FROM CycleStatus-- need to be done
-- Histrogram of AvgHR
SELECT AvgHR, Count(AvgHR) FROM CycleStatus GROUP BY AvgHR ORDER BY AvgHR


-- Dropout
-------------------
-- Dropout is null
SELECT StudySessionID,  CycleID, Dropout FROM CycleStatus WHERE Dropout is null
-- Histrogram of Dropout
SELECT Dropout, Count(Dropout) FROM CycleStatus GROUP BY Dropout ORDER BY Dropout

-- OffChest
-------------------
-- OffChest is null
SELECT StudySessionID,  CycleID, OffChest FROM CycleStatus WHERE OffChest is null
-- Histrogram of CycleStatus
SELECT OffChest, Count(OffChest) FROM CycleStatus GROUP BY OffChest ORDER BY OffChest

-- CycleMarker
-------------------
-- CycleMarker is null
SELECT StudySessionID,  CycleID, CycleMarker FROM CycleStatus WHERE CycleMarker is null
-- Histrogram of CycleMarker
SELECT CycleMarker, Count(CycleMarker) FROM CycleStatus GROUP BY CycleMarker ORDER BY CycleMarker

-- FrameMarker
-------------------
-- FrameMarker is null
SELECT StudySessionID,  CycleID, FrameMarker FROM CycleStatus WHERE FrameMarker is null


-- Parameter Table
---------------------
-- Looking for duplicates
SELECT StudySessionID,CycleID, SequenceNo,  COUNT(*) TotalCount
FROM Parameter
GROUP BY StudySessionID,CycleID, SequenceNo
HAVING COUNT(*) > 1
ORDER BY StudySessionID,CycleID, SequenceNo, COUNT(*) DESC 

SELECT * FROM Parameter WHERE StudySessionID=24231

-- CycleID
-------------------
-- CycleID is null
SELECT StudySessionID, CycleID, SequenceNo FROM Parameter WHERE CycleID is null

-- CycleID < 0
SELECT StudySessionID, CycleID, SequenceNo FROM Parameter WHERE CycleID < 0

-- SequenceNo
-------------------
-- SequenceNo is null
SELECT StudySessionID, CycleID, SequenceNo FROM Parameter WHERE SequenceNo is null

-- SequenceNo < 0
SELECT StudySessionID, CycleID, SequenceNo FROM Parameter WHERE SequenceNo < 0

-- SequenceNo > 6
SELECT StudySessionID, CycleID, SequenceNo FROM Parameter WHERE SequenceNo > 6 AND StudySessionID > 10000 AND StudySessionID < 20000 ORDER BY StudySessionID, CycleID

-- RR
-------------------
-- RR is null
SELECT StudySessionID,  CycleID, SequenceNo, RR FROM Parameter WHERE RR is null ORDER BY StudySessionID, CycleID, SequenceNo

-- Sum of all RR > 2560 (10second)
SELECT * From (SELECT StudySessionID, CycleID, sum(RR) as sumofRR, COUNT(RR) as countofRR FROM Parameter GROUP BY StudySessionID,CycleID ORDER BY StudySessionID, CycleID) as sumofvalue where sumofvalue.sumofRR>2560 ORDER BY StudySessionID, CycleID

-- RR < -32767 OR RR > 32768 
SELECT StudySessionID,  CycleID, SequenceNo, RR FROM Parameter WHERE RR < -32767 OR RR > 32768   ORDER BY StudySessionID, CycleID, SequenceNo

-- Histrogram of RR (only 12000 to 16000 group of studies)
SELECT RR, Count(RR) FROM Parameter WHERE StudysessionID >12000 AND StudysessionID <16000 GROUP BY RR ORDER BY RR

-- RR >=0 AND RR <=90
SELECT * FROM Parameter WHERE RR>=0 AND RR <=90  ORDER BY StudySessionID, CycleID, SequenceNo

-- Check at the Last cycle of RR if it is between RR >=0 and RR <=90
SELECT * FROM (SELECT StudySessionID, MAX(CycleID)as MaxCycleID FROM CycleStatus GROUP BY StudySessionID) as LastCycle FULL JOIN Parameter ON LastCycle.StudySessionID = Parameter.StudySessionID WHERE RR>=0 AND RR <=90  ORDER BY Parameter.StudySessionID, CycleID, SequenceNo

-- RPeak
-------------------
-- RPeak is null
SELECT StudySessionID,  CycleID, SequenceNo, RPeak FROM Parameter WHERE RPeak is null ORDER BY StudySessionID, CycleID, SequenceNo
-- Histrogram of RPeak
SELECT RPeak, Count(RPeak) FROM Parameter GROUP BY RPeak ORDER BY RPeak
-- QT
-------------------
-- QT is null
SELECT StudySessionID,  CycleID, SequenceNo, QT FROM Parameter WHERE QT is null ORDER BY StudySessionID, CycleID, SequenceNo
-- Histrogram of QT
SELECT QT, Count(QT) FROM Parameter GROUP BY QT ORDER BY QT
-- QT >=154 
SELECT StudySessionID,  CycleID, SequenceNo, QT,RR FROM Parameter WHERE QT >=154  ORDER BY StudySessionID, CycleID, SequenceNo

-- TPeak
-------------------
-- TPeak is null
SELECT StudySessionID,  CycleID, SequenceNo, TPeak FROM Parameter WHERE TPeak is null ORDER BY StudySessionID, CycleID, SequenceNo
-- Histrogram of TPeak
SELECT TPeak, Count(TPeak) FROM Parameter GROUP BY TPeak ORDER BY TPeak

-- Treatment Table
-------------------
-- Looking for duplicates
SELECT PatientIndex, Time, Amount, COUNT(*) TotalCount
FROM Treatment
GROUP BY PatientIndex, Time, Amount
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC 

-- Time
-------------------
-- Time is null
SELECT TreatmentIndex, Time FROM Treatment WHERE Time is null

-- Amount
-------------------
-- Amount is null
SELECT TreatmentIndex, Amount FROM Treatment WHERE Amount is null

-- Amount <0
SELECT TreatmentIndex, Amount FROM Treatment WHERE Amount <=0

-- Histrogram of Amount
SELECT Amount, Count(Amount) FROM Treatment GROUP BY Amount ORDER BY Amount

-- TX_Status Table
-------------------
-- Looking for duplicates
SELECT StudySessionID, CycleID,SequenceNo, COUNT(*) TotalCount
FROM TX_Status
WHERE StudySessionID != 15620
GROUP BY StudySessionID, CycleID,SequenceNo
HAVING COUNT(*) > 1
ORDER BY StudySessionID,COUNT(*) DESC 

-- ZRaRl
-------------------
-- ZRaRl is null
SELECT StudySessionID, CycleID,SequenceNo,TX_StatusIndex, ZRaRl FROM TX_Status WHERE ZRaRl is null ORDER BY StudySessionID, CycleID, SequenceNo

-- ZLaRl
-------------------
-- ZLaRl is null
SELECT StudySessionID, CycleID,SequenceNo,TX_StatusIndex, ZLaRl FROM TX_Status WHERE ZLaRl is null ORDER BY StudySessionID, CycleID, SequenceNo

-- eBatteryVoltage
-------------------
-- eBatteryVoltage is null
SELECT StudySessionID, CycleID,SequenceNo,TX_StatusIndex, eBatteryVoltage FROM TX_Status WHERE eBatteryVoltage is null ORDER BY StudySessionID, CycleID, SequenceNo

-- BoxTemp
-------------------
-- eBatteryVoltage is null
SELECT StudySessionID, CycleID,SequenceNo,TX_StatusIndex, BoxTemp FROM TX_Status WHERE BoxTemp is null ORDER BY StudySessionID, CycleID, SequenceNo

-- X
-------------------
-- X is null
SELECT StudySessionID, CycleID,SequenceNo,TX_StatusIndex, X FROM TX_Status WHERE X is null ORDER BY StudySessionID, CycleID, SequenceNo
-- Histrogram of X
SELECT X, Count(X) FROM TX_Status GROUP BY X ORDER BY X


-- Y
-------------------
-- Y is null
SELECT StudySessionID, CycleID,SequenceNo,TX_StatusIndex, Y FROM TX_Status WHERE Y is null ORDER BY StudySessionID, CycleID, SequenceNo
-- Histrogram of Y
SELECT Y, Count(Y) FROM TX_Status WHERE StudySessionID>=12000 AND StudySessionID<16000 GROUP BY Y ORDER BY Y

-- Z
-------------------
-- Z is null
SELECT StudySessionID, CycleID,SequenceNo,TX_StatusIndex, Z FROM TX_Status WHERE Z is null ORDER By StudySessionID, CycleID, SequenceNo
-- Histrogram of Z
SELECT Z, Count(Z) FROM TX_Status WHERE StudySessionID>=12000 AND StudySessionID<16000 GROUP By Z ORDER By Z
-- Z <-2063 OR Z > 2063 (Z should not be outside this range)
SELECT StudySessionID, CycleID,SequenceNo,TX_StatusIndex, Z FROM TX_Status WHERE Z <-2063 OR Z > 2063 ORDER By StudySessionID, CycleID, SequenceNo


-- XYZ old data migration
-------------------
SELECT * FROM TX_Status INNER JOIN (SELECT StudySessionID FROM StudySessionData WHERE StudyStart between '2010-11-24' AND '2010-12-24') as StudySelected ON TX_Status.StudySessionID=StudySelected.StudySessionID
SELECT * FROM TX_Status WHERE StudySessionID = 12002

-- UserInput Table
-- Looking for duplicates
SELECT StudySessionID, CycleID, Type, Value, COUNT(*) TotalCount
FROM UserInput
--WHERE StudySessionID != 15620
GROUP BY StudySessionID, CycleID, Type, Value
HAVING COUNT(*) > 1
ORDER BY StudySessionID,COUNT(*) DESC 

-------------------
-- Time
-------------------
-- Time is null
SELECT StudySessionID,UserInputIndex, Time FROM UserInput WHERE Time is null

-- Value (Type BGL)
-------------------
-- Value is null
SELECT StudySessionID,UserInputIndex, Value FROM UserInput WHERE Value is null
-- Histrogram of Value
SELECT Type, Value, Count(Value) as CountofValue FROM UserInput WHERE Type like '%BGL%' GROUP By Type, Value ORDER By Type, Value


-- Value (Type Bolus)
-------------------
-- Histrogram of Value
SELECT Type, Value, Count(Value) FROM UserInput WHERE Type like '%Bolus%' GROUP By Type, Value ORDER By Type, Value


-- Alarm Table
-------------------

-- Looking for duplicates
SELECT StudySessionID, CycleID, SequenceNo, COUNT(*) TotalCount
FROM Alarms
--WHERE StudySessionID != 15620
GROUP BY StudySessionID, CycleID, SequenceNo
HAVING COUNT(*) > 1
ORDER BY StudySessionID,COUNT(*) DESC 

-- SystemAlarmCondition
-------------------
-- SystemAlarmCondition is null
SELECT StudySessionID, CycleID,SystemAlarmCondition FROM Alarms WHERE SystemAlarmCondition is null

-- Histrogram of SystemAlarmCondition
SELECT SystemAlarmCondition, Count(SystemAlarmCondition) FROM Alarms GROUP BY SystemAlarmCondition ORDER BY SystemAlarmCondition

-- SystemAlarmActive
-------------------
-- SystemAlarmActive is null
SELECT StudySessionID, CycleID,SystemAlarmActive FROM Alarms WHERE SystemAlarmActive is null
-- Histrogram of SystemAlarmActive
SELECT SystemAlarmActive, Count(SystemAlarmActive) FROM Alarms GROUP BY SystemAlarmActive ORDER BY SystemAlarmActive

-- SystemAlarmSilence
-------------------
-- SystemAlarmSilence is null
SELECT StudySessionID, CycleID,SystemAlarmSilence FROM Alarms WHERE SystemAlarmSilence is null
-- Histrogram of SystemAlarmSilence
SELECT SystemAlarmSilence, Count(SystemAlarmSilence) FROM Alarms GROUP BY SystemAlarmSilence ORDER BY SystemAlarmSilence

-- Algorithm Table
-------------------
-- Looking for duplicates
SELECT StudySessionID, CycleID, ParameterID,AlgorithmNumber,ParameterValue, COUNT(*) TotalCount
FROM Algorithm
--WHERE StudySessionID != 15620
GROUP BY StudySessionID, CycleID,ParameterID, AlgorithmNumber,ParameterValue
HAVING COUNT(*) > 1
ORDER BY StudySessionID,COUNT(*) DESC 

-- ParameterValue
-------------------
-- ParameterValue is null
SELECT StudySessionID, CycleID, AlgorithmNumber FROM Algorithm WHERE ParameterValue is null
-- Histrogram of ParameterValue
SELECT ParameterValue, Count(ParameterValue) FROM Algorithm GROUP By ParameterValue ORDER By ParameterValue
-- ParameterValue > 1000 OR ParameterValue < -1000
SELECT StudySessionID, CycleID, AlgorithmNumber,ParameterID,ParameterValue FROM Algorithm WHERE ParameterValue > 100 OR ParameterValue < -100 ORDER BY StudySessionID, CycleID, AlgorithmNumber,ParameterID


-- AlgoStatus Table
-------------------
-- Looking for duplicates
SELECT StudySessionID, CycleID,  COUNT(*) TotalCount
FROM AlgoStatus
--WHERE StudySessionID != 15620
GROUP BY StudySessionID, CycleID
HAVING COUNT(*) > 1
ORDER BY StudySessionID,COUNT(*) DESC 

-- AlgIsCycleOffChest
-------------------
-- AlgIsCycleOffChest is null
SELECT StudySessionID, CycleID, AlgIsCycleOffChest FROM AlgoStatus WHERE AlgIsCycleOffChest is null
-- Histrogram of AlgIsCycleOffChest
SELECT AlgIsCycleOffChest, Count(AlgIsCycleOffChest) FROM AlgoStatus GROUP By AlgIsCycleOffChest ORDER By AlgIsCycleOffChest

-- AlgIsCycleBadData
-------------------
-- AlgIsCycleBadData is null
SELECT StudySessionID, CycleID, AlgIsCycleBadData FROM AlgoStatus WHERE AlgIsCycleBadData is null
-- Histrogram of AlgIsCycleBadData
SELECT AlgIsCycleBadData, Count(AlgIsCycleBadData) FROM AlgoStatus GROUP By AlgIsCycleBadData ORDER By AlgIsCycleBadData

-- AlgIsCycleBadComms
-------------------
-- AlgIsCycleBadComms is null
SELECT StudySessionID, CycleID, AlgIsCycleBadComms FROM AlgoStatus WHERE AlgIsCycleBadComms is null
-- Histrogram of AlgIsCycleOffChest
SELECT AlgIsCycleBadComms, Count(AlgIsCycleBadComms) FROM AlgoStatus GROUP By AlgIsCycleBadComms ORDER By AlgIsCycleBadComms

-- AlgIsDatProcDropouts
-------------------
-- AlgIsDatProcDropouts is null
SELECT StudySessionID, CycleID, AlgIsDatProcDropouts FROM AlgoStatus WHERE AlgIsDatProcDropouts is null
-- Histrogram of AlgIsCycleOffChest
SELECT AlgIsDatProcDropouts, Count(AlgIsDatProcDropouts) FROM AlgoStatus GROUP By AlgIsDatProcDropouts ORDER By AlgIsDatProcDropouts

-- AlgIsCycleDropOut
-------------------
-- AlgIsCycleDropOut is null
SELECT StudySessionID, CycleID, AlgIsCycleDropOut FROM AlgoStatus WHERE AlgIsCycleDropOut is null
-- Histrogram of AlgIsCycleOffChest
SELECT AlgIsCycleDropOut, Count(AlgIsCycleDropOut) FROM AlgoStatus GROUP By AlgIsCycleDropOut ORDER By AlgIsCycleDropOut

-- BGLData Table
-------------------
-- Looking for duplicates
SELECT PatientIndex, BGLTime, YSI1, YSI2, COUNT(*) TotalCount
FROM BGLData
WHERE state != 4
GROUP BY PatientIndex, BGLTime, YSI1, YSI2
HAVING COUNT(*) > 1
ORDER BY PatientIndex,COUNT(*) DESC 

SELECT StudySessionID,PatientIndex FROM StudySessionData ORDER BY PatientIndex,StudySessionID


-- BGLTime
-------------------
-- BGLTime is empty
SELECT * FROM BGLData WHERE BGLTime is null

-- YSI1
-------------------
-- YSI1 is null
SELECT * FROM BGLData WHERE YSI1 is null

-- YSI1 > 30 OR YSI1 < 0
SELECT * FROM BGLData WHERE YSI1 >= 30 OR YSI1 <= 0
-- Histrogram of YSI1
SELECT YSI1, Count(YSI1) FROM BGLData  GROUP By YSI1 ORDER By YSI1
-- YSI2
-------------------
-- YSI2 is null
SELECT * FROM BGLData WHERE YSI2 is null

-- YSI2 > 30 OR YSI2 <= 0
SELECT * FROM BGLData WHERE YSI2 > 30 OR YSI2 <= 0

-- Histrogram of YSI2
SELECT YSI2, Count(YSI2) FROM BGLData  GROUP By YSI2 ORDER By YSI2

-- Machine
-------------------
-- Machine is null
SELECT * FROM BGLData WHERE Machine is null
-- Histrogram of Machine
SELECT Machine, Count(Machine) FROM BGLData  GROUP By Machine ORDER By Machine


-- DeviceData
-----------------------
-- TransmitterSerial is Null
SELECT StudySessionID,TransmitterSerial FROM DeviceData WHERE TransmitterSerial is null order by StudySessionID
-- HypoMonVersion is not null and does not contain a letter C
SELECT StudySessionID,HypoMonVersion FROM DeviceData WHERE HypoMonVersion is not null AND HypoMonVersion not like '%C%' order by StudySessionID


