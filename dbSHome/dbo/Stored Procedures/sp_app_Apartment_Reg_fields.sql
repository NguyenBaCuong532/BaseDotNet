
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	details of MAS_Apartment_Reg
-- Output: form configuration
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_apartment_reg_fields] @userId UNIQUEIDENTIFIER = NULL
    , @apartmentId BIGINT = NULL
    , @apartmentRegId BIGINT = NULL
    , @isPreview BIT = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @tableKey VARCHAR(50) = 'app_MAS_Apartment_Reg'
    DECLARE @groupKey VARCHAR(50) = 'app_group_apartment_reg'
    DECLARE @status_key NVARCHAR(50) = 'apartment_member_status'

    --1 thong tin chung
    SELECT apartmentId = @apartmentId
        , apartmentRegId = @apartmentRegId
        , tableKey = @tableKey
        , groupKey = @groupKey

    --2- cac group
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
    WHERE (
            ISNULL(@isPreview,0) = 1
            OR group_cd = '1'
            )
    ORDER BY intOrder

    --fields (Updated: bỏ MAS_Rooms, dùng MAS_Apartments + MAS_Elevator_Floor)
    SELECT [a].[roomCode]
        , [a].[contractNo]
        , [a].[relationId]
        , b.BuildingCd
        , floor = ISNULL(ef.FloorName, ap.floorNo)
        , b.ProjectCd
        , [RequestDate] = CONVERT(NVARCHAR(10), a.reg_dt, 103)
        , [status] = s.objName
    INTO #MAS_Apartment_Reg
    FROM MAS_Apartment_Reg a
    INNER JOIN MAS_Apartments ap ON ap.RoomCode = a.roomCode
    INNER JOIN MAS_Buildings b ON ap.buildingOid = b.oid
    LEFT JOIN MAS_Elevator_Floor ef ON ap.floorOid = ef.oid
    LEFT JOIN fn_config_data_gets_lang(@status_key, @acceptLanguage) s ON s.objCode = a.reg_st
    WHERE a.Id = @apartmentRegId

    SELECT *
    INTO #form
    FROM dbo.fn_config_form_gets_temp()

    INSERT INTO #form
    EXEC [sp_config_data_fields_v2] @id = @apartmentRegId
        , @key_name = ''
        , @table_name = @tableKey
        , @dataTableName = '#MAS_Apartment_Reg'
        , @acceptLanguage = @acceptLanguage;

    --update parameter
    IF @apartmentRegId IS NOT NULL WITH cte AS (
            SELECT f.id
                , p.[Key]
                , [Value] = fp.columnValue
                , [Param] = CONCAT (
                    p.[Key]
                    , '='
                    , fp.columnValue
                    )
            FROM #form f
            CROSS APPLY dbo.fn_parse_query_params(f.columnObject) p
            INNER JOIN #form fp
                ON fp.field_name = p.[Key]
            WHERE f.columnObject LIKE '%?%'
                AND fp.columnValue IS NOT NULL
                OR fp.columnValue <> ''
            )
        UPDATE f
        SET f.columnObject = CONCAT (
                LEFT(f.columnObject, CHARINDEX('?', f.columnObject) - 1)
                , '?'
                , p.query
                )
        FROM #form f
        CROSS APPLY (
            SELECT query = STRING_AGG(sa.Param, '&')
            FROM cte sa
            WHERE sa.id = f.id
            ) p
        WHERE f.columnObject LIKE '%?%'

    SELECT *
    FROM #form
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