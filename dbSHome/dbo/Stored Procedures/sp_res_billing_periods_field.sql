-- =============================================
-- Author:      ThanhMT
-- Create date: 12/12/2025
-- Description: Kỳ thanh toán (dự thu/hóađơn) - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_billing_periods_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN',
    
    @period_code NVARCHAR(100) = NULL,
    @period_name NVARCHAR(100) = NULL,
    @reference_date NVARCHAR(50) = NULL,
    @start_date NVARCHAR(50) = NULL,
    @end_date NVARCHAR(50) = NULL,
    @note NVARCHAR(100) = NULL
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'common_group' -- sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'billing_periods_field';--sys_config_form
    
    IF(@period_code IS NULL OR TRIM(@period_code) = '')
        EXEC dbo.sp_res_billing_periods_get_new_code @period_code OUTPUT;
        
    IF(@reference_date IS NOT NULL AND TRIM(@reference_date) <> '')
    BEGIN
--         IF(@start_date IS NULL OR TRIM(@start_date) = '')
            SET @start_date = CONCAT('01/', @reference_date)
            
--         IF(@end_date IS NULL OR TRIM(@end_date) = '')
        BEGIN
            DECLARE @start_date_value DATE = CONVERT(DATE, @start_date, 103);
            DECLARE @end_date_value DATE = EOMONTH(@start_date_value, 0);
            SET @end_date = FORMAT(@end_date_value, 'dd/MM/yyyy');
        END
        
--         IF(@period_name IS NULL OR TRIM(@period_name) = '')
            SET @period_name = CONCAT(N'Kỳ thanh toán tháng ', @reference_date);
    END
    
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
                    WHEN 'period_code' THEN ISNULL(@period_code, b.period_code)
                    WHEN 'period_name' THEN ISNULL(@period_name, b.period_name)
                    WHEN 'reference_date' THEN ISNULL(@reference_date, FORMAT(b.reference_date, 'dd/MM/yyyy'))
                    WHEN 'start_date' THEN ISNULL(@start_date, FORMAT(b.start_date, 'dd/MM/yyyy'))
                    WHEN 'end_date' THEN ISNULL(@end_date, FORMAT(b.end_date, 'dd/MM/yyyy'))
                    WHEN 'note' THEN ISNULL(@note, b.note)
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
        OUTER APPLY (SELECT TOP 1 * FROM mas_billing_periods d WHERE oid = @oid) b
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