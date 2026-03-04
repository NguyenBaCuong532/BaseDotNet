
CREATE procedure [dbo].[sp_Crm_Loyal_Page]
	@UserId			nvarchar(450), 
	@clientId		nvarchar(50) = null,
	@base_type		int,
	@category		nvarchar(50)	= '',
	@birthdayFilter int,
	@foreign		int				= 0,
	@sex			int				= 0,
	@StartDate		nvarchar(20)	= NULL,
	@EndDate		nvarchar(20)	= NULL,
	@Filter			nvarchar(30)	= '',
	@gridWidth		int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
	,@gridKey			nvarchar(200) out
as
	begin try 
		declare @webId nvarchar(50) 
		set @webId = '16653310-AACC-452F-80D1-9B97BC8B017F'
		declare @dEndDate datetime
		declare @dDate datetime
		declare @isps bit

		declare @tbCats TABLE 
		(
			categoryCd [nvarchar](50) null INDEX IX1_category NONCLUSTERED
		)
		declare @tbdays TABLE 
		(
			bd_day int null,
			bd_month int null,
			INDEX IX3 NONCLUSTERED(bd_day,bd_month)
		)

		if @birthdayFilter = 1
		begin
			set @dEndDate = convert(datetime,@EndDate,103)
			set @dDate = convert(datetime,@StartDate,103)
			WHILE @dDate <= @dEndDate
			BEGIN
			   INSERT INTO @tbdays values (day(@dDate), month(@dDate))
			   set @dDate = dateadd(day,1,@dDate)
			END;
			
		end
		

		set		@category				= isnull(@category,'')
		INSERT INTO @tbCats
		select distinct u.categoryCd from [MAS_Category_User] u 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 0 
			and not exists(select CategoryCd from @tbCats where categoryCd = u.CategoryCd)
			and (@category = '' or u.categoryCd = @category)
		INSERT INTO @tbCats
		select distinct n.categoryCd from[MAS_Category_User] u join MAS_Category n on n.base_type = u.base_type 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 1
			and not exists(select CategoryCd from @tbCats where categoryCd = n.CategoryCd)
			and (@category = '' or n.categoryCd = @category)

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@Filter					= isnull(@Filter,'')
		set		@category				= isnull(@category,'')
		set		@sex					= isnull(@sex,-1)
		set		@foreign				= isnull(@foreign,0)


		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		if not (@birthdayFilter = 0 or @birthdayFilter = 1)
			set @birthdayFilter = 0

		if @Offset = 0
			begin
				SELECT * FROM [dbo].[fn_config_list_gets] ('view_Crm_Loyal_Care_Page', @gridWidth) 
				ORDER BY [ordinal]
			end

			
	--LOYAL K/h thành viên
	if @base_type = 1 --or @base_type = 3 or @base_type = 5 or @base_type = 6
	begin
		select	@Total					= count(c.CustId)
			FROM [MAS_Customers] c 			
			join CRM_Customer a on a.custId = c.CustId
			where (@category = '' or exists(select custid from MAS_Category_Customer m join @tbCats n on m.CategoryCd = n.categoryCd  where m.CategoryCd = @category and m.CustId = c.CustId))
				and (@birthdayFilter = 0 or (@birthdayFilter = 1 and exists(select * from @tbdays where bd_day = day(c.[Birthday]) and bd_month = month(c.[Birthday]))))
				and (@Filter = '' or c.Phone like @Filter+'%' or c.Email like @Filter+'%' or c.Pass_No like @Filter+'%' or c.FullName like '%'+@Filter+'%' 
						or exists(select 1 from CRM_Card cc where cc.CardCd like @Filter + '%' and cc.CustId = c.CustId ))
				and (@foreign = 0 
					or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
					or (@foreign = 2 and (c.IsForeign = 1))
				)
				and (@sex = -1 or c.IsSex = @sex) 

			set	@TotalFiltered = @Total
			

			SELECT c.[custId]
				  ,c.avatarUrl
				  ,c.fullName
				  ,case when @isps = 1 then c.Email else case when CHARINDEX('@',c.Email) > 3 then left(c.Email,1) + '***' + substring(c.Email, CHARINDEX('@',c.Email)-2, len(c.Email)) else c.Email end end email
				  ,case when @isps = 1 then c.Phone else left(c.Phone,3) + '*****' + right(c.Phone,2) end as phone
				  ,convert(nvarchar(10),[Birthday],103) as [birthday] 
				  ,case when IsSex = 1 then N'Nam' else N'Nữ' end as sexName
				  ,c.Pass_No  as passNo
				  ,c.[address]
				  ,countryCd
				  ,c.sysDate
				  ,STUFF((
					  SELECT ',' +  crmGro.GroupName 
					  FROM [dbo].[CRM_Membership] crmMem 
						join [CRM_Group] crmGro
						 on crmMem.[GroupId] = crmGro.[GroupId]
					  WHERE crmMem.CustId = c.CustId 
					  FOR XML PATH('')), 1, 1, '') as croupName
					,c.[address]
				  
				  ,STUFF((
					  SELECT ',' +  d.base_desc 
					  FROM MAS_Base_Type d
					  where exists(select a.CategoryCd 
						from MAS_Category_Customer a 
						join MAS_Category b
						 on a.CategoryCd = b.CategoryCd
					  WHERE a.CustId = c.CustId and b.base_type = d.base_type)
					  FOR XML PATH('')), 1, 1, '') as categoryNames
					,case when c.IsForeign = 1 then N'Nước ngoài' else N'Trong nước' end as [foreign]
		 FROM [MAS_Customers] c 			
			join CRM_Customer a on a.custId = c.CustId
		  where (@category = '' or exists(select custid from MAS_Category_Customer m join @tbCats n on m.CategoryCd = n.categoryCd  where m.CategoryCd = @category and m.CustId = c.CustId))
				and (@birthdayFilter = 0 or (@birthdayFilter = 1 and exists(select * from @tbdays where bd_day = day(c.[Birthday]) and bd_month = month(c.[Birthday]))))
				and (@Filter = '' or c.Phone like @Filter+'%' or c.Email like @Filter+'%' or c.Pass_No like @Filter+'%' or c.FullName like '%'+@Filter+'%'
						or exists(select 1 from CRM_Card cc where cc.CardCd like @Filter + '%' and cc.CustId = c.CustId ))
				and (@foreign = 0 
					or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
					or (@foreign = 2 and (c.IsForeign = 1))
				) 
				and (@sex = -1 or c.IsSex = @sex) 
		ORDER BY c.sysDate DESC,c.FullName
				offset @Offset rows	
						fetch next @PageSize rows only

	end
	--else if @base_type = 2 
	--begin
	--	select	@Total					= count(a.saler_id)
	--		FROM [dbSSBigTec].[dbo].[agency_saler_mb] a
	--			join [dbSSBigTec].[dbo].gr009mb u on a.userId = u.userId
	--			--join [MAS_Customers] c on u.custId = c.CustId
	--		where (@category = '' or exists(select categoryCd from @tbCats n where n.CategoryCd = @category and n.categoryCd = a.sub_prod_cd))
	--			and a.saler_st = 1
	--			and (@birthdayFilter = 0 or (@birthdayFilter = 1 and exists(select * from @tbdays where bd_day = day(u.[Birthday]) and bd_month = month(u.[Birthday]))))
	--			and (@Filter = '' or u.Phone like @Filter+'%' or u.Email like @Filter+'%' or u.idcard_No like @Filter+'%' or u.FullName like '%'+@Filter+'%')
	--			--and (@foreign = 0 
	--			--	or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
	--			--	or (@foreign = 2 and (c.IsForeign = 1))
	--			--)
	--			and (@sex = -1 or u.sex = @sex) 

	--		set	@TotalFiltered = @Total
			

	--		SELECT u.[CustId]
	--			  ,u.AvatarUrl
	--			  ,u.FullName
	--			  ,case when @isps = 1 then u.Email else case when CHARINDEX('@',u.Email) > 3 then left(u.Email,1) + '***' + substring(u.Email, CHARINDEX('@',u.Email)-2, len(u.Email)) else u.Email end end email
	--			  ,case when @isps = 1 then u.Phone else left(u.Phone,3) + '*****' + right(u.Phone,2) end as Phone
	--			  ,convert(nvarchar(10),u.[Birthday],103) as [Birthday] 
	--			  ,case when sex = 1 then N'Nam' else N'Nữ' end as SexName
	--			  ,u.idcard_No  as PassNo
	--			  ,u.res_Add [Address]
	--			  ,u.res_Cntry CountryCd
	--			  ,d.agency_name as GroupName
	--			  --,STUFF((
	--				 -- SELECT ',' +  crmGro.GroupName 
	--				 -- FROM [dbo].[CRM_Membership] crmMem 
	--					--join [CRM_Group] crmGro
	--					-- on crmMem.[GroupId] = crmGro.[GroupId]
	--				 -- WHERE crmMem.CustId = c.CustId 
	--				 -- FOR XML PATH('')), 1, 1, '') as GroupName
	--				,u.res_Add as [Address]
	--			  --,STUFF((
	--				 -- SELECT ',' +  a.RoomCode + ' - '+ mb.ProjectName
	--				 -- FROM MAS_Apartments a 
	--					--join MAS_Apartment_Member b on a.ApartmentId = b.ApartmentId
	--					--join MAS_Rooms r on a.RoomCode = r.RoomCode 
	--					--join MAS_Buildings mb on r.BuildingCd = mb.BuildingCd 
	--				 -- WHERE b.CustId = c.CustId 
	--				 -- FOR XML PATH('')), 1, 1, '') + isnull(c.[Address],'') as [address]
	--			  ,STUFF((
	--				  SELECT ',' +  d.base_desc 
	--				  FROM MAS_Base_Type d
	--				  where exists(select b.CategoryCd 
	--					--from MAS_Category_Customer a 
	--					from MAS_Category b
	--					 --on a.CategoryCd = b.CategoryCd
	--				  WHERE b.base_type = d.base_type and b.categoryCd = a.sub_prod_cd)
	--				  FOR XML PATH('')), 1, 1, '') as categoryNames
	--				,case when u.res_Cntry <> 'VN' then N'Nước ngoài' else N'Trong nước' end as [foreign]
	--	 FROM [dbSSBigTec].[dbo].[agency_saler_mb] a
	--			join [dbSSBigTec].[dbo].gr009mb u on a.userId = u.userId
	--			join [dbSSBigTec].[dbo].[agency_info_mb] d on a.agency_id = d.agency_id
	--			--join [MAS_Customers] c on u.custId = c.CustId
	--		where (@category = '' or exists(select categoryCd from @tbCats n where n.CategoryCd = @category and n.categoryCd = a.sub_prod_cd))
	--			and a.saler_st = 1
	--			and (@birthdayFilter = 0 or (@birthdayFilter = 1 and exists(select * from @tbdays where bd_day = day(u.[Birthday]) and bd_month = month(u.[Birthday]))))
	--			and (@Filter = '' or u.Phone like @Filter+'%' or u.Email like @Filter+'%' or u.idcard_No like @Filter+'%' or u.FullName like '%'+@Filter+'%')
	--			--and (@foreign = 0 
	--			--	or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
	--			--	or (@foreign = 2 and (c.IsForeign = 1))
	--			--) 
	--			and (@sex = -1 or u.sex = @sex) 
	--	ORDER BY a.saler_sysdate DESC--,u.FullName
	--			offset @Offset rows	
	--					fetch next @PageSize rows only

	--end
	--else if @base_type = 3 --Account, kh mua sp
	--begin
	--	select	@Total					= count(c.CustId)
	--		FROM [MAS_Customers] c 	
	--			join dbSCRM.dbo.COR_Contracts f on f.cif_No = c.cif_No
	--			join dbSCRM.dbo.BLD_Rooms d on f.roomCd = d.roomCd 
	--			join dbSCRM.dbo.BLD_RoomCategory e on d.categoryCd = e.categoryCd 
	--			join @tbCats n on e.ProjectCd = n.categoryCd 
	--		where (@birthdayFilter = 0 or (@birthdayFilter = 1 and exists(select * from @tbdays where bd_day = day(c.[Birthday]) and bd_month = month(c.[Birthday]))))
	--			and (@Filter = '' or c.Phone like @Filter+'%' or c.Email like @Filter+'%' or c.Pass_No like @Filter+'%' or c.FullName like '%'+@Filter+'%')
	--			and (@foreign = 0 
	--				or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
	--				or (@foreign = 2 and (c.IsForeign = 1))
	--				) 

	--		set	@TotalFiltered = @Total
			

	--		SELECT c.[CustId]
	--			  ,c.AvatarUrl
	--			  ,c.FullName
	--			  ,case when @isps = 1 then c.Email else case when CHARINDEX('@',c.Email) > 3 then left(c.Email,1) + '***' + substring(c.Email, CHARINDEX('@',c.Email)-2, len(c.Email)) else c.Email end end email
	--			  ,case when @isps = 1 then c.Phone else left(c.Phone,3) + '*****' + right(c.Phone,2) end as Phone
	--			  ,convert(nvarchar(10),[Birthday],103) as [Birthday] 
	--			  ,case when IsSex = 1 then N'Nam' else N'Nữ' end as SexName
	--			  ,c.Pass_No  as PassNo
	--			  ,c.[Address]
	--			  ,CountryCd
	--			  ,c.sysDate
	--			  ,STUFF((
	--				  SELECT ',' +  crmGro.GroupName 
	--				  FROM [dbo].[CRM_Membership] crmMem 
	--					join [CRM_Group] crmGro
	--					 on crmMem.[GroupId] = crmGro.[GroupId]
	--				  WHERE crmMem.CustId = c.CustId 
	--				  FOR XML PATH('')), 1, 1, '') as GroupName
	--				--,c.[Address]
	--			  ,STUFF((
	--				  SELECT ',' +  d.code + ' - '+ mb.ProjectName
	--				  FROM dbSCRM.dbo.BUS_Orders f 
	--					join dbSCRM.dbo.BLD_Rooms d on f.roomCd = d.roomCd 
	--					join dbSCRM.dbo.BLD_RoomCategory e on d.categoryCd = e.categoryCd 
	--					join dbSCRM.dbo.BLD_Projects mb on e.projectCd = mb.projectCd 
	--				  WHERE f.cif_No = c.cif_No 
	--				  FOR XML PATH('')), 1, 1, '') + isnull(c.[Address],'') as [address]
	--			  --,STUFF((
	--				 -- SELECT ',' +  d.base_desc 
	--				 -- FROM MAS_Base_Type d
	--				 -- where exists(select a.CategoryCd 
	--					--from MAS_Category_Customer a 
	--					--join MAS_Category b
	--					-- on a.CategoryCd = b.CategoryCd
	--				 -- WHERE a.CustId = c.CustId and b.base_type = d.base_type)
	--				 -- FOR XML PATH('')), 1, 1, '') as categoryNames
	--			   ,case when c.IsForeign = 1 then N'Nước ngoài' else N'Trong nước' end as [foreign]
	--	 FROM [MAS_Customers] c 	
	--			join dbSCRM.dbo.COR_Contracts f on f.cif_No = c.cif_No
	--			join dbSCRM.dbo.BLD_Rooms d on f.roomCd = d.roomCd 
	--			join dbSCRM.dbo.BLD_RoomCategory e on d.categoryCd = e.categoryCd 
	--			join @tbCats n on e.ProjectCd = n.categoryCd 		
	--	  where (@birthdayFilter = 0 or (@birthdayFilter = 1 and exists(select * from @tbdays where bd_day = day(c.[Birthday]) and bd_month = month(c.[Birthday]))))
	--			and (@Filter = '' or c.Phone like @Filter+'%' or c.Email like @Filter+'%' or c.Pass_No like @Filter+'%' or c.FullName like '%'+@Filter+'%')
	--			and (@foreign = 0 
	--				or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
	--				or (@foreign = 2 and (c.IsForeign = 1))
	--			) 
	--			and (@sex = -1 or c.IsSex = @sex) 
	--	ORDER BY c.sysDate DESC--,c.FullName
	--			offset @Offset rows	
	--					fetch next @PageSize rows only

	--end
	--else if @base_type = 4 --Investor, K/h đầu tư
	--begin
	--select	@Total					= count(c.CustId)
	--		FROM [MAS_Customers] c 
	--		where exists(select custid from dbSSBigTec.dbo.inv_order_info_mb a 
	--						join UserInfo b on a.buy_user_id = b.userId 
	--								where b.custid = c.CustId and a.ord_st = 3)
	--			and (@category = '' or exists(select custid from MAS_Category_Customer m where m.CategoryCd = @category and m.CustId = c.CustId))
	--			and (@birthdayFilter = 0 or (@birthdayFilter = 1 and exists(select * from @tbdays where bd_day = day(c.[Birthday]) and bd_month = month(c.[Birthday]))))
	--			and (c.FullName like '%'+@Filter+'%' or c.Phone like '%'+@Filter+'%' or c.Email like '%'+@Filter+'%' or c.Pass_No like '%'+@Filter+'%')
	--			and (@foreign = 0 
	--				or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
	--				or (@foreign = 2 and (c.IsForeign = 1))
	--				) 
	--			and (@sex = -1 or c.IsSex = @sex) 

	--		set	@TotalFiltered = @Total
			

	--		SELECT c.[CustId]
	--			  ,c.AvatarUrl
	--			  ,c.FullName
	--			  ,case when @isps = 1 then c.Email else case when CHARINDEX('@',c.Email) > 3 then left(c.Email,1) + '***' + substring(c.Email, CHARINDEX('@',c.Email)-2, len(c.Email)) else c.Email end end email
	--			  ,case when @isps = 1 then c.Phone else left(c.Phone,3) + '*****' + right(c.Phone,2) end as Phone
	--			  ,convert(nvarchar(10),[Birthday],103) as [Birthday] 
	--			  ,case when IsSex = 1 then N'Nam' else N'Nữ' end as SexName
	--			  ,c.Pass_No  as PassNo
	--			  ,CountryCd
	--			  ,c.sysDate
	--			  ,STUFF((
	--				  SELECT ',' +  crmGro.GroupName 
	--				  FROM [dbo].[CRM_Membership] crmMem 
	--					join [CRM_Group] crmGro
	--					 on crmMem.[GroupId] = crmGro.[GroupId]
	--				  WHERE crmMem.CustId = c.CustId 
	--				  FOR XML PATH('')), 1, 1, '') as GroupName
	--			  ,c.[Address]
	--			  --,STUFF((
	--				 -- SELECT ',' +  a.RoomCode + ' - '+ mb.ProjectName
	--				 -- FROM MAS_Apartments a 
	--					--join MAS_Apartment_Member b on a.ApartmentId = b.ApartmentId
	--					--join MAS_Rooms r on a.RoomCode = r.RoomCode 
	--					--join MAS_Buildings mb on r.BuildingCd = mb.BuildingCd 
	--				 -- WHERE b.CustId = c.CustId 
	--				 -- FOR XML PATH('')), 1, 1, '') + isnull(c.[Address],'') as [address]
	--			  ,STUFF((
	--				  SELECT ',' +  d.base_desc 
	--				  FROM MAS_Base_Type d
	--				  where exists(select a.CategoryCd 
	--					from MAS_Category_Customer a 
	--					join MAS_Category b
	--					 on a.CategoryCd = b.CategoryCd
	--				  WHERE a.CustId = c.CustId and b.base_type = d.base_type)
	--				  FOR XML PATH('')), 1, 1, '') as categoryNames
	--			  ,case when c.IsForeign = 1 then N'Nước ngoài' else N'Trong nước' end as [foreign]
	--	 FROM [MAS_Customers] c 
	--	 where exists(select custid from dbSSBigTec.dbo.inv_order_info_mb a 
	--						join UserInfo b on a.buy_user_id = b.userId 
	--								where b.custid = c.CustId and a.ord_st = 3)
	--			and (@category = '' or exists(select custid from MAS_Category_Customer m where m.CategoryCd = @category and m.CustId = c.CustId))
	--			and (@birthdayFilter = 0 or (@birthdayFilter = 1 and exists(select * from @tbdays where bd_day = day(c.[Birthday]) and bd_month = month(c.[Birthday]))))
	--			and (c.FullName like '%'+@Filter+'%' or c.Phone like '%'+@Filter+'%' or c.Email like '%'+@Filter+'%' or c.Pass_No like '%'+@Filter+'%')
	--			and (@foreign = 0 
	--				or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
	--				or (@foreign = 2 and (c.IsForeign = 1))
	--				) 
	--			and (@sex = -1 or c.IsSex = @sex) 
	--	ORDER BY c.sysDate DESC,c.FullName
	--			offset @Offset rows	
	--					fetch next @PageSize rows only

	--end
	else-- if @base_type = 5 --Resident, Cư dân
	begin
		select	@Total					= count(c.CustId)
			FROM [MAS_Customers] c 
				join MAS_Apartment_Member b on c.CustId = b.CustId and b.member_st = 1
				join MAS_Apartments a on b.ApartmentId = a.ApartmentId and a.IsReceived = 1
				join @tbCats n on a.ProjectCd = n.categoryCd 
			where ((c.Phone is not null and c.Phone <> '') or (c.Email is not null and c.Email <> ''))
				
				and (@birthdayFilter = 0 or (@birthdayFilter = 1 and exists(select * from @tbdays where bd_day = day(c.[Birthday]) and bd_month = month(c.[Birthday]))))
				and (@Filter = '' or c.Phone like @Filter+'%' or c.Email like @Filter+'%' or c.Pass_No like @Filter+'%' or c.FullName like '%'+@Filter+'%')
				and (@foreign = 0 
					or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
					or (@foreign = 2 and (c.IsForeign = 1))
					) 
				and (@sex = -1 or c.IsSex = @sex) 

			set	@TotalFiltered = @Total
			

			SELECT c.[custId]
				  ,c.avatarUrl
				  ,c.fullName
				  ,case when @isps = 1 then c.Email else case when CHARINDEX('@',c.Email) > 3 then left(c.Email,1) + '***' + substring(c.Email, CHARINDEX('@',c.Email)-2, len(c.Email)) else c.Email end end email
				  ,case when @isps = 1 then c.Phone else left(c.Phone,3) + '*****' + right(c.Phone,2) end as phone
				  ,convert(nvarchar(10),[Birthday],103) as [Birthday] 
				  ,case when IsSex = 1 then N'Nam' else N'Nữ' end as sexName
				  ,c.Pass_No  as passNo
				  ,c.[address]
				  ,c.countryCd
				  ,c.sysDate
				  ,STUFF((
					  SELECT ',' +  crmGro.GroupName 
					  FROM [dbo].[CRM_Membership] crmMem 
						join [CRM_Group] crmGro
						 on crmMem.[GroupId] = crmGro.[GroupId]
					  WHERE crmMem.CustId = c.CustId 
					  FOR XML PATH('')), 1, 1, '') as croupName
					--,c.[Address]
				  ,STUFF((
					  SELECT ',' +  a.RoomCode + ' - '+ mb.ProjectName
					  FROM MAS_Apartments a 
						join MAS_Apartment_Member b on a.ApartmentId = b.ApartmentId
						join MAS_Rooms r on a.RoomCode = r.RoomCode 
						join MAS_Buildings mb on r.BuildingCd = mb.BuildingCd 
					  WHERE b.CustId = c.CustId 
					  FOR XML PATH('')), 1, 1, '') + isnull(c.[Address],'') as [address]
				  ,STUFF((
					  SELECT ',' +  d.base_desc 
					  FROM MAS_Base_Type d
					  where exists(select a.CategoryCd 
						from MAS_Category_Customer a 
						join MAS_Category b
						 on a.CategoryCd = b.CategoryCd
					  WHERE a.CustId = c.CustId and b.base_type = d.base_type)
					  FOR XML PATH('')), 1, 1, '') as categoryNames
				  ,case when c.IsForeign = 1 then N'Nước ngoài' else N'Trong nước' end as [foreign]
		 FROM [MAS_Customers] c 
			join MAS_Apartment_Member b on c.CustId = b.CustId and b.member_st = 1
			join MAS_Apartments a on b.ApartmentId = a.ApartmentId and a.IsReceived = 1
			join @tbCats n on a.ProjectCd = n.categoryCd 
		  where ((c.Phone is not null and c.Phone <> '') or (c.Email is not null and c.Email <> ''))
				and (@birthdayFilter = 0 or (@birthdayFilter = 1 and exists(select * from @tbdays where bd_day = day(c.[Birthday]) and bd_month = month(c.[Birthday]))))
				and (c.Phone like @Filter+'%' or c.Email like @Filter+'%' or c.Pass_No like @Filter+'%' or c.FullName like '%'+@Filter+'%')
				and (@foreign = 0 
					or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
					or (@foreign = 2 and (c.IsForeign = 1))
					) 
				and (@sex = -1 or c.IsSex = @sex) 
		ORDER BY c.sysDate DESC,c.FullName
				offset @Offset rows	
						fetch next @PageSize rows only

	end
	
	--else if @base_type = 6 --Employee, Nhân viên
	--begin
	--select	@Total					= count(c.CustId)
	--		FROM [MAS_Customers] c 
	--			join [dbSHRM].[dbo].[Employees] a on a.CustId = c.CustId 
	--			join [dbSHRM].[dbo].Organize_Param op on a.organizeId = op.organizeId
	--			left join @tbCats m on m.categoryCd = op.organizationCd
	--		where a.emp_st = 1
	--			and (@category = '' or exists(select categoryCd from @tbCats m where m.CategoryCd = @category and m.categoryCd = op.organizationCd))
	--			and (@birthdayFilter = 0 or (@birthdayFilter = 1 and exists(select * from @tbdays where bd_day = day(c.[Birthday]) and bd_month = month(c.[Birthday]))))
	--			and (@Filter = '' or c.Phone like @Filter+'%' or c.Email like @Filter+'%' or c.FullName like '%'+@Filter+'%')
	--			and (@sex = -1 or c.IsSex = @sex) 

	--		set	@TotalFiltered = @Total
			

	--		SELECT c.[CustId]
	--			  ,c.AvatarUrl
	--			  ,c.FullName
	--			  ,case when @isps = 1 then c.Email else case when CHARINDEX('@',c.Email) > 3 then left(c.Email,1) + '***' + substring(c.Email, CHARINDEX('@',c.Email)-2, len(c.Email)) else c.Email end end email
	--			  ,case when @isps = 1 then c.Phone else left(c.Phone,3) + '*****' + right(c.Phone,2) end as Phone
	--			  ,convert(nvarchar(10),[Birthday],103) as [Birthday] 
	--			  ,case when IsSex = 1 then N'Nam' else N'Nữ' end as SexName
	--			  ,c.Pass_No  as PassNo
	--			  ,CountryCd
	--			  ,c.sysDate
	--			  ,STUFF((
	--				  SELECT ',' +  crmGro.GroupName 
	--				  FROM [dbo].[CRM_Membership] crmMem 
	--					join [CRM_Group] crmGro
	--					 on crmMem.[GroupId] = crmGro.[GroupId]
	--				  WHERE crmMem.CustId = c.CustId 
	--				  FOR XML PATH('')), 1, 1, '') as GroupName
	--			  ,c.[Address]
				  
	--			  ,STUFF((
	--				  SELECT ',' +  d.base_desc 
	--				  FROM MAS_Base_Type d
	--				  where exists(select a.CategoryCd 
	--					from MAS_Category_Customer a 
	--					join MAS_Category b
	--					 on a.CategoryCd = b.CategoryCd
	--				  WHERE a.CustId = c.CustId and b.base_type = d.base_type)
	--				  FOR XML PATH('')), 1, 1, '') as categoryNames
	--			 ,case when c.IsForeign = 1 then N'Nước ngoài' else N'Trong nước' end as [foreign]
	--	 FROM [MAS_Customers] c 
	--			join [dbSHRM].[dbo].[Employees] a on a.CustId = c.CustId 
	--			join [dbSHRM].[dbo].Organize_Param op on a.organizeId = op.organizeId
	--			join  b on a.UserId = b.UserId and b.userType = 1
	--			left join @tbCats m on m.categoryCd = op.organizationCd
	--		where a.emp_st = 1
	--			--and a.IsLock = 0
	--			and (@category = '' or exists(select categoryCd from @tbCats m where m.CategoryCd = @category and m.categoryCd = op.organizationCd))
	--			and (@birthdayFilter = 0 or (@birthdayFilter = 1 and exists(select * from @tbdays where bd_day = day(c.[Birthday]) and bd_month = month(c.[Birthday]))))
	--			and (@Filter = '' or c.Phone like @Filter+'%' or c.Email like @Filter+'%' or c.FullName like '%'+@Filter+'%')
	--			and (@sex = -1 or c.IsSex = @sex) 
	--	ORDER BY c.sysDate DESC,c.FullName
	--			offset @Offset rows	
	--					fetch next @PageSize rows only

	--end
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Loyal_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Loyal', 'GET', @SessionID, @AddlInfo
	end catch