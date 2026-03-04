
--declare @date datetime ='2017-03-31 09:50:22.033';
--    SELECT 
  --    CASE 
  --      WHEN DATEDIFF(SECOND, @date, GETDATE()) < 5 THEN N' vừa xong' 
		--WHEN DATEDIFF(SECOND, @date, GETDATE()) < 60 THEN CAST(DATEDIFF(SECOND, @date, GETDATE()) AS VARCHAR(10)) + N' giây trước'
  --      WHEN DATEDIFF(MINUTE, @date, GETDATE()) < 60 THEN CAST(DATEDIFF(MINUTE, @date, GETDATE()) AS VARCHAR(10)) + N' phút trước'
  --      WHEN DATEDIFF(MINUTE, @date, GETDATE()) < 24 * 60 THEN CAST(FLOOR(DATEDIFF(MINUTE, @date, GETDATE())/60) AS VARCHAR(10)) + N' giờ trước'
  --      ELSE CAST(FLOOR(DATEDIFF(HOUR, @date, GETDATE())/24) AS VARCHAR(10)) + N' ngày trước'
  --  END AS Postedon 


CREATE FUNCTION [dbo].[fn_Get_TimeAgo1](@givenDate DateTime,@curDate DateTime)
RETURNS nVarchar(100)
AS
BEGIN
  DECLARE @Date as nVarchar(100)
  SELECT @Date = 
        CASE 
        WHEN DATEDIFF(SECOND, @givenDate, GETDATE()) < 5 THEN N' vừa xong' 
		WHEN DATEDIFF(SECOND, @givenDate, GETDATE()) < 60 THEN CAST(DATEDIFF(SECOND, @givenDate, GETDATE()) AS VARCHAR(10)) + N' giây trước'
        WHEN DATEDIFF(MINUTE, @givenDate, GETDATE()) < 60 THEN CAST(DATEDIFF(MINUTE, @givenDate, GETDATE()) AS VARCHAR(10)) + N' phút trước'
        WHEN DATEDIFF(MINUTE, @givenDate, GETDATE()) < 24 * 60 THEN CAST(FLOOR(DATEDIFF(MINUTE, @givenDate, GETDATE())/60) AS VARCHAR(10)) + N' giờ trước'
        ELSE CAST(FLOOR(DATEDIFF(HOUR, @givenDate, GETDATE())/24) AS VARCHAR(10)) + N' ngày trước'
		--END 
 -- CASE
 --   WHEN DATEDIFF(ss,@givenDate,@curDate) <= 5 THEN N' vừa xong'
 --   WHEN DATEDIFF(ss,@givenDate,@curDate) > 5 AND DATEDIFF(ss,@givenDate,@curDate) <= 60 THEN CONVERT(nVarchar,DATEDIFF(ss,@givenDate,@curDate)) + N' giây trước'
 --   WHEN DATEDIFF(mi,@givenDate,@curDate) <= 1 THEN N' phút trước'
 --   WHEN DATEDIFF(mi,@givenDate,@curDate) > 1 AND DATEDIFF(mi,@givenDate,@curDate) <= 60 THEN CONVERT(nVarchar,DATEDIFF(mi,@givenDate,@curDate)) + N' phút, ' + CAST(DATEDIFF(ss, @givenDate, @curDate) % 60 AS NVARCHAR(50)) + N' giây trước'
 --   WHEN DATEDIFF(hh,@givenDate,@curDate) <= 1 THEN CONVERT(nVarchar,DATEDIFF(hh,@givenDate,@curDate)) + N' giờ trước'
 --   WHEN DATEDIFF(hh,@givenDate,@curDate) > 1 AND DateDiff(hh,@givenDate,@curDate) <= 24 THEN CONVERT(nVarchar,DATEDIFF(hh,@givenDate,@curDate)) + N' giờ, ' + CAST(DATEDIFF(ss, @givenDate, @curDate) / 60 % 60 AS NVARCHAR(50)) + N' phút trước'
 --   WHEN DATEDIFF(dd,@givenDate,@curDate) <= 1 THEN CONVERT(nVarchar,DATEDIFF(dd,@givenDate,@curDate)) + N' ngày trước'
 --   WHEN DATEDIFF(dd,@givenDate,@curDate) > 1 AND  DATEDIFF(dd,@givenDate,@curDate) < 7 THEN CONVERT(nVarchar,DATEDIFF(dd,@givenDate,@curDate)) + N' ngày, ' + CAST(DATEDIFF(second, @givenDate, @curDate) / 60 / 60 % 24  AS NVARCHAR(50)) + N' giờ trước'
 --   --WHEN DATEDIFF(ww,@givenDate,@curDate) <= 1 THEN CONVERT(nVarchar,DATEDIFF(ww,@givenDate,@curDate)) + N' tuần trước'
 --   --WHEN DATEDIFF(ww,@givenDate,@curDate) > 1 AND DATEDIFF(ww,@givenDate,@curDate) <= 4 THEN CONVERT(nVarchar,DATEDIFF(ww,@givenDate,@curDate)) + N' tuần trước'
 --   --WHEN DATEDIFF(mm,@givenDate,@curDate) <= 1 THEN CONVERT(nVarchar,DATEDIFF(mm,@givenDate,@curDate)) + N' tháng trước'
 --   --WHEN DATEDIFF(mm,@givenDate,@curDate) > 1 AND DATEDIFF(mm,@givenDate,@curDate) <= 12 THEN CONVERT(nVarchar,DATEDIFF(mm,@givenDate,@curDate)) + N' tháng trước'
 --   --WHEN DATEDIFF(yy,@givenDate,@curDate) <= 1 THEN CONVERT(nVarchar,DATEDIFF(yy,@givenDate,@curDate)) + N' năm trước'
 --   --WHEN DATEDIFF(yy,@givenDate,@curDate) > 1 THEN CONVERT(nVarchar,DATEDIFF(yy,@givenDate,@curDate)) + N' năm trước'
	--ELSE convert(nvarchar(100),@givenDate,105) + case when convert(nvarchar(5),@givenDate,108) = '00:00' then '' else ' ' + convert(nvarchar(5),@givenDate,108) end
  END
  RETURN @Date
END