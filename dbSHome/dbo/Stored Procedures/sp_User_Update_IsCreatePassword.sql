






CREATE procedure [dbo].[sp_User_Update_IsCreatePassword]
	@UserLogin	nvarchar(50),
	@UserPassword nvarchar(50),
	@isCreate bit
as
	begin try		
	
		update t1
			set  IsCreatePassword = @isCreate
				,UserPassword = @UserPassword
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
		set @ErrorMsg					= 'sp_User_Update_IsCreatePass ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin ' + @UserLogin

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'UserPass', 'Update', @SessionID, @AddlInfo
	end catch