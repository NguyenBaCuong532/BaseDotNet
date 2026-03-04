

-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	update userid
-- Output:
-- =============================================
CREATE   PROCEDURE [dbo].[sp_app_user_userid_update] 
	  @userId uniqueidentifier = NULL
    , @loginName NVARCHAR(100)
    , @newUserId uniqueidentifier
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
	declare @lastUserId uniqueidentifier =
		(
			select userid FROM [dbo].UserInfo u
			WHERE loginName = @loginName and u.userId <> @newUserId
		)

    UPDATE a
     SET userId			= @newUserId
        ,last_dt		= GETDATE()
        ,modified_dt	= GETDATE()
		,lastUserId		= isnull(@lastUserId,a.lastUserId)
    FROM UserInfo a
    WHERE a.loginName = @loginName

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
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'UserInfo'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;