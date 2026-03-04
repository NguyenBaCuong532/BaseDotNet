
CREATE procedure [dbo].[sp_res_document_page]
    @UserId UNIQUEIDENTIFIER = NULL,
	@ProjectCd	nvarchar(40) = null,
	@filter nvarchar(200) = null,
	@gridWidth			int			= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@AcceptLanguage VARCHAR(20) = 'vi-VN'
	--@Total				int out,
	--@TotalFiltered		int out,
	--@GridKey		nvarchar(100) out
as
	begin try
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_document_list_manager'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.DocId)
			FROM [TRS_DocumentUrl] a 
			WHERE ProjectCd = @ProjectCd
				and [DocumentTitle] like '%' + @filter + '%'

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

	--1 profile
	  SELECT 
		   a.[DocId]
		  ,a.[DocumentTitle]
		  ,a.[DocumentUrl]
		  ,convert(nvarchar(10),a.[InputDt],103) as [InputDate]
	  FROM [TRS_DocumentUrl] a 
		WHERE ProjectCd like @ProjectCd
		and [DocumentTitle] like '%' + @filter + '%'
		ORDER BY  a.InputDt DESC 
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
		set @ErrorMsg					= 'sp_Get_DocumentUrl_List_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Document', 'GET', @SessionID, @AddlInfo
	end catch