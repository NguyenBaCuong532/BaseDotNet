









CREATE procedure [dbo].[sp_res_notify_temp_set]
	 @userId			nvarchar(450)
	,@ClientId		nvarchar(50) = NULL
	,@external_key	nvarchar(50)
	,@tempId			uniqueidentifier
	,@tempName		nvarchar(200)
	,@tempCd		nvarchar(50)
	,@actionlist		nvarchar(200)
	,@Subject		nvarchar(500)
	,@content_notify	nvarchar(300)
	,@content_sms		nvarchar(320)
	,@content_type	int
	,@content_markdown	nvarchar(max)
	,@content_email		nvarchar(max)
	,@bodytype		nvarchar(10)	= 'text'	
	,@source_key		nvarchar(50)
	,@source_ref		uniqueidentifier = null
	,@external_event nvarchar(50)	= null
	,@send_by		nvarchar(50)	= null
	,@send_name		nvarchar(50)	= null
	,@brand_name		nvarchar(50)	= null
	,@external_sub nvarchar(50)	= null
	,@external_param nvarchar(50)	= null
	,@n_id uniqueidentifier = null
	,@app_st			bit
	,@attachs		user_notify_attach	readonly
as
begin
	declare @valid bit
	declare @messages nvarchar(300)

	begin try	
	declare @actionType int
	declare @inserted table(n_id uniqueidentifier)
	set	@actionlist = isnull(@actionlist,'push')
	
	set @bodytype	= isnull(@bodytype,'html')
	
	IF NOT EXISTS(SELECT tempId FROM NotifyTemplate WHERE tempId = @tempId)
	begin
		INSERT INTO [dbo].NotifyTemplate
			   ([Subject]
			   ,content_notify
			   ,content_markdown
			   ,content_email
			   ,content_sms
			   ,[bodytype]
			   ,[NotiDt]
			   ,tempName
			   ,notiType
			   ,app_st
			   ,source_key
			   ,source_ref
			   ,actionlist
			   ,createId
			   ,content_type
			   ,external_event
			   ,send_by
			   ,send_name
			   ,brand_name
			   ,external_key
			   ,tempCd
			   ) output inserted.tempId into @inserted
		 VALUES
			   (@Subject
			   ,@content_notify
			   ,@content_markdown
			   ,@content_email
			   ,@content_sms
			   ,@bodytype
			   ,getdate()
			   ,@tempName
			   ,0
			   ,@app_st
			   ,@source_key
			   ,@source_ref
			   ,@actionlist
			   ,@UserID
			   ,@content_type
			   ,@external_event
			   ,@send_by
			   ,@send_name
			   ,@brand_name
			   ,@external_key
			   ,@tempCd
			   )
		--set @tempId = @@IDENTITY
		set @valid = 1
		set @messages = N'Thêm mới thông báo thành công' 
	end
	ELSE
	begin
		UPDATE [dbo].NotifyTemplate
		   SET [Subject]		= @Subject
			  ,content_notify	= @content_notify
			  ,content_markdown = @content_markdown
			  ,content_email	= @content_email
			  ,content_sms		= @content_sms
			  ,tempName			= @tempName
			  ,bodytype			= @bodytype
			  ,source_key		= @source_key
			  ,source_ref		= @source_ref
			  ,actionlist		= @actionlist
			  ,content_type		= @content_type
			  ,external_event	= @external_event
			  ,send_by			= @send_by
			  ,send_name		= @send_name
			  ,brand_name		= @brand_name
			  ,app_st			= @app_st
			  ,tempCd			= @tempCd
		 WHERE tempId			= @tempId

		 insert into @inserted
		 SELECT tempId
		 FROM NotifyTemplate 
		 WHERE tempId = @tempId


		 set @valid = 1
		 set @messages = N'Sửa thông báo thành công' 

	end

		delete t from NotifyAttach t
		where t.n_id in (select n_id from @inserted) 
			and not exists (select 1 from @attachs a where a.attach_url = t.attach_url)
						
		INSERT INTO [dbo].[NotifyAttach]
				([attach_name]
				,[attach_url]
				,attach_type
				,n_id
				,created_dt
				,attach_size
				)
			select [attach_name]
				,[attach_url]
				,attach_type
				,i.n_id
				,getdate()
				,attach_size
			from @attachs a,
				@inserted i
			where not exists (select 1 from NotifyAttach o where o.attach_url = a.attach_url)

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_temp_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@tempId ' + cast(@tempId  as varchar(100))
		set @valid = 0
		set @messages = error_message()

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_res_notify_temp_set', 'Set', @SessionID, @AddlInfo
	end catch

	select @valid as valid
	      ,@messages as [messages]
		  ,@tempId as id

	end