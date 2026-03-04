CREATE procedure [dbo].[sp_res_notify_sent_byRoom_page]
	@UserId	UNIQUEIDENTIFIER = NULL,
	--@notiId bigint,
	@roomCode nvarchar(50),
	@filter nvarchar(30),
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@AcceptLanguage VARCHAR(20) = 'vi-VN'
	--@Total				bigint out,
	--@TotalFiltered		bigint out
	--@TotalUnread		bigint out
as
	begin try	
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'sp_NotificationSent_Page_ByApartment'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		--set		@notiUserId				= isnull(@notiUserId,'')

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		--if @notiId > 0
		--begin
		select	@Total					= count(b.id)
			FROM NotifyInbox a 
				join NotifySent b on a.NotiId = b.NotiId 
			WHERE a.IsPublish  = 1
				--And (@notiId = 0 or (a.notiId = @notiId and @notiId > 0))
				and (b.room = @roomCode)

		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		--grid config
		if @Offset = 0
		begin
			select * from [dbo].[fn_config_list_gets_lang] (@GridKey, @gridWidth, @AcceptLanguage) 
					order by [ordinal]
		end

		SELECT a.[NotiId]
			  ,a.[Subject]
			  ,a.content_notify [Description]
			  ,b.userId 
			  ,b.fullName 
			  ,b.phone 
			  ,b.email
			  ,b.room roomCode
			  ,case b.push_st 
					when 0 then N'<span class="bg-secondary noti-number ml5">Nháp</span>' 
					when 1 then N'<span class="bg-info noti-number ml5">Đang gửi</span>'
					when 2 then N'<span class="bg-success noti-number ml5">Đã gửi</span>'
					when 3 then N'<span class="bg-warning noti-number ml5">Không gửi được</span>' 
					else N'<span class="bg-dark noti-number ml5">Không áp dụng</span>'
					end as push_status				
			  ,case b.sms_st 
					when 0 then N'<span class="bg-secondary noti-number ml5">Nháp</span>' 
					when 1 then N'<span class="bg-info noti-number ml5">Đang gửi</span>'
					when 2 then N'<span class="bg-success noti-number ml5">Đã gửi</span>'
					when 3 then N'<span class="bg-warning noti-number ml5">Không gửi được</span>' 
					else N'<span class="bg-dark noti-number ml5">Không áp dụng</span>'
					end as sms_status 
			  ,case b.email_st 
					when 0 then N'<span class="bg-secondary noti-number ml5">Nháp</span>' 
					when 1 then N'<span class="bg-info noti-number ml5">Đang gửi</span>'
					when 2 then N'<span class="bg-success noti-number ml5">Đã gửi</span>'
					when 3 then N'<span class="bg-warning noti-number ml5">Không gửi được</span>' 
					else N'<span class="bg-dark noti-number ml5">Không áp dụng</span>'
					end as email_status
			  ,b.id
			  ,a.content_type contentType
	  FROM NotifyInbox a 
		join NotifySent b on a.n_id = b.n_id --and b.UserId = @UserId
		WHERE a.IsPublish  = 1
			and (b.room = @roomCode)
		ORDER BY NotiDt DESC
		  offset @Offset rows	
			fetch next @PageSize rows only
		--end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_sent_byRoom_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' + cast(@UserId as varchar(50))

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'NotificationSent', 'GET', @SessionID, @AddlInfo
	end catch