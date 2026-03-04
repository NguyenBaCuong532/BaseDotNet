








CREATE procedure [dbo].[sp_Hom_Get_RequestCard_Add_ById]
@UserId nvarchar(450),
@requestId	int

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
			  ,[AssignDate]
			  ,[VehicleTypeName]
			  ,r.[Status] as [Status]
			  ,case isnull(r.[Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' when 2 then N'Đâ phê duyệt' else N'Từ chối' end as [StatusName]
			  ,N'Cấp bỏ sung' as regForm
			  ,CardCd
		  FROM MAS_Requests r 
		  inner join MAS_Request_Types t on r.RequestTypeId = t.RequestTypeId 
		  inner join [MAS_CardVehicle] a on r.RequestId = a.RequestId 
		  inner join MAS_Cards b on a.CardId = b.CardId 
		  inner join [MAS_VehicleTypes] v on a.VehicleTypeId = v.VehicleTypeId 
		  join MAS_Apartments c on r.ApartmentId = c.ApartmentId 
		  INNER JOIN UserInfo cc ON c.UserLogin = cc.loginName
		  INNER JOIN MAS_Customers d ON b.CustId = d.custId
		  
		  left join MAS_Rooms rr on c.RoomCode = rr.RoomCode 
		  left join MAS_Buildings p ON rr.BuildingCd = p.BuildingCd 
		  WHERE RequestKey = 'CardAdd'  
			and r.RequestId = @requestId
	--2
		SELECT 
			   RoomCode
			  ,d.FullName
			  ,CardTypeName
			  ,CardCd
			  ,[VehicleNo] = (select top 1 [VehicleNo] from [MAS_CardVehicle] where CardId = b.CardId and [Status] = 1 and RequestId <> @requestId)
			  ,VehicleName = (select top 1 VehicleName from [MAS_CardVehicle] where CardId = b.CardId and [Status] = 1 and RequestId <> @requestId)
		  FROM MAS_Cards b 
			  inner join MAS_CardTypes v on b.CardTypeId = v.CardTypeId 
			  INNER JOIN MAS_Customers d ON b.CustId = d.CustId
			  left join MAS_Apartments c on b.ApartmentId = c.ApartmentId 
			  WHERE exists(select * from [MAS_CardVehicle] a where CardId = b.CardId 
			  and RequestId = @requestId)

		--3
		SELECT a.RequestId
			  ,VehicleNo
			  ,VehicleName
			  ,VehicleTypeName
			  ,CardCd
		  FROM [MAS_CardVehicle] a 
		  inner join MAS_Cards b on a.CardId = b.CardId 
		  inner join [MAS_VehicleTypes] v on a.VehicleTypeId = v.VehicleTypeId 
		  WHERE a.RequestId = @requestId 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_RequestCard_Add_ById ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestCard', 'GET', @SessionID, @AddlInfo
	end catch