

-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-23
-- Description:	set service_request
-- Output:
-- =============================================
CREATE   procedure [dbo].[sp_app_service_request_set_draft] @userId uniqueidentifier
    , @info NVARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @EstimatedAmount DECIMAL = 0;
    DECLARE @is_quick_support BIT

    DROP TABLE

    IF EXISTS #fields;
        SELECT a.[group_index]
            , a.[field_index]
            , a.[group_cd]
            , a.[field_name]
            , a.[columnValue]
            , [b].[id]
        INTO #fields
        FROM dbo.fn_get_fields_from_json(@info, null) a
        OUTER APPLY (
            SELECT id = [value]
            FROM string_split(a.columnValue, ',')
            ) b

    SELECT @EstimatedAmount = ISNULL((
                SELECT SUM(price)
                FROM service_package
                WHERE id IN (
                        SELECT id
                        FROM #fields
                        WHERE field_name IN ('package_id', 'service_extra')
                            AND id IS NOT NULL
                        )
                ), 0)

    SELECT @EstimatedAmount = @EstimatedAmount + ISNULL((
                SELECT SUM(price)
                FROM service_speed_extra
                WHERE id IN (
                        SELECT id
                        FROM #fields
                        WHERE field_name IN ('speed_extra_id')
                            AND id IS NOT NULL
                        )
                ), 0)
    FROM #fields

    SET @info = JSON_MODIFY(@info, '$.EstimatedAmount', @EstimatedAmount)

    DECLARE @current_date DATETIME = GETDATE()
    DECLARE @service_date NVARCHAR(10) = CONVERT(NVARCHAR, @current_date, 103)
    DECLARE @service_time NVARCHAR(5) = CONVERT(TIME, @current_date)


    SELECT @is_quick_support = columnValue
    FROM #fields
    WHERE field_name = 'is_quick_support'

    IF @is_quick_support = 1
        UPDATE f
        SET @info = JSON_MODIFY(@info, '$.group_fields[' + f.group_index + '].fields[' + f.field_index + '].columnValue', CASE f.field_name
                    WHEN 'service_date'
                        THEN @service_date
                    WHEN 'service_time'
                        THEN @service_time
                    END)
        FROM #fields f
        WHERE field_name IN ('service_date', 'service_time')

    SELECT @info
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
    SET @AddlInfo = ''

    PRINT @ErrorMsg

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'service_request'
        , 'SET'
        , @SessionID
        , @AddlInfo
END CATCH