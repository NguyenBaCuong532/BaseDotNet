





CREATE procedure [dbo].[sp_Crm_Issue_Process_Set]
	@UserID	nvarchar(450),
	@ProcessId bigint,
	@IssueId bigint,
	@Comment nvarchar(500),
	@Status int,
	@CustId nvarchar(50) = null
	
as
	begin try
		if @Status = 0 or @Status is null
			set @Status = 1		
		if not exists(select processid from [CRM_Issue_Process] where ProcessId = @ProcessId)
		begin
		if @CustId is null or @CustId = ''
			INSERT INTO [dbo].[CRM_Issue_Process]
				   ([IssueId]
				   ,[Comment]
				   ,[ProcessDt]
				   ,UserId
				   ,statusId
				   ,assignRole
				   )
			 SELECT
				    @IssueId
				   ,@Comment
				   ,getdate()
				   ,@UserID
				   ,@Status
				   ,1
			else
			INSERT INTO [dbo].[CRM_Issue_Process]
				   ([IssueId]
				   ,[Comment]
				   ,[ProcessDt]
				   ,CustId
				   ,statusId
				   ,assignRole
				   )
			 SELECT
				    @IssueId
				   ,@Comment
				   ,getdate()
				   ,@CustId
				   ,@Status
				   ,0
			
			set @ProcessId = @@IDENTITY

			UPDATE [dbo].CRM_Issues
			   SET issue_st = @Status
			 WHERE IssueId = @IssueId
		end
		else
		begin
			UPDATE [dbo].[CRM_Issue_Process]
			   SET [Comment] = @Comment
				  ,[ProcessDt] = getdate()
				  ,statusId = @Status
			 WHERE ProcessId = @ProcessId

			UPDATE [dbo].CRM_Issues
			   SET issue_st = @Status
			 WHERE IssueId = @IssueId

		end

			SELECT [ProcessId]
				  ,a.IssueId
				  ,[Comment]
				  ,b.FullName as [EmployeeName]
				  ,convert(nvarchar(10),a.[ProcessDt],103) + ' ' + convert(nvarchar(5),a.[ProcessDt],108) as [ProcessDate]  
				  ,a.CustId
				  ,statusId
		  FROM [CRM_Issue_Process] a 
			left join Users b On a.UserId = b.UserId and a.assignRole = 1
			left join MAS_Customers c On a.CustId = b.CustId 
		  WHERE ProcessId = @ProcessId


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Insert_IssueProcess ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@NotiId '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'IssueProcess', 'Insert', @SessionID, @AddlInfo
	end catch