







CREATE procedure [dbo].[sp_Hom_Apartment_List_ByManager]
	@userId		nvarchar(450),
	@clientId	nvarchar(50),
	@ProjectCd	nvarchar(40),
	@buildingCd nvarchar(30),
	@Received		int = -1,
	@Rent			int = -1,
	@Debt			int = -1,
	@setupStatus	int = -1,
	@filter		nvarchar(100) = '',
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
	    
		--set @clientId = 'web_s_service_prod'
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
		set		@Received				= isnull(@Received,-1)
		set		@Rent					= isnull(@Rent,-1)
		set		@setupStatus			= isnull(@setupStatus,-1)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		--set		@setupStatus = 0

		select	@Total					= count(a.[ApartmentId])
			FROM [MAS_Apartments] a 
				inner join MAS_Rooms r on a.RoomCode = r.RoomCode 
				INNER JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
				left join UserInfo m on a.UserLogin = m.loginName 
				left JOIN MAS_Customers c ON m.CustId = c.CustId
				join @tbCats t on a.projectCd = t.categoryCd 
			WHERE (@buildingCd= '' or b.BuildingCd = @buildingCd)
				and (@Received = -1 Or IsReceived = @Received)
				and (@Rent = -1 Or IsRent = @Rent)
				--and ((@Debt is null or @Debt = -1) Or (@Debt = 0 and a.CurrBal = 0) or (@Debt = 1 and a.CurrBal > 0) or (@Debt = 2 and a.CurrBal < 0))
				and (@setupStatus = -1 
					or (@setupStatus = 0 and (a.IsReceived = 0 or a.isFeeStart = 0 or a.isFeeStart is null or not exists(select a2.LivingId
											  from MAS_Apartment_Service_Living a2
											  where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 1 )
												or not exists(select a2.LivingId
											  from MAS_Apartment_Service_Living a2
											  where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 2 ))) 
					or (@setupStatus = 1 and (a.IsReceived = 1 and a.isFeeStart = 1 and exists(select a2.LivingId
											  from MAS_Apartment_Service_Living a2
											  where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 1 )
												and exists(select a2.LivingId
											  from MAS_Apartment_Service_Living a2
											  where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 2 )))
					)
				and (r.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%' or c.Phone like '%' + @filter +'%')
				
		set @TotalFiltered = @Total

	--1 list
		SELECT '' ProjectName
			  ,a.[ApartmentId]
			  ,BuildingName
              --,a.RoomCode
			  ,isnull(r.RoomCodeView,r.[RoomCode]) as RoomCode
			  ,c.FullName
			  ,c.AvatarUrl
			  ,a.WaterwayArea
			  ,b.ProjectCd
			  ,b.[BuildingCd]
			  ,MemberCount = (Select count(CustId) from MAS_Apartment_Member where ApartmentId = a.ApartmentId)
			  ,HouseholdCount = (select count(ch.custid) FROM [MAS_Customer_Household] ch join MAS_Apartment_Member am on ch.CustId = am.CustId where am.ApartmentId = a.ApartmentId)
			  ,CardCount = (Select count(cc.CardId) from MAS_Apartment_Card cc join MAS_Cards mc on cc.CardId = mc.CardId  where cc.ApartmentId = a.ApartmentId) 
			  ,c.Phone 
			  --,c.Email
			  ,isnull(IsReceived,0) as IsReceived
			  ,convert(nvarchar(10),ReceiveDt,103) as ReceiveDate
			  ,a.[isFeeStart]
			  ,isnull(IsRent,0) as IsRent
			  ,isLinkApp 
			  ,VehicleCount = (Select count(vh.CardVehicleId) from MAS_CardVehicle vh 
					where vh.ApartmentId = a.ApartmentId --and vh.Status = 1
					) 
			  ,SetUpStatus = case when (a.IsReceived = 1 and a.isFeeStart = 1 and exists(select a2.LivingId
											  from MAS_Apartment_Service_Living a2
											  where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 1 )
												and exists(select a2.LivingId
											  from MAS_Apartment_Service_Living a2
											  where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 2)) then 1 else 0 end
			  --,SetUpStatus = (case when (((select count(a1.CardVehicleId) 
					--						  from [dbo].[MAS_CardVehicle] a1 left join MAS_Apartment_Card ac on a1.CardId = ac.CardId 
					--						  where  ac.ApartmentId = a.ApartmentId) > 0)
					--					  and (select count(a2.LivingId) 
					--						  from MAS_Apartment_Service_Living a2
					--						  where a2.ApartmentId = a.ApartmentId )>0)
					--					  and (a.IsFree is not null) 	
					--			   then 1 else 0 end) 
			  ,ServerChargeStatus = (case when a.IsFree is not null then 1 else 0 end)
			  --,ServerVihicleStatus = (case when ((select count(a1.CardVehicleId) 
					--						  from [dbo].[MAS_CardVehicle] a1 left join MAS_Apartment_Card ac on a1.CardId = ac.CardId 
					--						  where  ac.ApartmentId = a.ApartmentId) > 0)	
					--			   then 1 else 0 end) 
			  --,ServerLivingStatus = (case when ((select count(a2.LivingId) 
					--						  from MAS_Apartment_Service_Living a2
					--						  where a2.ApartmentId = a.ApartmentId )>0)	
					--			   then 1 else 0 end) 
			    ,a.DebitAmt as CurrBal
			  FROM [MAS_Apartments] a 
					inner join MAS_Rooms r on a.RoomCode = r.RoomCode 
					INNER JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
					left join UserInfo m on a.UserLogin = m.loginName 
					left JOIN MAS_Customers c ON m.CustId = c.CustId 		
					join @tbCats t on a.projectCd = t.categoryCd 	
			  WHERE (@buildingCd= '' or b.BuildingCd = @buildingCd)
					and (@Received = -1 Or IsReceived = @Received)
					and (@Rent = -1 Or IsRent = @Rent)
					and ((@Debt is null or @Debt = -1) Or (@Debt = 0 and a.CurrBal = 0) or (@Debt = 1 and a.CurrBal > 0) or (@Debt = 2 and a.CurrBal < 0))
					and (@setupStatus = -1 
						or (@setupStatus = 0 and (a.IsReceived = 0 or a.isFeeStart = 0 or a.isFeeStart is null or not exists(select a2.LivingId
												  from MAS_Apartment_Service_Living a2
												  where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 1 )
													or not exists(select a2.LivingId
												  from MAS_Apartment_Service_Living a2
												  where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 2 ))) 
						or (@setupStatus = 1 and (a.IsReceived = 1 and a.isFeeStart = 1 and exists(select a2.LivingId
												  from MAS_Apartment_Service_Living a2
												  where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 1 )
													and exists(select a2.LivingId
												  from MAS_Apartment_Service_Living a2
												  where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 2 )))
					)
					and (r.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%' or c.Phone like '%' + @filter +'%')
				ORDER BY  a.[RoomCode] 
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
		set @ErrorMsg					= 'sp_Hom_Get_Apartment_List_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartments', 'GET', @SessionID, @AddlInfo
	end catch