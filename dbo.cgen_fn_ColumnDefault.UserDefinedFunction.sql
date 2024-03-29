USE [SAP_PRIORITY_SMB]
GO
/****** Object:  UserDefinedFunction [dbo].[cgen_fn_ColumnDefault]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[cgen_fn_ColumnDefault](
@sDomainName varchar(128),
@sTableName varchar(128), 
@sColumnName varchar(128)) 
RETURNS varchar(4000) 
AS 
BEGIN 
DECLARE @sDefaultValue varchar(4000)

SELECT @sDefaultValue =  SubString(COLUMN_DEFAULT, 2, DataLength(COLUMN_DEFAULT)-2) 
	FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE 
		TABLE_NAME = @sTableName AND 
		COLUMN_NAME = @sColumnName AND
		TABLE_CATALOG = @sDomainName

RETURN @sDefaultValue 

END

GO
