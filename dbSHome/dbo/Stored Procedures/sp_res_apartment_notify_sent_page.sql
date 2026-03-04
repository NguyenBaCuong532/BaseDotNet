
-- Lịch sử thông báo theo căn hộ
CREATE procedure [dbo].[sp_res_apartment_notify_sent_page]
	@UserId	UNIQUEIDENTIFIER = NULL,
	--@notiId bigint,
	@roomCode nvarchar(50),
	@filter nvarchar(30) = NULL,
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@AcceptLanguage VARCHAR(20) = 'vi-VN'
	--@Total				bigint out,
	--@TotalFiltered		bigint OUT,
	--@GridKey		nvarchar(100) out
as
	begin try	
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_notifySent_byApartment_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		--set		@GridKey			= 'view_notifySent_byApartment_page'

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
			select * from [dbo].[fn_config_list_gets_lang] (@GridKey, 0, @AcceptLanguage) 
					order by [ordinal]
		end

		SELECT a.[NotiId] AS notiId
			  ,a.[Subject] AS subject
			  ,a.content_notify [description]
			  ,b.userId 
			  ,b.fullName 
			  ,b.phone 
			  ,b.email
			  ,b.room roomCode
			  ,cd.value1 AS email_status
			  ,cd1.value1 AS push_status
		      ,cd2.value1 AS sms_status
			  ,b.id
			  ,a.content_type contentType
			   ,b.n_id
	  FROM NotifyInbox a 
		join NotifySent b on a.n_id = b.n_id --and b.UserId = @UserId
		JOIN dbo.sys_config_data cd ON cd.key_1 = 'email_st' AND b.email_st = cd.key_2
		 JOIN dbo.sys_config_data cd1 ON  cd1.key_1 = 'push_st'  AND b.push_st = cd1.key_2
		 JOIN dbo.sys_config_data cd2 ON  cd2.key_1 = 'sms_st' AND b.sms_st = cd2.key_2
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
	end CATCH