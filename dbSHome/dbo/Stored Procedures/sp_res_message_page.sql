

CREATE procedure [dbo].[sp_res_message_page]
	@UserId				UNIQUEIDENTIFIER = NULL,
	@AcceptLanguage VARCHAR(20) = 'vi-VN',
	@external_key			nvarchar(50),
	@custId				nvarchar(100),
	@filter				nvarchar(250),
	@fromDate           nvarchar(250),
	@toDate				nvarchar(250),
	@source_key			nvarchar(250),
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10
	--@Total				int out,
	--@TotalFiltered		int out
	--,@GridKey			nvarchar(200) out
as
	begin try
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_notify_message_page'
		if @custId = ''
				set @GridKey = 'view_notify_message_page'
			else
				set @GridKey = 'view_notify_message_page_cust'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		set		@custId					= isnull(@custId,'')

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.[MessageId])
			FROM [MessageSents] a
			join NotifyInbox n on a.sourceId = n.n_id
			WHERE ((a.custId = @custId) or (@custId = ''))
				and n.external_key = @external_key
				and (@filter = '' or a.Phone = @filter)
				and (@source_key is null or n.source_key = @source_key)
				and (@fromDate is null or CONVERT(DATE, a.createdDt, 103) >= CONVERT(DATE, @fromDate, 103))
				and (@toDate is null or CONVERT(DATE, a.createdDt, 103) <= CONVERT(DATE, @toDate, 103)) 
		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		
		if @Offset = 0
		begin
			select * from [dbo].[fn_config_list_gets]  (@GridKey, @gridWidth) 
			order by [ordinal]
		end
		
		SELECT a.[messageId]
			  ,a.[phone]
			  ,a.[contents]
			  ,a.[scheduleAt]
			  ,'Sunshine' as [brandName]
			  ,a.[custName] 
			  ,format([SendDt],'dd/MM/yyyy hh:mm:ss') as sendDate
			  ,a.[sendNum]
			  ,a.[status]
			  ,a.[sendFailed]
			  ,isnull(u.loginName,a.createId) as createId
			  ,format(a.[CreatedDt],'dd/MM/yyyy hh:mm:ss') [createdDt] 
			  ,remart as apartment
		FROM [MessageSents]  a
			join NotifyInbox n on a.sourceId = n.n_id
			left join Users u on a.createId = u.userId
		WHERE ((a.custId = @custId) or (@custId = ''))
			and n.external_key = @external_key
			and (@filter = '' or a.Phone = @filter)
			and (@source_key is null or source_key = @source_key)
			and (@fromDate is null or CONVERT(DATE, a.createdDt, 103) >= CONVERT(DATE, @fromDate, 103))
			and (@toDate is null or CONVERT(DATE, a.createdDt, 103) <= CONVERT(DATE, @toDate, 103)) 
			ORDER BY SendDt desc
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
		set @ErrorMsg					= 'sp_Message_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'Messages', 'Get', @SessionID, @AddlInfo
	end catch