-- =============================================
-- Author:      ThanhMT
-- Create date: 29/08/2025
-- Description: Cấu hình giá dịch vụ - Nước - Chi tiết - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_water_detail_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid UNIQUEIDENTIFIER = NULL,
    @par_water_oid UNIQUEIDENTIFIER = NULL,
    @par_service_price_type_oid UNIQUEIDENTIFIER = NULL,
    @config_name NVARCHAR(100) = NULL,
    @start_value DECIMAL(18, 0) = NULL,
    @end_value DECIMAL(18, 0) = NULL,
    @unit_price DECIMAL(18, 0) = NULL,
    @sort_order INT = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'config_sp_res_service_price_water_detail_field_group';--sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'config_sp_res_service_price_water_detail_field';--sys_config_form

    -- Config Info
    SELECT 
        CONVERT(UNIQUEIDENTIFIER, @oid) as gd,
        @TableName AS tableKey,
        @GroupKey AS groupKey
		
    -- Get Group Info
    SELECT * FROM [dbo].[fn_get_field_group](@GroupKey) ORDER by intOrder
	
    DECLARE @max_sort_order INT;
    
    SELECT TOP 1 @max_sort_order = (ISNULL(b.sort_order, 0) + 1)
    FROM
        par_water a
        INNER JOIN par_water_detail b ON a.oid = b.par_water_oid
    WHERE
        a.project_code = @project_code
        AND a.oid = @par_water_oid
    ORDER BY sort_order DESC;
    
    -- Fields Info
    SELECT
        CASE [data_type]
             WHEN 'uniqueidentifier'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'oid' THEN b.oid
                        WHEN 'par_water_oid' THEN ISNULL(@par_water_oid, b.par_water_oid)
                        WHEN 'par_service_price_type_oid' THEN ISNULL(@par_service_price_type_oid, w.par_service_price_type_oid)
                    END)
             WHEN 'nvarchar'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'config_name' THEN ISNULL(@config_name, b.config_name)
                    END)
             WHEN 'decimal'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'start_value' THEN IIF(c.is_step_price = 1, NULL, ISNULL(@start_value, b.start_value))
                        WHEN 'end_value' THEN IIF(c.is_step_price = 1, NULL, ISNULL(@end_value, b.end_value))
                        WHEN 'unit_price' THEN ISNULL(@unit_price, b.unit_price)
                    END)
            WHEN 'int'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'sort_order' THEN ISNULL(@sort_order, ISNULL(b.sort_order, @max_sort_order))
                    END)
        END AS columnValue,
        [field_name],
        [view_type],
        [data_type],
        [ordinal],
        [columnLabel] = case when @acceptLanguage = 'en' then [columnLabel] else [columnLabel] end,
        group_cd,
        [columnClass],
        [columnType],
        [columnObject],
        [isSpecial],
        [isRequire],
        [isDisable],
        [IsVisiable] = CASE WHEN c.is_step_price <> 1 AND [field_name] IN('start_value', 'end_value') THEN 0 ELSE [IsVisiable] END,
        [IsEmpty],
        isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip,
        [columnDisplay],
        [isIgnore]
        --[maxLength],
        --[table_relation]
    FROM
        dbo.[fn_config_form_gets](@TableName, @AcceptLanguage) a
        OUTER APPLY (SELECT TOP 1 * FROM par_water_detail d WHERE oid = @oid) b
        LEFT JOIN par_water w ON w.oid = b.par_water_oid
        LEFT JOIN par_service_price_type c ON c.oid = ISNULL(w.par_service_price_type_oid, @par_service_price_type_oid)
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