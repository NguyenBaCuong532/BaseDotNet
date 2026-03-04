-- =============================================
-- Author:      ThanhMT
-- Create date: 19/08/2025
-- Description: Cấu hình giá dịch vụ chung - Lấy thông tin thêm mới hoặc chỉnh sửa
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_common_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'config_sp_res_service_price_common_field_group';--sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'config_sp_res_service_price_common_field';--sys_config_form

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
                        WHEN 'Oid' THEN b.Oid
                        WHEN 'par_residence_type_oid' THEN b.par_residence_type_oid
                    END)
            WHEN 'nvarchar'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'project_code' THEN ISNULL(b.project_code, @project_code)
                        WHEN 'service_name' THEN b.service_name
                        WHEN 'unit_measure' THEN b.unit_measure
                        WHEN 'note' THEN b.note
                    END)
            WHEN 'number'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'value' THEN b.value
                        WHEN 'tax_percent' THEN b.tax_percent
                    END)
            WHEN 'datetime'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'effective_date' THEN FORMAT(b.effective_date, 'dd/MM/yyyy')
                        WHEN 'expiry_date' THEN FORMAT(b.expiry_date, 'dd/MM/yyyy')
                    END)
            WHEN 'bit'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'is_active' THEN IIF(b.is_active = 1, 'true', 'false')
                    END)
        END AS columnValue,
        [field_name],
        [view_type],
        [data_type],
        [ordinal],
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
    FROM
        dbo.[fn_config_form_gets](@TableName, @AcceptLanguage) a
        OUTER APPLY (SELECT TOP 1 * FROM par_common d WHERE Oid = @oid) b
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