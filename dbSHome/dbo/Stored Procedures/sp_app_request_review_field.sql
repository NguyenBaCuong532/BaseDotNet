

-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	details of request review
-- Output: form configuration
-- =============================================
CREATE   procedure [dbo].[sp_app_request_review_field] 
	  @userId uniqueidentifier = NULL
    , @id UNIQUEIDENTIFIER = NULL
    , @sourceId UNIQUEIDENTIFIER = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @tableKey VARCHAR(50) = 'app_request_review'
    DECLARE @groupKey VARCHAR(50) = 'app_group_request_review'
    DECLARE @custId UNIQUEIDENTIFIER = dbo.fn_get_customerid(@userId)

    --begin
    --1 thong tin chung
    SELECT [id] = @id
        , sourceId = @sourceId
        , tableKey = @tableKey
        , groupKey = @groupKey

    --2- cac group
    SELECT *
    FROM [dbo].[fn_get_field_group](@groupKey)
    ORDER BY intOrder

    --fields
    SELECT a.[id]
        , a.[src_id]
        , a.[rating]
        , a.[comment]
    INTO #temp
    FROM request_review a
    WHERE a.id = @id

    -- IF @id IS NULL
    -- BEGIN
    --     INSERT INTO #temp (
    --         id
    --         , src_id
    --         )
    --     VALUES (
    --         newid()
    --         , @sourceId
    --         )
    -- END

    EXEC [sp_config_data_fields_v2] @id = @id
        , @key_name = 'id'
        , @table_name = @tableKey
        , @dataTableName = '#temp'
        , @acceptLanguage = @acceptLanguage;
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