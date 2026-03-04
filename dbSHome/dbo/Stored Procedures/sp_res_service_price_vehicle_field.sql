-- =============================================
-- Author:      ThanhMT
-- Create date: 22/08/2025
-- Description: Cấu hình giá dịch vụ - Gửi xe tháng - Lấy thông tin thêm mới hoặc chỉnh sửa
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_vehicle_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'config_sp_res_service_price_vehicle_field_group';--sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'config_sp_res_service_price_vehicle_field';--sys_config_form

    -- Config Info
    SELECT 
        CONVERT(UNIQUEIDENTIFIER, @oid) as gd,
        @TableName AS tableKey,
        @GroupKey AS groupKey
		
    -- Get Group Info
    SELECT * FROM [dbo].[fn_get_field_group](@GroupKey) ORDER by intOrder
	
    -- Fields Info
    SELECT
        CASE [data_type]
            WHEN 'uniqueidentifier'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'oid' THEN b.oid
                        WHEN 'par_residence_type_oid' THEN b.par_residence_type_oid
                    END)
            WHEN 'datetime'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'effective_date' THEN FORMAT(b.effective_date, 'dd/MM/yyyy')
                        WHEN 'expiry_date' THEN FORMAT(b.expiry_date, 'dd/MM/yyyy')
                    END)                    
            WHEN 'nvarchar'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'note' THEN b.note
                    END)
            WHEN 'int'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'register_value' THEN b.register_value
                        WHEN 'cancel_value' THEN b.cancel_value
                    END)
            WHEN 'bit'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'register_by_day' THEN CONVERT(NVARCHAR(10), ISNULL(b.register_by_day, 0))
                        WHEN 'cancel_by_day' THEN CONVERT(NVARCHAR(10), ISNULL(b.cancel_by_day, 0))
                        WHEN 'is_active' THEN IIF(b.is_active = 1, 'true', 'false')
                    END)
        END AS columnValue,
        [field_name],
        [view_type],
        [data_type],
        [ordinal],
--         [columnLabel] = case when @acceptLanguage = 'en' then [columnLabelE] else [columnLabel] end,
        [columnLabel],
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
        OUTER APPLY (SELECT TOP 1 * FROM par_vehicle d WHERE Oid = @oid) b
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