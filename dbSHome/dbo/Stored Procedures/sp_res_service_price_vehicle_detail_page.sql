-- =============================================
-- Author:      ThanhMT
-- Create date: 27/08/2025
-- Description: Cấu hình giá dịch vụ - Gửi xe tháng - chi tiết - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_vehicle_detail_page]
    @UserId UNIQUEIDENTIFIER = null,
    @project_code VARCHAR(50) = NULL,
    @par_vehicle_oid UNIQUEIDENTIFIER = null,
    @par_vehicle_type_oid UNIQUEIDENTIFIER = null,
    @ClientId nvarchar(50) = null,
    @Filter nvarchar(150) = NULL,
    @GridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @AcceptLanguage nvarchar(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @ViewGrid NVARCHAR(100) = 'config_sp_res_service_price_vehicle_detail_page';--sys_config_list
    SET @OffSet = ISNULL(@OffSet, 0);
    SET @PageSize = ISNULL(@PageSize, 20);
    SET @Filter = ISNULL(@Filter, '');

    SELECT a.*
    INTO #par_vehicle_detail
    FROM par_vehicle_detail a
    WHERE
        a.par_vehicle_oid = @par_vehicle_oid
        AND (@par_vehicle_type_oid IS NULL OR a.par_vehicle_type_oid = @par_vehicle_type_oid)
        AND (@Filter = '' OR (@Filter <> '' AND (a.config_name LIKE N'%'+@Filter+'%')))
		
    SELECT *
    INTO #par_vehicle_detail_page
    FROM #par_vehicle_detail
    ORDER BY par_vehicle_type_oid, sort_order, created_date DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
	
    SELECT
        RecordsTotal = (SELECT COUNT(*) FROM #par_vehicle_detail),
        RecordsFiltered = (SELECT COUNT(*) FROM #par_vehicle_detail_page),
        GridKey = @ViewGrid
	
    SELECT*FROM dbo.fn_config_list_gets_lang(@ViewGrid, @gridWidth, @AcceptLanguage) ORDER BY ordinal;
	
    SELECT
        a.*,
        str_unit_price = FORMAT(a.unit_price, 'N0', 'vi-VN'),
        par_vehicle_type_name = b.config_name
    FROM
        #par_vehicle_detail_page a
        LEFT JOIN par_vehicle_type b ON b.oid = par_vehicle_type_oid

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH