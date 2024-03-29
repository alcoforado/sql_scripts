USE [SAP_PRIORITY_SMB]
GO
/****** Object:  UserDefinedFunction [dbo].[cgen_fn_Convert_Name_To_CSharp]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[cgen_fn_Convert_Name_To_CSharp]( @sName varchar (1000))
returns varchar(1000)
AS
BEGIN
DECLARE @sResult as varchar(8000), @i as int,@sCreationDate as varchar(100),@s as char,@c as char,@IsFirst int

SET @s = '_'  
SET @i = 1
SET @IsFirst = 1
SET @sResult=''
WHILE (@i <=  LEN(@sName))
BEGIN
	 SELECT @c = SUBSTRING(@sName,@i,1)
	 if (@c='_')
		SET @IsFirst=1
	else 
	BEGIN
		IF (@IsFirst=1)
		BEGIN
			SET @sResult = @sResult+UPPER(@c)
			SET @IsFirst = 0
		END
		ELSE
			SET @sResult = @sResult+LOWER(@c)
	END
	set @i = @i+ 1
END
	RETURN @sResult
END

GO
