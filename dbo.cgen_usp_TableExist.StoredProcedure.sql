USE [SAP_PRIORITY_SMB]
GO
/****** Object:  StoredProcedure [dbo].[cgen_usp_TableExist]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[cgen_usp_TableExist] @iOutput int output,@sDomain varchar(128),@sTableName varchar(128) 
AS 
BEGIN 
DECLARE @result int,@query nvarchar(1000),@paramDefinition nvarchar(1000)

SET  @paramDefinition = '@result int output,@sTableName varchar(128)'


exec master..xp_sprintf @query output, 
					  'SELECT @result = COUNT(name) FROM %s.SYS.TABLES WHERE name = @sTableName',
					   @sDomain

exec sp_executesql @query,@paramDefinition,@result output,@sTableName

IF (@result >= 1)
	SET @iOutput=1
else
	SET @iOutput=0
END
return

GO
