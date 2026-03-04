


-- =============================================
-- Author:		duongpx
-- Create date: 11/26/2024 10:16:46 AM
-- Description:	lấy thông tin xác minh thiết bị
-- =============================================
CREATE   procedure [dbo].[sp_app_user_device_verify_get]
	@userId uniqueidentifier,
	@acceptLanguage nvarchar(50) = 'vi-VN',
	@clientId	NVARCHAR(50),
	@udid		NVARCHAR(100)
AS
BEGIN
	declare @valid bit = 0
	declare @messages nvarchar(300)

	BEGIN TRY	
		IF NOT EXISTS(SELECT 1 FROM UserDevice t 
			WHERE udid = @udid AND userid = @UserID AND [clientId] = @clientId AND etokenDevice = 0)
		BEGIN
			SET @valid = 0
			SET @messages = N'Không tìm thấy thông tin!'
			GOTO FINAL
		END

		  -- profile
		  SELECT cast(regOid as varchar(50)) AS reg_id
				,[phone]	
				,[email]	
				--,[verifyType]
				,CASE WHEN etokenFail <= 5 THEN 1 ELSE 0 END AS valid
				,CASE WHEN etokenFail <= 5 THEN '' ELSE N'Đã quá số lần gửi OTP cho phép!' END AS [messages]
				,u.userId
			FROM [dbo].UserInfo u 
				JOIN UserDevice g ON u.userId = g.userId
			 WHERE g.udid = @udid 
				 AND g.userid = @UserID 
				 AND g.[clientId] = @clientId 
				 AND g.etokenDevice = 0

	END TRY
	BEGIN CATCH
		DECLARE	@ErrorNum				INT,
				@ErrorMsg				VARCHAR(200),
				@ErrorProc				VARCHAR(50),

				@SessionID				INT,
				@AddlInfo				VARCHAR(MAX)

		SET @ErrorNum					= ERROR_NUMBER()
		SET @ErrorMsg					= 'sp_app_user_device_Verify_Get ' + ERROR_MESSAGE()
		SET @ErrorProc					= ERROR_PROCEDURE()

		SET @AddlInfo					= '@UserLogin '
		SET @valid = 0
		SET @messages = ERROR_MESSAGE()

		EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'Device', 'Set', @SessionID, @AddlInfo
	END CATCH

	FINAL:
	SELECT @valid AS valid
	      ,@messages AS [messages]


END