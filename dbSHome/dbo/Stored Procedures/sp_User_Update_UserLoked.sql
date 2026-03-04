




CREATE procedure [dbo].[sp_User_Update_UserLoked]
	@userId	nvarchar(450),
	@IsLock bit
as
	begin try		
	
		 
		 UPDATE t1
			SET IsLock = @IsLock
		FROM MAS_Users t1 
		WHERE UserId = @userId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Update_UserLoked ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' +@userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'Update', @SessionID, @AddlInfo
	end catch