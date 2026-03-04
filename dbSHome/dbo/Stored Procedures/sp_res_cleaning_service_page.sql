
-- =============================================
-- Author: Cuongnb
-- Create date: 2025-12-03
-- Description: Grid phân trang cho bảng MAS_Requests (cleaning service)
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_cleaning_service_page]
    @UserId     UNIQUEIDENTIFIER = NULL,
    @clientId   NVARCHAR(50) = NULL,
    @ProjectCd  NVARCHAR(30),
    @apartmentId INT = NULL,
    @Status     INT = -1,
    @IsNow      INT = -1,
    @fromDate   NVARCHAR(20) = NULL,
    @toDate     NVARCHAR(20) = NULL,
    @filter     NVARCHAR(30) = '',
    @gridWidth  INT = 0,
    @Offset     INT = 0,
    @PageSize   INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    -- =============================================
    -- KHAI BÁO BIẾN
    -- =============================================

    DECLARE @Total BIGINT;
    DECLARE @GridKey NVARCHAR(100) = 'view_res_service_package_page';
    DECLARE @statusKey NVARCHAR(50) = 'request_st'

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @filter = ISNULL(@filter, '');
    SET @ProjectCd = ISNULL(@ProjectCd, '');
    SET @Status = ISNULL(@Status, -1);
    SET @IsNow = ISNULL(@IsNow, -1);

    IF @PageSize <= 0 SET @PageSize = 10;
    IF @Offset < 0 SET @Offset = 0;
    IF @fromDate IS NULL OR @fromDate = '' SET @fromDate = NULL;
    IF @toDate IS NULL OR @toDate = '' SET @toDate = NULL;

    -- =============================================
    -- COUNT - Đếm tổng số bản ghi
    -- =============================================
    SELECT @Total = COUNT(a.id)
    FROM service_request a
    INNER JOIN [service] sv ON sv.[id] = a.service_id
    INNER JOIN MAS_Apartments ap ON ap.ApartmentId = a.apartment_id
    INNER JOIN service_package p ON p.id = a.package_id
    LEFT JOIN [dbo].fn_config_data_gets_lang ('request_st', @acceptLanguage) s ON s.objCode = a.[status]
    LEFT JOIN request_review r ON r.src_id = a.id
    LEFT JOIN UserInfo u ON u.userId = a.created_by
    WHERE a.created_by = @userId
    AND a.apartment_id = @apartmentId

    -- =============================================
    -- RESULT SET 1: METADATA - Thông tin phân trang
    -- =============================================
    SELECT recordsTotal = @Total,
           recordsFiltered = @Total,
           gridKey = @GridKey,
           valid = 1;

    -- =============================================
    -- RESULT SET 2: HEADER - Cấu hình cột (chỉ lầu đầu)
    -- =============================================
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM dbo.fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
        ORDER BY [ordinal];
    END

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu với phân trang
    -- =============================================
        SELECT 
             a.id as RequestId,
             a.request_code,
             a.apartment_id,
             ap.RoomCode,
             u.fullName as createBy,
             FORMAT(a.created_dt, 'HH:mm:ss dd/MM/yyyy') AS AtTime,
           sv.name,
           Status = s.objValue1 ,
           a.is_quick_support as IsNow
          

    FROM service_request a
    INNER JOIN [service] sv ON sv.[id] = a.service_id
    INNER JOIN MAS_Apartments ap ON ap.ApartmentId = a.apartment_id
    INNER JOIN service_package p ON p.id = a.package_id
    LEFT JOIN [dbo].fn_config_data_gets_lang ('request_st', @acceptLanguage) s ON s.objCode = a.[status]
    LEFT JOIN request_review r ON r.src_id = a.id
    LEFT JOIN UserInfo u ON u.userId = a.created_by
  --  WHERE 
  --  a.created_by = @userId
  --  AND a.apartment_id = @apartmentId
    ORDER BY a.created_dt DESC OFFSET @Offset ROWS

    FETCH NEXT @PageSize ROWS ONLY;
END TRY
BEGIN CATCH
    -- =============================================
    -- ERROR HANDLING
    -- =============================================
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_cleaning_service_page ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = N'@UserId: ' + ISNULL(CAST(@UserId AS NVARCHAR(50)), 'NULL');

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Request', 'GET', @SessionID, @AddlInfo;

    -- Trả về lỗi
    SELECT 0 AS valid,
           N'Lỗi: ' + ERROR_MESSAGE() AS [messages];
END CATCH;