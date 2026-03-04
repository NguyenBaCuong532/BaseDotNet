-- =============================================
-- Author:      ThanhMT
-- Create date: 27/08/2025
-- Description: Cấu hình giá dịch vụ - Gửi xe tháng - chi tiết - Lấy thông tin thêm mới hoặc chỉnh sửa
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_vehicle_detail_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @vehicle_oid uniqueidentifier = NULL,
    @oid uniqueidentifier = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'config_sp_res_service_price_vehicle_detail_field_group';--sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'config_sp_res_service_price_vehicle_detail_field';--sys_config_form

    -- Config Info
    SELECT 
        CONVERT(UNIQUEIDENTIFIER, @oid) as gd,
        @TableName AS tableKey,
        @GroupKey AS groupKey
		
    -- Get Group Info
    SELECT * FROM [dbo].[fn_get_field_group](@GroupKey) ORDER by intOrder
    
    DECLARE @max_sort_order INT = (SELECT TOP 1 sort_order
                                  FROM par_vehicle_detail
                                  WHERE par_vehicle_oid = @vehicle_oid
                                  ORDER BY sort_order DESC);
    SET @max_sort_order = (ISNULL(@max_sort_order, 0) + 1);
	
    -- Fields Info
    SELECT
        CASE [data_type]
            WHEN 'uniqueidentifier'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'oid' THEN b.oid
                        WHEN 'par_vehicle_type_oid' THEN b.par_vehicle_type_oid
                        WHEN 'par_vehicle_oid' THEN ISNULL(b.par_vehicle_oid, @vehicle_oid)
                    END)
             WHEN 'nvarchar'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'config_name' THEN b.config_name
                    END)
             WHEN 'decimal'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'start_value' THEN b.start_value
                        WHEN 'end_value' THEN b.end_value
                        WHEN 'unit_price' THEN b.unit_price
                    END)
            WHEN 'int'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'sort_order' THEN ISNULL(b.sort_order, @max_sort_order)
                    END)
        END AS columnValue,
        [field_name],
        [view_type],
        [data_type],
        [ordinal],
        [columnLabel], -- = case when @acceptLanguage = 'en' then [columnLabelE] else [columnLabel] end,
        group_cd,
        [columnClass],
        [columnType],
        [columnObject],
        [isSpecial],
        [isRequire],
        [isDisable],
        [IsVisiable],
        [IsEmpty],
        isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip,
        [columnDisplay],
        [isIgnore]
--         [maxLength],
--         [table_relation]
    FROM
        dbo.[fn_config_form_gets](@TableName, @AcceptLanguage) a
        OUTER APPLY (SELECT TOP 1 * FROM par_vehicle_detail d WHERE oid = @oid) b
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