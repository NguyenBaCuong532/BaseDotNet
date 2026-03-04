

CREATE   PROCEDURE dbo.sp_res_calendar_set
(
      @userId         UNIQUEIDENTIFIER = NULL
    , @clientId       NVARCHAR(50)  = NULL
    , @acceptLanguage NVARCHAR(50)  = N'vi-VN'

    , @oid            UNIQUEIDENTIFIER = NULL
    , @projectCd      NVARCHAR(30)  = NULL
    , @buildCd        NVARCHAR(30)  = NULL
    , @title          NVARCHAR(250) = NULL
    , @content        NVARCHAR(MAX) = NULL
    , @location       NVARCHAR(250) = NULL
    , @startDt        DATETIME2(0)  = NULL
    , @endDt          DATETIME2(0)  = NULL
    , @isAllDay       BIT           = 0
    , @eventType      INT           = 0
    , @priority       INT           = 0
    , @status         INT           = 0
    , @assigneeUserId NVARCHAR(450) = NULL
    , @remindMin      INT           = NULL
)
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(200) = N'';

    SET @title = LTRIM(RTRIM(ISNULL(@title, N'')));

    IF @title = N''
    BEGIN
        SET @valid = 0;
        SET @messages = N'Phải nhập tiêu đề';
        SELECT @valid AS valid, @messages AS [messages];
        RETURN;
    END

    IF @startDt IS NULL
    BEGIN
        SET @valid = 0;
        SET @messages = N'Phải nhập thời gian bắt đầu';
        SELECT @valid AS valid, @messages AS [messages];
        RETURN;
    END

    IF @endDt IS NOT NULL AND @endDt < @startDt
    BEGIN
        SET @valid = 0;
        SET @messages = N'Thời gian kết thúc phải >= bắt đầu';
        SELECT @valid AS valid, @messages AS [messages];
        RETURN;
    END

    IF @oid IS NULL SET @oid = NEWID();

    IF EXISTS (SELECT 1 FROM dbo.calendar_event WHERE oid = @oid)
    BEGIN
        UPDATE dbo.calendar_event
        SET
              project_cd      = @projectCd
            , build_cd        = @buildCd
            , title           = @title
            , content         = @content
            , location        = @location
            , start_dt        = @startDt
            , end_dt          = @endDt
            , is_all_day      = ISNULL(@isAllDay, 0)
            , event_type      = ISNULL(@eventType, 0)
            , priority        = ISNULL(@priority, 0)
            , status          = ISNULL(@status, 0)
            , assignee_userid = @assigneeUserId
            , remind_min      = @remindMin
            , app_st          = 1
            , updated_at      = SYSUTCDATETIME()
            , updated_by      = @userId
        WHERE oid = @oid;

        SET @messages = N'Cập nhật thành công';
    END
    ELSE
    BEGIN
        INSERT INTO dbo.calendar_event
        (
            oid, project_cd, build_cd,
            title, content, location,
            start_dt, end_dt, is_all_day,
            event_type, priority, status,
            assignee_userid, remind_min,
            app_st, created_at, created_by
        )
        VALUES
        (
            @oid, @projectCd, @buildCd,
            @title, @content, @location,
            @startDt, @endDt, ISNULL(@isAllDay, 0),
            ISNULL(@eventType, 0), ISNULL(@priority, 0), ISNULL(@status, 0),
            @assigneeUserId, @remindMin,
            1, SYSUTCDATETIME(), @userId
        );

        SET @messages = N'Thêm mới thành công';
    END

    SELECT @valid AS valid, @messages AS [messages];

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @valid = 0;
    SET @messages = 'sp_res_calendar_set ' + ERROR_MESSAGE();

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