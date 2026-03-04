CREATE procedure [dbo].[sp_resident_email_set]
		@UserId nvarchar(450) = null,
		@clientId nvarchar(50) = null,
		@clientIp nvarchar(50) = null,
		@To nvarchar(255),
		@Cc nvarchar(255),
		@Bcc nvarchar(255),
		@SendBy nvarchar(255),
		@Subject nvarchar(255),
		@Contents nvarchar(max),
		@BodyType nvarchar(25),
		@Attachs nvarchar(max),
		@SendType int,
		@SendName nvarchar(50),
		@source_key nvarchar(250) = null,
		@SendingTime nvarchar(20) = null,
		@custId nvarchar(100),
		@isSent bit = 1,
		@sourceId NVARCHAR(450),
		@id uniqueidentifier = null,
		@remart nvarchar(100) = null,
		@AcceptLanguage nvarchar(50) = null
		
as
	begin try
	
	if @To is not null and @To <> ''
	begin
	set @id = isnull(@id,newid())
				
	if (@isSent = 0 or @isSent is null) and @to is not null and dbo.fn_check_mail(@To) = 1
       begin
            INSERT INTO [dbo].EmailJobs
			   ([mailto]
			   ,[Cc]
			   ,[Bcc]
			   ,[SendBy]
			   ,[Subject]
			   ,[Contents]
			   ,[BodyType]
			   ,[Attachs]
			   ,[Status]
			   ,[createdDate]
			   ,[Send]
			   ,[SendDate]
			   ,[SendType]
			   ,[SendName]
			   ,[createId]
			   ,[custId]
			   ,[clientId]
			   ,[sourceId]
			   ,[remart]
			   )
		 VALUES
				(@To
				,@Cc
				,@Bcc
				,@SendBy
				,@Subject
				,@Contents
				,@BodyType
				,@Attachs
				,0
				,getdate()
				,0
				,getdate()--convert(datetime,@SenddingTime,0) --convert(datetime,@SenddingTime,103)
				,@SendType
				,@SendName
				,@UserId
				,@custId
				,@clientId
				,@sourceId
				,@remart
				)
       end
	else
	begin
		INSERT INTO [dbo].EmailSents
			   ([mailto]
			   ,[Cc]
			   ,[Bcc]
			   ,[SendBy]
			   ,[Subject]
			   ,[Contents]
			   ,[BodyType]
			   ,[Attachs]
			   ,[Status]
			   ,[createdDate]
			   ,[Send]
			   ,[SendDate]
			   ,[SendType]
			   ,[SendName]
			   ,[createId]
			   ,[custId]
			   ,[clientId]
			   ,[sourceId]
			   ,sourceKey
			   ,[id]
			   ,[remart]
			   )
		 VALUES
				(@To
				,@Cc
				,@Bcc
				,@SendBy
				,@Subject
				,@Contents
				,@BodyType
				,@Attachs
				,0
				,getdate()
				,0
				,getdate()--convert(datetime,@SenddingTime,0) --convert(datetime,@SenddingTime,103)
				,@SendType
				,@SendName
				,@UserId
				,@custId
				,@clientId
				,@sourceId
				,(select top 1 sourceKey from EmailJobsHistory WHERE id = @id)
				--,@source_key
				,@id
				,@remart 
				)
	begin
		 UPDATE t2
		   SET [email_st] = 2
			  --,[sendDt] = getdate()
		 FROM [dbo].NotifySent t2 join EmailJobsHistory a on t2.n_id = a.sourceId 
		 WHERE a.id = @id

		 UPDATE t
			   SET email_count = isnull(email_count,0) + 1
		 FROM [dbo].NotifyInbox t
			join [dbo].NotifySent t2 on t2.n_id = t.n_id
			join EmailJobsHistory a on t2.n_id = a.sourceId
			 WHERE a.id = @id
	end

	 begin
		 DELETE FROM EmailJobsHistory WHERE id = @id or createdDate < dateadd(day,-1,getdate())
	 end
		

	end
	end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_resident_email_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User '+ isnull(@UserId ,'')

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'Emails', 'Set', @SessionID, @AddlInfo
	end catch