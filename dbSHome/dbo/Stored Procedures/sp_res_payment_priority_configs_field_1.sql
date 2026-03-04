-- =============================================
-- Author:      ThanhMT
-- Create date: 17/10/2025
-- Description: Cấu hình thứ tự ưu tiên thanh toán dịch vụ căn hộ - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_payment_priority_configs_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'common_group' -- 'config_sp_res_payment_priority_configs_field_group';--sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'config_sp_res_payment_priority_configs_field';--sys_config_form

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
                    END)
            WHEN 'nvarchar'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'ServiceTypeName' THEN c.ServiceTypeName
                    END)
             WHEN 'bit'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'is_collect_fee' THEN IIF(b.is_collect_fee = 1, 'true', 'false')
                    END)
            WHEN 'int'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'priority_order' THEN b.priority_order
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
        OUTER APPLY (SELECT TOP 1 * FROM mas_payment_priority_configs d WHERE oid = @oid) b
        LEFT JOIN MAS_ServiceTypes c ON c.ServiceTypeId = b.ServiceTypeId
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