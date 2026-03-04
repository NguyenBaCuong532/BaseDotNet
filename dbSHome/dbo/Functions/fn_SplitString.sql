CREATE FUNCTION [dbo].[fn_SplitString]
(
    @List NVARCHAR(MAX),
    @Delim VARCHAR(255)
)
RETURNS TABLE
AS
    RETURN ( SELECT [Value] = y.part FROM 
      [dbo].[fn_split_string] (
			   @List
			  ,@Delim) y
      --  SELECT 
      --    [Value] = LTRIM(RTRIM(SUBSTRING(@List, [Number],
      --    CHARINDEX(@Delim, @List + @Delim, [Number]) - [Number])))
      --  FROM (SELECT Number = ROW_NUMBER() OVER (ORDER BY name)
      --    FROM sys.all_objects) AS x
      --    WHERE Number <= LEN(@List)
      --    AND SUBSTRING(@Delim + @List, [Number], LEN(@Delim)) = @Delim
      --) AS y
    );