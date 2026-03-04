






CREATE procedure [dbo].[sp_Hom_Apartment_Household_Page]
	@UserId			nvarchar(450),
	@clientId		nvarchar(50),
	@ProjectCd		nvarchar(40),
	@buildingCd		nvarchar(30),
	@filter			nvarchar(100) = '',
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out

as
	begin try
	--1
		declare @webId nvarchar(50) 
		declare @tbCats TABLE 
		(
			categoryCd [nvarchar](50) not null INDEX IX1_category NONCLUSTERED
		)
		set		@projectCd				= isnull(@projectCd,'')
		INSERT INTO @tbCats
		select distinct u.categoryCd from [MAS_Category_User] u 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 0 
			and (@ProjectCd = '' or u.categoryCd = @ProjectCd)
			and not exists(select CategoryCd from @tbCats where categoryCd = u.CategoryCd)
		INSERT INTO @tbCats
		select distinct n.categoryCd from [MAS_Category_User] u join MAS_Category n on n.base_type = u.base_type 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 1
			and (@ProjectCd = '' or n.categoryCd = @ProjectCd)
			and not exists(select CategoryCd from @tbCats where categoryCd = n.CategoryCd)

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@buildingCd				= isnull(@buildingCd,'')
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		if @Offset = 0
		begin
			SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Apartment_Household_Page', @gridWidth) 
			ORDER BY [ordinal]
		end

		select 	@Total					= count(a.CustId)
		FROM [MAS_Customers] a 
			join MAS_Apartment_Member c on a.CustId = c.CustId 
			join [MAS_Apartments] e on c.ApartmentId = e.ApartmentId
			join @tbCats t on e.projectCd = t.categoryCd 
			inner join MAS_Rooms r on e.RoomCode = r.RoomCode 
			left join [MAS_Customer_Household] b ON a.CustId = b.CustId
			left join MAS_Customer_Relation d on c.RelationId = d.RelationId 
		WHERE (@buildingCd= '' or r.BuildingCd = @buildingCd)
			and (r.RoomCode like '%' + @filter + '%' or a.FullName like '%' + @filter +'%' or a.Phone like '%' + @filter +'%')
				
		set @TotalFiltered = @Total

		SELECT a.CustId 
			  ,a.[FullName]
			  ,case when a.[IsSex] = 1 then N'Nam' else N'Nữ' end as SexName
			  ,convert(nvarchar(10),a.birthday,103) as birthday
			  ,a.[Phone]
			  ,a.[Email]
			  ,case when exists(select ApartmentId from MAS_Apartments ma 
				join UserInfo mu on ma.UserLogin = mu.loginName 
					where mu.CustId = a.CustId and ma.ApartmentId = e.ApartmentId) then 1 else 0 end as [IsHost]
			  ,c.[ApartmentId]
			  ,a.[AvatarUrl]
			  ,isnull(a.IsForeign,0) as IsForeign
			  ,c.isNotification
			  ,case when c.memberUserId is not null or exists(select userid from UserInfo mu 
						where mu.CustId = a.CustId and mu.userType = 2) then 1 else 0 end as isApp
			  ,isnull(b.[IsResident],0) IsResident
			  ,b.[ResAdd1]
			  ,b.[ContactAdd1]
			  ,b.[Pass_No] as PassNo
			  ,convert(nvarchar(10),b.[Pass_I_Dt],103) as PassDate 
			  ,b.[Pass_I_Plc] as PassPlace
			  ,d.RelationName
			  ,e.RoomCode
			  ,f.BuildingName
			  ,p.projectName
			  ,a.CountryCd
			  ,g.CountryName 
		  FROM [MAS_Customers] a 
			join MAS_Apartment_Member c on a.CustId = c.CustId 
			join [MAS_Apartments] e on c.ApartmentId = e.ApartmentId
			join @tbCats t on e.projectCd = t.categoryCd 
			join MAS_Rooms r on e.RoomCode = r.RoomCode 
			JOIN MAS_Buildings f On r.BuildingCd = f.BuildingCd 
			JOIN MAS_Projects p On e.projectCd = p.projectCd or e.sub_projectCd = p.sub_projectCd
			left join [MAS_Customer_Household] b ON a.CustId = b.CustId
			left join MAS_Customer_Relation d on c.RelationId = d.RelationId 
			left join [COR_Countries] g on a.CountryCd = g.CountryCd 
		WHERE e.IsReceived  = 1
			and (@buildingCd= '' or r.BuildingCd = @buildingCd)
			and (r.RoomCode like '%' + @filter + '%' or a.FullName like '%' + @filter +'%' or a.Phone like '%' + @filter +'%')
			  ORDER BY  e.[RoomCode] 
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
		set @ErrorMsg					= 'sp_Hom_Apartment_Household_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'household', 'GET', @SessionID, @AddlInfo
	end catch