
CREATE   PROCEDURE dbo.sp_res_calendar_draft
(
      @userId    NVARCHAR(450) = NULL
    , @clientId  NVARCHAR(50)  = NULL
    , @projectCd NVARCHAR(30)  = NULL
    , @buildCd   NVARCHAR(30)  = NULL
    , @title     NVARCHAR(250) = NULL
    , @oid       UNIQUEIDENTIFIER = NULL
)
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(200) = N'';

    IF @oid IS NULL SET @oid = NEWID();
    SET @title = LTRIM(RTRIM(ISNULL(@title, N'')));
    IF @title = N'' SET @title = N'(Draft)';

    INSERT INTO dbo.calendar_event
    (
        oid, project_cd, build_cd, title,
        start_dt, is_all_day,
        event_type, priority, status,
        app_st, created_at, created_by
    )
    VALUES
    (
        @oid, @projectCd, @buildCd, @title,
        SYSUTCDATETIME(), 0,
        0, 0, 0,
        1, SYSUTCDATETIME(), @userId
    );

    SET @messages = N'Thêm mới thành công';

    SELECT @valid AS valid, @messages AS [messages];

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @valid = 0;
    SET @messages = 'sp_res_calendar_draft ' + ERROR_MESSAGE();

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = @messages;
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '@title ' + ISNULL(@title, 'NULL');

    EXEC utl_Insert_ErrorLog
          @ErrorNum, @ErrorMsg, @ErrorProc
        , 'Calendar', 'SET'
        , @SessionID, @AddlInfo;

    SELECT @valid AS valid, @messages AS [messages];
END CATCH