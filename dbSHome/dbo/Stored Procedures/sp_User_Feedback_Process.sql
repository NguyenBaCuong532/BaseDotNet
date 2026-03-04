






CREATE procedure [dbo].[sp_User_Feedback_Process]
	@UserID	nvarchar(450),
	@FeedbackId int,
	@Comment nvarchar(max),
	@Status int
	
as
	begin try		
			INSERT INTO [dbo].MAS_FeedbackProcess
				   ([FeedbackId]
				   ,Comment
				   ,userId
				   ,[ProcessDt]
				   ,[Status])
			 Values(@FeedbackId
				   ,@Comment
				   ,@UserID
				   ,getdate()
				   ,@Status
				   )

			UPDATE [dbo].[MAS_Feedbacks]
			   SET [Status] = @Status
			 WHERE [FeedbackId] = @FeedbackId

			SELECT [ProcessId]
				  ,a.[FeedbackId]
				  ,[Comment]
				  ,b.FullName as [EmployeeName]
				  ,convert(nvarchar(10),a.[ProcessDt],103) + ' ' + convert(nvarchar(5),a.[ProcessDt],108) as [ProcessDate]  
				  ,a.userId
				  ,[Status]
		  FROM MAS_FeedbackProcess a 
			inner join Users b On a.userId = b.UserId
		  WHERE ProcessId = @@IDENTITY


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Insert_FeedbackFix ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@NotiId ' + @FeedbackId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'FeedbackFix', 'Insert', @SessionID, @AddlInfo
	end catch