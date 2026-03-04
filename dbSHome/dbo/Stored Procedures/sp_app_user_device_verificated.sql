



-- =============================================
-- Author:		duongpx
-- Create date: 11/26/2024 10:16:46 AM
-- Description:	xác minh thiết bị
-- =============================================
CREATE   procedure [dbo].[sp_app_user_device_verificated]
	@userId uniqueidentifier,
	@acceptLanguage nvarchar(50) = 'vi-VN',
	@clientId	NVARCHAR(50),
	@udid		NVARCHAR(100),
	@otp		NVARCHAR(10),
	@status		INT

AS
	BEGIN TRY		
		declare @valid bit = 0
		declare @messages nvarchar(300)

		IF @status = 1
		BEGIN
		UPDATE g
		   SET etokenDevice = 1
			  ,etokenOnAt = GETDATE()
			  ,etokenFail = 0
			  ,etokenOTP = @otp
			FROM UserDevice g
		 WHERE g.udid = @udid 
				 AND g.userid = @UserID 
				 AND g.[clientId] = @clientId 
				 AND g.etokenDevice = 0
		
		--UPDATE u
		--   SET [verifyOtp] = 0
		--FROM [dbo].UserInfo u
		-- WHERE userid = @UserID 

			SET @valid =  1
			SET @messages = N'Xác minh thiết bị thành công!'
		END
		ELSE
		BEGIN
			SET @valid =  0
			SET @messages = N'Xác minh thiết bị không thành công!'
		END

		 SELECT @valid AS valid
			   ,@messages AS [messages]

	END TRY
	BEGIN CATCH
		DECLARE	@ErrorNum				INT,
				@ErrorMsg				VARCHAR(200),
				@ErrorProc				VARCHAR(50),

				@SessionID				INT,
				@AddlInfo				VARCHAR(MAX)

		SET @ErrorNum					= ERROR_NUMBER()
		SET @ErrorMsg					= 'sp_app_user_device_Verificated ' + ERROR_MESSAGE()
		SET @ErrorProc					= ERROR_PROCEDURE()

		SET @AddlInfo					= '@UserLogin '  

		EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserLog', 'Device', @SessionID, @AddlInfo
	END CATCH