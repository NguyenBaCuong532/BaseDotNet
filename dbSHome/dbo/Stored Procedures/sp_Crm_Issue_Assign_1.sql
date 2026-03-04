



CREATE procedure [dbo].[sp_Crm_Issue_Assign]
	@IssueID	bigint,
	@UserId nvarchar(250),
	@assignRole int,
	@used bit
as
	begin try		
	if @Used = 1
	begin
		if not exists(select * from CRM_Issue_Assign where IssueId = @IssueID and UserId = @UserId)
		INSERT INTO [dbo].CRM_Issue_Assign
           ([IssueID]
           ,[UserId]
           ,assignRole)
		VALUES
           (@IssueID
           ,@UserId
           ,@assignRole)

	end
	ELSE
		DELETE FROM [dbo].CRM_Issue_Assign
		WHERE [IssueID] = @IssueID 
			AND [UserId] = @UserId


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Issue_Assign ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Issue_Assingee', 'Set', @SessionID, @AddlInfo
	end catch