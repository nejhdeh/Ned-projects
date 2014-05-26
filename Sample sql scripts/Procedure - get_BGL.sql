USE [HypoMonClinical]
GO
/****** Object:  StoredProcedure [dbo].[get_BGL]    Script Date: 11/23/2012 15:55:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		N.Ghevondian
-- Create date: 23-11-2012
-- Description:	The BGL values index with patient
-- =============================================

	

ALTER procedure [dbo].[get_BGL] @PatientIndex varchar(255), @Selection varchar(255), @Condition varchar(255)
AS


Declare @sqlStr varchar(4000)

set @sqlStr = 'select (' + @Selection + ') as BGL
From BGLData t1
where t1.State < 4 ' + @Condition + '
and t1.PatientIndex = ' + @PatientIndex + '
order by cast(t1.BGLTime as datetime)'
execute(@sqlStr)
	

