
-- 7. SP CATEGORY Filter
CREATE   PROCEDURE [dbo].[elevator_device_category_filter]
AS
BEGIN
    SET NOCOUNT ON;
    EXEC sp_res_common_table_filter_get @table_key = 'MAS_Elevator_Device_Category';
END