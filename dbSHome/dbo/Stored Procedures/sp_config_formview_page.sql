



CREATE procedure [dbo].[sp_config_formview_page]
	 @userId			UNIQUEIDENTIFIER
	--,@Total				bigint out
	--,@TotalFiltered		bigint out
	--,@GridKey			nvarchar(100) out
	,@filter			nvarchar(250)
	,@table_name		nvarchar(100)
	,@gridWidth			int				= 0
	,@Offset			int				= 0
	,@PageSize			int				= 10
	,@acceptLanguage	nvarchar(50) = N'vi-VN'
as
	begin try
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_config_formview_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
			 
		select	@Total					= count(a.id)
			FROM sys_config_form a 
			WHERE [table_name] like @table_name 
				and a.field_name like @filter + '%'

		--root	
		select recordsTotal = @Total
				,recordsFiltered = @Total
				,gridKey = @GridKey
				,valid = 1

		--gridflexs
		if @Offset = 0
		begin
			SELECT * FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage) 
			ORDER BY [ordinal]
		end

		--dataList
		SELECT id
			  ,table_name
			  ,field_name
			  ,view_type
			  ,data_type
			  ,ordinal
			  ,group_cd
			  ,columnLabel
			  ,columnLabelE
			  ,columnTooltip
			  ,columnDefault
			  ,columnClass
			  ,columnType
			  ,columnObject
			  ,isVisiable
			  ,isSpecial
			  ,isRequire
			  ,isDisable			  
		FROM dbo.sys_config_form a
			WHERE [table_name] like @table_name 
				and a.field_name like @filter + '%'
		ORDER BY group_cd, ordinal
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
		set @ErrorMsg					= 'sp_config_formview_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'formview', 'GET', @SessionID, @AddlInfo
	end catch