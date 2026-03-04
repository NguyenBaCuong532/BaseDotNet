
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	details of amenity
-- Output: form configuration
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_card_amenity_field] 
	  @userId UNIQUEIDENTIFIER = NULL
    , @id UNIQUEIDENTIFIER = NULL
    , @type NVARCHAR(50) = NULL
    , @cardCd NVARCHAR(50) = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @tableKey VARCHAR(50) = 'app_card_vehicle_Reg'
    DECLARE @groupKey VARCHAR(50) = 'app_group_vehicle'
    DECLARE @customerId UNIQUEIDENTIFIER = dbo.fn_get_customerid(@userId);

    --begin
    --1 thong tin chung
    SELECT Id = @Id
        , CardCd = @cardCd
        , [type] = @type
        , tableKey = @tableKey
        , groupKey = @groupKey

    --2- cac group
    SELECT *
    FROM [dbo].[fn_get_field_group](@groupKey)
    ORDER BY intOrder

    -- IF @cardType IS NULL
    --     GOTO FINAL
    --fields
    -- IF @cardType = 'vehicle'
    SELECT [AssignDate]
        , CustId
        , [VehicleNo]
        , [VehicleTypeId]
        , [VehicleName]
        , VehicleColor
        , StartTime
        , [Status]
        , [ServiceId]
        , monthlyType
        , ProjectCd
        , Reason
        , CardId
        , Mkr_Id
        , Mkr_Dt
        , note
        , IdCardAttach
        , VehicleNoAttach
        , VehicleLicenseAttach
    INTO #temp
    FROM MAS_CardVehicle a
    -- INNER JOIN MAS_Customers c ON c.CustId = a.CustId
    -- INNER JOIN MAS_Apartment_Card ac ON a.CardId = ac.CardId
    -- INNER JOIN MAS_Apartments ap ON a.ApartmentId = ap.ApartmentId
    -- LEFT JOIN (SELECT DISTINCT projectCd, projectName FROM MAS_Projects) p ON p.projectCd = a.ProjectCd
    -- LEFT JOIN MAS_Buildings b ON b.BuildingCd = ap.buildingCd
    WHERE a.id = @id

    EXEC [sp_config_data_fields_v2] @id = @id
        , @key_name = 'id'
        , @table_name = @tableKey
        , @dataTableName = '#temp'
        , @acceptLanguage = @acceptLanguage

    RETURN;

    -- FINAL:

    -- SELECT 1
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , @tableKey
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;