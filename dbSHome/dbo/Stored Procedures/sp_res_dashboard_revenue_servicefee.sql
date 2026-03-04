
CREATE PROCEDURE [dbo].[sp_res_dashboard_revenue_servicefee]
    @ProjectCd NVARCHAR(30),
    @Year INT = NULL,
    @DataType NVARCHAR(20) = 'all'
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @Year IS NULL
        SET @Year = YEAR(GETDATE());

    DECLARE @YearStart DATE = DATEFROMPARTS(@Year, 1, 1);
    DECLARE @YearEnd DATE = DATEFROMPARTS(@Year, 12, 31);

    ;WITH Months AS (
         SELECT MonthNumber = 1
        , [Month] = CONVERT(NVARCHAR(3), N'T1')
    
    UNION ALL
    SELECT MonthNumber = MonthNumber + 1
        , [Month] = N'T'+ CAST(MonthNumber + 1 AS NVARCHAR(2))
    FROM Months
    WHERE MonthNumber < 12
    ),
    RevenueData AS (
        SELECT 
            MONTH(ReceiveDt) AS MonthNum,
            SUM(ISNULL(TotalAmt, 0)) / 1000000.0 AS Revenue,
            SUM(ISNULL(LivingAmt, 0)) / 1000000.0 AS ServiceFee
        FROM MAS_Service_ReceiveEntry WITH (NOLOCK)
        WHERE ProjectCd = @ProjectCd 
          AND ReceiveDt >= @YearStart 
          AND ReceiveDt <= @YearEnd
          AND IsPayed = 1
        GROUP BY MONTH(ReceiveDt)
    )
    SELECT 
        m.Month,
        m.MonthNumber,
        CAST(ISNULL(r.Revenue, 0) AS DECIMAL(18,2)) AS Revenue,
        CAST(ISNULL(r.ServiceFee, 0) AS DECIMAL(18,2)) AS ServiceFee
    FROM Months m
    LEFT JOIN RevenueData r ON m.MonthNumber = r.MonthNum
    ORDER BY m.MonthNumber
    OPTION (MAXRECURSION 12);
END