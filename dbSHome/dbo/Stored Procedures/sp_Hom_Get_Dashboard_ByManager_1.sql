



CREATE procedure [dbo].[sp_Hom_Get_Dashboard_ByManager]
	@UserId nvarchar(450),
	@ProjectCd nvarchar(30)
as
	begin try
	
		declare @curdate date
		set @curdate = getdate()
		--1 Apartment
		SELECT  --(select count(RoomCode) from MAS_Rooms a inner join MAS_Buildings b on a.BuildingCd = b.BuildingCd  where b.ProjectCd = @ProjectCd) 
			313 as ApartmentTotal
				,(select count(ApartmentId) from MAS_Rooms a inner join MAS_Buildings b on a.BuildingCd = b.BuildingCd 
					inner join MAS_Apartments c on a.RoomCode = c.RoomCode where b.ProjectCd = @ProjectCd and c.IsReceived = 1) as ApartmentReceived
				,(select count(ApartmentId) from MAS_Rooms a inner join MAS_Buildings b on a.BuildingCd = b.BuildingCd 
					inner join MAS_Apartments c on a.RoomCode = c.RoomCode where b.ProjectCd = @ProjectCd) as ApartmentContracted
				,N'Căn hộ ' as [description]
		
			
		--2 Resident
		SELECT (select count(c.ApartmentId) from MAS_Rooms a inner join MAS_Buildings b on a.BuildingCd = b.BuildingCd 
					inner join MAS_Apartments c on a.RoomCode = c.RoomCode 
					inner join MAS_Apartment_Member d on c.ApartmentId = d.ApartmentId where b.ProjectCd = @ProjectCd) as ResidentTotal
			,(select count(c.ApartmentId) from MAS_Rooms a inner join MAS_Buildings b on a.BuildingCd = b.BuildingCd 
					inner join MAS_Apartments c on a.RoomCode = c.RoomCode 
					inner join MAS_Apartment_Member d on c.ApartmentId = d.ApartmentId 
					inner join MAS_Customer_Household e on d.CustId = e.CustId where b.ProjectCd = @ProjectCd) as ResidentRegisted
			,(select count(c.ApartmentId) from MAS_Rooms a inner join MAS_Buildings b on a.BuildingCd = b.BuildingCd 
					inner join MAS_Apartments c on a.RoomCode = c.RoomCode 
					inner join MAS_Apartment_Member d on c.ApartmentId = d.ApartmentId 
					inner join MAS_Cards e on d.CustId = e.CustId where b.ProjectCd = @ProjectCd) as ResidentCard
			,(select count(c.ApartmentId) from MAS_Rooms a inner join MAS_Buildings b on a.BuildingCd = b.BuildingCd 
					inner join MAS_Apartments c on a.RoomCode = c.RoomCode 
					inner join MAS_Apartment_Member d on c.ApartmentId = d.ApartmentId 
					inner join MAS_Cards e on d.CustId = e.CustId 
					inner join MAS_CardVehicle f on e.CardId = f.CardId where b.ProjectCd = @ProjectCd) as ResidentCardVehicle
			,(select count(c.ApartmentId) from MAS_Rooms a inner join MAS_Buildings b on a.BuildingCd = b.BuildingCd 
					inner join MAS_Apartments c on a.RoomCode = c.RoomCode 
					inner join MAS_Apartment_Member d on c.ApartmentId = d.ApartmentId 
					inner join MAS_Cards e on d.CustId = e.CustId 
					inner join MAS_CardCredit f on e.CardId = f.CardId where b.ProjectCd = @ProjectCd) as ResidentCardCredit
			,N'Thông tin cư dân' as [description]
		

		--3 ResidentCard
		SELECT (select count(c.ApartmentId) from MAS_Rooms a inner join MAS_Buildings b on a.BuildingCd = b.BuildingCd 
					inner join MAS_Apartments c on a.RoomCode = c.RoomCode 
					inner join MAS_Apartment_Member d on c.ApartmentId = d.ApartmentId 
					inner join MAS_Cards e on d.CustId = e.CustId where b.ProjectCd = @ProjectCd) as CardTotal
			,(select count(e.CardId) from MAS_Rooms a 
					inner join MAS_Buildings b on a.BuildingCd = b.BuildingCd 
					inner join MAS_Apartments c on a.RoomCode = c.RoomCode 
					inner join MAS_Apartment_Member d on c.ApartmentId = d.ApartmentId 
					inner join MAS_Cards e on d.CustId = e.CustId where b.ProjectCd = @ProjectCd and e.Card_St = 0) as CardUsed
			,(select count(e.CardId) from MAS_Rooms a 
					inner join MAS_Buildings b on a.BuildingCd = b.BuildingCd 
					inner join MAS_Apartments c on a.RoomCode = c.RoomCode 
					inner join MAS_Apartment_Member d on c.ApartmentId = d.ApartmentId 
					inner join MAS_Cards e on d.CustId = e.CustId where b.ProjectCd = @ProjectCd and e.Card_St <> 0) as CardLock
			,(select count(c.ApartmentId) from MAS_Rooms a inner join MAS_Buildings b on a.BuildingCd = b.BuildingCd 
					inner join MAS_Apartments c on a.RoomCode = c.RoomCode 
					inner join MAS_Apartment_Member d on c.ApartmentId = d.ApartmentId 
					inner join MAS_Cards e on d.CustId = e.CustId 
					inner join MAS_CardVehicle f on e.CardId = f.CardId where b.ProjectCd = @ProjectCd and e.Card_St = 0) as CardVehicle
			,N'Tổng quan thẻ cư dân' as [description]
		

		--4 InternalCard
		SELECT (select count(e.CardId) from MAS_Cards e where e.IsVip = 1) as CardTotal
			,(select count(e.CardId) from MAS_Cards e where e.IsVip = 1 and e.Card_St = 0) as CardUsed
			,(select count(e.CardId) from MAS_Cards e where e.IsVip = 1 and e.Card_St <> 0) as CardLock
			,(select count(e.CardId) from MAS_Cards e 
					inner join MAS_CardVehicle f on e.CardId = f.CardId where e.IsVip = 1 and e.Card_St = 0) as CardVehicle
			,N'Tổng quan thẻ nội bộ' as [description]
		

		--5 Request
		SELECT (SELECT count(a.RequestId)
			  FROM MAS_Requests a 
				  INNER JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
				  inner join MAS_Request_Types r On a.RequestTypeId = r.RequestTypeId
				  inner join MAS_Rooms rr on b.RoomCode = rr.RoomCode
				  inner join MAS_Buildings d on rr.BuildingCd = d.BuildingCd 
				WHERE r.Category in ('Fix','Ext') and d.ProjectCd = @ProjectCd) as RequestFixTotal
			,(select count(a.RequestId)
			FROM MAS_Requests a Inner JOIN MAS_Apartments b On a.ApartmentId = b.ApartmentId 
					inner join MAS_Request_Types r On a.RequestTypeId = r.RequestTypeId
					inner join MAS_Rooms rr on b.RoomCode = rr.RoomCode
					inner join MAS_Buildings d on rr.BuildingCd = d.BuildingCd 
				WHERE r.Category in ('Sev') and d.ProjectCd = @ProjectCd) as RequestSevTotal
			,N'Yêu cầu khách hàng' as [description]
		

		--6 ElectricMeter
		SELECT count(*) as Total
			,N'Lái xe hủy chuyến' as [description]
		FROM CAB_TripStatus Where [Status] = 5 and CabDriverId is not null

		--7 WaterMeter
		SELECT (select count(*) from CAB_TripBook WHERE IsNow = 0 or (IsNow = 0 and TripDt > @curdate)) as TripSchedule
			,(select count(*) from CAB_TripBook WHERE (IsNow = 0 or (IsNow = 0 and TripDt > @curdate)) and [Status] = 1) as TripTaked
			,(select count(*) from CAB_TripBook WHERE (IsNow = 0 or (IsNow = 0 and TripDt > @curdate)) and [Status] = 0) as TripWaiting
			,N'Đang đặt chuyến' as [description]
		FROM CAB_TripBook WHERE IsNow = 0 

		----8
		--SELECT (select count(*) from CAB_UserProfiles) as Total
		--	,(select count(*) from CAB_UserProfiles where month(CreateDt) = month(@curdate) and month(CreateDt) = month(@curdate)) as newMemberMonth
		--	,(select count(CabUserId) from CAB_UserProfiles a where exists(Select TripId from CAB_TripBook b where b.CabUserId = a.CabUserId)) as UserTriped
		--	,N'Khách hàng' as [description]

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Cab_Get_Dashboard_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'DashBoard', 'GET', @SessionID, @AddlInfo
	end catch