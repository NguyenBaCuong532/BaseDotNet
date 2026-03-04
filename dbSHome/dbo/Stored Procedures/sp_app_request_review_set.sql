

-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	set request review
-- Output:
-- =============================================
CREATE   procedure [dbo].[sp_app_request_review_set] 
	  @userId uniqueidentifier
    , @id UNIQUEIDENTIFIER = NULL
    , @sourceId UNIQUEIDENTIFIER
    , @rating INT
    , @Comment NVARCHAR(250)
    , @acceptLanguage NVARCHAR(10) = 'vi'
AS
BEGIN TRY
    DECLARE @valid BIT
    DECLARE @messages NVARCHAR(250)

    IF @id IS NULL
        SET @id = NEWID()

    INSERT INTO request_review (
        [id]
        , [src_id]
        , [rating]
        , [comment]
        , [created_by]
        )
    VALUES (
        @id
        , @sourceId
        , @rating
        , @Comment
        , @UserId
        )

    SET @valid = 1
    SET @messages = N'Đánh giá thành công'

    SELECT [Data] = @id
        , [valid] = @valid
        , [messages] = @messages
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ''

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'Feedbacks'
        , 'SET'
        , @SessionID
        , @AddlInfo
END CATCH