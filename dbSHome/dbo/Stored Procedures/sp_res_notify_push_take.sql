CREATE procedure [dbo].[sp_res_notify_push_take]
	@userID			nvarchar(450) = null,
	@ClientId		nvarchar(50) = null,
	@n_id			uniqueidentifier	= null,
	@prodType		nvarchar(30) = null,
	@notiType		int				= 0,
	@action_list	nvarchar(100) = null,
	@subject		nvarchar(100) = null,
	@content_notify	nvarchar(300) = null,
	@content_sms	nvarchar(300) = null,
	@contentType	int = null,
	@content_markdown	nvarchar(max) = null,
	@content_email		nvarchar(max) = null,
	@bodytype		nvarchar(10)	= 'text',
	@external_key	nvarchar(50)	= null,
	@external_sub	nvarchar(50)	= null,
	@external_param	nvarchar(max)	= null,
	@external_event	nvarchar(50)	= null,
	@source_ref		uniqueidentifier= null,
	@source_id		NVARCHAR(450)	= null,
	@source_key		nvarchar(50)	= null,
	@send_by		nvarchar(100)	= null,
	@send_name		nvarchar(100)	= null,
	@brand_name		nvarchar(20)	= 'Unicloud',
    @push_count		int = null,
    @sms_count		int = null,
    @email_count	int = null,
	@attachs		user_notify_attach	readonly,
	@notiusers		user_notify_type readonly
	
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(200) = N'Tạo thông báo thành công'

	begin try	
	declare @inserted table(n_id uniqueidentifier)
	--declare @orgId uniqueidentifier = isnull((select top 1 organizeId from Employees e where userid = @userID)
	--									,(select top 1 orgId from users e where userid = @userID))
	IF NOT EXISTS(SELECT n_id FROM NotifyInbox WHERE n_id = @n_id)
	begin
		INSERT INTO [dbo].NotifyInbox
			   ([Subject]
			   ,content_notify
			   ,content_markdown
			   ,content_email
			   ,content_sms
			   ,[bodytype]
			   ,[NotiDt]
			   ,IsPublish
			   ,notiType
			   ,external_param
			   ,external_event
			   ,clientId
			   ,source_key
			   ,source_id
			   ,actionlist
			   ,createId
			   ,content_type
			   ,send_by
			   ,send_name
			   ,brand_name
			   ,external_key
			   ,external_sub
			   ) output inserted.n_id into @inserted
		 VALUES(@Subject
			   ,@content_notify
			   ,@content_markdown
			   ,@content_email
			   ,@content_sms
			   ,@bodytype
			   ,getdate()
			   ,1
			   ,@notiType
			   ,@external_param
			   ,@external_event
			   ,@ClientId
			   ,@source_key
			   ,try_cast(@source_id as uniqueidentifier)
			   ,@action_list
			   ,@UserID
			   ,@contentType
			   ,@send_by
			   ,@send_name
			   ,@brand_name
			   ,@external_key
			   ,@external_sub
				)

	end
	ELSE
	begin
		UPDATE [dbo].NotifyInbox
		   SET [Subject] = @Subject
			  ,content_notify = @content_notify
			  ,content_markdown = @content_markdown
			  ,content_email = @content_email
			  ,content_sms = @content_sms
			  ,[bodytype] = @bodytype
			  ,[NotiDt] = getdate()
			  ,notiType = @notiType
			  ,external_param = @external_param
			  ,external_event = @external_event
			  ,source_ref = @source_ref
			  ,source_id	= try_cast(@source_id as uniqueidentifier)
			  ,actionlist = @action_list
			  ,createId = isnull(createId,@userid)
			  ,content_type = @contentType
		 WHERE n_id = @n_id
	end
	if @n_id is null
		select top 1 @n_id = n_id from @inserted
		--attach
		insert into NotifyAttach
				(n_id
				,attach_name
				,attach_url
				,attach_type
				,attach_size
				,notiId
				)
			select i.n_id
				,attach_name
				,attach_url
				,attach_type
				,attach_size	
				,n.notiId
			from @attachs a  
				,NotifyInbox n join @inserted i on n.n_id = i.n_id
				where not exists (select 1 from NotifyAttach 
					where n_id = @n_id and attach_url = a.attach_url)					
				and n.notiType = @notiType
				and a.attach_url is not null

		INSERT INTO [dbo].NotifySent
				   (n_id
				   ,[userId]
				   ,[custId]
				   ,[email]
				   ,[phone]
				   ,[fullName]
				   ,[push_st]
				   ,[sms_st]
				   ,[email_st]
				   ,[createId]
				   ,createDt
				   ,NotiId
				   )
			select distinct i.n_id
				  ,userId
				  ,custid
				  ,email 
				  ,phone 
				  ,fullName
				  ,case when isLinkApp = 1 and userId is not null and userId != '' then 2 else 4 end
				  ,case when phone is not null and [dbo].funcSDT(phone) = 1 then 0 else 4 end
				  ,case when email is not null and [dbo].fn_check_mail(email) = 1 then 0 else 4 end
				  ,@UserId
				  ,getdate()
				  ,n.notiId
			 from @notiusers a
				,NotifyInbox n join @inserted i on n.n_id = i.n_id
				where not exists(select 1 from NotifySent where n_id = @n_id 
					and userId = a.userid
					)
				    and n.notiType = @notiType

			

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_resident_notify_push_take ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@ ' 
		set @valid = 0
		set @messages =  error_message()

		exec utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotificationApp', 'Set', @SessionID, @AddlInfo
	end catch



	select @valid as valid
		  ,@messages as [messages]
		  ,n_id as id
		from @inserted

		if @valid = 1

			EXECUTE [dbo].sp_res_notify_push_run 
			   @UserID
			  ,@n_id
			  ,''
			  ,@action_list
			  ,1
end