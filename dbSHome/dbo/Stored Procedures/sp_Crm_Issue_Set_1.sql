





CREATE procedure [dbo].[sp_Crm_Issue_Set] 
	@userId nvarchar(450),
	@IssueId	bigint,
	@thread_id	nvarchar(200),
	@CustId nvarchar(50), 
	@ProjectCd nvarchar(30), 
	@IssueType int,
	@Summary nvarchar(200),
	@Description nvarchar(500),
	@SecurityLevel int,
	@SubStatus int,
	@Priority int,
	@Serverity int,
	--@Assignee nvarchar(50),
	--@ReporterTo nvarchar(50),
	@StartDt nvarchar(30),
	@DueDt nvarchar(30),
	@DueCustDt nvarchar(30),
	@SubType int,
	--@Requestor nvarchar(200),
	@Impart nvarchar(200),
	@Feedback nvarchar(200),
	@CauseIssue nvarchar(200),
	@CPAction nvarchar(200),
	@IssueLevel nvarchar(200),
	@Solution nvarchar(200)
as
	begin try	
		declare @valid bit = 1
		if exists(select IssueId from CRM_Issues where IssueId = @IssueId)
			UPDATE [dbo].[CRM_Issues]
			   SET [ProjectCd] = @ProjectCd
				  ,[IssueType] = @IssueType
				  ,[Summary] = @Summary
				  ,[Description] = @Description
				  ,[SecurityLevel] = @SecurityLevel
				  ,[SubStatus] = @SubStatus
				  ,[Priority] = @Priority
				  ,[Serverity] = @Serverity
				  --,[Assignee] = @Assignee
				  --,[ReporterTo] = @ReporterTo
				  ,[StartDt] = convert(datetime,@StartDt,103)
				  ,[DueDt] = convert(datetime,@DueDt,103)
				  ,[DueCustDt] = convert(datetime,@DueCustDt,103)
				  ,[SubType] = @SubType
				  ,[thread_id] = @thread_id
				  ,[Impart] = @Impart
				  ,[Feedback] = @Feedback
				  ,[CauseIssue] = @CauseIssue
				  ,[CPAction] = @CPAction
				  ,[IssueLevel] = @IssueLevel
				  ,[Solution] = @Solution
			 WHERE IssueId = @IssueId
		else
		begin
			INSERT INTO [dbo].[CRM_Issues]
				   (CustId
				   ,[ProjectCd]
				   ,[IssueType]
				   ,[Summary]
				   ,[Description]
				   ,[SecurityLevel]
				   ,[CreateBy]
				   ,[CreateDt]
				   ,[SubStatus]
				   ,[Priority]
				   ,[Serverity]
				   --,[Assignee]
				   --,[ReporterTo]
				   ,[StartDt]
				   ,[DueDt]
				   ,[DueCustDt]
				   ,[SubType]
				   ,[thread_id]
				   ,[Impart]
				   ,[Feedback]
				   ,[CauseIssue]
				   ,[CPAction]
				   ,[IssueLevel]
				   ,[Solution])
			 VALUES
				   (@CustId
				   ,@ProjectCd
				   ,@IssueType
				   ,@Summary
				   ,@Description
				   ,@SecurityLevel
				   ,@userId
				   ,getdate()
				   ,@SubStatus
				   ,@Priority
				   ,@Serverity
				   --,@Assignee
				   --,@ReporterTo
				   ,isnull(convert(datetime,getdate()), convert(datetime,@StartDt,103))
				   ,isnull(convert(datetime,getdate()),convert(datetime,@DueDt,103))
				   ,isnull(convert(datetime,getdate()),convert(datetime,@DueCustDt,103))
				   ,@SubType
				   ,@thread_id
				   ,@Impart
				   ,@Feedback
				   ,@CauseIssue
				   ,@CPAction
				   ,@IssueLevel
				   ,@Solution
				   )
				
				set @IssueId = @@IDENTITY

			end

			--EXECUTE [dbo].[sp_Crm_Get_Customer_Issue_ById] 
			--	   @userId
			--	  ,@IssueId

			select @valid as valid, 'success' as messages

			end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Insert_Customer_Issue ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@CustId '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Issues', 'Insert', @SessionID, @AddlInfo
		select 0 as valid, 'Error' as messages
	end catch