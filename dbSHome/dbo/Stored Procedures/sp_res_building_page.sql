
CREATE procedure [dbo].[sp_res_building_page]
	 @UserId		UNIQUEIDENTIFIER = null
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
	,@filter		nvarchar(200) = null
	,@Offset			int				= 0
	,@PageSize			int				= 10
	,@gridWidth			int = 0
	,@ProjectCd		nvarchar(50) = null
as
	begin try
		-- =============================================
		-- LẤY TENANT_OID TỪ USERS
		-- =============================================
		DECLARE @tenantOid UNIQUEIDENTIFIER = NULL;
		
		IF @UserId IS NOT NULL
		BEGIN
			SELECT @tenantOid = tenant_oid
			FROM Users
			WHERE userId = @UserId;
		END
		
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_building_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.Id)
		from MAS_Buildings a 
		where (@ProjectCd is null or a.ProjectCd = @ProjectCd)
		  AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid)
		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		
		IF @Offset = 0
		BEGIN
			SELECT *
			FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
			ORDER BY [ordinal];
		END

		  select a.buildingCd
				,a.buildingName
				,a.intOrder
				,a.id
				,a.projectCd
				,p.projectName
				,a.created_at 
				,created_by = mk.fullName
		from MAS_Buildings a
			left join Users mk on a.created_by = mk.userId
			join MAS_Projects p on a.ProjectCd = p.projectCd
		where (@ProjectCd is null or a.ProjectCd = @ProjectCd)
		 AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid)
		 and (a.BuildingName like '%' + @filter + '%' or a.ProjectName like '%' + @filter +'%' )
		ORDER BY a.intOrder
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
		set @ErrorMsg					= 'sp_res_building_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Buildings', 'GET', @SessionID, @AddlInfo
	end catch