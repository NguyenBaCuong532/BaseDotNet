



CREATE procedure [dbo].[sp_Hom_Request_Closed]
	@userId		nvarchar(450),
	@RequestID	int
as
	begin try		
	
	 UPDATE [dbo].MAS_Requests
	   SET [Status] = 4
	 WHERE RequestID = @RequestID
	 
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Request_Closed ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Request', 'Update', @SessionID, @AddlInfo
	end catch