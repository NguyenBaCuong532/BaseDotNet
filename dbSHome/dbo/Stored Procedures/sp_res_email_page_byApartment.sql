
CREATE procedure [dbo].[sp_res_email_page_byApartment]
	@UserId				UNIQUEIDENTIFIER = NULL,
	@sourceId			uniqueidentifier,
	@filter				nvarchar(250),
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@AcceptLanguage VARCHAR(20) = 'vi-VN'
	--@Total				int out,
	--@TotalFiltered		int out,
	--@GridKey		nvarchar(200) out

as
	begin try
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_Email_Page_BySource'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.[Id])
			FROM EmailSents a 
			WHERE (a.sourceId = @sourceId)
				and (@filter = '' or a.mailto like '%' + @filter + '%')

		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		--grid config
		if @Offset = 0
		begin
			select * from [dbo].[fn_config_list_gets_lang] (@GridKey, @gridWidth - 100, @AcceptLanguage) 
			order by [ordinal]
		end
		
		SELECT [Id]
			  ,[mailto]
			  ,[SendBy]
			  ,[Subject]
			  ,[Status] as sendStatus
			  ,[CreatedDate]
			  ,[Send]
			  ,[SendName]
			  ,[SendDate]
			  ,IsRead
			  ,ReadDt as ReadDate
			  ,remart as apartment
		FROM EmailSents as a 
		WHERE (a.sourceId = @sourceId)
			and (@filter = '' or a.mailto like '%' + @filter + '%')
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
		set @ErrorMsg					= 'sp_Email_Page_BySource' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Notifications', 'Get', @SessionID, @AddlInfo
	end catch