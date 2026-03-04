







CREATE procedure [dbo].[sp_Hom_Card_Guest_ByManager]
	@UserId		nvarchar(450),
	@clientId	nvarchar(50),
	@projectCd	nvarchar(50),
	@partner_id	int				= -1,
	@filter		nvarchar(50)	= null,
	@Statuses			int		= null,
	@Offset				int		= 0,
	@PageSize			int		= 10,
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
		set		@Statuses				= isnull(@Statuses,-1)
		--set		@partner_id				= isnull(@partner_id,0)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.CardId)
			FROM [MAS_Cards] a 
				join @tbCats t on a.projectCd = t.categoryCd 
				join MAS_Customers c on a.CustId = c.CustId
			WHERE a.IsGuest = 1 
				and (@Statuses = -1 or Card_St = @Statuses)
				and (@partner_id = -1 or a.partner_id = @partner_id)
				and (CardCd like '%' + @filter + '%' or c.Phone like '%' + @filter + '%' or c.FullName like '%' + @filter + '%' )
				
				

		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end
	
	--1
		SELECT a.[CardCd]
			  ,format(a.[IssueDate],'dd/MM/yyyy hh:mm:ss') as [IssueDate]
			  ,format(a.[ExpireDate],'dd/MM/yyyy hh:mm:ss') as [ExpireDate]
			  ,s.[StatusName]
			  ,a.Card_St as [Status]
			  ,c.FullName as CustName
			  ,a.IsClose 
			  ,a.CloseDate 
			  ,c.Phone as CustPhone
			  ,c.Email
			  ,a.CardName
			  ,a.CustId
			  ,case when exists(select CardId from MAS_CardVehicle where cardid = a.CardId) then 1 else 0 end IsVehicle
			  ,p.projectName
			  ,a.ProjectCd
			  ,d.partner_name
			  ,a.partner_id
	  FROM [dbo].[MAS_Cards] a 
			join @tbCats t on a.projectCd = t.categoryCd 
			join MAS_Customers c on a.CustId = c.CustId
			join MAS_CardStatus s on a.Card_St = s.StatusId
			join MAS_Projects p on a.ProjectCd = p.projectCd
			left join MAS_CardPartner d on a.partner_id = d.partner_id 
		WHERE a.IsGuest = 1 
				and (@Statuses = -1 or Card_St = @Statuses)
				and (@partner_id = -1 or a.partner_id = @partner_id)
				and (CardCd like '%' + @filter + '%' or c.Phone like '%' + @filter + '%' or c.FullName like '%' + @filter + '%' )
			ORDER BY a.CardCd 
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
		set @ErrorMsg					= 'sp_Hom_Card_Guest_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardGuest', 'GET', @SessionID, @AddlInfo
	end catch