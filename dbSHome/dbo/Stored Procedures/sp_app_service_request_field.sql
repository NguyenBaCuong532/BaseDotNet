

-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	details of service request
-- Output: form configuration
-- =============================================
CREATE   procedure [dbo].[sp_app_service_request_field] @userId uniqueidentifier = NULL
    , @id UNIQUEIDENTIFIER = NULL
    , @serviceId UNIQUEIDENTIFIER = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @tableKey VARCHAR(50) = 'app_service_request'
    DECLARE @groupKey VARCHAR(50) = 'app_group_service_request'
    DECLARE @custId UNIQUEIDENTIFIER = dbo.fn_get_customerid(@userId)
    DECLARE @rating INT = NULL
    DECLARE @estimated_amount DECIMAL

    IF @id IS NOT NULL
    BEGIN
        SELECT @serviceId = service_id
            , @estimated_amount = estimated_amount
        FROM service_request
        WHERE id = @id

        SELECT @rating = rating
        FROM request_review
        WHERE src_id = @id
    END

    --begin
    --1 thong tin chung
    SELECT [id] = @id
        , serviceId = @serviceId
        , EstimatedAmount = @estimated_amount
        , rating = @rating
        , tableKey = @tableKey
        , groupKey = @groupKey

    --2- cac group
    SELECT *
    FROM dbo.fn_get_field_group_lang(@groupKey, @acceptLanguage)
    ORDER BY intOrder

    --fields
    SELECT a.[id]
        , a.[apartment_id]
        , a.[package_id]
        , a.[service_date]
        , a.[service_time]
        , a.[speed_extra_id]
        , a.[is_quick_support]
        --, a.[estimated_amount]
        , [service_extra] = (
            SELECT STRING_AGG(LOWER(sa.service_package_id), ',')
            FROM service_request_extra sa
            WHERE sa.service_request_id = @id
            )
        , a.[status]
    INTO #temp
    FROM service_request a
    WHERE a.id = @id

    IF @id IS NULL
    BEGIN
        DECLARE @main_apartment_id BIGINT

        SELECT @main_apartment_id = ApartmentId
        FROM MAS_Apartment_Member
        WHERE main_st = 1
            AND CustId = @custId

        INSERT INTO #temp (
            id
            , apartment_id
            )
        VALUES (
            newid()
            , @main_apartment_id
            )
    END

    --tạo bảng tạm lưu form config
    SELECT *
    INTO #form
    FROM dbo.fn_config_form_gets_temp()

    INSERT INTO #form
    EXEC [sp_config_data_fields_v2] @id = @id
        , @key_name = 'id'
        , @table_name = @tableKey
        , @dataTableName = '#temp'
        , @acceptLanguage = @acceptLanguage;

    --update field
    UPDATE a
    SET columnObject = CONCAT (
            columnObject
            , CASE a.field_name
                WHEN 'package_id'
                    THEN lower(@serviceId)
                END
            )
    FROM #form a
    WHERE columnObject IS NOT NULL

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