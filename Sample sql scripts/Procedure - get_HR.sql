USE [HypoMonClinical]
GO
/****** Object:  StoredProcedure [Matlab].[Get_HRData]   Script Date: 10/17/2012 14:59:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		N.Ghevondian
-- Create date: 19-10-2012
-- Description:	This Report display the StudySessionID 
-- and all the HR within each cycle.
-- =============================================
ALTER PROCEDURE [Matlab].[Get_HRData]
	-- Add the parameters for the stored procedure here
@StudyID nvarchar(4000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	-- interfering with SELECT statements.

    -- Insert statements for procedure here


With VisitStudy as (
SELECT t1.VisitRefID,t1.VisitNumber,t1.StudyID,t1.PatientIndex,t2.StudySessionID 
FROM
Visit_Master t1
full join
StudySessionData t2
on t1.VisitRefID = t2.VisitRefID
),
VisitStudyCycle as (
SELECT t1.*,t2.CycleID,convert(datetime,t2.EndCycleTime,120) EndCycleTime,AvgHR
FROM
VisitStudy t1
full join
CycleStatus t2
on t1.StudySessionID = t2.StudySessionID
)
SELECT * FROM VisitStudyCycle
order by StudyID, PatientIndex, VisitNumber, StudySessionID, CycleID

END

