

CREATE   procedure [dbo].[sp_app_request_voted]
	@userId uniqueidentifier,
	@RequestId uniqueidentifier,
	@Comment nvarchar(max),
	@rating int
as
	begin try		
		
			UPDATE [dbo].MAS_Requests
				SET  review_dt = getdate()
					,rating = @rating
					,review_comment = @Comment
			WHERE Oid = @RequestId


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_app_request_voted ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@ApartmentId '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Request_Voted', 'Insert', @SessionID, @AddlInfo
	end catch