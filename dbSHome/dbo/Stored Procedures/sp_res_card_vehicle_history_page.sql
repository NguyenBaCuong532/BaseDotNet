
CREATE PROCEDURE [dbo].[sp_res_card_vehicle_history_page]
    @UserId UNIQUEIDENTIFIER,
    @clientId NVARCHAR(50) = NULL,
    @ProjectCd NVARCHAR(30),
    @filter NVARCHAR(500) = '',
    @ActionType INT = -1,
    @CardCd NVARCHAR(50) = '',
    @VehicleNo NVARCHAR(16) = '',
    @VehicleTypeId INT = -1,
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
    DECLARE @GridKey NVARCHAR(100) = 'view_card_vehicle_history_page'
    DECLARE @DateFrom DATETIME = NULL
    DECLARE @DateTo DATETIME = NULL

    SET @Offset = ISNULL(@Offset, 0)
    SET @PageSize = ISNULL(@PageSize, 10)
    SET @Total = ISNULL(@Total, 0)
    SET @filter = ISNULL(@filter, '')
    SET @ActionType = ISNULL(@ActionType, -1)
    SET @VehicleTypeId = ISNULL(@VehicleTypeId, -1)
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
    FROM MAS_CardVehicle_Card_H h WITH (NOLOCK)
    WHERE
    (@ProjectCd = '-1' OR h.ProjectCd = @ProjectCd)
        AND (
            @ActionType = -1 OR h.ActionType = @ActionType
        )
        AND (
            @CardCd = '' 
            OR h.NewCardCode LIKE '%' + @CardCd + '%'
            OR h.OldCardCode LIKE '%' + @CardCd + '%'
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
            @DateFrom IS NULL 
            OR h.ActionTime >= @DateFrom
        )
        AND (
            @DateTo IS NULL 
            OR h.ActionTime < @DateTo
        )
        AND (
            @filter = '' 
            OR h.NewCardCode LIKE '%' + @filter + '%'
            OR h.OldCardCode LIKE '%' + @filter + '%'
            OR h.VehicleNo LIKE '%' + @filter + '%'
            OR h.OldOwner LIKE '%' + @filter + '%'
            OR h.NewOwner LIKE '%' + @filter + '%'
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
        h.CardHistoryId AS HistoryId,
        h.ActionType AS actionType,
        ISNULL(h.ActionTypeName,
            CASE 
                WHEN h.ActionType = 1 THEN N'Đổi mã thẻ'
                WHEN h.ActionType = 2 THEN N'Đổi chủ sở hữu'
                WHEN h.ActionType = 3 THEN N'Khóa xe'
                WHEN h.ActionType = 4 THEN N'Khoá thẻ'
                WHEN h.ActionType = 5 THEN N'Huỷ xe'
                ELSE N'Không xác định'
            END
        ) AS actionTypeName,
        CONVERT(NVARCHAR(50), h.FromDate, 103) AS fromDate,
        CONVERT(NVARCHAR(50), h.ToDate, 103) AS toDate,
        h.VehicleTypeId AS vehicleTypeId,
        ISNULL(vt.VehicleTypeName, N'') AS vehicleTypeName,
        h.OldCardCode AS oldCardCode,
        h.NewCardCode AS newCardCode,
        ISNULL(h.OldOwner, N'') AS oldOwner,
        ISNULL(h.NewOwner, N'') AS newOwner,
        h.VehicleNo AS vehicleNo,
        u.fullName AS performedBy,
        CONVERT(NVARCHAR(50), h.ActionTime, 103) AS actionTime,
        CONVERT(NVARCHAR(19), h.ActionTime, 120) AS actionTimeStr,
        ISNULL(h.Notes, N'') AS note
    FROM MAS_CardVehicle_Card_H h WITH (NOLOCK)
    LEFT JOIN MAS_VehicleTypes vt WITH (NOLOCK) ON h.VehicleTypeId = vt.VehicleTypeId
    LEFT JOIN UserInfo u WITH (NOLOCK) ON h.Operator = u.userId


    WHERE  
    --(@ProjectCd = '-1' OR h.ProjectCd = @ProjectCd)
    --    AND 
    (
            @ActionType = -1 OR h.ActionType = @ActionType
        )
        AND (
            @CardCd = '' 
            OR h.NewCardCode LIKE '%' + @CardCd + '%'
            OR h.OldCardCode LIKE '%' + @CardCd + '%'
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
            @DateFrom IS NULL 
            OR h.ActionTime >= @DateFrom
        )
        AND (
            @DateTo IS NULL 
            OR h.ActionTime < @DateTo
        )
        AND (
            @filter = '' 
            OR h.NewCardCode LIKE '%' + @filter + '%'
            OR h.OldCardCode LIKE '%' + @filter + '%'
            OR h.VehicleNo LIKE '%' + @filter + '%'
            OR h.OldOwner LIKE '%' + @filter + '%'
            OR h.NewOwner LIKE '%' + @filter + '%'
        )
    ORDER BY h.ActionTime DESC
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
    SET @ErrorMsg = 'sp_res_card_vehicle_history_page ' + ERROR_MESSAGE()
    SET @ErrorProc = ERROR_PROCEDURE()

    SET @AddlInfo = '@UserId ' + cast(@UserId as varchar(50))

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardVehicleHistory', 'GET', @SessionID, @AddlInfo

END CATCH