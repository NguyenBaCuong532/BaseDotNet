-- =============================================
-- Author:      ThanhMT
-- Create date: 19/11/2025
-- Description: Kỳ hóa đơn - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_mas_invoice_periods_page]
    @UserId UNIQUEIDENTIFIER = null,
    @project_code NVARCHAR(50) = NULL,
    @from_month NVARCHAR(50) = NULL,
    @to_month NVARCHAR(50) = NULL,
    @ClientId nvarchar(50) = null,
    @Filter nvarchar(150) = NULL,
    @GridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @AcceptLanguage nvarchar(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @ViewGrid NVARCHAR(100) = 'config_sp_res_mas_invoice_periods_page';--sys_config_list
    SET @OffSet = ISNULL(@OffSet, 0);
    SET @PageSize = ISNULL(@PageSize, 20);
    SET @Filter = ISNULL(@Filter, '');

    SELECT a.*
    INTO #mas_invoice_periods
    FROM mas_invoice_periods a
    -- WHERE
    -- 	(@Filter = '' OR (@Filter <> '' AND (a.Name LIKE N'%'+@Filter+'%')))
		
    SELECT *
    INTO #mas_invoice_periods_page
    FROM #mas_invoice_periods
    ORDER BY created_date DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
	
    SELECT
        RecordsTotal = (SELECT COUNT(*) FROM #mas_invoice_periods),
        RecordsFiltered = (SELECT COUNT(*) FROM #mas_invoice_periods_page),
        GridKey = @ViewGrid
	
    SELECT*FROM dbo.fn_config_list_gets_lang(@ViewGrid, @gridWidth, @AcceptLanguage) ORDER BY ordinal;
	
    SELECT
        a.*,
        revenue_periods_status = CASE WHEN b.locked = 1 THEN N'<span class="bg-success noti-number ml5">Đã khóa</span>' ELSE N'<span class="bg-secondary noti-number ml5">Đang thực hiện</span>' END,
        revenue_periods_code = b.period_code,
        revenue_periods_name = b.period_name,
        from_date = FORMAT(b.start_date, 'dd/MM/yyyy'),
        to_date = FORMAT(b.end_date, 'dd/MM/yyyy')
    FROM
        #mas_invoice_periods_page a
        LEFT JOIN mas_revenue_periods b ON a.revenue_periods_oid = b.oid

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH