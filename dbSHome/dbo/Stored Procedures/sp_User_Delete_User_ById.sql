



CREATE procedure [dbo].[sp_User_Delete_User_ById]
	@userId	nvarchar(450)	
	
as
	begin try			

		DELETE 
		FROM [dbo].MAS_Users
		WHERE UserId = @userId 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Delete_User_ById' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= 'UserId' +@userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Member', 'DEL', @SessionID, @AddlInfo
	end catch