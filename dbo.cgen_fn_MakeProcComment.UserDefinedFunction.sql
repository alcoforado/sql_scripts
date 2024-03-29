USE [SAP_PRIORITY_SMB]
GO
/****** Object:  UserDefinedFunction [dbo].[cgen_fn_MakeProcComment]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[cgen_fn_MakeProcComment](
@sDesc varchar(5000) 
) RETURNS varchar(8000) 
AS
BEGIN
DECLARE @sResult as varchar(8000), @sCreationDate as varchar(100),@sCRLF as char

SET @sCRLF = char(13) + char(10) 
SELECT @sCreationDate = LEFT(CONVERT(VARCHAR, SYSDATETIME(), 120), 10)
RETURN '/******************************************************************************' + @sCRLF +
	   'Author: ' + CURRENT_USER + @sCRLF +
	   'Date: ' + @sCreationDate  +@sCRLF +
	   'Description: ' + @sDesc + @sCRLF + 
		'*****************************************************************************/' + @sCRLF 

END

GO
