
CREATE FUNCTION [dbo].[ToHex](@value bigint)
RETURNS varchar(50)
AS
BEGIN
    --DECLARE @seq char(16)
    DECLARE @result varchar(50)
  --  DECLARE @digit char(1)
  --  SET @seq = '0123456789ABCDEF'

  --  SET @result = SUBSTRING(@seq, (@value%16)+1, 1)

  --  WHILE @value > 0
  --  BEGIN
  --      SET @digit = SUBSTRING(@seq, ((@value/16)%16)+1, 1)

  --      SET @value = @value/16
  --      --IF @value <> 0 
		--SET @result =  @result + @digit
  --  END 
	set @result = SUBSTRING(UPPER(master.dbo.fn_varbintohexstr(CONVERT(varbinary, @value))), 3, 16)
    
	RETURN substring(@result,1,8) +
	  (substring(@result,15,2)) +
	  (substring(@result,13,2)) +
	  (substring(@result,11,2)) +
	  (substring(@result,9,2))  --REVERSE(substring(@result,14,2))
END