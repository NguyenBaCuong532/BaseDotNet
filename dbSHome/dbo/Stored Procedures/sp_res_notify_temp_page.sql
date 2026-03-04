




CREATE procedure [dbo].[sp_res_notify_temp_page]
	 @UserId		UNIQUEIDENTIFIER
	,@clientId		nvarchar(50) = null
	,@external_key		nvarchar(50) = null
	,@filter		nvarchar(200)
	,@source_key	nvarchar(50) = 'all'
	,@app_st			int	= -1
	,@gridWidth			int				= 0
	,@Offset			int				= 0
	,@PageSize			int				= 10
	,@projectcode	nvarchar(10) = NULL
	,@acceptLanguage		NVARCHAR(50) = N'vi-VN'
	--,@Total				int out
	--,@TotalFiltered		int out
	--,@GridKey			nvarchar(100) out
as
	begin try	
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_notify_temp_Page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= ltrim(rtrim(isnull(@filter,'')))
		set		@app_st					= isnull(@app_st,-1)

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.[tempId])
			FROM NotifyTemplate a 
				--join Users u on a.orgId = u.orgId or a.orgId is null
			WHERE a.external_key = @external_key and a.projectCd = @projectcode
				and (@source_key = 'all' or a.source_key = @source_key)
				and (@app_st = -1 or a.app_st = @app_st)
				and (@filter = '' or a.tempName like '%' + @filter +'%')

		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		--grid config
		if @Offset = 0
		begin
			select * from [dbo].[fn_config_list_gets_lang]  (@GridKey, @gridWidth, @acceptLanguage) 
					order by [ordinal]
		end

		SELECT a.[tempId]
			  ,a.tempCd
			  ,a.tempName
			  ,a.[subject]
			  ,a.content_notify
			  ,a.content_markdown 
			  ,a.content_email
			  ,a.content_sms as contentSms
			  ,a.[n_id]
			  ,format(a.NotiDt,'dd/MM/yyyy hh:mm:ss') as pushDate
			  ,format(a.NotiDt,'dd/MM/yyyy hh:mm:ss') as [pushTimeAgo]
			  ,a.actionlist as actionList
			  ,mk.fullName as createBy
			  ,format(a.createDt,'dd/MM/yyyy hh:mm:ss') as createDt
			  ,app_status = CASE ISNULL(a.app_st, 0)
					WHEN 1 THEN N'<span class="bg-success noti-number ml5">Hoạt động</span>'
					ELSE N'<span class="bg-secondary noti-number ml5">Đóng</span>'
				END
			  ,notify_source_key = tk.objName
	  FROM NotifyTemplate a 
		left join Users mk on a.createId = mk.userId
		left join dbo.fn_config_data_gets_lang('object_active_st', @acceptLanguage) st on isnull(a.app_st,0) = st.objValue
		left join dbo.fn_config_data_gets_lang('notify_source_key', @acceptLanguage) tk on isnull(a.source_key,0) = tk.objValue
		--join Users u on a.orgId = u.orgId or a.orgId is null
	  WHERE a.external_key = @external_key and a.projectCd = @projectcode
		and (@source_key = 'all' or a.source_key = @source_key)
		and (@app_st = -1 or a.app_st = @app_st)
		and (@filter = '' or a.tempName like '%' + @filter +'%')
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
		set @ErrorMsg					= 'sp_Notify_Temp_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' + cast(@UserId as varchar(50))

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotifyTemp', 'GET', @SessionID, @AddlInfo
	end catch