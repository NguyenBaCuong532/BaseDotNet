
-- =============================================
-- Author: duongpx
-- Create date: 9/24/2025 9:16:52 PM
-- Description:	details of feedback
-- Output: form configuration
-- =============================================
CREATE   procedure [dbo].[sp_app_point_field] 
      @userId uniqueidentifier = NULL
    , @Oid UNIQUEIDENTIFIER = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @tableKey VARCHAR(50) = 'WAL_PointOrder'
    DECLARE @groupKey VARCHAR(50) = 'common_group'

    --begin
    --1 thong tin chung
    SELECT tableKey = @tableKey
        , groupKey = @groupKey
		,Oid = @Oid
    --2- cac group
    SELECT *
    FROM [dbo].[fn_get_field_group](@groupKey)
    ORDER BY intOrder

    --fields
    SELECT *
    INTO #temp
    FROM WAL_PointOrder a
    WHERE a.PointTranId = @Oid

    EXEC [sp_config_data_fields_v2] @id = @Oid
        , @key_name = 'Oid'
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