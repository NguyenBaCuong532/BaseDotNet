


CREATE procedure [dbo].[sp_Crm_Card_Lock]
	@UserID	nvarchar(450),
	@CardCd nvarchar(50),
	@Status int
as
	begin try		 
		if @Status = 1
			Update CRM_Card
				set Status = 3
			where CardCd = @CardCd
		else
			Update CRM_Card
			set Status = 1
		where CardCd = @CardCd

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Card_Lost ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'Update', @SessionID, @AddlInfo
	end catch