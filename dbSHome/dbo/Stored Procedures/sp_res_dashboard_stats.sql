
CREATE PROCEDURE [dbo].[sp_res_dashboard_stats]
    @ProjectCd NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentMonthStart DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0);
    DECLARE @LastMonthStart DATE = DATEADD(MONTH, -1, @CurrentMonthStart);

    -- Result Set 1: Apartment Stats (Single table scan with conditional aggregation)
    ;WITH ProjectApartments AS (
        SELECT a.ApartmentId, a.IsReceived, a.IsRent
        FROM MAS_Apartments a 
        LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
        WHERE b.ProjectCd = @ProjectCd
    ),
    TransferredApartments AS (
        SELECT COUNT(DISTINCT h.ApartmentId) AS TransferredCount
        FROM MAS_Apartment_HostChange_History h
        WHERE EXISTS (
            SELECT 1 FROM MAS_Apartments a 
            LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
            WHERE h.ApartmentId = a.ApartmentId AND b.ProjectCd = @ProjectCd
        )
    )
    SELECT 
        COUNT(*) AS Total,
        SUM(CASE WHEN IsReceived = 1 THEN 1 ELSE 0 END) AS Received,
        SUM(CASE WHEN IsReceived = 0 OR IsReceived IS NULL THEN 1 ELSE 0 END) AS Empty,
        SUM(CASE WHEN IsRent = 1 THEN 1 ELSE 0 END) AS Rented,
        (SELECT TransferredCount FROM TransferredApartments) AS Transferred,
        CAST(0 AS DECIMAL(10,2)) AS Trend
    FROM ProjectApartments;

    -- Result Set 2: Card Stats (Single table scan with conditional aggregation)
    SELECT 
        COUNT(*) AS Total,
        SUM(CASE WHEN Card_St = 0 AND CustId IS NOT NULL THEN 1 ELSE 0 END) AS Active,
        SUM(CASE WHEN CustId IS NULL THEN 1 ELSE 0 END) AS Unassigned,
        SUM(CASE WHEN IsVip = 1 THEN 1 ELSE 0 END) AS Internal,
        SUM(CASE WHEN partner_id IS NOT NULL THEN 1 ELSE 0 END) AS Partner,
        CAST(0 AS DECIMAL(10,2)) AS Trend
    FROM MAS_Cards 
    WHERE ProjectCd = @ProjectCd;

    -- Result Set 3: Vehicle Stats (Single join with conditional aggregation)
    SELECT 
        COUNT(*) AS Total,
        SUM(CASE WHEN cv.monthlyType IS NOT NULL THEN 1 ELSE 0 END) AS Monthly,
        SUM(CASE WHEN c.IsGuest = 1 THEN 1 ELSE 0 END) AS Visitor,
        SUM(CASE WHEN c.IsVip = 1 THEN 1 ELSE 0 END) AS Internal,
        SUM(CASE WHEN c.StarLevel > 0 THEN 1 ELSE 0 END) AS VIP,
        CAST(0 AS DECIMAL(10,2)) AS Trend
    FROM MAS_CardVehicle cv
    INNER JOIN MAS_Cards c ON cv.CardId = c.CardId
    WHERE c.ProjectCd = @ProjectCd AND cv.Status != 3;

    -- Result Set 4: Partner Stats (Optimized with single scan)
    ;WITH PartnerData AS (
        SELECT 
            (SELECT COUNT(*) FROM MAS_CardPartner WHERE projectCd = @ProjectCd) AS Total,
            (SELECT COUNT(DISTINCT partner_id) FROM MAS_Cards 
             WHERE ProjectCd = @ProjectCd AND partner_id IS NOT NULL AND Card_St = 0) AS Active
    )
    SELECT 
        Total,
        Active,
        CAST(0 AS INT) AS Suspended,
        CAST(0 AS INT) AS Terminated,
        CAST(0 AS DECIMAL(10,2)) AS Trend
    FROM PartnerData;

    -- Result Set 5: Revenue Stats (Single table scan with conditional aggregation)
    SELECT 
        ISNULL(SUM(CASE WHEN ReceiveDt >= @CurrentMonthStart THEN TotalAmt ELSE 0 END), 0) AS ThisMonth,
        ISNULL(SUM(CASE WHEN ReceiveDt >= @LastMonthStart AND ReceiveDt < @CurrentMonthStart THEN TotalAmt ELSE 0 END), 0) AS LastMonth,
        CAST(0 AS DECIMAL(10,2)) AS Growth
    FROM MAS_Service_ReceiveEntry 
    WHERE ProjectCd = @ProjectCd 
      AND IsPayed = 1 
      AND ReceiveDt >= @LastMonthStart;

    -- Result Set 6: Pending Counts (Using EXISTS for better performance)
    ;WITH ProjectApartmentIds AS (
        SELECT a.ApartmentId
        FROM MAS_Apartments a 
        LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
        WHERE b.ProjectCd = @ProjectCd
    )
    SELECT 
        (SELECT COUNT(*) FROM MAS_Requests r 
         WHERE r.Status IN (0, 1) 
           AND EXISTS (SELECT 1 FROM ProjectApartmentIds p WHERE p.ApartmentId = r.ApartmentId)) AS PendingRequests,
        (SELECT COUNT(*) FROM MAS_Feedbacks f 
         WHERE f.Status IN (0, 1) 
           AND EXISTS (SELECT 1 FROM ProjectApartmentIds p WHERE p.ApartmentId = f.ApartmentId)) AS PendingFeedback;
END