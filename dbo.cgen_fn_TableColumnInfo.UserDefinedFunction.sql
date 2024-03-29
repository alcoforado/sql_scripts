USE [SAP_PRIORITY_SMB]
GO
/****** Object:  UserDefinedFunction [dbo].[cgen_fn_TableColumnInfo]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[cgen_fn_TableColumnInfo](@sTableName varchar(128)) RETURNS TABLE 
AS 
RETURN SELECT c.name AS sColumnName, 
			  c.colid AS nColumnID, 
			  dbo.cgen_fn_IsColumnPrimaryKey(@sTableName, c.name) AS bPrimaryKeyColumn, 
			  CASE WHEN t.name IN ('char', 'varchar', 'binary', 'varbinary', 'nchar', 'nvarchar') THEN 1 
				   WHEN t.name IN ('decimal', 'numeric') THEN 2 
				   ELSE 0 
			   END AS nAlternateType, 
			   c.length AS nColumnLength, 
			   c.prec AS nColumnPrecision, 
			   c.scale AS nColumnScale, 
			   c.IsNullable, 
			   SIGN(c.status & 128) AS IsIdentity, 
			   t.name as sTypeName, 
			   dbo.fnColumnDefault(@sTableName, c.name) AS sDefaultValue, 
			   dbo.cgen_fn_IsComputedColumn(@sTableName,c.name) AS nIsComputed
			   FROM syscolumns c INNER JOIN systypes t ON c.xtype = t.xtype and c.usertype = t.usertype 
			   WHERE c.id = OBJECT_ID(@sTableName)

GO
