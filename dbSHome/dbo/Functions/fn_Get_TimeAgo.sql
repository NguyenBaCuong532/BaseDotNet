CREATE FUNCTION [dbo].[fn_Get_TimeAgo](@givenDate DateTime,@curDate DateTime)
RETURNS nVarchar(100)
AS
BEGIN
  DECLARE @Date as nVarchar(100)
  SELECT @Date = 
  CASE
    WHEN DATEDIFF(dd,@givenDate,@curDate) < 1 THEN N'Hôm nay ' + FORMAT(@givenDate,'hh:mm tt')
    WHEN DATEDIFF(dd,@givenDate,@curDate) = 1 THEN N'Hôm qua ' + FORMAT(@givenDate,'hh:mm tt') --DATEDIFF(ss,@givenDate,@curDate) <= 60 THEN CONVERT(nVarchar,DATEDIFF(ss,@givenDate,@curDate)) + N' giây trước'
    --WHEN DATEDIFF(mi,@givenDate,@curDate) <= 1 THEN N' phút trước'
    --WHEN DATEDIFF(mi,@givenDate,@curDate) > 1 AND DATEDIFF(mi,@givenDate,@curDate) <= 60 THEN CONVERT(nVarchar,DATEDIFF(mi,@givenDate,@curDate)) + N' phút, ' + CAST(DATEDIFF(ss, @givenDate, @curDate) % 60 AS NVARCHAR(50)) + N' giây trước'
    --WHEN DATEDIFF(hh,@givenDate,@curDate) <= 1 THEN CONVERT(nVarchar,DATEDIFF(hh,@givenDate,@curDate)) + N' giờ trước'
    --WHEN DATEDIFF(hh,@givenDate,@curDate) > 1 AND DateDiff(hh,@givenDate,@curDate) <= 24 THEN CONVERT(nVarchar,DATEDIFF(hh,@givenDate,@curDate)) + N' giờ, ' + CAST(DATEDIFF(ss, @givenDate, @curDate) / 60 % 60 AS NVARCHAR(50)) + N' phút trước'
    --WHEN DATEDIFF(dd,@givenDate,@curDate) <= 1 THEN CONVERT(nVarchar,DATEDIFF(dd,@givenDate,@curDate)) + N' ngày trước'
    --WHEN DATEDIFF(dd,@givenDate,@curDate) > 1 AND  DATEDIFF(dd,@givenDate,@curDate) < 7 THEN CONVERT(nVarchar,DATEDIFF(dd,@givenDate,@curDate)) + N' ngày, ' + CAST(DATEDIFF(second, @givenDate, @curDate) / 60 / 60 % 24  AS NVARCHAR(50)) + N' giờ trước'
    --WHEN DATEDIFF(ww,@givenDate,@curDate) <= 1 THEN CONVERT(nVarchar,DATEDIFF(ww,@givenDate,@curDate)) + N' tuần trước'
    --WHEN DATEDIFF(ww,@givenDate,@curDate) > 1 AND DATEDIFF(ww,@givenDate,@curDate) <= 4 THEN CONVERT(nVarchar,DATEDIFF(ww,@givenDate,@curDate)) + N' tuần trước'
    --WHEN DATEDIFF(mm,@givenDate,@curDate) <= 1 THEN CONVERT(nVarchar,DATEDIFF(mm,@givenDate,@curDate)) + N' tháng trước'
    --WHEN DATEDIFF(mm,@givenDate,@curDate) > 1 AND DATEDIFF(mm,@givenDate,@curDate) <= 12 THEN CONVERT(nVarchar,DATEDIFF(mm,@givenDate,@curDate)) + N' tháng trước'
    --WHEN DATEDIFF(yy,@givenDate,@curDate) <= 1 THEN CONVERT(nVarchar,DATEDIFF(yy,@givenDate,@curDate)) + N' năm trước'
    --WHEN DATEDIFF(yy,@givenDate,@curDate) > 1 THEN CONVERT(nVarchar,DATEDIFF(yy,@givenDate,@curDate)) + N' năm trước'
	ELSE convert(nvarchar(100),@givenDate,103) + case when convert(nvarchar(5),@givenDate,108) = '00:00' then '' else ' ' + FORMAT(@givenDate,'hh:mm tt') end
  END
  RETURN @Date
END


--SELECT  FORMAT(getdate(),'hh:mm tt') AS PerDate,convert(nvarchar(103),getdate(),105)