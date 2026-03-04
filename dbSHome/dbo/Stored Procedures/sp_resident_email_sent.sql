
CREATE procedure [dbo].[sp_resident_email_sent]
	 @Id nvarchar(100)
	,@errNum int
	,@errDes nvarchar(200)
as
	begin try	
		INSERT INTO [dbo].[EmailSents]
			   ([id]
			   ,[mailto]
			   ,[cc]
			   ,[bcc]
			   ,[sendBy]
			   ,[subject]
			   ,[contents]
			   ,[bodyType]
			   ,[attachs]
			   ,[status]
			   ,[send]
			   ,[sendName]
			   ,[sendDate]
			   ,[sendType]
			   ,[custId]
			   ,[isRead]
			   ,[readDt]
			   ,[createId]
			   ,[createdDate]
			   ,[clientId]
			   ,[clientIp]			   
			   ,[sourceId]
			   ,sourcekey
			   ,[saveDt]
			   ,error_mess
			   --,orgId
			   )
		SELECT [id]
			  ,[mailto]
			  ,[cc]
			  ,[bcc]
			  ,[sendBy]
			  ,[subject]
			  ,[contents]
			  ,[bodyType]
			  ,[attachs]
			  ,[status]
			  ,[send]
			  ,[sendName]
			  ,[sendDate]
			  ,[sendType]
			  ,[custId]
			  ,[isRead]
			  ,[readDt]
			  ,[createId]
			  ,[createdDate]
			  ,[clientId]
			  ,[clientIp]
			  ,[sourceId]
			  ,sourcekey
			  ,getdate()
			  ,@errDes
			  --,orgId
		  FROM [dbo].[EmailJobs]
	  WHERE id = @id;
	 
		UPDATE t2
		   SET [email_st] = 3--case when @errNum > 0 then 3 else 2 end --3: gửi thất bại
			  --,[sendDt] = getdate()
		 FROM [dbo].NotifySent t2
			join EmailJobsHistory a on t2.n_id = a.sourceId --and t2.custId = a.custId
		 WHERE a.id = @id

		 UPDATE t
			   SET email_count = isnull(email_count,0) + 1
		 FROM [dbo].NotifyInbox t
			join [dbo].NotifySent t2 on t2.n_id = t.n_id
			join EmailJobsHistory a on t2.n_id = a.sourceId --and t2.custId = a.custId
			 WHERE a.id = @id

	 DELETE
		FROM EmailJobs
	  WHERE id = @Id;

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_resident_email_sent ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Id ' + @Id

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'Email', 'Set', @SessionID, @AddlInfo
	end catch