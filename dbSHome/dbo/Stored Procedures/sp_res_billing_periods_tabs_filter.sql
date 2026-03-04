-- =============================================
-- Author:      ThanhMT
-- Create date: 09/01/2026
-- Description: Kỳ thanh toán - Hóa đơn - Lấy thông tin thêm mới hoặc chỉnh sửa
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_billing_periods_tabs_filter]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'common_group' -- sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'billing_periods_tabs_filter';--sys_config_form

    -- Config Info
    SELECT 
        CONVERT(UNIQUEIDENTIFIER, @oid) as gd,
        @TableName AS tableKey,
        @GroupKey AS groupKey
		
    -- Get Group Info
    SELECT * FROM [dbo].[fn_get_field_group](@GroupKey) ORDER by intOrder
	
    -- Fields Info
    SELECT
        [columnValue] = b.code,
        [field_name],
        [view_type],
        [data_type],
        [ordinal],
        [columnLabel] = b.name,
        [group_cd],
        [columnClass],
        [columnType],
        [columnObject],
        [isSpecial],
        [isRequire],
        [isDisable],
        [IsVisiable],
        [IsEmpty],
        isnull(a.columnTooltip, a.[columnLabel]) as columnTooltip,
        [columnDisplay],
        [isIgnore]
    FROM
        par_billing_periods_status b
        LEFT JOIN dbo.[fn_config_form_gets](@TableName, @AcceptLanguage) a ON 1 = 1
    ORDER BY a.group_cd, a.ordinal, b.sort_order

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH