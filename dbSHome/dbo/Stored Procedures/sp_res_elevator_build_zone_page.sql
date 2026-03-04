CREATE procedure [dbo].[sp_res_elevator_build_zone_page]
	 @UserId		UNIQUEIDENTIFIER = null
	,@filter		nvarchar(200) = null
	,@Offset			int				= 0
	,@PageSize			int				= 10
	,@gridWidth			int = 0
	,@ProjectCd		nvarchar(50) = null
	,@areaCd		nvarchar(30) = null
	,@acceptLanguage		NVARCHAR(50) = N'vi-VN'
as
	begin try
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_elevator_zone_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.Id)
		from ELE_BuildZone a 
		where (@ProjectCd is null or ProjectCd = @ProjectCd)
					and (@areaCd is null or AreaCd = @areaCd)
		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		
		--grid config
		IF @Offset = 0
		BEGIN
			SELECT *
			FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
			ORDER BY [ordinal];
		END

		select a.areaCd 
			  ,a.buildZone 
			  ,a.projectCd
			  ,a.id
			from ELE_BuildZone a
			where (@ProjectCd is null or ProjectCd = @ProjectCd)
					and (@areaCd is null or AreaCd = @areaCd)
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_elevator_build_zone_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ELE_BuildZone', 'GET', @SessionID, @AddlInfo
	end catch