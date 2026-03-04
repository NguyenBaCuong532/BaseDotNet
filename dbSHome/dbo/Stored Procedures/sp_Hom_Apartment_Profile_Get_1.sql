




-- exec sp_Hom_Apartment_Profile_Get null,71199


CREATE procedure [dbo].[sp_Hom_Apartment_Profile_Get]
	@userId			nvarchar(450),
	@ApartmentId	int
as
	begin try
		

		if @ApartmentId = 0 or @ApartmentId is null
			set @ApartmentId = (select top 1 a.ApartmentId FROM [MAS_Apartments] a 
					join UserInfo u on a.UserLogin = u.loginName 
					  WHERE exists(select userId from UserInfo 
						where userid = @UserId and CustId = u.CustId)
					order by a.isMain desc
				)
	--1 profile
		SELECT ProjectName
			  ,b.ProjectCd
			  ,a.[ApartmentId]
			  ,BuildingName
			  ,r.BuildingCd as BuildingCd
			  ,isnull(r.RoomCodeView,r.[RoomCode]) as RoomCodeView
			  ,a.RoomCode as RoomCode
			  ,c.FullName
			  ,c.AvatarUrl
			  ,r.[Floor]
			  ,a.WaterwayArea
			  ,a.[UserLogin]
			  ,a.[Cif_No] 
			  ,c.CustId
			  ,b.[BuildingCd]
			  ,[FamilyImageUrl]
			  ,MemberCount = (Select count(CustId) from MAS_Apartment_Member where ApartmentId = a.ApartmentId)
			  ,(Select count(CardId) from MAS_Apartment_Member mm inner join MAS_Cards cc on mm.CustId = cc.CustId where mm.ApartmentId = a.ApartmentId) as CardCount
			  ,VehicleCount = (Select count(vh.CardVehicleId) from MAS_CardVehicle vh where vh.ApartmentId = a.ApartmentId --and vh.Status = 1
			  ) 
			  ,c.Phone
			  ,c.Email
			  ,a.IsReceived
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceiveDate
			  ,a.IsRent 
			  ,'02473037999' as projectHotline
			  ,a.isMain
			  ,a.CurrBal 
			  ,isnull(p.CurrPoint ,0) as CurrPoint
	  FROM [MAS_Apartments] a 
		 join MAS_Rooms r on a.RoomCode = r.RoomCode 
		 JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
		 join UserInfo u on a.UserLogin = u.loginName
		 left join MAS_Customers c ON u.CustId = c.CustId
			left join MAS_Points p on c.CustId = p.CustId 
	  WHERE a.ApartmentId = @ApartmentId
		
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Apartment_Profile_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartment', 'GET', @SessionID, @AddlInfo
	end catch

	--select * from UserInfo where UserLogin =