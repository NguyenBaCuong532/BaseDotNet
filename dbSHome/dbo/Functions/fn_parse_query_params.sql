-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	parse query params
-- Output: form configuration
-- =============================================
CREATE FUNCTION [dbo].[fn_parse_query_params] (@qs NVARCHAR(4000))
RETURNS TABLE
AS
RETURN (
        WITH query_string AS (
                SELECT RIGHT(@qs, LEN(@qs) - CHARINDEX('?', @qs)) AS qs -- get part after "?"
                )
            , cte AS (
                SELECT LTRIM(RTRIM(value)) AS value
                FROM query_string
                CROSS APPLY STRING_SPLIT(qs, '&')
                )
        SELECT CASE 
                WHEN CHARINDEX('=', value) > 0
                    THEN LEFT(value, CHARINDEX('=', value) - 1)
                ELSE value
                END AS [Key]
            , CASE 
                WHEN CHARINDEX('=', value) > 0
                    THEN SUBSTRING(value, CHARINDEX('=', value) + 1, LEN(value))
                ELSE NULL
                END AS [Value]
        FROM cte
        );