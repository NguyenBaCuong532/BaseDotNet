

CREATE   PROCEDURE dbo.sp_res_calendar_del
(
      @userId         NVARCHAR(450)
    , @oid            UNIQUEIDENTIFIER
)
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(100) = N'';

    IF NOT EXISTS (SELECT 1 FROM dbo.calendar_event WHERE oid = @oid AND app_st = 1)
    BEGIN
        SET @valid = 0;
        SET @messages = N'Không tìm thấy dữ liệu';
        SELECT @valid AS valid, @messages AS [messages];
        RETURN;
    END

    UPDATE dbo.calendar_event
    SET
        app_st     = 0,
        updated_at = SYSUTCDATETIME(),
        updated_by = @userId
    WHERE oid = @oid AND app_st = 1;

    SET @messages = N'Xóa thành công';

    SELECT @valid AS valid, @messages AS [messages];
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @valid = 0;
    SET @messages = 'sp_res_calendar_del ' + ERROR_MESSAGE();

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = @messages;
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = CAST(@oid AS VARCHAR(50));

    EXEC utl_Insert_ErrorLog
          @ErrorNum, @ErrorMsg, @ErrorProc
        , 'Calendar', 'DEL'
        , @SessionID, @AddlInfo;

    SELECT @valid AS valid, @messages AS [messages];
END CATCH