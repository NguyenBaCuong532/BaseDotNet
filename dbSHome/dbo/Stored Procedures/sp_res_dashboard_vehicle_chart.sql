
CREATE PROCEDURE [dbo].[sp_res_dashboard_vehicle_chart]
    @ProjectCd NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    
    ;WITH VehicleStats AS (
        SELECT 
            SUM(CASE WHEN c.IsVip = 0 AND c.IsGuest = 0 AND c.partner_id IS NULL THEN 1 ELSE 0 END) AS ResidentVehicles,
            SUM(CASE WHEN c.IsVip = 1 THEN 1 ELSE 0 END) AS InternalVehicles,
            SUM(CASE WHEN c.partner_id IS NOT NULL THEN 1 ELSE 0 END) AS PartnerVehicles
        FROM MAS_CardVehicle cv WITH (NOLOCK)
        INNER JOIN MAS_Cards c WITH (NOLOCK) ON cv.CardId = c.CardId
        WHERE c.ProjectCd = @ProjectCd AND cv.Status != 3
    )
    SELECT Name, Value, Color
    FROM (
        SELECT N'Xe cư dân' AS Name, ResidentVehicles AS Value, '#0091FF' AS Color, 1 AS SortOrder FROM VehicleStats
        UNION ALL
        SELECT N'Xe nội bộ', InternalVehicles, '#F76808', 2 FROM VehicleStats
        UNION ALL
        SELECT N'Xe đối tác', PartnerVehicles, '#10B981', 3 FROM VehicleStats
    ) AS ChartData
    ORDER BY SortOrder;
END