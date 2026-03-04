






CREATE procedure [dbo].[sp_User_Update_EmailConfirmed]
	@UserId nvarchar(450)
as
	begin try	
	
		UPDATE [dbo].MAS_Users
		   SET EmailConfirm = 2
		 WHERE UserId = @UserId

		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Update_EmailConfirmed ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'EmailConfirmed', 'Update', @SessionID, @AddlInfo
	end catch