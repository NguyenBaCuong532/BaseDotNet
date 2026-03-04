








CREATE procedure [dbo].[sp_Hom_Apartment_Fee_Get]
	@UserId nvarchar(450),
	@ApartmentId	bigint

as
	begin try
	
	--1 profile
		SELECT a.[ApartmentId]
			  ,r.[RoomCode]
			  ,c.FullName
			  ,c.AvatarUrl
			  ,r.[Floor]
			  ,u.[UserId]
			  ,a.[UserLogin]
			  ,a.WaterwayArea
			  ,b.ProjectName
			  ,c.Phone
			  ,c.Email
			  ,a.IsReceived
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceiveDate
			  ,a.IsRent 
			  ,convert(nvarchar(10),isnull(a.FeeStart,a.ReceiveDt),103) as FeeStart 
			  ,a.IsFree
			  ,convert(nvarchar(10),a.FreeToDt,103) as FreeToDate
			  ,a.AccrualLastDt
			  ,a.PayLastDt
			  ,a.numFreeMonth as FreeMonth
			  ,a.FeeNote
			  ,a.isFeeStart
			  ,a.DebitAmt
			  ,a.isLinkApp
			  ,MemberCount = (Select count(CustId) from MAS_Apartment_Member where ApartmentId = a.ApartmentId)
			  --,HouseholdCount = (select count(ch.custid) FROM [MAS_Customer_Household] ch join MAS_Apartment_Member am on ch.CustId = am.CustId where am.ApartmentId = a.ApartmentId)
			  ,CardCount = (Select count(cc.CardId) from MAS_Apartment_Card cc join MAS_Cards mc on cc.CardId = mc.CardId  where cc.ApartmentId = a.ApartmentId) 
			  ,VehicleCount = (Select count(vh.CardVehicleId) from MAS_CardVehicle vh where vh.ApartmentId = a.ApartmentId and vh.Status = 1) 
	  FROM [MAS_Apartments] a 
			join MAS_Rooms r on r.RoomCode = a.RoomCode
			JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
			join UserInfo u on a.UserLogin = u.loginName 
			JOIN MAS_Customers c ON u.CustId = c.CustId 
	  WHERE a.ApartmentId = @ApartmentId

	  --4 vehicles
	  SELECT CardVehicleId
		  ,convert(nvarchar(10),a.[AssignDate],103) [AssignDate]
		  ,[VehicleNo]
		  ,a.[VehicleTypeID]
		  ,f.VehicleTypeName
		  ,[VehicleName]
		  ,convert(nvarchar(10),a.[StartTime],103) [StartTime]
		  ,convert(nvarchar(10),a.[EndTime],103) [EndTime]
		  ,a.CustId
		  ,a.[Status]
		  ,mv.StatusName
		  ,c.FullName
		  ,d.[CardCd]
		  ,a.isVehicleNone
		  ,a.isCharginFee
	  FROM [dbo].[MAS_CardVehicle] a 
		join MAS_Apartments e on a.ApartmentId = e.ApartmentId 
		join MAS_VehicleStatus mv on a.Status = mv.StatusId 
		join MAS_Customers c on a.CustId = c.CustId
		join MAS_VehicleTypes f on a.VehicleTypeId = f.VehicleTypeId 
		left JOIN [MAS_Cards] d on a.CardId = d.CardId
	  WHERE a.ApartmentId = @ApartmentId

		--2 living
		SELECT a.CustId  
			  ,a.CustName
			  ,a.CustPhone
			  ,a.ApartmentId 
			  ,a.ContractNo 
			  ,convert(nvarchar(10),a.ContractDt ,103) as ContractDate
			  ,a.MeterSeri as meterSerial
			  ,a.MeterNum as meterNumber
			  ,convert(nvarchar(10),a.MeterDate,103) as startDate
			  ,a.DeliverName
			  ,a.LivingTypeId as LivingType
			  ,a.LivingId
			  ,a.AccrualToDt as accrualLast
			  ,a.PayLastDt
			  ,a.ProviderCd
			  ,a.Note
			  ,c.LivingTypeName
			  ,a.EmployeeCd
			  ,d.ProviderName
			  ,a.NumPersonWater
	  FROM MAS_Apartment_Service_Living a 
		  join MAS_Apartments b on a.ApartmentId = b.ApartmentId 
		  join MAS_LivingTypes c on a.LivingTypeId = c.LivingTypeId
		  left join MAS_ServiceProvider d on a.ProviderCd = d.ProviderCd 
	  WHERE a.ApartmentId = @ApartmentId
	  ORDER BY a.sysDate 
	  
	  --3 Extand
	    SELECT a.CustId 
			  ,a.CustName
			  ,a.CustPhone
			  ,a.ApartmentId 
			  ,a.ContractNo 
			  ,convert(nvarchar(10),a.ContractDt ,103) as ContractDate
			  ,a.ContractUser
			  ,a.ContractPassword
			  ,a.DeviceSeri as DeviceSerial
			  ,a.DeviceName
			  ,convert(nvarchar(10),a.DeviceWarranty,103) as DeviceWarranty
			  ,a.ContractTypeId
			  ,a.ExtendId
			  ,a.AccrualToDt
			  ,a.PayLastDt
			  ,a.ProviderCd
			  ,a.isCompany 
			  ,a.CompanyCode
			  ,a.CompanyName
			  ,a.CompanyRepresent
			  ,a.CompanyAddress
			  ,a.PackPriceId
			  ,c.PriceName as PackPriceName
	  FROM MAS_Apartment_Service_Extend a 
		  join MAS_Apartments b on a.ApartmentId = b.ApartmentId 
		  left join PAR_TelecomPrice c on a.PackPriceId = c.PriceId 
	  WHERE a.ApartmentId = @ApartmentId
	  ORDER BY a.sysDate 
	  
	  

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Apartment_FeeById ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartment_Fee', 'GET', @SessionID, @AddlInfo
	end catch