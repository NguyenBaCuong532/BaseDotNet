

-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	feedback filter
-- Output: form configuration
-- =============================================
CREATE   PROCEDURE [dbo].[sp_app_feedback_filter] @userId uniqueidentifier = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @tableKey VARCHAR(50) = 'app_filter_feedback'
    DECLARE @groupKey VARCHAR(50) = 'common_group'

    --begin
    --1 thong tin chung
    SELECT tableKey = @tableKey
        , groupKey = @groupKey

    --2- cac group
    SELECT *
    FROM [dbo].[fn_get_field_group](@groupKey)
    ORDER BY intOrder

    --fields
    SELECT projectCd = NULL
    INTO #temp

    EXEC [sp_config_data_fields_v2] @id = null
        , @key_name = 'projectCd'
        , @table_name = @tableKey
        , @dataTableName = '#temp'
        , @acceptLanguage = @acceptLanguage
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