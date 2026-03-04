


CREATE procedure [dbo].[sp_res_email_page]
	@UserId				UNIQUEIDENTIFIER = NULL,
	@AcceptLanguage VARCHAR(20) = 'vi-VN',
	@external_key			nvarchar(50),
	@custId				nvarchar(100),
	@filter				nvarchar(250),
	@fromDate			nvarchar(250),
	@toDate				nvarchar(250),
	@source_key			nvarchar(250),
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10
	--@Total				int out,
	--@TotalFiltered		int out,
	--@GridKey			nvarchar(100) out
as
	begin try
		--declare @orgId	uniqueidentifier = (select top 1 orgId from Users where userId = @userId)
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_email_send_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		set		@CustId					= isnull(@CustId,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.[Id])
			FROM EmailSents a 
			WHERE (a.custId = @CustId or @CustId = '' )
				--and external_key = @external_key
				and (@filter = '' or a.mailto = @filter)
				and (@source_key is null or sourceKey = @source_key)
				and (@fromDate is null or CONVERT(DATE, a.createdDate, 103) >= CONVERT(DATE, @fromDate, 103))
				and (@toDate is null or CONVERT(DATE, a.createdDate, 103) <= CONVERT(DATE, @toDate, 103)) 
		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		--grid config
		if @Offset = 0
		begin
			if @CustId = ''
				set @GridKey = 'view_email_send_page'
			else
				set @GridKey = 'view_email_send_page'
		
			select * from [dbo].[fn_config_list_gets]  (@GridKey, @gridWidth) 
			order by [ordinal]
		end
		
		SELECT cast([Id] as nvarchar(250)) id
			  ,[mailto] as [to]
			  ,[SendBy] as sendBy
			  ,[Subject] as subject
			  ,[Status] as sendStatus
			  ,created_dt as createdDate
			  ,[Send]
			  ,[SendName] as sendName
			  ,[SendDate]
			  ,IsRead as isRead
			  ,ReadDt as readDate
			  ,isnull(u.loginName,a.createId) as createdId
			  ,contents as contents
		FROM EmailSents as a 
			left join users u on a.createId = u.userId
		WHERE   --a.orgId = @orgId and
				(a.custId = @CustId or @CustId = '' )
				and (@filter = '' or a.mailto = @filter)
				and (@source_key is null or sourceKey = @source_key)
				and (@fromDate is null or CONVERT(DATE, a.createdDate, 103) >= CONVERT(DATE, @fromDate, 103))
				and (@toDate is null or CONVERT(DATE, a.createdDate, 103) <= CONVERT(DATE, @toDate, 103)) 
		ORDER BY a.[CreatedDate] DESC
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
		set @ErrorMsg					= 'sp_hrm_email_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'Notifications', 'Get', @SessionID, @AddlInfo
	end catch