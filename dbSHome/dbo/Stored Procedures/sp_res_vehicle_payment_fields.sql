
CREATE PROCEDURE [dbo].[sp_res_vehicle_payment_fields]
    @UserId UNIQUEIDENTIFIER = NULL,
    @PayId INT = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN',
    @cardVehicleId INT = NULL,
    @cardVehicleOid UNIQUEIDENTIFIER = NULL,
    @paymentId UNIQUEIDENTIFIER = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    IF @cardVehicleOid IS NOT NULL
        SET @cardVehicleId = (SELECT CardVehicleId FROM MAS_CardVehicle WHERE oid = @cardVehicleOid);

    DECLARE @tableKey NVARCHAR(100) = N'MAS_CardVehicle_Pay';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    BEGIN TRY
        /* =========================================
           Resolve PayId from paymentId / cardVehicleId
           ========================================= */
        DECLARE @PayIdResolved INT = @PayId;

        -- 1) Nếu không có PayId nhưng có paymentId => map về PayId + CardVehicleId
        IF @PayIdResolved IS NULL AND @paymentId IS NOT NULL
        BEGIN
            SELECT TOP (1)
                @PayIdResolved = p.PayId,
                @cardVehicleId = ISNULL(@cardVehicleId, p.CardVehicleId)
            FROM dbo.MAS_CardVehicle_Pay p
            WHERE p.paymentId = @paymentId;
        END

        -- 2) Nếu chỉ có cardVehicleId (không có PayId/paymentId):
        --    Lấy bản ghi mới nhất của xe đó (nếu muốn trả form rỗng luôn thì bỏ block này)
        IF @PayIdResolved IS NULL AND @paymentId IS NULL AND ISNULL(@cardVehicleId, 0) <> 0
        BEGIN
            SELECT TOP (1)
                @PayIdResolved = p.PayId
            FROM dbo.MAS_CardVehicle_Pay p
            WHERE p.CardVehicleId = @cardVehicleId
            ORDER BY ISNULL(p.updated_dt, p.created_dt) DESC, p.PayId DESC;
        END

        /* =============================
           RESULT SET 1: INFO
        ============================== */
        SELECT 
            PayId    = @PayIdResolved,
            tableKey = @tableKey,
            groupKey = @groupKey;

        /* =============================
           RESULT SET 2: GROUPS
        ============================== */
        SELECT *
        FROM dbo.fn_get_field_group_lang(@groupKey, @acceptLanguage)
        ORDER BY intOrder;

        /* =============================
           RESULT SET 3: DATA (dynamic by field_name)
        ============================== */
        DECLARE @rowJson NVARCHAR(MAX);

        SELECT @rowJson =
        (
            SELECT TOP (1) *
            FROM dbo.MAS_CardVehicle_Pay
            WHERE PayId = @PayIdResolved
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        IF (@rowJson IS NULL) SET @rowJson = N'{}';

        SELECT
              a.id
            , a.table_name
            , a.field_name
            , a.view_type
            , a.data_type
            , a.ordinal
            , a.columnLabel
            , a.group_cd
            , columnValue =
                ISNULL(
                    CASE a.data_type
                        WHEN 'nvarchar' THEN
                            CASE 
                                WHEN a.field_name = 'UserId' THEN @UserId
                                ELSE j.val
                            END

                        WHEN 'datetime' THEN
                            CASE 
                                WHEN j.val IS NULL THEN NULL
                                ELSE FORMAT(TRY_CONVERT(datetime2(0), j.val), 'dd/MM/yyyy HH:mm:ss')
                            END

                        WHEN 'date' THEN
                            CASE 
                                WHEN j.val IS NULL THEN NULL
                                ELSE FORMAT(TRY_CONVERT(date, j.val), 'dd/MM/yyyy')
                            END

                        WHEN 'uniqueidentifier' THEN
                            CASE
                                WHEN a.field_name = 'paymentId' AND @paymentId IS NOT NULL
                                    THEN LOWER(CONVERT(NVARCHAR(100), @paymentId))
                                WHEN j.val IS NOT NULL
                                    THEN LOWER(j.val)
                                ELSE NULL
                            END

                        WHEN 'bit' THEN
                            j.val

                        ELSE
                            CASE
                                WHEN a.field_name = 'PayId' THEN
                                    CASE WHEN @PayIdResolved IS NULL THEN NULL ELSE CONVERT(NVARCHAR(50), @PayIdResolved) END
                                WHEN a.field_name = 'CardVehicleId' THEN
                                    CASE WHEN @cardVehicleId IS NULL THEN NULL ELSE CONVERT(NVARCHAR(50), @cardVehicleId) END
                                ELSE j.val
                            END
                    END
                , a.columnDefault)
            , a.columnClass
            , a.columnType
            , a.columnObject
            , a.isSpecial
            , a.isRequire
            , a.isDisable
            , a.IsVisiable
            , a.isEmpty
            , columnTooltip = ISNULL(a.columnTooltip, a.columnLabel)
            , a.columnDisplay
            , a.isIgnore
        FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
        OUTER APPLY (
            SELECT TOP (1) CONVERT(NVARCHAR(MAX), j2.[value]) AS val
            FROM OPENJSON(@rowJson) j2
            WHERE j2.[key] COLLATE DATABASE_DEFAULT = a.field_name COLLATE DATABASE_DEFAULT
        ) j
        WHERE a.table_name COLLATE DATABASE_DEFAULT = @tableKey COLLATE DATABASE_DEFAULT
          AND (a.IsVisiable = 1 OR a.isRequire = 1)
        ORDER BY a.ordinal;

    END TRY
    BEGIN CATCH
        DECLARE 
            @ErrorNum INT = ERROR_NUMBER(),
            @ErrorMsg VARCHAR(200) = N'sp_res_vehicle_payment_fields ' + ERROR_MESSAGE(),
            @ErrorProc VARCHAR(50) = ERROR_PROCEDURE(),
            @SessionID INT = NULL,
            @AddlInfo VARCHAR(MAX) =
                N'@UserId=' + cast(@UserId as varchar(50))
                + N'; @PayId=' + ISNULL(CONVERT(NVARCHAR(20), @PayId), 'NULL')
                + N'; @cardVehicleId=' + ISNULL(CONVERT(NVARCHAR(20), @cardVehicleId), 'NULL')
                + N'; @paymentId=' + ISNULL(CONVERT(NVARCHAR(50), @paymentId), 'NULL');

        BEGIN TRY
            EXEC utl_errorlog_set 
                @ErrorNum, @ErrorMsg, @ErrorProc, 
                N'MAS_CardVehicle_Pay', N'GET', 
                @SessionID, @AddlInfo;
        END TRY
        BEGIN CATCH
            -- ignore
        END CATCH;

        /* ===== CATCH trả đủ 3 result sets để không disposed ===== */

        -- RESULT SET 1: INFO
        SELECT 
            PayId    = @PayId,
            tableKey = @tableKey,
            groupKey = @groupKey;

        -- RESULT SET 2: GROUPS (rỗng)
        SELECT
            CAST(NULL AS NVARCHAR(200)) AS group_key,
            CAST(NULL AS NVARCHAR(50))  AS group_cd,
            CAST(NULL AS NVARCHAR(200)) AS group_name,
            CAST(NULL AS NVARCHAR(50))  AS group_column,
            CAST(NULL AS INT)           AS intOrder,
            CAST(NULL AS NVARCHAR(200)) AS key_group
        WHERE 1 = 0;

        -- RESULT SET 3: DATA (rỗng)
        SELECT
              CAST(NULL AS INT)           AS id
            , CAST(NULL AS NVARCHAR(200)) AS table_name
            , CAST(NULL AS NVARCHAR(200)) AS field_name
            , CAST(NULL AS INT)           AS view_type
            , CAST(NULL AS NVARCHAR(50))  AS data_type
            , CAST(NULL AS INT)           AS ordinal
            , CAST(NULL AS NVARCHAR(200)) AS columnLabel
            , CAST(NULL AS NVARCHAR(50))  AS group_cd
            , CAST(NULL AS NVARCHAR(MAX)) AS columnValue
            , CAST(NULL AS NVARCHAR(50))  AS columnClass
            , CAST(NULL AS NVARCHAR(50))  AS columnType
            , CAST(NULL AS NVARCHAR(500)) AS columnObject
            , CAST(NULL AS BIT)           AS isSpecial
            , CAST(NULL AS BIT)           AS isRequire
            , CAST(NULL AS BIT)           AS isDisable
            , CAST(NULL AS BIT)           AS IsVisiable
            , CAST(NULL AS BIT)           AS isEmpty
            , CAST(NULL AS NVARCHAR(200)) AS columnTooltip
            , CAST(NULL AS NVARCHAR(200)) AS columnDisplay
            , CAST(NULL AS BIT)           AS isIgnore
        WHERE 1 = 0;
    END CATCH
END