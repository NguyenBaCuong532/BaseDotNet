
-- =============================================
-- Author: ANHTT
-- Create date: 2025-12-24
-- Description: sync rocketchat user
-- Output: 
-- =============================================
create PROCEDURE [dbo].[sp_res_rocketchat_user_sync] @userId NVARCHAR(50) = NULL
    , @rocketchatUserId NVARCHAR(50)
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @valid BIT = 1
        , @messages NVARCHAR(250) = N''

    UPDATE UserInfo
    SET rocketchat_userid = @rocketchatUserId
    WHERE userId = @userId
    
    SELECT valid = @valid
        , messages = @messages
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
        , 'UserInfo'
        , 'SET'
        , @SessionID
        , @AddlInfo;
END CATCH;