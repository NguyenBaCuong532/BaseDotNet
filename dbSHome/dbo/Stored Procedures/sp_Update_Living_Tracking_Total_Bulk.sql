CREATE PROCEDURE [dbo].[sp_Update_Living_Tracking_Total_Bulk]
    @LivingType INT = 1,
    @PeriodMonth INT = 8,
    @PeriodYear INT = 2025,
    @ProjectCd NVARCHAR(30) = '01'
AS
BEGIN
    IF OBJECT_ID('tempdb..#TrackingDiscount') IS NOT NULL DROP TABLE #TrackingDiscount;

    CREATE TABLE #TrackingDiscount (
        TrackingId INT PRIMARY KEY,
        DiscountRate DECIMAL(5,2)
    );

    INSERT INTO #TrackingDiscount (TrackingId, DiscountRate)
    SELECT 
        b.TrackingId,
        CASE
            WHEN @LivingType = 1 THEN
                CASE ISNULL(mp.type_discount_elec, 0)
                    WHEN 1 THEN 0.1
                    WHEN 2 THEN
                        CASE WHEN SUM(cs.Quantity) > 200 THEN 0.1 ELSE 0.15 END
                    ELSE 0
                END
            WHEN @LivingType = 2 THEN
                CASE ISNULL(mp.type_discount_water, 0)
                    WHEN 1 THEN 0.15 ELSE 0
                END
            ELSE 0
        END AS DiscountRate
    FROM MAS_Service_Living_Tracking b
    JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd
    LEFT JOIN MAS_Service_Living_CalSheet cs ON b.TrackingId = cs.TrackingId
    JOIN MAS_Apartments d ON b.ApartmentId = d.ApartmentId
    WHERE b.LivingTypeId = @LivingType
      AND MONTH(b.ToDt) = @PeriodMonth
      AND YEAR(b.ToDt) = @PeriodYear
      AND d.ProjectCd = @ProjectCd
      AND IsReceivable = 0
      AND NOT EXISTS (
          SELECT 1 
          FROM MAS_Service_ReceiveEntry r 
          WHERE r.ApartmentId = b.ApartmentId 
          AND MONTH(r.ToDt) = @PeriodMonth 
          AND YEAR(r.ToDt) = @PeriodYear 
          AND r.IsBill = 1
      )
    GROUP BY b.TrackingId, mp.type_discount_elec, mp.type_discount_water;

    UPDATE b
    SET 
        b.IsCalculate = 1,
        b.Amount = cs.TotalAmount * (1 - ISNULL(td.DiscountRate, 0)),
        b.FreeAmt = cs.TotalFreeAmt,
        b.DiscountAmt = cs.TotalAmount * ISNULL(td.DiscountRate, 0),
		b.VatAmt = cs.TotalVat
    FROM MAS_Service_Living_Tracking b
    JOIN (
        SELECT TrackingId, SUM(Amount) AS TotalAmount, SUM(ISNULL(FreeAmt, 0)) AS TotalFreeAmt, SUM(ISNULL(VatAmt,0)) as TotalVat
        FROM MAS_Service_Living_CalSheet
        GROUP BY TrackingId
    ) cs ON b.TrackingId = cs.TrackingId
    JOIN #TrackingDiscount td ON b.TrackingId = td.TrackingId
    JOIN MAS_Apartments d ON b.ApartmentId = d.ApartmentId
    WHERE b.LivingTypeId = @LivingType
      AND MONTH(b.ToDt) = @PeriodMonth
      AND YEAR(b.ToDt) = @PeriodYear
      AND d.ProjectCd = @ProjectCd
      AND IsReceivable = 0;
END;