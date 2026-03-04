
CREATE PROCEDURE [dbo].[sp_res_dashboard_apartment_chart]
    @ProjectCd NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    
    ;WITH ProjectApartments AS (
        SELECT a.ApartmentId, a.IsReceived, a.IsRent
        FROM MAS_Apartments a WITH (NOLOCK)
        LEFT JOIN MAS_Buildings b WITH (NOLOCK) ON a.buildingOid = b.oid
        WHERE b.ProjectCd = @ProjectCd
    ),
    AggregatedStats AS (
        SELECT 
            SUM(CASE WHEN IsReceived = 1 AND (IsRent = 0 OR IsRent IS NULL) THEN 1 ELSE 0 END) AS Received,
            SUM(CASE WHEN IsRent = 1 THEN 1 ELSE 0 END) AS Rented,
            SUM(CASE WHEN IsReceived = 0 OR IsReceived IS NULL THEN 1 ELSE 0 END) AS Empty
        FROM ProjectApartments
    ),
    TransferredCount AS (
        SELECT COUNT(DISTINCT h.ApartmentId) AS Transferred
        FROM MAS_Apartment_HostChange_History h WITH (NOLOCK)
        WHERE EXISTS (
            SELECT 1 FROM MAS_Apartments a 
            LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
            WHERE h.ApartmentId = a.ApartmentId AND b.ProjectCd = @ProjectCd
        )
    )
    SELECT Name, Value, Color
    FROM (
        SELECT N'Đã nhận' AS Name, s.Received AS Value, '#0091FF' AS Color, 1 AS SortOrder FROM AggregatedStats s
        UNION ALL
        SELECT N'Cho thuê', s.Rented, '#8B5CF6', 2 FROM AggregatedStats s
        UNION ALL
        SELECT N'Trống', s.Empty, '#F59E0B', 3 FROM AggregatedStats s
        UNION ALL
        SELECT N'Chuyển nhượng', t.Transferred, '#EC4899', 4 FROM TransferredCount t
    ) AS ChartData
    ORDER BY SortOrder;
END