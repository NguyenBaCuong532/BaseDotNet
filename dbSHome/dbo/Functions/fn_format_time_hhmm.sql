CREATE FUNCTION fn_format_time_hhmm (@time TIME)
RETURNS NVARCHAR(5)
AS
BEGIN
    RETURN FORMAT(@time, 'hh\:mm');
END