
CREATE PROCEDURE [dbo].[sp_res_card_vehicle_payment_history_page]
    @UserId UNIQUEIDENTIFIER,
    @clientId NVARCHAR(50) = NULL,
    @ProjectCd NVARCHAR(30),
    @filter NVARCHAR(500) = '',
    @CardVehicleId INT = -1,
    @CardCd NVARCHAR(50) = '',
    @VehicleNo NVARCHAR(16) = '',
    @VehicleTypeId INT = -1,
    @PaymentStatus INT = -1,
    @StartDate NVARCHAR(20) = NULL,
    @EndDate NVARCHAR(20) = NULL,
    @gridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    DECLARE @Total BIGINT
    DECLARE @GridKey NVARCHAR(100) = 'view_card_vehicle_payment_history_page'
    DECLARE @DateFrom DATETIME = NULL
    DECLARE @DateTo DATETIME = NULL

    SET @Offset = ISNULL(@Offset, 0)
    SET @PageSize = ISNULL(@PageSize, 10)
    SET @Total = ISNULL(@Total, 0)
    SET @filter = ISNULL(@filter, '')
    SET @PaymentStatus = ISNULL(@PaymentStatus, -1)
    SET @VehicleTypeId = ISNULL(@VehicleTypeId, -1)
    SET @CardVehicleId = ISNULL(@CardVehicleId, -1)
    SET @CardCd = ISNULL(@CardCd, '')
    SET @VehicleNo = ISNULL(@VehicleNo, '')

    IF @PageSize <= 0
    BEGIN
        SET @PageSize = 10
    END

    -- Xử lý date filter
    IF @StartDate IS NOT NULL AND @StartDate != ''
    BEGIN
        SET @DateFrom = CONVERT(DATETIME, @StartDate, 103)
    END
    IF @EndDate IS NOT NULL AND @EndDate != ''
    BEGIN
        SET @DateTo = DATEADD(day, 1, CONVERT(DATETIME, @EndDate, 103))
    END

    -- Count total records từ bảng lịch sử
    SELECT @Total = COUNT(*)
    FROM MAS_CardVehicle_Pay_H h WITH (NOLOCK)
    WHERE 
    --(@ProjectCd = '-1' OR h.ProjectCd = @ProjectCd)
      --  AND 
        (@CardVehicleId = -1 OR h.CardVehicleId = @CardVehicleId)
        AND (
            @CardCd = '' 
            OR h.CardCd LIKE '%' + @CardCd + '%'
        )
        AND (
            @VehicleNo = '' 
            OR h.VehicleNo LIKE '%' + @VehicleNo + '%'
        )
        AND (
            @VehicleTypeId = -1 
            OR h.VehicleTypeId = @VehicleTypeId
        )
        AND (
            @PaymentStatus = -1 
            OR h.PaymentStatus = @PaymentStatus
        )
        AND (
            @DateFrom IS NULL 
            OR h.CreatedDate >= @DateFrom
        )
        AND (
            @DateTo IS NULL 
            OR h.CreatedDate < @DateTo
        )
        AND (
            @filter = '' 
            OR h.CardCd LIKE '%' + @filter + '%'
            OR h.VehicleNo LIKE '%' + @filter + '%'
            OR CAST(h.PayId AS NVARCHAR(50)) LIKE '%' + @filter + '%'
        )

    -- 1) Return metadata
    SELECT recordsTotal = @Total
          , recordsFiltered = @Total
          , gridKey = @GridKey
          , valid = 1

    -- 2) Return grid configuration
    SELECT *
    FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
    ORDER BY [ordinal];

    -- 3) Return data list từ bảng lịch sử
    SELECT 
        h.PayId AS transCode,                    -- 1. Mã giao dịch
        h.Amount AS amount,                      -- 2. Số tiền
        CONVERT(NVARCHAR(50), h.PaymentDate, 103) AS paymentDate,   -- 3. Ngày thanh toán
        h.PaymentStatus AS paymentStatus,        -- 4. Trạng thái thanh toán
        ISNULL(h.PaymentStatusName,
            CASE 
                WHEN h.PaymentStatus = 0 THEN N'Chưa thanh toán'
                WHEN h.PaymentStatus = 1 THEN N'Đã thanh toán'
                WHEN h.PaymentStatus = 2 THEN N'Chờ hoàn tiền'
                WHEN h.PaymentStatus = 3 THEN N'Đã hoàn tiền'
                ELSE N'Không xác định'
            END
        ) AS paymentStatusName,
        h.StartDate AS startDate,                -- 5. Ngày bắt đầu
        CONVERT(NVARCHAR(50), h.StartDate, 103) AS startDateStr,
        h.EndDate AS endDate,                    -- 6. Ngày kết thúc
        CONVERT(NVARCHAR(50), h.EndDate, 103) AS endDateStr,
        ISNULL(h.PeriodName,
            CASE 
                WHEN h.StartDate IS NOT NULL THEN 
                    N'Tháng ' + CAST(MONTH(h.StartDate) AS NVARCHAR(2)) + '/' + CAST(YEAR(h.StartDate) AS NVARCHAR(4))
                WHEN h.EndDate IS NOT NULL THEN 
                    N'Tháng ' + CAST(MONTH(h.EndDate) AS NVARCHAR(2)) + '/' + CAST(YEAR(h.EndDate) AS NVARCHAR(4))
                ELSE N''
            END
        ) AS periodName,                         -- 7. Kỳ dự thu
        h.CreatedDate AS createdDate,            -- 8. Ngày tạo
        CONVERT(NVARCHAR(50), h.CreatedDate, 103) AS createdDateStr,
        CONVERT(NVARCHAR(19), h.CreatedDate, 120) AS createdDateStrFull,
        h.CreatedBy AS createdBy,                -- 9. Người thực hiện
        h.CardCd AS CardCd,
        h.VehicleNo AS VehicleNo,
        h.VehicleTypeId AS VehicleTypeId,
        ISNULL(h.VehicleTypeName, N'') AS VehicleTypeName,
        h.CardVehicleId AS CardVehicleId,
        ISNULL(h.Remark, N'') AS Remark
    FROM MAS_CardVehicle_Pay_H h WITH (NOLOCK)
  --  WHERE 
    --(@ProjectCd = '-1' OR h.ProjectCd = @ProjectCd)
    --    AND
        --(@CardVehicleId = -1 OR h.CardVehicleId = @CardVehicleId)
        --AND (
        --    @CardCd = '' 
        --    OR h.CardCd LIKE '%' + @CardCd + '%'
        --)
        --AND (
        --    @VehicleNo = '' 
        --    OR h.VehicleNo LIKE '%' + @VehicleNo + '%'
        --)
        --AND (
        --    @VehicleTypeId = -1 
        --    OR h.VehicleTypeId = @VehicleTypeId
        --)
        --AND (
        --    @PaymentStatus = -1 
        --    OR h.PaymentStatus = @PaymentStatus
        --)
        --AND (
        --    @DateFrom IS NULL 
        --    OR h.CreatedDate >= @DateFrom
        --)
        --AND (
        --    @DateTo IS NULL 
        --    OR h.CreatedDate < @DateTo
        --)
        --AND (
        --    @filter = '' 
        --    OR h.CardCd LIKE '%' + @filter + '%'
        --    OR h.VehicleNo LIKE '%' + @filter + '%'
        --    OR CAST(h.PayId AS NVARCHAR(50)) LIKE '%' + @filter + '%'
        --)
    ORDER BY h.CreatedDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX)

    SET @ErrorNum = ERROR_NUMBER()
    SET @ErrorMsg = 'sp_res_card_vehicle_payment_history_page ' + ERROR_MESSAGE()
    SET @ErrorProc = ERROR_PROCEDURE()
    SET @AddlInfo = '@UserId ' + cast(@UserId as varchar(50))

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardVehiclePaymentHistory', 'GET', @SessionID, @AddlInfo

END CATCH