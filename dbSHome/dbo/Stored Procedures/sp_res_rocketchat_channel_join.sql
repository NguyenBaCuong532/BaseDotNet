
-- =============================================
-- Author: ANHTT
-- Create date: 2025-12-17
-- Description: list channel
-- Output: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_rocketchat_channel_join] @userId NVARCHAR(50) = NULL
    , @channelId NVARCHAR(100)
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @valid BIT = 1
        , @messages NVARCHAR(250)

    IF EXISTS (
            SELECT 1
            FROM rocketchat_channel_member
            WHERE channel_id = @channelId
                AND user_id = @userId
            )
        OR EXISTS (
            SELECT 1
            FROM rocketchat_channel_join_request
            WHERE channel_id = @channelId
                AND user_id = @userId
                AND approval_status = 0
            )
    BEGIN
        GOTO FINAL
    END

    INSERT INTO rocketchat_channel_join_request (
        channel_id
        , user_id
        )
    VALUES (
        @channelId
        , @userId
        )

    FINAL:

    SELECT [valid] = @valid
        , [messages] = @messages
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