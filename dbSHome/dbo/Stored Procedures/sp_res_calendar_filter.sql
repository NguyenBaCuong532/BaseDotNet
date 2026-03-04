CREATE   PROCEDURE dbo.sp_res_calendar_filter
(
      @userId         NVARCHAR(450) = NULL
    , @clientId       NVARCHAR(50)  = NULL
    , @acceptLanguage NVARCHAR(50)  = N'vi-VN'
)
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Status
    SELECT [value] = CAST(v.st AS NVARCHAR(50)), [label] = v.lb
    FROM (VALUES
        (0, N'To Do'),
        (1, N'Doing'),
        (2, N'Done'),
        (9, N'Cancel')
    ) v(st, lb)
    ORDER BY v.st;

    -- Priority
    SELECT [value] = CAST(v.p AS NVARCHAR(50)), [label] = v.lb
    FROM (VALUES
        (0, N'Low'),
        (1, N'Medium'),
        (2, N'High')
    ) v(p, lb)
    ORDER BY v.p;

    -- EventType
    SELECT [value] = CAST(v.t AS NVARCHAR(50)), [label] = v.lb
    FROM (VALUES
        (0, N'Work'),
        (1, N'Meeting'),
        (2, N'Personal')
    ) v(t, lb)
    ORDER BY v.t;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_calendar_filter ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog
          @ErrorNum, @ErrorMsg, @ErrorProc
        , 'Calendar', 'GET'
        , @SessionID, @AddlInfo;
END CATCH