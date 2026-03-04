-- =============================================
-- Author:      ThanhMT
-- Create date: 22/10/2025
-- Description: Cấu hình chung cho dự án - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_ProjectConfig_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'common_group' -- 'config_sp_res_ProjectConfig_field_group';--sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'config_sp_res_ProjectConfig_field';--sys_config_form
    SELECT TOP 1
        @TableName = CASE [config_type]
                          WHEN 'file' THEN N'config_sp_res_ProjectConfig_file_field'
                          WHEN 'notify' THEN N'config_sp_res_ProjectConfig_notify_field'
                     END
    FROM par_project_config
    WHERE oid = @oid

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
            WHEN 'uniqueidentifier' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'oid' THEN b.oid
                END)
            WHEN 'nvarchar' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'config_value_default' THEN b.config_value_default
                    WHEN 'config_value' THEN IIF(TRIM(ISNULL(b.config_value, '')) = '', b.config_value_default, b.config_value)
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
        [columnObject] = CASE
                              WHEN b.config_type = 'file' AND a.field_name = 'config_value_default' THEN CONCAT([columnObject], b.config_value_default)
                              WHEN b.config_type = 'file' AND a.field_name = 'config_value' THEN CONCAT([columnObject], b.config_value)
                              ELSE [columnObject]
                         END,
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
        OUTER APPLY (SELECT TOP 1 * FROM par_project_config d WHERE oid = @oid) b
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