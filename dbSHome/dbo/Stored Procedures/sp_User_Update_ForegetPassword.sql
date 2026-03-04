







CREATE procedure [dbo].[sp_User_Update_ForegetPassword]
	@UserLogin	nvarchar(50)
as
	begin try		
	
		update t1
			set  IsVerify = 0
		FROM MAS_Users t1
		WHERE t1.UserLogin = @UserLogin


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Update_ForegetPassword ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin ' + @UserLogin

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'UserPass', 'Update', @SessionID, @AddlInfo
	end catch