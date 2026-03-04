
CREATE    PROCEDURE dbo.sp_res_calendar_page
(
      @UserId         UNIQUEIDENTIFIER
    , @clientId       NVARCHAR(50)  = NULL
    , @projectCd      NVARCHAR(30)  = NULL
    , @buildCd        NVARCHAR(30)  = NULL
    , @status         INT           = NULL
    , @eventType      INT           = NULL
    , @priority       INT           = NULL
    , @fromDt         DATETIME2(0)  = NULL
    , @toDt           DATETIME2(0)  = NULL
    , @filter         NVARCHAR(200) = NULL
    , @gridWidth      INT           = 0
    , @Offset         INT           = 0
    , @PageSize       INT           = 10
    , @acceptLanguage NVARCHAR(50)  = N'vi-VN'
)
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @Total   BIGINT;
    DECLARE @GridKey NVARCHAR(100) = 'view_res_calendar_page'; -- TODO: đổi đúng gridKey config

    SET @projectCd = NULLIF(LTRIM(RTRIM(ISNULL(@projectCd, N''))), N'');
    SET @buildCd   = NULLIF(LTRIM(RTRIM(ISNULL(@buildCd,   N''))), N'');
    SET @filter    = LTRIM(RTRIM(ISNULL(@filter, N'')));

    SET @Offset   = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    IF @PageSize <= 0 SET @PageSize = 10;
    IF @Offset < 0 SET @Offset = 0;

    ;WITH Q AS
    (
        SELECT e.*
        FROM dbo.calendar_event e
        WHERE e.app_st = 1
          AND (@projectCd IS NULL OR e.project_cd = @projectCd)
          AND (@buildCd   IS NULL OR e.build_cd   = @buildCd)
          AND (@status    IS NULL OR e.status     = @status)
          AND (@eventType IS NULL OR e.event_type = @eventType)
          AND (@priority  IS NULL OR e.priority   = @priority)
          AND (@fromDt    IS NULL OR e.start_dt  >= @fromDt)
          AND (@toDt      IS NULL OR e.start_dt  <  @toDt)
          AND (
                @filter = N'' OR
                e.title LIKE N'%' + @filter + N'%' OR
                ISNULL(e.location, N'') LIKE N'%' + @filter + N'%'
          )
          -- nếu có phân quyền theo project:
          -- AND EXISTS (SELECT 1 FROM dbo.UserProject up WHERE up.projectCd = e.project_cd AND up.userId = @UserId)
    )
	select * into #Q
	from Q

    SELECT @Total = COUNT(1) FROM #Q;

    -- root
    SELECT
          recordsTotal    = @Total
        , recordsFiltered = @Total
        , gridKey         = @GridKey
        , valid           = 1;

    -- grid config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM dbo.fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY ordinal;
    END

    -- data
    SELECT *
    FROM #Q
    ORDER BY created_at desc
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_calendar_page ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog
          @ErrorNum, @ErrorMsg, @ErrorProc
        , 'Calendar', 'GET'
        , @SessionID, @AddlInfo;
END CATCH