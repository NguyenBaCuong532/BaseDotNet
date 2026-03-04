







CREATE procedure [dbo].[sp_Crm_Opportunity_Process_Approve]
	@UserID	nvarchar(450),
	@ProcessId bigint
	
as
	begin try
		
			UPDATE [dbo].CRM_Opportunity_Process
			   SET approve_st = 1
				  ,approve_dt = getdate()
				  ,approve_by = @UserID
			 WHERE ProcessId = @ProcessId and approve_st = 0

	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Opportunity_Process_Approve ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@NotiId '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'OpportunityProcess', 'Set', @SessionID, @AddlInfo
	end catch