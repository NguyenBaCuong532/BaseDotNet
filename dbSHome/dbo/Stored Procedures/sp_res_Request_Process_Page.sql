
CREATE PROCEDURE [dbo].[sp_res_Request_Process_Page] @UserId NVARCHAR(450)
    , @requestId BIGINT
    , @Filter NVARCHAR(30)
    , @Offset INT = 0
    , @PageSize INT = 10
    , @Total INT OUT
    , @TotalFiltered INT OUT
	, @GridKey NVARCHAR(200) ='' OUTPUT
AS
BEGIN TRY
    SET @Offset = isnull(@Offset, 0)
    SET @PageSize = isnull(@PageSize, 10)
    SET @Total = isnull(@Total, 0)
    SET @filter = isnull(@filter, '')
    SET @GridKey = isnull(@GridKey, '') 

    IF @PageSize = 0
        SET @PageSize = 10

    IF @Offset < 0
        SET @Offset = 0

    -- Rest of your procedure remains the same...
    SELECT @Total = count(a.requestId)
    FROM [MAS_Request_Process] a
    LEFT JOIN Users b
        ON a.userId = b.UserId
    WHERE requestId = @requestId
        AND (
            @Filter = ''
            OR b.loginName = @Filter
            OR b.Phone = @Filter
            )

    SET @TotalFiltered = @Total

    IF @PageSize < 0
    BEGIN
        SET @PageSize = 10
    END

    -- Your existing SELECT statements...
    SELECT ProcessId
        , requestId
        , [Comment]
        , dbo.fn_Get_TimeAgo1(a.ProcessDt, getdate()) AS ProcessDate
        , b.loginName AS UserName
        , CASE 
            WHEN a.UserId = @UserId
                THEN 0
            ELSE 0
            END AS IsOwn
        , a.STATUS
        , s.StatusName
    FROM [MAS_Request_Process] a
    LEFT JOIN Users b
        ON a.userId = b.UserId
    LEFT JOIN CRM_Status s
        ON a.STATUS = s.StatusId
            AND s.statusKey = 'Request'
    WHERE requestId = @requestId
        AND (
            @Filter = ''
            OR b.loginName = @Filter
            OR b.Phone = @Filter
            )
    ORDER BY ProcessDt DESC offset @Offset rows
    FETCH NEXT @PageSize rows ONLY

    SELECT [id]
        , requestId
        , [processId]
        , [attachUrl]
        , [attachType]
        , attachFileName
        , 1 AS used
        , [createDt]
    FROM [dbSHome].[dbo].[MAS_Request_Attach]
    WHERE requestId = @requestId
        AND processId > 0
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_Request_Process_Page ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Request_Process'
        , 'GET'
        , @SessionID
        , @AddlInfo
END CATCH