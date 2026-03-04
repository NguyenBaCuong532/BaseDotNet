






CREATE procedure [dbo].[sp_Hom_App_ServiceVehicle_ByUserId]
	@UserId	nvarchar(450),
	@ApartmentId int
as
	begin try
		
	    if @ApartmentId is null or @ApartmentId = 0
			set @ApartmentId = (select top 1 ApartmentId from [dbo].[fn_Hom_User_Apartment] (@userId))
				
	--1
		SELECT a.CardVehicleId
			  ,convert(nvarchar(10),a.StartTime,103) StartTime
			  ,convert(nvarchar(10),a.EndTime,103) EndTime
			  ,a.CustId 
			  ,a.VehicleTypeId
			  ,c.VehicleTypeName
			  ,b.FullName
			  ,a.[Status]
			  ,mc.StatusName 
			  --,case a.Card_St when 0 then N'Đang hoạt động' when 1 then N'Hết hiệu lực' when 2 then N'Đã báo mất thẻ' else N'Khóa thẻ' end [StatusName]
			  --,case Card_St when 0 then N'Đang hoạt động' when 1 then N'Hết hiệu lực' when 2 then N'Đã báo mất thẻ' else N'Khóa thẻ' end as [Status]
			  ,ac.ApartmentId
			  ,b.CustId
			  ,a.VehicleNo 
			  ,a.VehicleNum 
			  ,a.VehicleName 
			  ,a.isVehicleNone 
			  ,a.lastReceivable
			  ,ac.RoomCode
			  ,p.CardCd
			  ,b.Phone
	  FROM MAS_CardVehicle a 
			left JOIN MAS_Customers b On a.CustId = b.CustId 
			inner join MAS_VehicleTypes c on a.VehicleTypeId = c.VehicleTypeId 
			join MAS_Apartments ac on a.ApartmentId = ac.ApartmentId 
			left join MAS_Cards p on a.CardId = p.CardId 
			left join MAS_VehicleStatus mc on a.[Status] = mc.StatusId 
	  WHERE ac.ApartmentId = @ApartmentId 
	  ORDER BY a.AssignDate

	--2
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Page_ServiceVehicle_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServiceVehicle', 'GET', @SessionID, @AddlInfo
	end catch