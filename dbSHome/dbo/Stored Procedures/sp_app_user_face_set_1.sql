
-- =============================================
-- Author:		duongpx -
-- Create date: 12/3/2024 11:59:01 PM
-- Description:	Lwu anh  sơ cá nhân
-- =============================================
CREATE procedure [dbo].[sp_app_user_face_set]
	@userId uniqueidentifier = null,
	@acceptLanguage nvarchar(50) = null,
	@groupFileId uniqueidentifier = null
	
as
begin
	begin try	
	
	BEGIN
	    declare @valid bit = 1
        declare @messages nvarchar(100) = N'Cập nhật thông tin profile thành công' 

		UPDATE [dbo].UserInfo
		   SET face_id = @groupFileId
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
		set @ErrorMsg					= 'sp_app_user_face_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Set', @SessionID, @AddlInfo
	end catch
	 FINAL:
	    select @valid as valid
		       ,@messages as [messages]
end