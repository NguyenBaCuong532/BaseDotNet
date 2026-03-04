


CREATE   PROCEDURE dbo.sp_res_calendar_export
(
      @userId         NVARCHAR(450) = NULL
    , @clientId       NVARCHAR(50)  = NULL
    , @acceptLanguage NVARCHAR(50)  = N'vi-VN'

    , @projectCd      NVARCHAR(30)  = NULL
    , @buildCd        NVARCHAR(30)  = NULL
    , @status         INT           = NULL
    , @eventType      INT           = NULL
    , @priority       INT           = NULL
    , @fromDt         DATETIME2(0)  = NULL
    , @toDt           DATETIME2(0)  = NULL
    , @filter         NVARCHAR(200) = NULL
)
AS
BEGIN TRY
    SET NOCOUNT ON;
    SET @filter = LTRIM(RTRIM(ISNULL(@filter, N'')));

    SELECT
        [Tiêu đề]        = title,
        [Nội dung]       = content,
        [Địa điểm]       = location,
        [Bắt đầu]        = CONVERT(NVARCHAR(19), start_dt, 103),
        [Kết thúc]       = CASE WHEN end_dt IS NULL THEN NULL ELSE CONVERT(NVARCHAR(19), end_dt, 103) END,
        [Cả ngày]        = CASE WHEN is_all_day = 1 THEN N'Có' ELSE N'Không' END,
        [Loại]           = event_type,
        [Ưu tiên]        = priority,
        [Trạng thái]     = status,
        [Người được giao]= assignee_userid
    FROM dbo.calendar_event
    WHERE app_st = 1
      AND (@projectCd IS NULL OR project_cd = @projectCd)
      AND (@buildCd   IS NULL OR build_cd   = @buildCd)
      AND (@status    IS NULL OR status     = @status)
      AND (@eventType IS NULL OR event_type = @eventType)
      AND (@priority  IS NULL OR priority   = @priority)
      AND (@fromDt    IS NULL OR start_dt  >= @fromDt)
      AND (@toDt      IS NULL OR start_dt  <  @toDt)
      AND (
            @filter = N'' OR
            title LIKE N'%' + @filter + N'%' OR
            ISNULL(location, N'') LIKE N'%' + @filter + N'%'
      )
    ORDER BY start_dt DESC;

END TRY
BEGIN CATCH
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@msg, 16, 1);
END CATCH