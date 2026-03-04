

CREATE procedure [dbo].[sp_res_notify_ref_page]
	@userId			UNIQUEIDENTIFIER,
	@external_key	nvarchar(50),
	@clientId		nvarchar(50) = null,
	@filter			nvarchar(200),
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
	--@Total				int out,
	--@TotalFiltered		int out,
	--@GridKey			nvarchar(100) out
as
	begin try	
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_notify_ref_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= LTRIM(RTRIM(isnull(@filter,'')))

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		select	@Total					= count(*)
			FROM NotifyRef a 
				--join Users u on a.orgId = u.orgId
			WHERE a.external_key = @external_key

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

		SELECT a.source_ref			  
			  ,a.refKey
			  ,a.refName 
			  ,ref_st	= f.[objClass]
			  ,a.refIcon
			  ,mk.fullName as created_by
			  ,format(a.created_dt,'dd/MM/yyyy HH:mm:ss') as created_dt
	  FROM NotifyRef a 
		left join Users mk on a.created_by = mk.userId
		left join dbo.fn_config_data_gets_lang('object_active_st', @acceptLanguage) f on a.ref_st = f.objValue
		--join Users u on a.orgId = u.orgId
	WHERE a.external_key = @external_key
		and (@filter = '' or a.refName like '%' + @filter +'%' or a.refKey like '%' + @filter +'%')
	ORDER BY a.created_dt DESC
	  offset @Offset rows	
		fetch next @PageSize rows only

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_notify_ref_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' + cast(@UserId as varchar(50))

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'notify_ref', 'GET', @SessionID, @AddlInfo
	end catch