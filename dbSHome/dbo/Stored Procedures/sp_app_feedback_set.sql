
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	set feedback
-- Output:
-- =============================================
CREATE   procedure [dbo].[sp_app_feedback_set] 
      @userId uniqueidentifier
    , @id UNIQUEIDENTIFIER = NULL
    , @clientId NVARCHAR(50) = NULL
    , @FeedbackTypeId INT = 0
    , @Title NVARCHAR(100)
    , @Comment NVARCHAR(max)
    , @attach UNIQUEIDENTIFIER = NULL
    , @InputDate NVARCHAR(30) = NULL
AS
BEGIN TRY
    DECLARE @valid BIT
    DECLARE @messages NVARCHAR(250)
    DECLARE @appId INT = 0
    DECLARE @ApartmentId BIGINT

    --SET @appId = dbo.fn_get_appid(@clientId)
    IF @ApartmentId IS NULL
        OR @ApartmentId = 0
        SET @ApartmentId = ([dbo].[fn_get_apartment_main](dbo.fn_get_customerid(@UserId)));
     
    IF @ApartmentId IS NULL
        SET @ApartmentId = (
                SELECT TOP 1 a.ApartmentId
                FROM [MAS_Apartments] a
                JOIN UserInfo u
                    ON a.UserLogin = u.loginName
                WHERE EXISTS (
                        SELECT userId
                        FROM UserInfo
                        WHERE userid = @UserId
                            AND CustId = u.CustId
                        )
                ORDER BY isnull(a.isMain, 0) DESC
                )

    IF @id IS NULL
    BEGIN
        SET @id = NEWID()

        INSERT INTO [dbo].MAS_Feedbacks (
            Oid
            , UserId
            , Title
            , Comment
            , [InputDate]
            , FeedbackTypeId
            , AppId
            , ClientId
            , ApartmentId
            , AttachOid
            ,Status
           -- ,viewed_by
            ,viewed_at
            )
        VALUES (
            @id
            , @UserId
            , @Title
            , @Comment
            , getdate()
            , @FeedbackTypeId
            , @appId
            , @ClientID
            , @ApartmentId
            , @attach
            ,1
           -- ,null
            ,getdate()
            )

        SET @valid = 1
        SET @messages = N'Gửi góp ý thành công'
    END

    -- ELSE
    -- BEGIN
    --     UPDATE MAS_Feedbacks
    --     SET Title = @Title
    --         , Comment = @Comment
    --         , FeedbackTypeId = @FeedbackTypeId
    --     WHERE FeedbackId = @id
    --     SET @valid = 1
    --     SET @messages = N'Cập nhật góp ý thành công'
    -- END
    SELECT [id] = @id
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