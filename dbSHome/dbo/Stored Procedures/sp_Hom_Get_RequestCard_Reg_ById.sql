





CREATE procedure [dbo].[sp_Hom_Get_RequestCard_Reg_ById]
	@UserId	nvarchar(450),
	@requestId int
as
	begin try
		--1
		SELECT r.RequestKey
			  ,r.RequestId
			  ,rr.RoomCode
			  ,ProjectName
			  ,d.FullName
			  ,[VehicleNo]
			  ,VehicleName
			  ,[dbo].[fn_Get_TimeAgo1](r.RequestDt ,getdate()) as RequestDate
			  ,[VehicleTypeName]
			  ,r.[Status] as [Status]
			  ,case isnull(r.[Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' when 2 then N'Đâ phê duyệt' else N'Từ chối' end as [StatusName]
			  ,N'Cấp mới' as regForm
			  
		  FROM MAS_Requests r 
		  inner join MAS_Request_Types t on r.RequestTypeId = t.RequestTypeId 
		  inner join TRS_Request_Card a on r.RequestId = a.RequestId 
		  inner join MAS_Apartments c on r.ApartmentId = c.ApartmentId 
		  INNER JOIN UserInfo cc ON c.UserLogin = cc.loginName
		  INNER JOIN MAS_Customers d ON cc.CustId = d.custId
		  inner join MAS_Rooms rr on c.RoomCode = rr.RoomCode 
		  inner join MAS_Buildings p ON rr.BuildingCd = p.BuildingCd  

		  left join TRS_RegCardVehicle b on b.RequestId = a.RequestId
		  left join [MAS_VehicleTypes] v on b.VehicleTypeId = v.VehicleTypeId 
		  
		  WHERE r.RequestId = @requestId and RequestKey = 'CardRegister'
		
		--2
		SELECT 
			   RoomCode
			  ,d.FullName
			  ,CardTypeName

		  FROM MAS_Requests b 
			  inner join TRS_Request_Card a on a.RequestId = b.RequestId 
			  inner join MAS_CardTypes v on a.CardTypeId = v.CardTypeId 
			  inner join MAS_Apartments c on b.ApartmentId = c.ApartmentId 
			  inner join UserInfo cc ON c.UserLogin = cc.loginName
			  INNER JOIN MAS_Customers d ON cc.CustId = d.CustId
			  WHERE a.RequestId = @requestId and RequestKey = 'CardRegister'

		--3
		SELECT a.RequestId
			  ,VehicleNo
			  ,VehicleName
			  ,VehicleTypeName
			  --,CardCd
		  FROM TRS_RegCardVehicle a 
		  --inner join TRS_Request_Card b on a.RequestId = b.RequestId 
		  inner join [MAS_VehicleTypes] v on a.VehicleTypeId = v.VehicleTypeId 
		  WHERE a.RequestId = @requestId 

		--4
		SELECT RequestId 
		  ,[Cif_No2] as CifNo2
		  ,b.FullName
		  ,[CreditLimit]
		  ,[SalaryAvg]
		  ,[isSalaryTranfer]
		  ,[ResidenProvince]
	  FROM [TRS_RegCardCredit] a Left Join MAS_Customers b On a.Cif_No2 = b.Cif_No
	  WHERE RequestId = @requestId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_SalerSumary_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'SalerMonthly', 'GET', @SessionID, @AddlInfo
	end catch