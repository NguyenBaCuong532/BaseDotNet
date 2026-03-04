




-- =============================================
-- Author:		duongpx 
-- Create date: 11/7/2024 11:45:57 AM
-- Description:	Lưu thông tin ảnh các nhân
-- =============================================
CREATE   procedure [dbo].[sp_app_user_profile_image_set]
	@userId uniqueidentifier = null,
	@acceptLanguage nvarchar(50) = null,
	@imageUrl nvarchar(500) = null,
	@imageType nvarchar(50) = null
	
as
	begin try	
	
	BEGIN
	    declare @valid bit = 1
        declare @messages nvarchar(100) = N'Cập nhật thông tin profile thành công' 

		if @imageType = 'avatar'
			UPDATE [dbo].UserInfo
			   SET avatarUrl = @imageUrl
			 WHERE userId = @userId
		 else
			 UPDATE  UserInfo
			   SET avatarUrl = @imageUrl
			 WHERE userId = @userId
	END

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_user_profile_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Set', @SessionID, @AddlInfo
	end catch
	 FINAL:
	    select @valid as valid
		       ,@messages as [messages]