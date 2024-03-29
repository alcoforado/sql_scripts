USE [SAP_PRIORITY_SMB]
GO
/****** Object:  UserDefinedFunction [dbo].[cgen_fn_Type_Translate]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[cgen_fn_Type_Translate]( @sSqlType varchar (1000), @IsSqlTypeNullable int)
returns varchar(1000)
AS
BEGIN
DECLARE @RTN VARCHAR(1000)


SELECT @RTN =  CASE WHEN (IsCTypeNullable <> 1)  AND (@IsSqlTypeNullable = 1)  THEN CType+'?' 
						  ELSE CType
						  END
				FROM [dbo].[cgen_fn_Type_Translate_Table]()
				WHERE UPPER(SqlType) = UPPER(@sSqlType) 
	
	
	RETURN @RTN
END

GO
