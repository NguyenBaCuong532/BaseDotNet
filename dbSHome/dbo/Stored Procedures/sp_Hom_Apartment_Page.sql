








CREATE procedure [dbo].[sp_Hom_Apartment_Page]
	@userId nvarchar(450),
	@clientId nvarchar(50),
	@ProjectCd	nvarchar(40),
	@Received int = -1,
	@setupStatus int = -1,
	@Rent int = -1,
	@buildingCd nvarchar(30),
	@filter nvarchar(100) = '',
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@buildingCd				= isnull(@buildingCd,'')
		set		@filter					= isnull(@filter,'')
		set		@projectCd				= isnull(@projectCd,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		
		if @Offset = 0
		begin
			SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Apartment_Household_Page', 100) 
			ORDER BY [ordinal]
		end
	
		select	@Total					= count(a.[ApartmentId])
			FROM [MAS_Apartments] a 
				inner join MAS_Rooms r on a.RoomCode = r.RoomCode 
				INNER JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
				inner join UserInfo m on a.UserLogin = m.loginName 
				INNER JOIN MAS_Customers c ON m.CustId = c.CustId
			WHERE b.ProjectCd like @ProjectCd +'%' 
				and b.BuildingCd like @buildingCd +'%' 
				and ((@Received is null or @Received = -1 ) Or isnull(IsReceived,0) = @Received)
				and ((@Rent is null or @Rent = -1 ) Or isnull(IsRent,0) = @Rent)
				--and exists (SELECT * FROM [dbo].[fn_Exists_CustCategory] (@UserId,c.CustId) where CategoryCd = b.ProjectCd)
				and (r.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%' or c.Phone like '%' + @filter +'%')
				
		set @TotalFiltered = @Total

	--1 list
		SELECT '' ProjectName
			  ,a.[ApartmentId]
			  ,BuildingName
			  ,a.[RoomCode]
			  ,c.FullName
			  ,c.AvatarUrl
			  ,r.[Floor]
			  ,a.WaterwayArea
			  ,b.ProjectCd
			  ,a.[UserLogin]
			  ,b.[BuildingCd]
			  ,[FamilyImageUrl]
			  ,MemberCount = (Select count(CustId) from MAS_Apartment_Member where ApartmentId = a.ApartmentId)
			  ,HouseholdCount = (select count(ch.custid) FROM [MAS_Customer_Household] ch join MAS_Apartment_Member am on ch.CustId = am.CustId where am.ApartmentId = a.ApartmentId)
			  ,CardCount = (Select count(cc.CardId) from MAS_Apartment_Card cc join MAS_Cards mc on cc.CardId = mc.CardId  where cc.ApartmentId = a.ApartmentId) 
			  ,c.Phone 
			  ,c.Email
			  ,isnull(IsReceived,0) as IsReceived
			  ,convert(nvarchar(10),ReceiveDt,103) as ReceiveDate
			  ,isnull(IsRent,0) as IsRent
			  ,VehicleCount = (Select count(vh.CardVehicleId) 
					from --MAS_Apartment_Card mm 
				--inner join MAS_Cards cc on mm.CardId = cc.CardId 
				--inner join 
						MAS_CardVehicle vh --on cc.CardId = vh.CardId
					where vh.ApartmentId = a.ApartmentId --and cc.Card_St < 3
					) 
			  ,SetUpStatus = (case when (((select count(a1.CardVehicleId) 
											  from [dbo].[MAS_CardVehicle] a1 left join MAS_Apartment_Card ac on a1.CardId = ac.CardId 
											  where  ac.ApartmentId = a.ApartmentId) > 0)
										  and (select count(a2.LivingId) 
											  from MAS_Apartment_Service_Living a2
											  where a2.ApartmentId = a.ApartmentId )>0)
										  and (a.IsFree is not null) 	
								   then 1 else 0 end) 
			  ,ServerChargeStatus = (case when a.IsFree is not null then 1 else 0 end)
			  ,ServerVihicleStatus = (case when ((select count(a1.CardVehicleId) 
											  from [dbo].[MAS_CardVehicle] a1 left join MAS_Apartment_Card ac on a1.CardId = ac.CardId 
											  where  ac.ApartmentId = a.ApartmentId) > 0)	
								   then 1 else 0 end) 
			  ,ServerLivingStatus = (case when ((select count(a2.LivingId) 
											  from MAS_Apartment_Service_Living a2
											  where a2.ApartmentId = a.ApartmentId )>0)	
								   then 1 else 0 end) 
			  FROM [MAS_Apartments] a 
			 join MAS_Rooms r on a.RoomCode = r.RoomCode 
			 JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
			 join UserInfo m on a.UserLogin = m.loginName 
			 JOIN MAS_Customers c ON m.CustId = c.CustId 			
	  WHERE b.ProjectCd like @ProjectCd +'%' 
				and b.BuildingCd like @buildingCd +'%' 
				and ((@Received is null or @Received = -1 ) Or isnull(IsReceived,0) = @Received)
				and ((@Rent is null or @Rent = -1 ) Or isnull(IsRent,0) = @Rent)
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
		set @ErrorMsg					= 'sp_Hom_Apartment_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartments', 'GET', @SessionID, @AddlInfo
	end catch