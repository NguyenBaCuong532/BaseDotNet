-- =============================================
-- Author:      ThanhMT
-- Create date: 12/12/2025
-- Description: Kỳ thanh toán (dự thu/hóađơn) - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_billing_periods_page]
    @UserId UNIQUEIDENTIFIER = null,
    @project_code NVARCHAR(50) = NULL,
    @reference_date NVARCHAR(50) = NULL,
    @status INT = NULL,
    @ClientId nvarchar(50) = null,
    @Filter nvarchar(150) = NULL,
    @GridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @AcceptLanguage nvarchar(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @ViewGrid NVARCHAR(100) = 'billing_periods_page';--sys_config_list
    SET @OffSet = ISNULL(@OffSet, 0);
    SET @PageSize = ISNULL(@PageSize, 20);
    SET @Filter = ISNULL(@Filter, '');
    
    DECLARE @reference_date_value DATE;
    IF(@reference_date IS NOT NULL AND TRIM(@reference_date) <> '')
        SET @reference_date_value = CONVERT(DATE, @reference_date, 103);
        
    SELECT a.*
    INTO #mas_billing_periods
    FROM mas_billing_periods a
    WHERE
        a.project_code = @project_code
        AND (@Filter = '' OR (@Filter <> '' AND (a.period_code LIKE N'%'+@Filter+'%' OR a.period_name LIKE N'%'+@Filter+'%')))
        AND (@status IS NULL OR a.status = @status)
        AND (@reference_date_value IS NULL OR a.reference_date = @reference_date_value)
		
    SELECT *
    INTO #mas_billing_periods_page
    FROM #mas_billing_periods
    ORDER BY reference_date DESC, created_date DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
	
    SELECT
        RecordsTotal = (SELECT COUNT(*) FROM #mas_billing_periods),
        RecordsFiltered = (SELECT COUNT(*) FROM #mas_billing_periods_page),
        GridKey = @ViewGrid
	
    IF(@OffSet <= 0)
        SELECT*FROM dbo.fn_config_list_gets_lang(@ViewGrid, @gridWidth, @AcceptLanguage) ORDER BY ordinal;
	
    SELECT
        a.oid,
        order_numbers = ROW_NUMBER() OVER (ORDER BY a.reference_date DESC, a.created_date DESC) + @OffSet,
        a.period_code,
        a.period_name,
        a.locked,
        reference_date = FORMAT(a.reference_date, 'MM/yyyy'),
        start_date = FORMAT(a.start_date, 'dd/MM/yyyy'),
        end_date = FORMAT(a.end_date, 'dd/MM/yyyy'),
        created_date = FORMAT(a.created_date, 'dd/MM/yyyy HH:mm'),
        status_name = CONCAT(N'<span class="', b.class_name, ' noti-number ml5">', b.name, '</span>')
    FROM
        #mas_billing_periods_page a
        LEFT JOIN par_billing_periods_status b ON IIF(a.locked = 1, 3, a.status) = b.code
    ORDER BY reference_date DESC, created_date DESC

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH