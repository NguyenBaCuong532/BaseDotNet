-- =============================================
-- Author:      ThanhMT
-- Create date: 19/11/2025
-- Description: Kỳ hóa đơn - Lấy thông tin thêm mới hoặc chỉnh sửa
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_mas_invoice_periods_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'common_group' -- 'config_sp_res_mas_invoice_periods_field_group';--sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'config_sp_res_mas_invoice_periods_field';--sys_config_form

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
                    WHEN 'name' THEN b.name
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
        [isDisable] = IIF(@oid IS NULL, 1, 0),
        [IsVisiable],
        [IsEmpty],
        isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip,
        [columnDisplay],
        [isIgnore]
    FROM
        dbo.[fn_config_form_gets](@TableName, @AcceptLanguage) a
        OUTER APPLY (SELECT TOP 1 * FROM mas_invoice_periods d WHERE oid = @oid) b
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