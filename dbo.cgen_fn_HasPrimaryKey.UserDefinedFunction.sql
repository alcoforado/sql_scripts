USE [SAP_PRIORITY_SMB]
GO
/****** Object:  UserDefinedFunction [dbo].[cgen_fn_HasPrimaryKey]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 CREATE FUNCTION [dbo].[cgen_fn_HasPrimaryKey](@sTableName varchar(128))
RETURNS int
AS 
BEGIN

DECLARE @result int, @nTableID int;

SET @nTableID = OBJECT_ID(@sTableName)
 
SELECT @result = COUNT(NAME) 
	FROM sys.columns  
	WHERE 
		object_id = @nTableID AND
		 [dbo].[cgen_fn_IsColumnPrimaryKey](@sTableName,NAME) = 1

if @result = 0
	return 0

	return 1
END

GO
