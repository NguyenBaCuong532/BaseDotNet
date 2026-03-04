-- =============================================
-- Author:      ThanhMT
-- Create date: 20/10/2025
-- Description: Kỳ tính dự thu - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_RevenuePeriods_page]
    @UserId UNIQUEIDENTIFIER = null,
    @project_code NVARCHAR(50) = NULL,
    @ClientId nvarchar(50) = null,
    @Filter nvarchar(150) = NULL,
    @GridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @from_month NVARCHAR(50) = NULL,
    @to_month NVARCHAR(50) = NULL,
    @AcceptLanguage nvarchar(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @ViewGrid NVARCHAR(100) = 'config_sp_res_RevenuePeriods_page';--sys_config_list
    SET @OffSet = ISNULL(@OffSet, 0);
    SET @PageSize = ISNULL(@PageSize, 20);
    SET @Filter = ISNULL(@Filter, '');
    DECLARE @from_date DATETIME = CONVERT(DATE, @from_month, 103);
    DECLARE @to_date DATETIME = CONVERT(DATE, @to_month, 103);

    SELECT a.*
    INTO #mas_revenue_periods
    FROM mas_revenue_periods a
    WHERE
        (@Filter = '' OR (@Filter <> '' AND (a.period_code LIKE N'%'+@Filter+'%' OR a.period_name LIKE N'%'+@Filter+'%')))
        AND project_code = @project_code
        AND (@from_date IS NULL OR (start_date >= @from_date))
        AND (@to_date IS NULL OR (end_date <= @to_date))
		
    SELECT *
    INTO #mas_revenue_periods_page
    FROM #mas_revenue_periods
    ORDER BY created_date DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
	
    SELECT
        RecordsTotal = (SELECT COUNT(*) FROM #mas_revenue_periods),
        RecordsFiltered = (SELECT COUNT(*) FROM #mas_revenue_periods_page),
        GridKey = @ViewGrid
	
    SELECT*FROM dbo.fn_config_list_gets_lang(@ViewGrid, @gridWidth, @AcceptLanguage) ORDER BY ordinal;
	
    SELECT
        *,
        str_start_date = FORMAT(start_date, 'dd/MM/yyyy'),
        str_end_date = FORMAT(end_date, 'dd/MM/yyyy'),
        status_name = IIF(locked = 1, N'<span class="bg-success noti-number ml5">Đã khóa</span>', N'<span class="bg-secondary noti-number ml5">Đang thực hiện</span>'),
        AllowDelete = IIF(locked = 1, 0, 1)
    FROM #mas_revenue_periods_page

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH