USE [SAP_PRIORITY_SMB]
GO
/****** Object:  UserDefinedFunction [dbo].[cgen_fn_Type_Translate_Table]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[cgen_fn_Type_Translate_Table]()
RETURNS  @rtnTable TABLE  ([SqlType] [varchar] (500), [CType] [varchar] (500), IsCTypeNullable int )
AS
BEGIN


insert into @rtnTable VALUES
	('varchar','String','1'),
	('nvarchar','String','1'),
	('char','String','0'),
	('nchar','short int','0'),
	('int','int','0'),
	('smallint','short int','0'),
	('Timestamp','DateTime','0'),
	('BigInt','long','0'),
	('DateTime','DateTime','0'),
	('datetimeoffset','DateTime','0'),
	('datetime2','DateTime','0'),
	('smalldatetime','DateTime','0')

	RETURN 
END

GO
