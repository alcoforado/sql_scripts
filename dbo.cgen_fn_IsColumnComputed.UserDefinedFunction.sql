USE [SAP_PRIORITY_SMB]
GO
/****** Object:  UserDefinedFunction [dbo].[cgen_fn_IsColumnComputed]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[cgen_fn_IsColumnComputed] (@sTableName varchar(128), @sColumnName varchar(128)) 
RETURNS bit 
AS 
BEGIN 
DECLARE @nTableID int, @result int 

SET @nTableID = OBJECT_ID(@sTableName)

-- Get the value is computed

SELECT  @result = is_computed 
FROM sys.columns 
WHERE 
	object_id = @nTableID AND 
	name = @sColumnName 


IF @result = 1
BEGIN 
	RETURN 1 
END 
	RETURN 0 
END

GO
