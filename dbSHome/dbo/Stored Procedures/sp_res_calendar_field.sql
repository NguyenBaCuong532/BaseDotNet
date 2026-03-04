
CREATE   PROCEDURE dbo.sp_res_calendar_field
(
      @userid UNIQUEIDENTIFIER = NULL
    , @id UNIQUEIDENTIFIER = NULL
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
)
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @group_key VARCHAR(50) = 'common_group';
    DECLARE @table_key VARCHAR(50) = 'calendar_event'; -- TODO: nếu config table_key khác thì đổi

    SELECT
          [id] = @id
        , tableKey = @table_key
        , groupKey = @group_key;

    SELECT *
    FROM dbo.fn_get_field_group_lang(@group_key, @acceptLanguage)
    ORDER BY intOrder;

    EXEC sp_get_data_fields
          @id
        , @table_key
        , 'oid'; -- PK column của calendar_event

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_calendar_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set
          @ErrorNum, @ErrorMsg, @ErrorProc
        , 'calendar_event', 'GetInfo'
        , @SessionID, @AddlInfo;
END CATCH;