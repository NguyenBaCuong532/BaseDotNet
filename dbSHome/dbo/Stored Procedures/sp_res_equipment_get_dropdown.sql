-- =============================================
-- Author:      Agent
-- Create date: 2026-01-30
-- Description: Get Equipment Dropdown List
-- =============================================
CREATE   PROCEDURE [dbo].[sp_res_equipment_get_dropdown]
    @keyword NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        CAST(oid AS NVARCHAR(50)) as [Value],
        equipment_name + ' (' + equipment_code + ')' as [Label]
    FROM maintenance_equipment
    WHERE is_deleted = 0
    AND (@keyword IS NULL OR equipment_name LIKE N'%' + @keyword + N'%' OR equipment_code LIKE N'%' + @keyword + N'%')
    AND status = 0 -- Only active equipment
    ORDER BY equipment_name;
END