USE [SAP_PRIORITY_SMB]
GO
/****** Object:  UserDefinedFunction [dbo].[cgen_fn_MakeTagFromStringList]    Script Date: 7/11/2014 10:37:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[cgen_fn_MakeTagFromStringList](
@sList varchar(5000) 
) RETURNS varchar(8000) 
AS
BEGIN
DECLARE @sResult as varchar(8000), @i as int,@sCreationDate as varchar(100),@s as char,@c as char

SET @s = '_'  
SET @i = 1
SET @sResult=''
WHILE (@i <=  LEN(@sList))
BEGIN
	 SELECT @c = SUBSTRING(@sList,@i,1)
	 if (@c=',')
		SET @sResult=@sResult+'_'
	 else if (@c !=	' ')  
		SET @sResult=@sResult+@c
	 
	set @i = @i+ 1
END
	RETURN @sResult
END

GO
