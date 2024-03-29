USE [SAP_PRIORITY_SMB]
GO
/****** Object:  StoredProcedure [dbo].[cgen_usp_GENERATE_GET_ADO_METHOD]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[cgen_usp_GENERATE_GET_ADO_METHOD] 
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

		------------------------    The Parameters definition -----------------------
		IF ( @IsKeyColumn = 1)
		BEGIN
				IF (@sParams <> '') 
	 				SELECT @sParams= @sParams + ', ' + dbo.cgen_fn_Type_Translate(@sTypeName,@IsNullable) + ' ' + @sColumnName
				ELSE
					SELECT @sParams= @sParams + ', ' + dbo.cgen_fn_Type_Translate(@sTypeName,@IsNullable) + ' ' + @sColumnName
		END
		
		------------------------   The Set Procedure parameters ------------------  
		SELECT @sSetProcParams  = @sSetProcParams + 'cmd.Parameters.Add(new SqlParameter("@' + @sColumnName + '", ' + @sColumnName + ');'
		
		------------------------  The Record assignment statements ---------------------
		SELECT @sRecAssignment 	= @sRecAssignment + 'rec.' + @sColumnName + '=' + 'reader.Get<' + dbo.cgen_fn_Type_Translate(@sTypeName,@IsNullable) + '>("' + @sColumnName + '");'

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
		SET @sDBProcName = '[dbo].usp_GET_' + @sTableName 
		SELECT @sDBProcName = @sDBProcName + '_FROM_' + dbo.cgen_fn_MakeTagFromStringList(@sKeyColumns)

		SET @sClassName = 'Record'  + @sTableName 
		SET @sProcName = 'Get'+@sTableName
		SET @sResult = 'public ' +@sClassName + ' ' + @sProcName + '('  + @sParams + ')' + @N +
'{
      using (var conn = new SqlConnection(GetConnectionString()))
      {
                conn.Open();

                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.CommandText = "'+ @sDBProcName + '";' + @N +
					@sSetProcParams+ '
					using (var reader = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                    {
						var rec = new '+@sClassName+'();
                        if (reader.HasRows)
                        {
                            reader.Read();' + @N +
							@sRecAssignment + '
						}
                        else
                            throw new Exception("Database Inconsistency: The Record was not found in Table '+@sTableName+'"); 
						return rec;
                    }
                 }
		}
}'
	PRINT @sResult



GO
