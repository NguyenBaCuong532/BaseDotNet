






CREATE procedure [dbo].[sp_Hom_Card_Daily_ByManager]
	@userId		nvarchar(450),
	@clientId	nvarchar(50),
	@projectCd	nvarchar(30),
	@filter		nvarchar(60),
	@Statuses			int = null,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
		declare @webId nvarchar(50) = (select id from [dbAppManager].[dbo].[ClientWebs] where clientId = @clientId or clientIdDev = @clientId)
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
		set		@ProjectCd				= isnull(@ProjectCd,'')
		set		@Statuses				= isnull(@Statuses,-1)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.CardId)
			FROM [MAS_Cards] a 
				join @tbCats t on a.projectCd = t.categoryCd 
			WHERE a.CardTypeId = 3
				and a.IsDaily = 1
				and a.CardCd like @filter + '%'
				and (@Statuses = -1 or Card_St = @Statuses)
		
		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end
	
	--1
		SELECT a.[CardCd]
			  ,convert(nvarchar(10),a.[IssueDate],103) [InputDate]
			  ,s.[StatusName]
			  ,a.Card_St as [Status]
			  ,a.VehicleTypeId
			  ,VehicleTypeName
			  ,a.ProjectCd
			  ,a.IsClose 
			  ,a.CloseDate 
			  ,p.ProjectName
		  FROM [MAS_Cards] a 
			join @tbCats t on a.projectCd = t.categoryCd 
			join MAS_VehicleTypes b on a.VehicleTypeId = b.VehicleTypeId 
			join MAS_CardStatus s on a.Card_St = s.StatusId
			left join MAS_Projects p on a.ProjectCd = p.ProjectCd
			WHERE a.CardTypeId = 3 
				and a.IsDaily = 1
				and a.CardCd like @filter + '%'
				and (@Statuses = -1 or Card_St = @Statuses)
			ORDER BY [CardCd] 
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
		set @ErrorMsg					= 'sp_Hom_Card_Daily_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'GET', @SessionID, @AddlInfo
	end catch