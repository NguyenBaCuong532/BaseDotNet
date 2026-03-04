-- =============================================
-- Author:      ThanhMT
-- Create date: 21/08/2025
-- Description: Cấu hình giá dịch vụ - Gửi xe ngày block - Lấy thông tin thêm mới hoặc chỉnh sửa
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_vehicle_daily_detail_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @VehicleDailyOid uniqueidentifier = NULL,
    @Oid uniqueidentifier = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'config_sp_res_service_price_vehicle_daily_detail_field_group';--sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'config_sp_res_service_price_vehicle_daily_detail_field';--sys_config_form

    -- Config Info
    SELECT 
        CONVERT(UNIQUEIDENTIFIER, @Oid) as gd,
        @TableName AS tableKey,
        @GroupKey AS groupKey
		
    -- Get Group Info
    SELECT * FROM [dbo].[fn_get_field_group](@GroupKey) ORDER by intOrder
    
    DECLARE @max_sort_order INT = (SELECT TOP 1 sort_order
                                  FROM par_vehicle_daily_detail
                                  WHERE par_vehicle_daily_oid = @VehicleDailyOid
                                  ORDER BY sort_order DESC);
    SET @max_sort_order = (ISNULL(@max_sort_order, 0) + 1);
	
    -- Fields Info
    SELECT
        CASE [data_type]
            WHEN 'uniqueidentifier'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'oid' THEN b.oid
                        WHEN 'par_vehicle_daily_oid' THEN ISNULL(b.par_vehicle_daily_oid, @VehicleDailyOid)
                        WHEN 'par_vehicle_daily_type_oid' THEN IIF(t.block_pricing <> 1, NULL, b.par_vehicle_daily_type_oid)
                    END)
             WHEN 'nvarchar'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'config_name' THEN b.config_name
                        WHEN 'note' THEN b.note
                    END)
             WHEN 'int'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'start_value' THEN b.start_value
                        WHEN 'end_value' THEN b.end_value
                        WHEN 'sort_order' THEN ISNULL(b.sort_order, @max_sort_order)
                    END)
            WHEN 'time'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'start_time' THEN CONVERT(VARCHAR(5), b.start_time, 108)
                        WHEN 'end_time' THEN CONVERT(VARCHAR(5), b.end_time, 108)
                    END)
            WHEN 'decimal'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'unit_price' THEN b.unit_price
                    END)
        END AS columnValue,
        [field_name],
        [view_type],
        [data_type],
        [ordinal],
        [columnLabel] = case when @acceptLanguage = 'en' then [columnLabelE] else [columnLabel] end,
        group_cd,
        [columnClass],
        [columnType],
        [columnObject],
        [isSpecial],
        [isRequire],
        [isDisable],
        [IsVisiable] = CASE
                          WHEN t.block_pricing = 1 AND [field_name] IN('start_time', 'end_time') THEN 0
                          WHEN t.block_pricing <> 1 AND [field_name] IN('start_value', 'end_value', 'par_vehicle_daily_type_oid') THEN 0
                          ELSE [IsVisiable]
                       END,
        [IsEmpty],
        isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip,
        [columnDisplay],
        [isIgnore],
        [maxLength],
        [table_relation]
    FROM
        dbo.[fn_config_from_gets](@TableName, @AcceptLanguage) a
        OUTER APPLY (SELECT TOP 1 * FROM par_vehicle_daily_detail d WHERE Oid = @Oid) b
        LEFT JOIN par_vehicle_daily d ON d.oid = ISNULL(b.par_vehicle_daily_oid, @VehicleDailyOid)
        LEFT JOIN par_vehicle_type t ON t.oid = d.par_vehicle_type_oid
    ORDER BY a.group_cd, a.ordinal

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH