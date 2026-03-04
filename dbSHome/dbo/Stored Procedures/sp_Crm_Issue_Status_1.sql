




CREATE procedure [dbo].[sp_Crm_Issue_Status]
	@userId	nvarchar(300),
	@IssueId	bigint,
	@Comment nvarchar(300),
	@Status int
as
	begin try		
	
		INSERT INTO [dbo].[CRM_Issue_Process]
				([IssueId]
				,[Comment]
				,[ProcessDt]
				,[UserId]
				,[statusId]
				,assignRole
				)
			SELECT
				 @IssueId
				,@Comment
				,getdate()
				,@UserID
				,@Status
				,1
		

	 UPDATE [dbo].CRM_Issues
	   SET issue_st = @Status
	 WHERE IssueId = @IssueID
	 
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Update_Issue_Status ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Issue_Status', 'Update', @SessionID, @AddlInfo
	end catch