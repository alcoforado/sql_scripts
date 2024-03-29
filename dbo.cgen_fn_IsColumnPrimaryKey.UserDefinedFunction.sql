USE [SAP_PRIORITY_SMB]
GO
/****** Object:  UserDefinedFunction [dbo].[cgen_fn_IsColumnPrimaryKey]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/***********************************
  Check is a column of a table is actually part of a primary key
************************************/
CREATE FUNCTION [dbo].[cgen_fn_IsColumnPrimaryKey] (@sTableName varchar(128), @sColumnName varchar(128)) 
RETURNS bit 
AS 
BEGIN 
DECLARE @nTableID int, @nIndexID int, @i int 

SET @nTableID = OBJECT_ID(@sTableName)

-- Get the Index ID for the primary key
SELECT @nIndexID = indid 
FROM sysindexes 
WHERE 
	id = @nTableID AND 
	indid BETWEEN 1 and 254 AND 
	(status & 2048) = 2048 ORDER BY indid 

--There is no primary key index file always return false on this case
IF (@nIndexID Is Null) RETURN 0

IF @sColumnName IN (SELECT sc.[name] 
					FROM sysindexkeys sik 
						INNER JOIN syscolumns sc ON sik.id = sc.id AND sik.colid = sc.colid 
					WHERE 
						sik.id = @nTableID AND 
						sik.indid = @nIndexID ) 
BEGIN 
	RETURN 1 
END 
	RETURN 0 
END

GO
