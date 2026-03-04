






CREATE procedure [dbo].[sp_Crm_Opportunity_Process_Set]
	@UserID	nvarchar(450),
	@ProcessId bigint,
	@opp_Id bigint,
	@Comment nvarchar(500),
	@Status int
	
as
	begin try
		
		if @Status = 0 or @Status is null
			set @Status = 1		
		if not exists(select processid from CRM_Opportunity_Process where ProcessId = @ProcessId)
		begin
		
			INSERT INTO [dbo].CRM_Opportunity_Process
				   (opp_Id
				   ,[comment]
				   ,[processDt]
				   ,userId
				   ,statusId
				   ,assignRole
				   ,approve_st 
				   ,approve_dt 
				   ,approve_by 
				   )
			 SELECT
				    @opp_Id
				   ,@Comment
				   ,getdate()
				   ,@UserID
				   ,@Status
				   ,a.assignRole 
				   ,case when a.assignRole = 1 then 1 else 0 end
				   ,case when a.assignRole = 1 then getdate() else null end
				   ,case when a.assignRole = 1 then userId else null end
			from CRM_Opportunity_Assign a
			where userId = @UserID 
				and opp_Id = @opp_Id 

			set @ProcessId = @@IDENTITY

			UPDATE [dbo].CRM_Opportunity
			   SET opp_st = @Status
			 WHERE Id = @opp_Id
		end
		else
		begin
			UPDATE [dbo].CRM_Opportunity_Process
			   SET [Comment] = @Comment
				  ,[ProcessDt] = getdate()
				  ,statusId = @Status
			 WHERE ProcessId = @ProcessId

			UPDATE [dbo].CRM_Opportunity
			   SET opp_st = @Status
			 WHERE Id = @opp_Id

		end

			SELECT [ProcessId]
				  ,a.opp_Id
				  ,[Comment]
				  ,b.UserLogin as userName
				  ,convert(nvarchar(10),a.[ProcessDt],103) + ' ' + convert(nvarchar(5),a.[ProcessDt],108) as [ProcessDate]  
				  ,statusId
		  FROM CRM_Opportunity_Process a 
			left join MAS_Users b On a.UserId = b.UserId --and a.assignRole = 1
		  WHERE ProcessId = @ProcessId


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Opportunity_Process ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@NotiId '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'OpportunityProcess', 'Insert', @SessionID, @AddlInfo
	end catch