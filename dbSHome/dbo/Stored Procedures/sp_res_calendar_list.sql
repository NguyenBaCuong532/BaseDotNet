
CREATE   PROCEDURE dbo.sp_res_calendar_list
(
      @UserId NVARCHAR(50) = NULL
    , @projectCd NVARCHAR(30) = NULL
)
AS
BEGIN TRY
    SET NOCOUNT ON;

    SELECT TOP (50)
          [value] = CAST(oid AS NVARCHAR(50))
        , [name]  = title
    FROM dbo.calendar_event
    WHERE app_st = 1
      AND (@projectCd IS NULL OR project_cd = @projectCd)
    ORDER BY start_dt DESC, created_at DESC;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_calendar_list' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog
          @ErrorNum, @ErrorMsg, @ErrorProc
        , 'calendar_event', 'GET'
        , @SessionID, @AddlInfo;
END CATCH;