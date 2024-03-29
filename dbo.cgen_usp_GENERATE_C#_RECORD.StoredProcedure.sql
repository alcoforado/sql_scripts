USE [SAP_PRIORITY_SMB]
GO
/****** Object:  StoredProcedure [dbo].[cgen_usp_GENERATE_C#_RECORD]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[cgen_usp_GENERATE_C#_RECORD] 
@DBName sysname,
@sTableName sysname,
@sKeyColumns varchar (3000) = null 
AS 
	DECLARE @sProcText varchar(8000), 
	@oResult int,
	@sKeyFields varchar(2000), 
	@sSetClause varchar(2000),
	@sValueClause varchar (2000),
	@sClassDef varchar(4000),
	@sCType varchar(1000),
	@sCreationDate varchar(120), 
	@sWhereClause varchar(2000), 
	@sColumnName varchar(128),
	@nColumnID smallint, 
	@bPrimaryKeyColumn bit, 
	@nAlternateType int, 
	@nColumnLength int, 
	@nColumnPrecision int, 
	@nColumnScale int, 
	@IsNullable bit, 
	@IsIdentity int, 
	@sTypeName varchar(128), 
	@sDefaultValue varchar(4000), 
	@sCRLF char(2), 
	@sTAB char(1), 
	@sProcName varchar(128),
	@nIsComputed int,
	@IsKeyColumn int,
	@sTypeComplement varchar(128) 

	SET @sTAB = char(9) 
	SET @sCRLF =  char(10) 
	SET @sProcText = '' 
	SET @sKeyFields = '' 
	SET @sSetClause = '' 
	SET @sWhereClause = ''
	SET @sClassDef = ''
	
	SET NOCOUNT ON

	exec dbo.cgen_usp_TableExist @oResult output, @DBName, @sTableName
	 if (@oResult = 0)  
	 BEGIN
		RAISERROR ('Table  "%s" does not exist in the current catalog "%s"', 10, 1,@sTableName,@DBName) 
		RETURN 2
	 END 

	IF OBJECT_ID('tempdb..#COLUMNS_INFO_TABLE') IS NOT NULL 
		DROP TABLE #COLUMNS_INFO_TABLE
	CREATE TABLE #COLUMNS_INFO_TABLE(sColumnName sysname,nColumnID  int,IsPrimary int,nAlternateType int,nColumnLength int, nColumnPrecision int, 
		                             nColumnScale int,IsNullable int,IsIdentity int,	sTypeName sysname, sTypeComplement varchar(128),	sDefaultValue nvarchar(4000),	nIsComputed int, IsKeyColumn int)
	
	exec dbo.cgen_usp_POPULATE_COLUMNS_INFO_TABLE @DBName,@sTableName,@sKeyColumns
	

	if (NOT EXISTS 	(SELECT * 
				FROM #COLUMNS_INFO_TABLE 
				WHERE IsKeyColumn = 1))
	BEGIN 
		RAISERROR ('Delete Procedure cannot be created on a table with no key fields. Make sure the table has primary keys or specify the sKeyColumns parameter to have
		valid columns to be used as keys', 18, 1) 
		RETURN 1
	END 
	
	DECLARE @CSharpTableName varchar(1000)
	SELECT  @CSharpTableName =dbo.cgen_fn_Convert_Name_To_CSharp(@sTableName)

	SET @sClassDef =  'public class ' + @CSharpTableName +  @sCRLF + '{'  + @sCRLF
	

	 DECLARE crKeyFields cursor for 
		SELECT 
			sColumnName, 
			nColumnID, 
			IsPrimary, 
			nAlternateType, 
			nColumnLength, 
			nColumnPrecision, 
			nColumnScale, 
			IsNullable, 
			IsIdentity, 
			sTypeName, 
			sTypeComplement,
			sDefaultValue,
			nIsComputed,
			IsKeyColumn  
		FROM #COLUMNS_INFO_TABLE ORDER BY 2 
		
		OPEN crKeyFields 
		
		FETCH NEXT 
		FROM crKeyFields INTO 
			@sColumnName, 
			@nColumnID, 
			@bPrimaryKeyColumn, 
			@nAlternateType, 
			@nColumnLength, 
			@nColumnPrecision, 
			@nColumnScale, 
			@IsNullable, 
			@IsIdentity, 
			@sTypeName, 
			@sTypeComplement,
			@sDefaultValue,
			@nIsComputed,
			@IsKeyColumn   
		WHILE (@@FETCH_STATUS = 0) BEGIN

		------------------------    The Class definition -----------------------
		
		print @sTypeName
		SELECT @sCType = dbo.cgen_fn_Type_Translate(@sTypeName,@IsNullable)
		
		if (@sCType is NULL)
			RAISERROR('DBType %s does not have any equivalent in C#', 12,12,@sTypeName)

		
		DECLARE @CSharpName varchar(1000)
		SELECT @CSharpName = dbo.cgen_fn_Convert_Name_To_CSharp(@sColumnName)
		SET @sClassDef =  @sClassDef + @sTAB + 'public ' + @sCType + ' ' + @CSharpName + ' {get; set;}'	+ @sCRLF	
		

	
	FETCH NEXT FROM crKeyFields 
	INTO 
			@sColumnName, 
			@nColumnID, 
			@bPrimaryKeyColumn, 
			@nAlternateType, 
			@nColumnLength, 
			@nColumnPrecision, 
			@nColumnScale, 
			@IsNullable, 
			@IsIdentity, 
			@sTypeName,
			@sTypeComplement, 
			@sDefaultValue,
			@nIsComputed,
			@IsKeyColumn  
	END
   CLOSE crKeyFields 
   DEALLOCATE crKeyFields

   SET @sClassDef  = @sClassDef + @sCRLF  + '}' + @sCRLF 
   PRINT @sClassDef
 	

GO
