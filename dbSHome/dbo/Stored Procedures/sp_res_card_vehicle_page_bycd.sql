
CREATE PROCEDURE [dbo].[sp_res_card_vehicle_page_bycd] 
      @userId UNIQUEIDENTIFIER = NULL
    , @clientId NVARCHAR(50) = NULL
    , @filter NVARCHAR(30) = NULL
    , @CardCd NVARCHAR(50)
    , @gridWidth INT = 0
    , @Offset INT = 0
    , @PageSize INT = 10
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @Total BIGINT;
    DECLARE @GridKey NVARCHAR(100) = 'view_apartment_vehicle_card_page';

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @filter = ISNULL(@filter, '');

    IF @PageSize = 0 SET @PageSize = 10;
    IF @Offset < 0 SET @Offset = 0;

    SELECT @Total = COUNT(a.CardVehicleId)
    FROM dbo.MAS_CardVehicle a
    INNER JOIN dbo.MAS_Cards d ON a.CardId = d.CardId
    WHERE d.CardCd = @CardCd;

    -- root
    SELECT recordsTotal = @Total,
           recordsFiltered = @Total,
           gridKey = @GridKey,
           valid = 1;

    -- grid config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM dbo.fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
    END;

    -- Data
    SELECT
          a.CardVehicleId
        , CONVERT(NVARCHAR(10), a.AssignDate, 103) AS AssignDate
        , a.VehicleNo
        , a.VehicleTypeId AS VehicleTypeID
        , e.VehicleTypeName
        , a.VehicleName
        , CONVERT(NVARCHAR(10), a.StartTime, 103) AS StartTime
        , CONVERT(NVARCHAR(10), a.EndTime, 103)   AS EndTime
        , a.ServiceId
        , CASE 
              WHEN e.VehicleTypeName IS NOT NULL THEN N'Vé tháng - ' + e.VehicleTypeName
              ELSE NULL
          END AS ServiceName
        , a.Status
        , cd.StatusName AS StatusName
        , mv.StatusName AS VehicleStatusName
        , CASE WHEN a.Status = 3 THEN 1 ELSE 0 END AS IsLock
        , d.CardCd
        , a.isVehicleNone

        
        , COALESCE(uMkr.fullName, a.Mkr_Id) AS AuthName
        , CONVERT(NVARCHAR(10), a.Mkr_Dt, 103) AS AuthDate

        
        , COALESCE(uEdit.fullName, a.Edit_Id) AS EditName
        , CONVERT(NVARCHAR(10), a.Edit_Dt, 103) AS EditDate

    FROM dbo.MAS_CardVehicle a
    INNER JOIN dbo.MAS_Cards d ON a.CardId = d.CardId
    LEFT JOIN dbo.MAS_VehicleTypes  e  ON a.VehicleTypeId = e.VehicleTypeId
    LEFT JOIN dbo.MAS_VehicleStatus mv ON a.Status = mv.StatusId
    LEFT JOIN dbo.MAS_VehicleStatus cd ON cd.StatusId = a.Status

    LEFT JOIN dbo.Users uMkr  ON uMkr.userId  = a.Mkr_Id
    LEFT JOIN dbo.Users uEdit ON uEdit.userId = a.Edit_Id

    WHERE d.CardCd = @CardCd
    ORDER BY d.CardCd
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_vehicle_page_bycd ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set
          @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'apartment_vehicle_card'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;