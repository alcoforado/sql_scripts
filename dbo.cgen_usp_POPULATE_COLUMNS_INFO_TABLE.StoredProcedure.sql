USE [SAP_PRIORITY_SMB]
GO
/****** Object:  StoredProcedure [dbo].[cgen_usp_POPULATE_COLUMNS_INFO_TABLE]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[cgen_usp_POPULATE_COLUMNS_INFO_TABLE]
@sDomain varchar(128),
@sTableName varchar(128),
@sKeyColumns varchar(3000) = null
AS
BEGIN

DECLARE @sQuery nvarchar(4000), @sParamsDef nvarchar (4000)
DECLARE @param1 nvarchar(4000)

SET  @sParamsDef = '@sTableName sysname, @sDomain varchar(128), @sKeyColumns varchar(3000)'

--exec master..xp_sprintf 
	
SET @sQuery = N'
	INSERT INTO #COLUMNS_INFO_TABLE 
	SELECT	c.name AS sColumnName, 
			c.colid AS nColumnID, 
			CASE WHEN c.name in (	SELECT cols.name
									FROM    SAP_EC_WEB.sys.indexes AS i 
									INNER JOIN  ' + @sDomain + '.SYS.index_columns AS ic ON  i.OBJECT_ID = ic.OBJECT_ID AND
																		                   i.index_id = ic.index_id  
									INNER JOIN ' + @sDomain + '.SYS.COLUMNS AS cols ON cols.OBJECT_ID = ic.OBJECT_ID  AND
																				 cols.column_id = ic.column_id	
									INNER JOIN ' + @sDomain + '.SYS.TABLES AS ctbl ON cols.OBJECT_ID = ctbl.OBJECT_ID
									WHERE   i.is_primary_key = 1 and
									ctbl.name = @sTableName ) THEN 1
				ELSE 0
				END AS isPrimary,
			CASE WHEN t.name IN (''char'', ''varchar'', ''binary'', ''varbinary'' ) THEN 1 
				 WHEN t.name IN (''decimal'', ''numeric'') THEN 2 
				 WHEN t.name IN (''nvarchar'',''nchar'') THEN 3 
				 ELSE 0 
				 END AS nAlternateType,
			c.length AS nColumnLength, 
			c.prec AS nColumnPrecision, 
			c.scale AS nColumnScale, 
			c.IsNullable AS IsNullable, 
			SIGN(c.status & 128) AS IsIdentity, 
			t.name as sTypeName, 
			CASE WHEN t.name IN (''char'', ''varchar'', ''binary'', ''varbinary'' ) THEN ''('' + CAST( c.length  AS VARCHAR(10)) + '')''  
				 WHEN t.name IN (''decimal'', ''numeric'') THEN  ''('' + CAST( c.prec as varchar(10)) + '','' + CAST(c.scale AS VARCHAR(10)) +  '')'' 
				 WHEN t.name IN (''nvarchar'',''nchar'') THEN ''('' + CAST( c.prec  AS VARCHAR(10)) +  '')'' 
				 ELSE '' '' 
				 END AS sTypeComplement, 
			dbo.cgen_fn_ColumnDefault(@sDomain,@sTableName, c.name) AS sDefaultValue, 
			c.iscomputed AS nIsComputed,
			CASE WHEN @sKeyColumns is not NULL and 
					  c.name in (SELECT * FROM dbo.cgen_fn_SplitStringToTable(@sKeyColumns)) THEN 1
				 WHEN @sKeyColumns is NULL and 
					  c.name in (	SELECT cols.name
									FROM    SAP_EC_WEB.sys.indexes AS i 
									INNER JOIN  ' + @sDomain + '.SYS.index_columns AS ic ON  i.OBJECT_ID = ic.OBJECT_ID AND
																		                   i.index_id = ic.index_id  
									INNER JOIN ' + @sDomain + '.SYS.COLUMNS AS cols ON cols.OBJECT_ID = ic.OBJECT_ID  AND
																				 cols.column_id = ic.column_id	
									INNER JOIN ' + @sDomain + '.SYS.TABLES AS ctbl ON cols.OBJECT_ID = ctbl.OBJECT_ID
									WHERE   i.is_primary_key = 1 and
									ctbl.name = @sTableName ) THEN 1
				ELSE 0
				END As IsKeyColumn
	FROM 
			' + @sDomain + '.dbo.syscolumns c 
			INNER JOIN ' + @sDomain + '.dbo.systypes t ON c.xtype = t.xtype and c.usertype = t.usertype 
			INNER JOIN ' + @sDomain + '.sys.tables tbl ON tbl.object_id = c.id
	WHERE tbl.name = @sTableName'
	
	

	
	

	
	exec sp_executesql @sQuery,@sParamsDef,@sTableName,@sDomain,@sKeyColumns


if (@sKeyColumns is NULL)
BEGIN
	-- If key columns was not supplied and no column was flagged as 
	-- a key it means that there is no primary key on this table
	if NOT EXISTS(SELECT * FROM #COLUMNS_INFO_TABLE WHERE IsKeyColumn = 1)
	BEGIN
		--Search other options 
		--Try to use a auto increment column identity as the KeyColumn
		DECLARE @colName sysname
		SET @colName = NULL
	
		SET @colName = (SELECT top 1 sColumnName 
					FROM #COLUMNS_INFO_TABLE
					WHERE IsIdentity = 1)
		IF (@colName  is not NULL)
			UPDATE #COLUMNS_INFO_TABLE 
			SET IsKeyColumn = IsIdentity 
			WHERE sColumnName = @colName;
		ELSE
		BEGIN
		-- If auto increment column does not exist try to find 	a index on that table
		-- And use its columns
			SET @sQuery = N'
			UPDATE #COLUMNS_INFO_TABLE 
			SET IsKeyColumn = 1
			WHERE sColumnName in (	SELECT cols.name
									FROM    ' + @sDomain + '.sys.indexes AS i 
									INNER JOIN  ' + @sDomain + '.SYS.index_columns AS ic ON  i.OBJECT_ID = ic.OBJECT_ID AND
																					   i.index_id = ic.index_id  
									INNER JOIN ' + @sDomain + '.SYS.COLUMNS AS cols ON cols.OBJECT_ID = ic.OBJECT_ID  AND
																					 cols.column_id = ic.column_id	
									INNER JOIN ' + @sDomain + '.SYS.TABLES AS ctbl ON cols.OBJECT_ID = ctbl.OBJECT_ID
									WHERE   ctbl.name = @sTableName and
											i.index_id = (SELECT TOP 1  i2.index_id
														  FROM ' + @sDomain + '.sys.indexes as i2
														  WHERE i2.OBJECT_ID = ctbl.OBJECT_ID and
								    					  i2.index_id > 0))'
	   		
												   
			SET  @sParamsDef = '@sTableName sysname'
			exec sp_executesql @sQuery,@sParamsDef,@sTableName
		END
	END
END
ELSE
BEGIN	
	if (EXISTS (SELECT * 
				FROM dbo.cgen_fn_SplitStringToTable(@sKeyColumns) 	
				WHERE Name not in (SELECT sColumnName 
								   FROM  #COLUMNS_INFO_TABLE)))
	BEGIN
		DECLARE @not_found_columns varchar(3000)
		SET @not_found_columns = (SELECT * FROM  dbo.cgen_fn_SplitStringToTable(@sKeyColumns) 	
								  WHERE Name not in (SELECT sColumnName 
								  FROM  #COLUMNS_INFO_TABLE))
		RAISERROR('Error: Specified Key Columns %s do not exist on table %s, please check the parameters again',18,12,@not_found_columns,@sTableName);
		--RAISERROR('HELLO WORLD',12,12);
    END
END

END


GO
