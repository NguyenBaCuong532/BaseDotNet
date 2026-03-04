







CREATE procedure [dbo].[sp_Hom_Card_Resident_ByManager]
	@UserId		nvarchar(450),
	@clientId	nvarchar(50),
	@ProjectCd	nvarchar(50),
	@RoomCd		nvarchar(30),
	@Statuses			int = null,
	@vehicle			int = -1,
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
		set		@RoomCd					= isnull(@RoomCd,'')
		set		@vehicle				= isnull(@vehicle,-1)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		select	@Total					= count(a.CardId)
			FROM MAS_Apartments c  
				join [MAS_Cards] a on a.ApartmentId = c.ApartmentId 
				JOIN MAS_Customers b On a.CustId = b.CustId  
				join @tbCats t on c.projectCd = t.categoryCd 
			WHERE a.CardTypeId <= 3
				and ((@Statuses is null or @Statuses = -1 ) Or a.Card_St = @Statuses)
				and ((@vehicle = -1) 
					or (@vehicle = 0 and not exists(select CardVehicleId from MAS_CardVehicle where CardId = a.CardId and [Status] < 3))
					or (@vehicle = 1 and exists(select CardVehicleId from MAS_CardVehicle where CardId = a.CardId and [Status] < 3))
					)
				and (@RoomCd= '' or c.RoomCode like @RoomCd + '%' Or a.CardCd like @RoomCd +'%' --or b.FullName like '%'+ @RoomCd +'%'
				)
		set	@TotalFiltered = @Total

	--1
		SELECT [CardCd]
			  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
			  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
			  ,a.CustId as CifNo
			  ,a.CustId
			  ,a.[CardTypeId]
			  --,isnull(pp.CurrPoint,0) [CurrentPoint]
			  ,pp.CardTypeImg as [ImageUrl]
			  ,b.FullName
			  ,s.[StatusName]
			  ,a.Card_St as [Status]
			  ,c.RoomCode
			  ,a.ApartmentId
			  ,cb.Card_Hex as cardHex
			  ,case when count(vh.CardVehicleId) > 0 then 1 else 0 end as IsVehicle
			  ,p.projectName 
	  FROM  [MAS_Apartments] c
		join @tbCats t on c.projectCd = t.categoryCd 
		join MAS_Projects p on c.projectCd = p.projectCd 
		join [MAS_Cards] a  on a.ApartmentId = c.ApartmentId
		join MAS_CardBase cb on a.CardCd = cb.Code
		join MAS_Customers b On a.CustId = b.CustId 
		join MAS_CardStatus s on a.Card_St = s.StatusId
		join MAS_CardTypes pp on a.[CardTypeId] = pp.[CardTypeId]
		left join MAS_CardVehicle vh on a.CardId = vh.CardId and vh.[Status] < 3
	  WHERE a.CardTypeId <= 3
			and ((@Statuses is null or @Statuses = -1 ) Or a.Card_St = @Statuses)
			and ((@vehicle = -1) 
					or (@vehicle = 0 and not exists(select CardVehicleId from MAS_CardVehicle where CardId = a.CardId and [Status] < 3))
					or (@vehicle = 1 and exists(select CardVehicleId from MAS_CardVehicle where CardId = a.CardId and [Status] < 3))
					)
			and (@RoomCd= '' or c.RoomCode like @RoomCd + '%' Or CardCd like @RoomCd +'%' --or b.FullName like '%'+ @RoomCd +'%'
			)
		group by
			   [CardCd]
			  ,convert(nvarchar(10),a.[IssueDate],103) 
			  ,convert(nvarchar(10),a.[ExpireDate],103) 
			  ,a.CustId 
			  ,a.CustId
			  ,a.[CardTypeId]
			  ,pp.CardTypeImg 
			  ,b.FullName
			  ,s.[StatusName]
			  ,a.Card_St 
			  ,c.RoomCode
			  ,a.ApartmentId
			  ,cb.Card_Hex
			  ,p.projectName 
		ORDER BY c.RoomCode,a.[CardCd]
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
		set @ErrorMsg					= 'sp_Get_Card_List_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'SalerMonthly', 'GET', @SessionID, @AddlInfo
	end catch