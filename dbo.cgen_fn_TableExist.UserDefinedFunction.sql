USE [SAP_PRIORITY_SMB]
GO
/****** Object:  UserDefinedFunction [dbo].[cgen_fn_TableExist]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[cgen_fn_TableExist] (@sDomain varchar(128),@sTableName varchar(128)) 
RETURNS bit 
AS 
BEGIN 
DECLARE @result int,@query varchar(5000),@paramDefinition varchar(1000)

SET  @paramDefinition = '@result int,@sTableName varchar(128)'

/*
exec master..xp_sprintf @query output, 
					  'SELECT @result = COUNT(name) FROM %s.SYS.TABLES WHERE name = @sTableName',
					   @sDomain

exec sp_executesql @query,@paramDefinition,@result,@sTableName*/


SELECT @result = COUNT(TABLE_NAME)
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = @sTableName AND
	   TABLE_CATALOG = @sDomain

IF (@result >= 1)
	RETURN 1

RETURN 0
END

GO
