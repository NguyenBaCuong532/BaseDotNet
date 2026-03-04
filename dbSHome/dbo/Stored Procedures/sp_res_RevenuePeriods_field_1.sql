-- =============================================
-- Author:      ThanhMT
-- Create date: 20/10/2025
-- Description: Kỳ tính dự thu - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_RevenuePeriods_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid UNIQUEIDENTIFIER = NULL,
    @period_code NVARCHAR(100) = NULL,
    @period_name NVARCHAR(100) = NULL,
    @start_date NVARCHAR(50) = NULL,
    @end_date NVARCHAR(50) = NULL,
    @locked BIT = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'common_group' -- 'config_sp_res_RevenuePeriods_field_group';--sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'config_sp_res_RevenuePeriods_field';--sys_config_form
    
    DECLARE @period_code_default NVARCHAR(100) = FORMAT(GETDATE(), 'MM/yyyy');
    IF(@period_code IS NOT NULL AND trim(@period_code) <> '')
        SET @period_code_default = @period_code;
    
    DECLARE @StartMonth DATE = CONVERT(DATE, CONCAT('01/', @period_code_default), 103);
    DECLARE @EndMonth DATE = EOMONTH(@StartMonth, 0)
    
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
                        WHEN 'period_code' THEN CASE
                                                    WHEN b.period_code IS NULL AND @period_code IS NULL THEN @period_code_default
                                                    WHEN @period_code IS NOT NULL THEN @period_code
                                                    ELSE b.period_code
                                                END
                        WHEN 'period_name' THEN ISNULL(b.period_name, CONCAT(N'Kỳ dự thu tháng ', FORMAT(@StartMonth, 'MM/yyyy')))
                    END)
            WHEN 'bit'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'locked' THEN IIF(b.locked = 1, 'true', 'false')
                    END)
            WHEN 'datetime'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'start_date' THEN FORMAT(IIF(@oid IS NULL, @StartMonth, b.start_date), 'dd/MM/yyyy')
                        WHEN 'end_date' THEN FORMAT(IIF(@oid IS NULL, @EndMonth, b.end_date), 'dd/MM/yyyy')
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
        [isDisable] = IIF(b.locked = 1, 1, [isDisable]),
        [IsVisiable],
        [IsEmpty],
        isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip,
        [columnDisplay],
        [isIgnore]
    FROM
        dbo.[fn_config_form_gets](@TableName, @AcceptLanguage) a
        OUTER APPLY(SELECT TOP 1 * FROM mas_revenue_periods d WHERE oid = @oid) b
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