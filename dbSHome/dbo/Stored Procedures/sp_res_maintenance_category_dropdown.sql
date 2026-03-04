
-- =============================================
-- Author:      Agent
-- Create date: 2026-01-30
-- Description: Get Maintenance Category Dropdown
-- =============================================
CREATE   PROCEDURE [dbo].[sp_res_maintenance_category_dropdown]
    @base_type INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        categoryCd as [Value],
        categoryName as [Label]
    FROM MAS_Category
    WHERE base_type = @base_type
      AND isActive = 1
    ORDER BY intOrder;
END