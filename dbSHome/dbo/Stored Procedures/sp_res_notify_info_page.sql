
CREATE PROCEDURE [dbo].[sp_res_notify_info_page]
	@UserId			UNIQUEIDENTIFIER = null,
	@clientId		NVARCHAR(50) = null,
	@externalKey	NVARCHAR(50) = null,
	@source_key     nvarchar(50) = null,
	@source_ref		uniqueidentifier = null,
	@actionlist		NVARCHAR(150) = null,
	@isPublish		int = -1,
	@external_sub	NVARCHAR(50) = null,
	@filter			NVARCHAR(200) = null,
	@gridWidth			INT				= 0,
	@Offset				INT				= 0,
	@PageSize			INT				= 10,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
	
AS
	BEGIN TRY	
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_notification_page'
	
		SET		@external_sub			= ISNULL(@external_sub,'')
		set		@isPublish				= isnull(@isPublish,-1)
		SET		@Offset					= ISNULL(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)		
		set		@filter					= isnull(@filter,'')

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.NotiId)
			FROM NotifyInbox a 
			WHERE a.external_key = @externalKey 
				and a.source_key = 'common'
				and (@source_ref is null or a.source_ref = @source_ref)
				and (@external_sub = '' or a.external_sub = @external_sub)
				and (@isPublish = -1 or a.isPublish = @isPublish)
				and (exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = a.external_sub) or a.createId = @UserId)
				and (@filter = '' or a.subject like '%' + @filter +'%')
				
		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		--grid config
		if @Offset = 0
		begin
			select * from [dbo].[fn_config_list_gets_lang] (@GridKey, @gridWidth, @acceptLanguage) 
					order by [ordinal]
		end

		

		SELECT a.[notiId]
			  ,a.[subject]
			  ,a.content_notify
			  --,a.content_markdown 
			  --,a.content_email
			  ,a.content_sms as contentSms
			  ,a.notiAvatarUrl
			  ,format(a.NotiDt,'dd/MM/yyyy hh:mm:ss') as pushDate
			  --,convert(nvarchar(5),a.NotiDt,108) + ' - ' + convert(nvarchar(10),a.NotiDt,103) as [pushDate]
			  ,[dbo].[fn_Get_DateAgo] (NotiDt,getdate()) as [pushTimeAgo]
			  ,actionlist = REPLACE(REPLACE(REPLACE(actionlist,'push', 'Push(' + cast(isnull(a.push_count,0) as varchar) + ')')
						,'sms', 'SMS(' + cast(isnull(a.sms_count,0) as varchar) + ')')
						,'email','Email(' + cast(isnull(a.email_count,0) as varchar) + ')')
			  ,projectName	= isnull(t.external_name,p.projectName)
			  ,u.fullName as alterBy
			  ,format(a.createDt,'dd/MM/yyyy hh:mm:ss') as createDt
			  ,a.isPublish
			  ,st.objClass as publish
			  ,a.external_sub
			  ,n_id = cast(a.n_id as varchar(100))
	  FROM NotifyInbox a 
		left join NotifyExternal t on a.external_sub = t.external_sub
		left join MAS_Projects p on a.external_sub = p.projectCd
		left join Users u on a.createId = u.userId
		left join dbo.fn_config_data_gets_lang('order_refer_st', @acceptLanguage) st on isnull(a.isPublish,0) = st.objValue
	  WHERE a.external_key = @externalKey 
		and (@source_ref is null or a.source_ref = @source_ref)
		and (@external_sub = '' or a.external_sub = @external_sub)
		and (@isPublish = -1 or a.isPublish = @isPublish)
		and a.source_key = 'common'
		and (exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = a.external_sub) or a.createId = @UserId)
		and (@filter = '' or a.subject like '%' + @filter +'%')
	ORDER BY NotiDt DESC
	  offset @Offset rows	
		fetch next @PageSize rows only


		--select * from @tbCats
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_info_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' + cast(@UserId as varchar(50))

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'NotificationApp', 'GET', @SessionID, @AddlInfo
	end catch