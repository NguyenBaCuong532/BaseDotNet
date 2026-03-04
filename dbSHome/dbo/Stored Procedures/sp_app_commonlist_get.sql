
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	list
-- Output: list name,value
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_commonlist_get] 
	  @userId UNIQUEIDENTIFIER = NULL
    , @selectionName NVARCHAR(100)
    , @queryParams NVARCHAR(4000) = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @tableKey NVARCHAR(50) = 'selection_list'

    CREATE TABLE #list (
        [name] NVARCHAR(250)
        , [value] NVARCHAR(4000)
        )

    SELECT [Key]
        , [Value]
    INTO #params
    FROM dbo.fn_parse_query_params(@queryParams)

    DECLARE @isAll BIT

    SELECT @isAll = [value]
    FROM #params
    WHERE [Key] = 'isAll'

    IF @isAll = 1
        INSERT INTO #list
        VALUES (
            N'Tất cả'
            , 'all'
            )

    IF @selectionName = 'project'
    BEGIN
        INSERT INTO #list (
            [name]
            , [value]
            )
        SELECT projectName AS name
            , [projectCd] AS value
        FROM MAS_Projects

        GOTO FINAL;
    END

    IF @selectionName = 'building'
    BEGIN
        DECLARE @projectCd NVARCHAR(50)

        SELECT @projectCd = [value]
        FROM #params
        WHERE [Key] = 'projectCd'

        INSERT INTO #list (
            [name]
            , [value]
            )
        SELECT b.BuildingName AS name
            , b.[BuildingCd] AS value
        FROM MAS_Buildings b
        WHERE ProjectCd LIKE @ProjectCd + '%'

        GOTO FINAL;
    END

    IF @selectionName = 'floor'
    BEGIN
        DECLARE @BuildingCd NVARCHAR(50)

        SELECT @BuildingCd = [value]
        FROM #params
        WHERE [Key] = 'buildingCd'

        INSERT INTO #list (
            [name]
            , [value]
            )
        SELECT DISTINCT IIF(ISNULL(ef.FloorName, a.floorNo) = '', FORMAT(ISNULL(ef.FloorNumber, a.Floor), '00'), ISNULL(ef.FloorName, a.floorNo)) AS name
            , ISNULL(ef.FloorName, a.floorNo) AS value
        FROM MAS_Apartments a
        LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
        LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid
        WHERE b.BuildingCd = @BuildingCd AND (a.floorNo IS NOT NULL OR ef.FloorName IS NOT NULL)
        GOTO FINAL;
    END

    IF @selectionName = 'room'
    BEGIN
        DECLARE @floor NVARCHAR(50)

        SELECT @buildingCd = [value]
        FROM #params
        WHERE [Key] = 'buildingCd'

        SELECT @floor = [value]
        FROM #params
        WHERE [Key] = 'floor'

        INSERT INTO #list (
            [name]
            , [value]
            )
        SELECT a.[RoomCode] AS name
            , a.[RoomCode] AS value
        FROM MAS_Apartments a
        LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
        LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid
        WHERE b.BuildingCd = @BuildingCd
            AND (
                @floor IS NULL
                OR ef.FloorName = @floor
                OR a.floorNo LIKE @floor + '%'
                OR CAST(ISNULL(ef.FloorNumber, a.Floor) AS NVARCHAR(20)) = @floor
                )

        GOTO FINAL;
    END

    IF @selectionName = 'apartment_relation'
    BEGIN
        INSERT INTO #list (
            [name]
            , [value]
            )
        SELECT [RelationName] AS name
            , [RelationId] AS value
        FROM MAS_Customer_Relation

        GOTO FINAL;
    END

    IF @selectionName = 'vehicle_type'
    BEGIN
        INSERT INTO #list (
            [name]
            , [value]
            )
        SELECT [VehicleTypeName] AS name
            , [VehicleTypeId] AS value
        FROM MAS_VehicleTypes

        GOTO FINAL;
    END

    IF @selectionName = 'feedback_type'
    BEGIN
        --DECLARE @appid BIGINT = dbo.fn_get_appid('swagger');
        INSERT INTO #list (
            [name]
            , [value]
            )
        SELECT [FeedbackTypeName] AS name
            , [FeedbackTypeId] AS value
        FROM MAS_FeedbackType

        --WHERE AppId = @appid
        GOTO FINAL;
    END

    IF @selectionName = 'card_amenity_type'
    BEGIN
        INSERT INTO #list (
            [name]
            , [value]
            )
        SELECT [name] AS name
            , [code] AS value
        FROM card_amenity_type

        GOTO FINAL;
    END

    IF @selectionName = 'sex'
    BEGIN
        INSERT INTO #list (
            [name]
            , [value]
            )
        SELECT N'Nam' AS [name]
            , 'true' AS [value]
        
        UNION ALL
        
        SELECT N'Nữ' AS [name]
            , 'false' AS [value]

        GOTO FINAL;
    END

    IF @selectionName = 'ischeck'
    BEGIN
        INSERT INTO #list (
            [name]
            , [value]
            )
        SELECT N'Đang sử dụng' AS [name]
            , 'true' AS [value]
        
        UNION ALL
        
        SELECT N'Chưa hoạt động' AS [name]
            , 'false' AS [value]

        GOTO FINAL;
    END

    IF @selectionName = 'language'
    BEGIN
        INSERT INTO #list (
            [name]
            , [value]
            )
        SELECT [name]
            , code
        FROM sys_language
        ORDER BY ordinal

        GOTO FINAL;
    END

    --lấy từ config data
    INSERT INTO #list (
        [name]
        , [value]
        )
    SELECT [objCode]
        , [objName] [objClass]
    FROM dbo.fn_config_data_gets_lang(@selectionName, @acceptLanguage)

    FINAL:

    SELECT [name]
        , [value]
    FROM #list
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

    --SET @AddlInfo = NULL;
    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , @tableKey
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;