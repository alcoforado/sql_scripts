USE [SAP_PRIORITY_SMB]
GO
/****** Object:  StoredProcedure [dbo].[cgen_usp_GENERATE_C#_UPDATE_METHOD]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[cgen_usp_GENERATE_C#_UPDATE_METHOD] 
@DBName sysname,
@sTableName sysname,
@sKeyColumns varchar (3000) = null 
AS 
	DECLARE @sProcText varchar(8000), 
	@oResult int,
	@sCType varchar(1000),
	@sParams varchar(4000),
	@sProcName varchar(1000),
	@sCreationDate varchar(120), 
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
	@N char(2), 
	@sTAB char(1), 
	@sClassName varchar(128),
	@nIsComputed int,
	@IsKeyColumn int,
	@sTypeComplement varchar(128), 
	@sResult varchar(max),
	@sSetProcParams varchar(max),
	@sRecAssignment varchar(max)


	SET @sTAB = char(9) 
	SET @N =  char(10) 
	SET @sProcText = '' 
	SET @sParams=''
	SET @sRecAssignment = ''
	SET @sSetProcParams = ''
	
	
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

		DECLARE @CSharpName varchar(1000)
		SELECT @CSharpName = dbo.cgen_fn_Convert_Name_To_CSharp(@sColumnName)

		
		------------------------   The Set Procedure parameters ------------------  
		SELECT @sSetProcParams  = @sSetProcParams +    @sTAB + @sTAB + @sTAB + 'cmd.Parameters.Add(new SqlParameter("@' + @sColumnName + '", record.' + @CSharpName + '));' + @N
		

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

		DECLARE @sDBProcName  varchar(512)
		SET @sDBProcName = '[dbo].usp_UPDATE_' + @sTableName 
		IF (@sKeyColumns is not NULL)
			SELECT @sDBProcName = @sDBProcName + '_FROM_' + dbo.cgen_fn_MakeTagFromStringList(@sKeyColumns)

		DECLARE @CSharpTableName varchar(1000)
		SELECT  @CSharpTableName =dbo.cgen_fn_Convert_Name_To_CSharp(@sTableName)
		SET     @sClassName =@CSharpTableName 
		SET		@sProcName = 'Update'+@sClassName
		
		SET @sResult = 'public void '  + @sProcName + '(' + @sClassName + ' record)' + @N +
'{
    using (var conn = new SqlConnection(GetConnectionString()))
	{
		conn.Open();
		using (var cmd = conn.CreateCommand())
		{
			cmd.CommandType = System.Data.CommandType.StoredProcedure;
			cmd.CommandText = "'+ @sDBProcName + '";' + @N +
			@sSetProcParams+ '
			cmd.ExecuteNonQuery();
		}
	}
}'
	PRINT @sResult



GO
