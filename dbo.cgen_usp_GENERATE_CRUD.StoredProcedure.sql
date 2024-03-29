USE [SAP_PRIORITY_SMB]
GO
/****** Object:  StoredProcedure [dbo].[cgen_usp_GENERATE_CRUD]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[cgen_usp_GENERATE_CRUD] 
@DBName sysname,
@sTableName sysname,
@sKeyColumns varchar(3000) = NULL
AS 
	SET NOCOUNT ON
	PRINT 'USE ['+@DBName+']'
	exec dbo.cgen_usp_GENERATE_INSERT_PROC @DBName, @sTableName, @sKeyColumns
	exec dbo.cgen_usp_GENERATE_SELECT_PROC @DBName, @sTableName, @sKeyColumns
	exec dbo.cgen_usp_GENERATE_UPDATE_PROC @DBName, @sTableName, @sKeyColumns
	exec dbo.cgen_usp_GENERATE_DELETE_PROC @DBName, @sTableName, @sKeyColumns
	

GO
