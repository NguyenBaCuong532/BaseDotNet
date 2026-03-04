-- =============================================
-- Deployment: Update sp_app_service_request_page
-- Date: 2026-02-06
-- =============================================

-- =============================================
-- Author: AnhTT
-- Create date: 2025-09-23
-- Modified: 2026-02-06 - Added acceptLanguage support
-- Description: Grid phân trang cho bảng service_request (with multi-language support)
-- =============================================
CREATE   PROCEDURE [dbo].[sp_app_service_request_page] 
    @userId UNIQUEIDENTIFIER = NULL,
    @apartmentId INT = NULL,
    @filter NVARCHAR(30) = NULL,
    @Offset INT = 0,
    @PageSize INT = 10,
    @gridWidth INT = 0,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    -- Khai báo biến
    DECLARE @Total BIGINT;
    DECLARE @GridKey NVARCHAR(100) = N'view_app_service_request_page';
    DECLARE @statusKey NVARCHAR(50) = 'request_st'
    -- =============================================
    -- VALIDATION - Kiểm tra và validate parameters
    -- =============================================
    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @filter = ISNULL(@filter, N'');

    IF @PageSize <= 0
        SET @PageSize = 10;

    IF @Offset < 0
        SET @Offset = 0;

    -- =============================================
    -- COUNT - Đếm tổng số bản ghi
    -- =============================================
    SELECT @Total = COUNT(1)
    FROM service_request a
    WHERE a.created_by = @userId

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
        FROM dbo.fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY ordinal;
    END

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu với phân trang
    -- =============================================
    SELECT [a].[id],
        [requestName] = CONCAT (
            '['
            , a.request_code
            , '] '
            , sv.service_name
            ),
        [requestTime] = CONCAT (
            dbo.fn_format_time_hhmm(a.service_time) + ' - '
            , CONVERT(NVARCHAR, a.service_date, 103)
            ),
        [canReview] = CONVERT(BIT, IIF(a.[status] = 5
                AND DATEDIFF(HH, a.approved_dt, GETDATE()) <= 24, 1, 0)),
        [rating] = r.rating,
        [a].[status],
        [statusName] = s.objClass
    FROM service_request a
    INNER JOIN [dbo].[fn_get_service_lang](@acceptLanguage) sv ON sv.[id] = a.service_id
    INNER JOIN MAS_Apartments ap
        ON ap.ApartmentId = a.apartment_id
    INNER JOIN service_package p
        ON p.id = a.package_id
    LEFT JOIN [dbo].fn_config_data_gets (@statusKey) s ON s.objCode = a.[status]
    LEFT JOIN request_review r
        ON r.src_id = a.id
    WHERE a.created_by = @userId
    AND a.apartment_id = @apartmentId
    ORDER BY a.created_dt DESC OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT,
        @ErrorMsg VARCHAR(200),
        @ErrorProc VARCHAR(50),
        @SessionID INT,
        @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = N'@Userid: ' + ISNULL(CAST(@userId AS VARCHAR(50)), N'NULL') + N', @filter: ' + ISNULL(@filter, N'NULL');

    EXEC utl_errorlog_set @ErrorNum,
        @ErrorMsg,
        @ErrorProc,
        N'service_request',
        N'GET',
        @SessionID,
        @AddlInfo;

    -- Trả về lỗi
    SELECT 0 AS valid,
        N'Lỗi: ' + ERROR_MESSAGE() AS [messages];
END CATCH