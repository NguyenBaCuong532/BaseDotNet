

CREATE procedure [dbo].[sp_Hom_Card_Partner_ByManager]
	@UserId		nvarchar(450),
	@clientId	nvarchar(50),
	@projectCd	nvarchar(50),
	@filter		nvarchar(30),
	@gridWidth			int = 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
		declare @webId nvarchar(50) --= (select id from [dbAppManager].[dbo].[ClientWebs] where clientId = @clientId or clientIdDev = @clientId)
		declare @tbCats TABLE 
		(
			categoryCd [nvarchar](50) not null INDEX IX1_category NONCLUSTERED
		)
		set		@projectCd				= isnull(@projectCd,'')
		INSERT INTO @tbCats
		select distinct u.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 0 
			and (@ProjectCd = '' or u.categoryCd = @ProjectCd)
			and not exists(select CategoryCd from @tbCats where categoryCd = u.CategoryCd)
		INSERT INTO @tbCats
		select distinct n.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u join [dbSHome].[dbo].MAS_Category n on n.base_type = u.base_type 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 1
			and (@ProjectCd = '' or n.categoryCd = @ProjectCd)
			and not exists(select CategoryCd from @tbCats where categoryCd = n.CategoryCd)

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		if @Offset = 0
			begin
				SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Card_Partner_Page', @gridWidth) 
				ORDER BY [ordinal]
			end

		select	@Total					= count(a.partner_id)
			FROM MAS_CardPartner a 
				join @tbCats t on a.projectCd = t.categoryCd 
			WHERE (partner_name like '%' + @filter + '%')
							

		set	@TotalFiltered = @Total
				
		--1
		SELECT a.partner_id 
		      ,a.partner_cd 
			  ,a.partner_name 
			  ,a.projectCd
			  ,p.projectName
			  ,a.create_dt 
			  ,a.create_by 
			  ,a.update_dt 
			  ,a.update_by 
	  FROM [dbo].MAS_CardPartner a 
			join MAS_Projects p on a.ProjectCd = p.projectCd
			join @tbCats t on a.projectCd = t.categoryCd 
			
		WHERE (partner_name like '%' + @filter + '%')
			ORDER BY a.partner_name 
			  offset @Offset rows	
				fetch next @PageSize rows only
	  
	--2
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Card_Partner_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardParnet', 'GET', @SessionID, @AddlInfo
	end catch