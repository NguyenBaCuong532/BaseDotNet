





CREATE   procedure [dbo].[sp_app_request_closed]
	@userId uniqueidentifier,
	@RequestID	uniqueidentifier
as
	begin try		
	
	 UPDATE [dbo].MAS_Requests
	   SET [Status] = 4 --(close)
		   ,close_dt = getdate()
		   ,close_by = @userId
	 WHERE Oid = @RequestID
	 
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_app_request_closed ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Request', 'Update', @SessionID, @AddlInfo
	end catch