
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	page of card amenity (Danh sách tiện ích)
-- Output: page
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_card_amenity_page] 
	  @UserId UNIQUEIDENTIFIER
    , @cardCd NVARCHAR(40) = NULL
    , @type NVARCHAR(50) = 'vehicle'
    , @filter NVARCHAR(100)
    , @gridWidth INT = 0
    , @Offset INT = 0
    , @PageSize INT = 10
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @Total BIGINT
    DECLARE @GridKey NVARCHAR(100) = 'view_card_amenity_page'
    DECLARE @tableName NVARCHAR(100)
    -- DECLARE @status_key NVARCHAR(50) = 'feedback_status'
    SET @Offset = isnull(@Offset, 0)
    SET @PageSize = isnull(@PageSize, 10)
    SET @Total = isnull(@Total, 0)
    SET @filter = isnull(@filter, '')

    IF @PageSize = 0
        SET @PageSize = 10

    IF @Offset < 0
        SET @Offset = 0

    IF @type = 'vehicle'
    BEGIN
        SELECT @Total = COUNT_BIG(1)
        FROM MAS_CardVehicle a
        WHERE EXISTS (
                SELECT TOP 1 1
                FROM MAS_Cards sa
                WHERE sa.CardCd = @cardCd
                    AND sa.CardId = a.CardId
                )
    END

    --root	
    SELECT recordsTotal = @Total
        , recordsFiltered = @Total
        , gridKey = @GridKey
        , valid = 1

    --grid config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
    END
    IF @type = 'vehicle'
    BEGIN
        SET @tableName = 'MAS_CardVehicle'
        
        SELECT id = a.id
            , a.CardVehicleId
            , c.CardCd
            , a.[AssignDate]
            , a.[CardId]
            , a.[CustId]
            , a.[VehicleTypeId]
            , [amenityName] = t.VehicleTypeName
            , [amenityContent] = a.[VehicleNo]
            , a.[VehicleName]
            , a.[VehicleColor]
            , a.[StartTime]
            , a.[EndTime]
            , a.[Status]
            , [statusName] = s.objClass
            , [icon] = t.icon
        FROM MAS_CardVehicle a
        LEFT JOIN MAS_VehicleTypes t ON t.VehicleTypeId = a.VehicleTypeId
        INNER JOIN MAS_Cards c
            ON c.CardId = a.CardId
        LEFT JOIN dbo.fn_config_data_gets_lang('vehicleCardStatus', @acceptLanguage) s ON s.objValue = a.[Status]
        WHERE EXISTS (
                SELECT TOP 1 1
                FROM MAS_Cards sa
                WHERE sa.CardCd = @cardCd
                    AND sa.CardId = a.CardId
                )
        ORDER BY a.AssignDate DESC offset @Offset rows

        FETCH NEXT @PageSize rows ONLY

        RETURN;
    END

    SELECT 1 WHERE 1 = 0
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , @tableName
        , 'GET'
        , @SessionID
        , @AddlInfo
END CATCH