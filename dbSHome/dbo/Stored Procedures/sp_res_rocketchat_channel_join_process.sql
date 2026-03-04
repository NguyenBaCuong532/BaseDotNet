
-- =============================================
-- Author: ANHTT
-- Create date: 2025-12-17
-- Description: list channel
-- Output: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_rocketchat_channel_join_process] @userId NVARCHAR(50) = NULL
    , @requestId UNIQUEIDENTIFIER
    , @approve BIT
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @valid BIT = 0
        , @messages NVARCHAR(250)

    IF NOT EXISTS (
            SELECT 1
            FROM rocketchat_channel_join_request
            WHERE id = @requestId
                AND approval_status = 0
            )
    BEGIN
        SET @messages = N'Yêu cầu đã được xử lý'

        GOTO FINAL
    END

    DECLARE @channel_id VARCHAR(50)
        , @user_id UNIQUEIDENTIFIER
        , @rc_userid NVARCHAR(50)

    SELECT @channel_id = channel_id
        , @user_id = user_id
    FROM rocketchat_channel_join_request

    SELECT @rc_userid = rocketchat_userid
    FROM UserInfo
    WHERE userId = @user_id

    IF ISNULL(@rc_userid, '') = ''
    BEGIN
        SET @messages = N'Người dùng chưa được gán tài khoản chat'

        GOTO FINAL
    END

    BEGIN TRAN

    UPDATE a
    SET a.approval_status = IIF(@approve = 1, 1, - 1)
    FROM rocketchat_channel_join_request a
    WHERE id = @requestId

    IF @approve = 1
    BEGIN
        INSERT INTO rocketchat_channel_member (
            channel_id
            , user_id
            , [status]
            )
        SELECT channel_id
            , user_id
            , 1
        FROM rocketchat_channel_join_request r
        WHERE id = @requestId
            AND NOT EXISTS (
                SELECT 1
                FROM rocketchat_channel_member rcm
                WHERE rcm.channel_id = r.channel_id
                    AND rcm.user_id = r.user_id
                )
    END

    COMMIT

    SET @valid = 1

    FINAL:

    SELECT [valid] = @valid
        , [messages] = @messages

    SELECT [RoomId] = @channel_id
        , [UserId] = @rc_userid
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    PRINT @ErrorMsg

    --SET @AddlInfo = NULL;
    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'rocketchat_channel_join_request'
        , 'SET'
        , @SessionID
        , @AddlInfo;
END CATCH;