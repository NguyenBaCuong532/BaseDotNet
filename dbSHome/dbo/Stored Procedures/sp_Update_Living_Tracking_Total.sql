CREATE PROCEDURE [dbo].[sp_Update_Living_Tracking_Total]
    @TrackingId INT,
    @LivingType INT
AS
BEGIN
    DECLARE @DiscountRate DECIMAL(5,2) = 0;

    SELECT @DiscountRate =
        CASE
            WHEN @LivingType = 1 THEN
                CASE ISNULL(mp.type_discount_elec, 0)
                    WHEN 1 THEN 0.1
                    WHEN 2 THEN
                        CASE
                            WHEN (
                                SELECT SUM(Quantity)
                                FROM MAS_Service_Living_CalSheet
                                WHERE TrackingId = b.TrackingId
                            ) > 200 THEN 0.1 ELSE 0.15
                        END
                    ELSE 0
                END
            WHEN @LivingType = 2 THEN
                CASE ISNULL(mp.type_discount_water, 0)
                    WHEN 1 THEN 0.15 ELSE 0
                END
            ELSE 0
        END
    FROM MAS_Service_Living_Tracking b
    JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd
    WHERE b.TrackingId = @TrackingId;

    IF EXISTS (
        SELECT 1
        FROM MAS_Service_Living_Tracking t
        JOIN MAS_Service_ReceiveEntry r ON t.ApartmentId = r.ApartmentId
        WHERE t.TrackingId = @TrackingId
        AND MONTH(t.ToDt) = MONTH(r.ToDt) AND YEAR(t.ToDt) = YEAR(r.ToDt)
        AND r.IsBill = 1
    )
    BEGIN
        RETURN;
    END

    UPDATE b
    SET IsCalculate = 1,
        Amount = cs.TotalAmount * (1 - @DiscountRate),
        FreeAmt = cs.TotalFreeAmt,
        DiscountAmt = cs.TotalAmount * @DiscountRate,
		VatAmt = cs.TotalVat
    FROM MAS_Service_Living_Tracking b
    JOIN (
        SELECT TrackingId, SUM(Amount) AS TotalAmount, SUM(ISNULL(FreeAmt, 0)) AS TotalFreeAmt, SUM(ISNULL(VatAmt,0)) as TotalVat
        FROM MAS_Service_Living_CalSheet
        WHERE TrackingId = @TrackingId
        GROUP BY TrackingId
    ) cs ON b.TrackingId = cs.TrackingId;
END;