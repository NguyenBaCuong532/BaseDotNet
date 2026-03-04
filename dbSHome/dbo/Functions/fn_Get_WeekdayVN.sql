

CREATE FUNCTION [dbo].[fn_Get_WeekdayVN](@givenDate DateTime)
RETURNS nVarchar(100)
AS
BEGIN
  DECLARE @Date as nVarchar(100)
  set @Date = DATENAME(weekday, getdate())
  set @Date = 
  CASE @Date
    
    WHEN 'Monday' THEN N'Th 2, '
    WHEN 'Tuesday' THEN N'Th 3, '
    WHEN 'Wednesday' THEN N'Th 4, '
    WHEN 'Thursday' THEN N'Th 5, '
    WHEN 'Friday' THEN N'Th 6, '
    WHEN 'Saturday' THEN N'Th 7, '
    WHEN 'Sunday' THEN N'CN, '
	ELSE ''
  END
  + N'tháng ' + cast(MONTH(@givenDate) as varchar) + ' ' + cast(day(@givenDate) as varchar)
  RETURN @Date
END