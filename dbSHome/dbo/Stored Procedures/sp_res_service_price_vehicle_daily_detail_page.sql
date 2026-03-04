-- =============================================
-- Author:      ThanhMT
-- Create date: 21/08/2025
-- Description: Cấu hình giá dịch vụ - Gửi xe ngày block - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_vehicle_daily_detail_page]
    @UserId UNIQUEIDENTIFIER = null,
    @project_code VARCHAR(50) = NULL,
    @VehicleDailyOid UNIQUEIDENTIFIER = null,
    @par_vehicle_daily_type_oid UNIQUEIDENTIFIER = null,
    @ClientId nvarchar(50) = null,
    @Filter nvarchar(150) = NULL,
    @GridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @AcceptLanguage nvarchar(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @ViewGrid NVARCHAR(100) = 'config_sp_res_service_price_vehicle_daily_detail_page';--sys_config_list
    SET @OffSet = ISNULL(@OffSet, 0);
    SET @PageSize = ISNULL(@PageSize, 20);
    SET @Filter = ISNULL(@Filter, '');
    DECLARE @IsBlockPricing BIT = (SELECT TOP 1 b.block_pricing
                                  FROM
                                      par_vehicle_daily a
                                      LEFT JOIN par_vehicle_type b ON b.oid = a.par_vehicle_type_oid
                                  WHERE a.oid = @VehicleDailyOid)
                                  
    SELECT a.*
    INTO #par_vehicle_daily_detail
    FROM par_vehicle_daily_detail a
    WHERE
        a.par_vehicle_daily_oid = @VehicleDailyOid
        AND (@par_vehicle_daily_type_oid IS NULL OR a.par_vehicle_daily_type_oid = @par_vehicle_daily_type_oid)
        AND (@Filter = '' OR (@Filter <> '' AND (a.config_name LIKE N'%'+@Filter+'%')))
		
    SELECT *
    INTO #par_vehicle_daily_detail_page
    FROM #par_vehicle_daily_detail
    ORDER BY sort_order, created_date DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
	
    SELECT
        RecordsTotal = (SELECT COUNT(*) FROM #par_vehicle_daily_detail),
        RecordsFiltered = (SELECT COUNT(*) FROM #par_vehicle_daily_detail_page),
        GridKey = @ViewGrid
	
    SELECT *
    FROM dbo.fn_config_list_gets_lang(@ViewGrid, @gridWidth, @AcceptLanguage)
    WHERE ((@IsBlockPricing = 1 AND columnField NOT IN('str_start_time', 'str_end_time')) OR (@IsBlockPricing <> 1 AND columnField NOT IN('start_value', 'end_value', 'VehicleDailyBlockTypeName')))
    ORDER BY ordinal;
	
    SELECT
        a.*,
        str_unit_price = FORMAT(a.unit_price, 'N0', 'vi-VN'),
        str_start_time = CONVERT(VARCHAR(5), a.start_time, 108),
        str_end_time = CONVERT(VARCHAR(5), a.end_time, 108),
        VehicleDailyBlockTypeName = b.config_name
    FROM
        #par_vehicle_daily_detail_page a
        LEFT JOIN par_vehicle_daily_type b ON b.Oid = a.par_vehicle_daily_type_oid
    ORDER BY sort_order

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH