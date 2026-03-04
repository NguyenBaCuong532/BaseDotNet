
CREATE PROCEDURE [dbo].[sp_res_notify_push_page_byNotiId]
	@UserId			UNIQUEIDENTIFIER = NULL,
	@n_id			uniqueidentifier,
	@filter			nvarchar(30) = NULL,
	--@send			int				= -1,
	@push_st		int				= -1,
	@email_st		int				= -1,
	@sms_st			int				= -1,
	@gridWidth			int			= 0,
	@Offset				int			= 0,
	@PageSize			int			= 10,
	@AcceptLanguage VARCHAR(20) = 'vi-VN'
as
	begin try	
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_notificationApp_page_byNotiId_page'
		declare @is_act_push bit, @is_act_sms bit,@is_act_email bit
			   ,@to_type nvarchar(10)

		select @is_act_push = is_act_push
			  ,@is_act_sms = is_act_sms
			  ,@is_act_email = is_act_email
			  ,@to_type = n.to_type 
		from NotifyInbox n
		where n_id = @n_id

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		set		@push_st				= isnull(@push_st,-1)
		set		@email_st				= isnull(@email_st,-1)
		set		@sms_st					= isnull(@sms_st,-1)

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		--if @notiId > 0
		begin
		select	@Total					= count(a.n_id)
			FROM NotifyInbox a 
				join NotifySent b on a.n_id = b.n_id 
			WHERE a.n_id = @n_id 
				and (@push_st = -1 or b.push_st = @push_st)
				and (@email_st = -1 or b.email_st = @email_st)
				and (@sms_st = -1 or b.sms_st = @sms_st)
				and (@filter = '' or a.subject like '%'+@filter+'%')

		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		
		--grid config
		if @Offset = 0
		begin
			select * from [dbo].[fn_config_list_gets_lang] (@GridKey, @gridWidth, @AcceptLanguage)
			where (columnField not in ('push_status') and @is_act_push = 0 or @is_act_push = 1)
				and (columnField not in ('sms_status','phone') and @is_act_sms = 0 or @is_act_sms = 1)
				and (columnField not in ('email_status','email') and @is_act_email = 0 or @is_act_email = 1)
					order by [ordinal]
		end

		SELECT b.userId 
			  ,b.fullName 
			  ,b.phone 
			  ,b.email
			  ,b.room 
			  ,cd1.value1 AS push_status
			  ,cd2.value1 AS sms_status
			  ,cd3.value1 AS email_status
			  ,b.createDt sendDt
			  ,CONVERT(NVARCHAR(50),b.id) as id
			  ,a.content_type contentType
			  ,a.subject as [description]
	  FROM NotifyInbox a 
		join NotifySent b on a.n_id = b.n_id
		LEFT JOIN dbo.sys_config_data cd1 ON cd1.key_2 = b.push_st AND cd1.key_1 ='push_st'
		LEFT JOIN dbo.sys_config_data cd2 ON cd2.key_2 = b.sms_st AND cd2.key_1 ='sms_st'
		LEFT JOIN dbo.sys_config_data cd3 ON cd3.key_2 = b.email_st AND cd3.key_1 ='email_st'
		WHERE a.n_id = @n_id 
			and (@push_st = -1 or b.push_st = @push_st)
			and (@email_st = -1 or b.email_st = @email_st)
			and (@sms_st = -1 or b.sms_st = @sms_st)
			and (@filter = '' or a.subject like '%'+@filter+'%')
		ORDER BY NotiDt DESC
		  offset @Offset rows	
			fetch next @PageSize rows only
		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_push_page_byn_id ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' + cast(@UserId as varchar(50))

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'NotificationSent', 'GET', @SessionID, @AddlInfo
	end catch