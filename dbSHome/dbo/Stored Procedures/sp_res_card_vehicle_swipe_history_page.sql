
CREATE PROCEDURE [dbo].[sp_res_card_vehicle_swipe_history_page]
    @UserId UNIQUEIDENTIFIER,
    @clientId NVARCHAR(50) = NULL,
    @ProjectCd NVARCHAR(30),
    @filter NVARCHAR(500) = '',
    @CardCd NVARCHAR(50) = '',
    @VehicleNo NVARCHAR(16) = '',
    @VehicleTypeId INT = -1,
    @Status INT = -1,
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
    DECLARE @GridKey NVARCHAR(100) = 'view_card_vehicle_swipe_history_page'
    DECLARE @DateFrom DATETIME = DATEADD(day, -30, GETDATE())
    DECLARE @DateTo DATETIME = GETDATE()

    SET @Offset = ISNULL(@Offset, 0)
    SET @PageSize = ISNULL(@PageSize, 10)
    SET @Total = ISNULL(@Total, 0)
    SET @filter = ISNULL(@filter, '')
    SET @Status = ISNULL(@Status, -1)
    SET @VehicleTypeId = ISNULL(@VehicleTypeId, -1)
    SET @CardCd = ISNULL(@CardCd, '')
    SET @VehicleNo = ISNULL(@VehicleNo, '')

    IF @PageSize <= 0
    BEGIN
        SET @PageSize = 10
    END

    -- Xử lý date filter (ưu tiên StartDate/EndDate nếu có, nếu không thì dùng 30 ngày gần nhất)
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
    FROM MAS_CardVehicle_Swipe_H h WITH (NOLOCK)
    WHERE 1=1
        AND (@ProjectCd = '-1' OR h.ProjectCd = @ProjectCd)
        AND (
            @CardCd = '' OR h.CardCd LIKE '%' + @CardCd + '%'
        )
        AND (
            @VehicleNo = '' OR h.VehicleNo LIKE '%' + @VehicleNo + '%'
        )
        AND (
            @VehicleTypeId = -1 OR h.VehicleTypeId = @VehicleTypeId
        )
        AND (
            @Status = -1 OR h.Status = @Status
        )
        AND (
            @DateFrom IS NULL OR h.SwipeTime >= @DateFrom
        )
        AND (
            @DateTo IS NULL OR h.SwipeTime < @DateTo
        )
        AND (
            @filter = '' 
            OR h.CardCd LIKE '%' + @filter + '%'
            OR h.VehicleNo LIKE '%' + @filter + '%'
            OR h.VehicleTypeName LIKE '%' + @filter + '%'
        )

    -- 1) Return metadata
    SELECT recordsTotal = @Total
          , recordsFiltered = @Total
          , gridKey = @GridKey
          , valid = 1

    -- 2) Return grid configuration (luôn trả 3 result sets)
    SELECT *
    FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
    ORDER BY [ordinal];

    -- 3) Return data list từ bảng lịch sử
    SELECT 
        h.SwipeHistoryId AS LogId,
        h.CardCd AS CardCd,                    -- 1. Mã thẻ
        h.VehicleNo AS VehicleNo,              -- 2. Biển số xe
        ISNULL(h.VehicleTypeName, N'') AS VehicleTypeName,  -- 3. Loại xe
        h.SwipeTime AS SwipeTime,              -- 4. Thời gian (Thời gian người dùng quẹt thẻ)
        CONVERT(NVARCHAR(19), h.SwipeTime, 120) AS SwipeTimeStr,
        h.Status AS Status,                    -- 5. Trạng thái: 1 = Vào, 2 = Ra, 3 = Thất bại
        ISNULL(h.StatusName, 
            CASE 
                WHEN h.Status = 1 THEN N'Vào'
                WHEN h.Status = 2 THEN N'Ra'
                WHEN h.Status = 3 THEN N'Thất bại'
                ELSE N''
            END
        ) AS StatusName,
        ISNULL(h.Notes, N'') AS Notes,         -- 6. Ghi chú (chỉ có khi thất bại)
        h.CardId,
        h.CardVehicleId,
        h.VehicleTypeId,
        h.StationId,
        ISNULL(h.StationName, N'') AS StationName
    FROM MAS_CardVehicle_Swipe_H h WITH (NOLOCK)
    WHERE 1=1
        AND (@ProjectCd = '-1' OR h.ProjectCd = @ProjectCd)
        AND (
            @CardCd = '' OR h.CardCd LIKE '%' + @CardCd + '%'
        )
        AND (
            @VehicleNo = '' OR h.VehicleNo LIKE '%' + @VehicleNo + '%'
        )
        AND (
            @VehicleTypeId = -1 OR h.VehicleTypeId = @VehicleTypeId
        )
        AND (
            @Status = -1 OR h.Status = @Status
        )
        AND (
            @DateFrom IS NULL OR h.SwipeTime >= @DateFrom
        )
        AND (
            @DateTo IS NULL OR h.SwipeTime < @DateTo
        )
        AND (
            @filter = '' 
            OR h.CardCd LIKE '%' + @filter + '%'
            OR h.VehicleNo LIKE '%' + @filter + '%'
            OR h.VehicleTypeName LIKE '%' + @filter + '%'
        )
    ORDER BY h.SwipeTime DESC
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
    SET @ErrorMsg = 'sp_res_card_vehicle_swipe_history_page ' + ERROR_MESSAGE()
    SET @ErrorProc = ERROR_PROCEDURE()

    SET @AddlInfo = '@UserId ' + cast(@UserId as varchar(50))

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardVehicleSwipeHistory', 'GET', @SessionID, @AddlInfo
END CATCH