CREATE procedure [dbo].[sp_res_household_get]
	@UserId			UNIQUEIDENTIFIER,
	@clientId		nvarchar(50) = NULL,
	@ProjectCd		nvarchar(40),
	@buildingCd		nvarchar(30) = 'all',
	@filter			nvarchar(100) = '',
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int OUT,
	@GridKey		nvarchar(100) out,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
as
	begin try
	--1
		--DECLARE @temp NVARCHAR(500)
		--SET @temp =(SELECT TOP(1) categoryIds FROM dbo.UserConfig WHERE userId = @userId)

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@buildingCd				= isnull(@buildingCd,'all')
		set		@filter					= isnull(@filter,'')
		set		@GridKey				= 'view_household_page'

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		if @Offset = 0
		begin
			SELECT * FROM dbo.fn_config_list_gets_lang('view_household_page', @gridWidth, @acceptLanguage) 
			ORDER BY [ordinal]
		end

		select 	@Total					= count(a.CustId)
		FROM [MAS_Customers] a 
			join MAS_Apartment_Member c on a.CustId = c.CustId 
			join [MAS_Apartments] e on c.ApartmentId = e.ApartmentId
			LEFT JOIN MAS_Buildings bld ON e.buildingOid = bld.oid
			left join [MAS_Customer_Household] b ON a.CustId = b.CustId
			left join MAS_Customer_Relation d on c.RelationId = d.RelationId 
		WHERE (@buildingCd= 'all' or bld.BuildingCd = @buildingCd)
			and (e.RoomCode like '%' + @filter + '%' or a.FullName like '%' + @filter +'%' or a.Phone like '%' + @filter +'%')
			AND (@ProjectCd= '-1' or e.projectCd = @ProjectCd)
			AND exists(SELECT projectCd
							FROM UserProject where userId = @userId and projectCd = e.projectCd)
				
		set @TotalFiltered = @Total

		SELECT a.CustId 
			  ,a.[FullName]
			  --,case when a.[IsSex] = 1 then N'Nam' else N'Nữ' end as SexName
			  ,cd.par_desc AS SexName
			  ,convert(nvarchar(10),a.birthday,103) as birthday
			  ,a.[Phone]
			  ,a.[Email]
			  ,case when exists(select ApartmentId from MAS_Apartments ma 
				join UserInfo mu on ma.UserLogin = mu.loginName 
					where mu.CustId = a.CustId and ma.ApartmentId = e.ApartmentId) then cast(1 AS BIT) else cast(0 AS BIT) end as [IsHost]
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
			LEFT JOIN MAS_Buildings f On e.buildingOid = f.oid 
			JOIN MAS_Projects p On e.projectCd = p.projectCd or e.sub_projectCd = p.sub_projectCd
			left join [MAS_Customer_Household] b ON a.CustId = b.CustId
			left join MAS_Customer_Relation d on c.RelationId = d.RelationId 
			left join [COR_Countries] g on a.CountryCd = g.CountryCd
			LEFT JOIN dbo.sys_config_data cd ON cd.value1 = a.IsSex AND cd.key_1 = 'sex'
		WHERE e.IsReceived  = 1
			and (@buildingCd= 'all' or f.BuildingCd = @buildingCd)
			and (e.RoomCode like '%' + @filter + '%' or a.FullName like '%' + @filter +'%' or a.Phone like '%' + @filter +'%')
			AND (@ProjectCd= '-1' or e.projectCd = @ProjectCd)
			AND exists(SELECT projectCd
							FROM UserProject where userId = @userId and projectCd = e.projectCd)
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
		set @ErrorMsg					= 'sp_res_household_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'household', 'GET', @SessionID, @AddlInfo
	end catch