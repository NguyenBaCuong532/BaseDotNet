
CREATE PROCEDURE [dbo].[sp_res_Feedback_Process_Set] @UserID NVARCHAR(50)
    , @FeedbackId INT
    , @Comment NVARCHAR(max)
    , @Status INT
AS
BEGIN TRY
    INSERT INTO [dbo].MAS_FeedbackProcess (
        [FeedbackId]
        , Comment
        , userId
        , [ProcessDt]
        , [Status]
        )
    VALUES (
        @FeedbackId
        , @Comment
        , @UserID
        , getdate()
        , @Status
        )

    UPDATE [dbo].[MAS_Feedbacks]
    SET [Status] = @Status
    WHERE [FeedbackId] = @FeedbackId

    SELECT [ProcessId]
        , a.[FeedbackId]
        , [Comment]
        , b.FullName AS [EmployeeName]
        , convert(NVARCHAR(10), a.[ProcessDt], 103) + ' ' + convert(NVARCHAR(5), a.[ProcessDt], 108) AS [ProcessDate]
        , a.userId
        , [Status]
    FROM MAS_FeedbackProcess a
    LEFT JOIN Users b
        ON a.userId = b.UserId
    WHERE ProcessId = @@IDENTITY
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_Feedback_Process_Set ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = '@NotiId ' + @FeedbackId

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_FeedbackProcess'
        , 'Set'
        , @SessionID
        , @AddlInfo
END CATCH