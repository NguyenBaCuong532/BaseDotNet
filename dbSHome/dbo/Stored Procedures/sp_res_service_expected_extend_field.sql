-- =============================================
-- Author:      ThanhMT
-- Create date: 18/11/2025
-- Description: Khóa thẻ xe cư dân - Lấy thông tin thêm mới hoặc chỉnh sửa
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_expected_extend_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @receiveId INT,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'common_group' -- 'config_sp_res_service_expected_extend_field_group';--sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'config_sp_res_service_expected_extend_field';--sys_config_form

    -- Config Info
    SELECT
        @TableName AS tableKey,
        @GroupKey AS groupKey
		
    -- Get Group Info
    SELECT * FROM [dbo].[fn_get_field_group](@GroupKey) ORDER by intOrder
	
    -- Fields Info
    SELECT
        CASE [data_type]
            WHEN 'int' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'ReceiveId' THEN @receiveId
            END)
            WHEN 'bit' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'IsRefundCustomer' THEN 'true'
            END)
            WHEN 'decimal' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'Amount' THEN 0
                    WHEN 'VatAmt' THEN 0
            END)
            WHEN 'date' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'ToDt' THEN EOMONTH(GETDATE(), 0)
            END)
            WHEN 'nvarchar' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'ServiceObject' THEN N'Hoàn tiền thanh toán thừa từ dịch vụ ....'
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
    FROM dbo.[fn_config_form_gets](@TableName, @AcceptLanguage) a
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