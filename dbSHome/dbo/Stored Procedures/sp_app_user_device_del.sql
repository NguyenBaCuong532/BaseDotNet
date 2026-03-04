



-- =============================================
-- Author:		duongpx
-- Create date: 11/26/2024 10:16:46 AM
-- Description:	xóa thiết bị
-- =============================================
CREATE   procedure [dbo].[sp_app_user_device_del]
	@userId uniqueidentifier = null,
	@acceptLanguage nvarchar(50) = 'vi-VN',
	@clientId		NVARCHAR(50),
	@udid			NVARCHAR(50)
AS
BEGIN
	DECLARE @valid BIT = 1
	DECLARE @messages NVARCHAR(100) = N'Xóa thiết bị thành công'

	BEGIN TRY		
		
			DELETE t
			FROM UserDevice t 
			WHERE udid = @udid 
			AND userid = @UserID --and [clientId] = @clientId

	END TRY
	BEGIN CATCH
		DECLARE	@ErrorNum				INT,
				@ErrorMsg				VARCHAR(200),
				@ErrorProc				VARCHAR(50),

				@SessionID				INT,
				@AddlInfo				VARCHAR(MAX)

		SET @ErrorNum					= ERROR_NUMBER()
		SET @ErrorMsg					= 'sp_app_user_device_Del ' + ERROR_MESSAGE()
		SET @ErrorProc					= ERROR_PROCEDURE()

		SET @AddlInfo					= '@UserID ' -- + @UserID 
		SET @valid = 0
		SET @messages = ERROR_MESSAGE()

		EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'User', 'Del', @SessionID, @AddlInfo
	END CATCH


	SELECT @valid AS valid
		  ,@messages AS [messages]


END