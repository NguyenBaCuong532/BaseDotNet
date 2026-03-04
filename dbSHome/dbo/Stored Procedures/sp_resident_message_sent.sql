CREATE procedure [dbo].[sp_resident_message_sent]
     @UserId nvarchar(50) = null
	,@AcceptLanguage nvarchar(50) = null
	,@messageId nvarchar(100)
	,@errNum int
	,@errDes nvarchar(200)
as
	begin try	
	if not exists(select [MessageId] from [MessageSents] WHERE MessageId = @messageId)
		INSERT INTO [dbo].[MessageSents]
			   ([MessageId]
			   ,[Phone]
			   ,[Contents]
			   ,[ScheduleAt]
			   ,[BrandName]
			   ,[IsSent]
			   ,[SendDt]
			   ,[SendNum]
			   ,[Status]
			   ,[SendFailed]
			   ,[createId]
			   ,[CreatedDt]
			   ,custName
			   ,custId
			   ,clientIp
			   ,sourceId
			   ,partner
			   --,orgId
			   )
			SELECT [MessageId]
			  ,[Phone]
			  ,[Contents]
			  ,[ScheduleAt]
			  ,[BrandName]
			  ,1
			  ,getdate()
			  ,1
			  ,case when @errNum = 0 then 1 else 0 end
			  ,case when @errNum = 0 then 1 else 0 end
			  ,[createId]
			  ,[CreatedDt]
			  ,custName
			  ,custId
			  ,clientIp
			  ,sourceId
			  ,partner
			  --,orgId
	  FROM [MessageJobs]
	  WHERE MessageId = @messageId;
	 else
		UPDATE t
		   SET IsSent = 0
			  ,SendDt = getdate()
			  ,SendNum = isnull(t.SendNum,0)+1
			  ,[Status] = case when @errNum = 0 then 1 else 0 end
			  ,SendFailed = isnull(SendFailed,0)+ case when @errNum = 0 then 1 else 0 end
			  ,[Contents] = a.Contents
			  ,custName = a.custName 
			  ,CreatedDt = a.CreatedDt 
			  ,createId = a.createId
			  ,Phone = a.Phone
			  ,t.sourceId = a.sourceId
		FROM [dbo].[MessageSents] t 
			join [MessageJobs] a on t.MessageId = a.MessageId
		 WHERE t.MessageId = @messageId

		 UPDATE t2
		   SET [sms_st] = 3 -- update trạng thái fall = 3
			  --,[sendDt] = getdate()
		 FROM [dbo].NotifySent t2
			join [MessageJobs] a on t2.n_id = a.sourceId and t2.custId = a.custId
		 WHERE a.MessageId = @messageId

		 UPDATE t
			   SET sms_count = isnull(sms_count,0) + 1
		 FROM [dbo].NotifyInbox t
			join [dbo].NotifySent t2 on t2.n_id = t.n_id
			join [MessageJobs] a on t2.n_id = a.sourceId and t2.custId = a.custId
			 WHERE a.MessageId = @messageId

	 DELETE
		FROM [MessageJobs]
	  WHERE MessageId = @messageId;

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_resident_message_sent ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Id ' + @messageId

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'MessageSent', 'Set', @SessionID, @AddlInfo
	end catch