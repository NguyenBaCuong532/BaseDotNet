


CREATE   PROCEDURE dbo.sp_res_calendar_fields
(
      @userId         NVARCHAR(450) = NULL
    , @clientId       NVARCHAR(50)  = NULL
    , @acceptLanguage NVARCHAR(50)  = N'vi-VN'
    , @oid            UNIQUEIDENTIFIER = NULL
)
AS
BEGIN TRY
    SET NOCOUNT ON;

   
    SELECT TOP 0 e.* INTO #tempIn FROM dbo.calendar_event e;

    IF @oid IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.calendar_event WHERE oid = @oid AND app_st = 1)
    BEGIN
        INSERT INTO #tempIn
        SELECT e.* FROM dbo.calendar_event e WHERE e.oid = @oid;
    END
    ELSE
    BEGIN
        IF @oid IS NULL SET @oid = NEWID();

        INSERT INTO #tempIn
        (
            oid, project_cd, build_cd,
            title, content, location,
            start_dt, end_dt, is_all_day,
            event_type, priority, status,
            assignee_userid, remind_min,
            app_st, created_at, created_by, updated_at, updated_by
        )
        VALUES
        (
            @oid, NULL, NULL,
            N'', NULL, NULL,
            SYSUTCDATETIME(), NULL, 0,
            0, 0, 0,
            NULL, NULL,
            1, SYSUTCDATETIME(), @userId, NULL, NULL
        );
    END

    SELECT * FROM #tempIn;

END TRY
BEGIN CATCH
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@msg, 16, 1);
END CATCH