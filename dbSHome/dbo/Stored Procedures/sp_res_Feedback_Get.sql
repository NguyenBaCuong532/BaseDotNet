CREATE PROCEDURE [dbo].[sp_res_Feedback_Get]
    @UserId NVARCHAR(50)
    , @FeedbackId INT
AS
BEGIN TRY
    --1
    SELECT p.projectName
        , n.[RoomCode]
        , c.FullName
        , c.AvatarUrl
        , f.FeedbackTypeName
        , a.Title
        , a.Comment
        , dbo.fn_Get_DateAgo(a.InputDate, getdate()) FeedbackDate
        , a.FeedbackId
        , a.[Status]
        , CASE a.[Status]
            WHEN 0
                THEN N'Mới tại'
            WHEN 1
                THEN N'Đang thực hiện'
            ELSE N'Hoàn thành'
            END AS StatusName
    FROM
        [MAS_Feedbacks] a
        INNER JOIN UserInfo b ON a.UserId = b.UserId
        LEFT JOIN MAS_FeedbackType f ON f.FeedbackTypeId = a.FeedbackTypeId
        INNER JOIN MAS_Customers c ON b.CustId = c.CustId
        INNER JOIN [MAS_Apartments] n ON a.ApartmentId = n.ApartmentId
        INNER JOIN MAS_Projects p ON p.projectCd = n.projectCd
    WHERE FeedbackId = @FeedbackId

    --2
    SELECT [ProcessId]
        , FeedbackId
        , [Comment]
        , b.FullName AS [EmployeeName]
        , convert(NVARCHAR(5), a.[ProcessDt], 108) + ' - ' + convert(NVARCHAR(10), a.[ProcessDt], 103) AS [ProcessDate]
        , a.userId
        , isnull([Status], 0) [Status]
        , b.FullName
        , b.AvatarUrl
        , isnull([Status], 0) [Status]
        , CASE isnull([Status], 0)
            WHEN 0
                THEN N'Mới tại'
            WHEN 1
                THEN N'Đang thực hiện'
            ELSE N'Hoàn thành'
            END AS StatusName
    FROM MAS_FeedbackProcess a
    LEFT JOIN UserInfo b ON a.userId = b.UserId
    WHERE FeedbackId = @FeedbackId
    ORDER BY [ProcessDt] DESC

    --3
    SELECT [id]
        , FeedbackId AS requestId
        , [processId]
        , [attachUrl]
        , [attachType]
        , attachFileName
        , 1 AS used
        , [createDt]
    FROM [dbo].MAS_FeedbackAttach
    WHERE
        FeedbackId = @FeedbackId
        AND processId = 0
        
    SELECT *
    INTO #MAS_Feedbacks
    FROM MAS_Feedbacks
    WHERE
        FeedbackId = @FeedbackId
        AND (viewed_by IS NULL OR viewed_at IS NULL)
        
    IF EXISTS(SELECT TOP 1 1 FROM #MAS_Feedbacks)
    BEGIN
        UPDATE a
        SET
            a.viewed_by = ISNULL(@UserId, a.viewed_by),
            a.viewed_at = ISNULL(GETDATE(), a.viewed_at)
        FROM
            MAS_Feedbacks a
            INNER JOIN #MAS_Feedbacks b ON b.Oid = a.Oid
    END
        
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_Feedback_Get ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_FeedbackProcess'
        , 'GET'
        , @SessionID
        , @AddlInfo
END CATCH