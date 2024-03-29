USE [SAP_PRIORITY_SMB]
GO
/****** Object:  UserDefinedFunction [dbo].[cgen_fn_DropIfExist]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[cgen_fn_DropIfExist](
@sProcName varchar(4000) 
) RETURNS varchar(4000) 
AS
BEGIN
DECLARE @sResult as varchar(4000), @N as char,@sTAB  as char

SET @N =  + char(10) 
SET @sTAB = char(9)

RETURN  'IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @sProcName + '''))' + @N + 
	                  'DROP PROC ' + @sProcName +  @N + 'GO'   
END

GO
