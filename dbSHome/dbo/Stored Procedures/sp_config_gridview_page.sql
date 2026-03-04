



CREATE procedure [dbo].[sp_config_gridview_page]
	 @userId			nvarchar(450)	
	--,@Total			bigint out
	--,@TotalFiltered	bigint out
	--,@GridKey			nvarchar(100) out
	,@filter		nvarchar(250)
	,@view_grid		nvarchar(250)
	,@gridWidth		int				= 0
	,@Offset		int				= 0
	,@PageSize		int				= 10
	,@acceptLanguage	nvarchar(50) = 'vi-VN'
as
	begin try
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_config_gridview_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
			 
		select	@Total					= count(a.id)
			FROM [sys_config_list] a 
			WHERE [view_grid] like @view_grid  
				and columnField like '%' + @filter + '%'

		--root	
		select recordsTotal = @Total
				,recordsFiltered = @Total
				,gridKey = @GridKey
				,valid = 1

		--gridflexs
		if @Offset = 0
		begin
			SELECT * FROM [dbo].fn_config_list_gets (@GridKey, @gridWidth) 
			ORDER BY [ordinal]
		end

		--dataList
		SELECT [id]
			  ,[view_grid]
			  ,[view_type]
			  ,[columnField]
			  ,[columnCaption]
			  ,[columnCaptionE]
			  ,[columnWidth]
			  ,[data_type]
			  ,[fieldType]
			  ,[cellClass]
			  ,[conditionClass]
			  ,[pinned]
			  ,[ordinal]
			  ,[isUsed]
			  ,[isHide]
			  ,[isMasterDetail]
			  ,[isStatusLable]
			  ,[isFilter]
		  FROM [dbo].[sys_config_list]
		  WHERE [view_grid] like @view_grid  
			and columnField like '%' + @filter + '%'
		  ORDER BY ordinal
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
		set @ErrorMsg					= 'sp_config_gridview_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'gridview', 'GET', @SessionID, @AddlInfo
	end catch