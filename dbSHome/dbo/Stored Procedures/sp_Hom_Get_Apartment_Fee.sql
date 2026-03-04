



CREATE procedure [dbo].[sp_Hom_Get_Apartment_Fee]
	@UserId nvarchar(450),
	@clientId nvarchar(450),
	@ProjectCd	nvarchar(50)

as
	begin try
	
	--1 profile
		SELECT a.[ApartmentId]
			  ,a.[RoomCode]
			  ,c.FullName
			  ,c.AvatarUrl
			  ,r.[Floor]
			  ,u.[UserId]
			  ,a.[UserLogin]
			  
			  ,b.ProjectName
			  ,c.Phone
			  ,c.Email
			  ,a.IsReceived
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceiveDate
			  ,a.IsRent 
			  ,a.isFeeStart
			  ,convert(nvarchar(10),isnull(a.FeeStart,a.ReceiveDt),103) as FeeStart 
			  ,a.IsFree
			  ,convert(nvarchar(10),a.FreeToDt,103) as FreeToDate
			  ,a.DebitAmt
			  ,a.AccrualLastDt
			  ,a.PayLastDt
			  ,a.numFreeMonth as FreeMonth
			  ,a.FeeNote
			  ,a.WaterwayArea
			  ,a.isLinkApp
			  ,(r.WaterwayArea * (select top 1 Price from PAR_ServicePrice where TypeId = 1 and ProjectCd = @ProjectCd)) as PriceWaterArea
			  ,MemberCount = (Select count(CustId) from MAS_Apartment_Member where ApartmentId = a.ApartmentId)
			  --,HouseholdCount = (select count(ch.custid) FROM [MAS_Customer_Household] ch join MAS_Apartment_Member am on ch.CustId = am.CustId where am.ApartmentId = a.ApartmentId)
			  ,CardCount = (Select count(cc.CardId) from MAS_Apartment_Card cc join MAS_Cards mc on cc.CardId = mc.CardId  where cc.ApartmentId = a.ApartmentId) 
			  ,VehicleCount = (Select count(vh.CardVehicleId) from MAS_Apartment_Card mm 
					inner join MAS_Cards cc on mm.CardId = cc.CardId 
					inner join MAS_CardVehicle vh on cc.CardId = vh.CardId
						where mm.ApartmentId = a.ApartmentId and cc.Card_St < 3) 
	  FROM [MAS_Apartments] a 
			 join MAS_Rooms r on r.RoomCode = a.RoomCode
			 JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd and b.ProjectCd = @ProjectCd
			 join UserInfo u on a.UserLogin = u.loginName 
			 JOIN MAS_Customers c ON u.CustId = c.CustId 
		where a.projectCd = @ProjectCd 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Apartment_Fee ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartment_Fee', 'GET', @SessionID, @AddlInfo
	end catch