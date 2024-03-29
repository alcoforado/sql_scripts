USE [SAP_PRIORITY_SMB]
GO
/****** Object:  UserDefinedFunction [dbo].[cgen_fn_Grant_Permissions]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[cgen_fn_Grant_Permissions](
@sProcName varchar(5000) 
) RETURNS varchar(8000) 
AS
BEGIN
DECLARE @sResult as varchar(8000), @N as char

SET @N =  char(10) 

RETURN  'GRANT EXECUTE ON ' + @sProcName + ' TO  [SVC_EC_COMMON] AS [dbo]' +  @N +
		'IF @@SERVERNAME = ''USCLWSQLD22\SQLL22''' + @N +  
	   '   GRANT EXECUTE ON ' + @sProcName + ' TO  [ALL_DEVELOPERS] AS [dbo]' +  @N 
END

GO
