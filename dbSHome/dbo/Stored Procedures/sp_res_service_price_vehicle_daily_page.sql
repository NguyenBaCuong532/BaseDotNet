-- =============================================
-- Author:      ThanhMT
-- Create date: 21/08/2025
-- Description: Cấu hình giá dịch vụ - Gửi xe ngày - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_vehicle_daily_page]
    @UserId UNIQUEIDENTIFIER = null,
    @project_code VARCHAR(50) = NULL,
    @ClientId nvarchar(50) = null,
    @Filter nvarchar(150) = NULL,
    @GridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @AcceptLanguage nvarchar(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @ViewGrid NVARCHAR(100) = 'config_sp_res_service_price_vehicle_daily_page';--sys_config_list
    SET @OffSet = ISNULL(@OffSet, 0);
    SET @PageSize = ISNULL(@PageSize, 20);
    SET @Filter = ISNULL(@Filter, '');

    SELECT a.*
    INTO #par_vehicle_daily
    FROM par_vehicle_daily a
    WHERE
        a.project_code = @project_code
    -- 	(@Filter = '' OR (@Filter <> '' AND (a.Name LIKE N'%'+@Filter+'%')))
		
    SELECT *
    INTO #par_vehicle_daily_page
    FROM #par_vehicle_daily
    ORDER BY created_date DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
	
    SELECT
        RecordsTotal = (SELECT COUNT(*) FROM #par_vehicle_daily),
        RecordsFiltered = (SELECT COUNT(*) FROM #par_vehicle_daily_page),
        GridKey = @ViewGrid
	
    SELECT*FROM dbo.fn_config_list_gets_lang(@ViewGrid, @gridWidth, @AcceptLanguage) ORDER BY ordinal;
	
    SELECT
        a.*,
        str_effective_date = FORMAT(a.effective_date, 'dd/MM/yyyy'),
        str_expiry_date = FORMAT(a.expiry_date, 'dd/MM/yyyy'),
        StatusName = IIF(a.is_active = 1, N'<span class="bg-success noti-number ml5">Đang áp dụng</span>', N'<span class="bg-secondary noti-number ml5">Ngừng áp dụng</span>'),
        ResidenceTypeName = b.config_name
    FROM
        #par_vehicle_daily_page a
        LEFT JOIN par_vehicle_type b ON b.Oid = a.par_vehicle_type_oid

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH