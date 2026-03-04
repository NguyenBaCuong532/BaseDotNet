








CREATE procedure [dbo].[sp_Hom_Vehicle_Pay_Get]
	@UserID	nvarchar(450),
	@ProjectCd nvarchar(10),
	@cardVehicleId nvarchar(100),
	@endDate nvarchar(10)
as
	begin try	
	declare @ToDt datetime
	declare @Price decimal
	declare @VehNum int

	set @ToDt = EOMONTH(convert(datetime,@endDate,103))


	--set @VehNum = (SELECT top 1 isnull(VehicleNum,1) FROM [dbo].[MAS_CardVehicle] a where CardVehicleId = @cardVehicleId)
	--(select top 1 case sp.ServiceId when 5 then case when isnull(v.VehicleNum,1) <= 1 then Price else Price2 end when 6 then case when v.VehicleNum <= 3 then Price else Price2 end when 7 then Price end  from [PAR_ServicePrice] sp join MAS_VehicleTypes vt on sp.ServiceId = vt.ServiceId where vt.VehicleTypeId = v.VehicleTypeId and TypeId = 1)
	set @Price = (select top 1 case sp.ServiceId when 5 then case when isnull(v.VehicleNum,1) <= 1 then Price else Price2 end when 6 then case when v.VehicleNum <= 3 then Price else Price2 end when 7 then Price end
		 from [PAR_ServicePrice] sp 
					join MAS_VehicleTypes c on sp.ServiceId = c.ServiceId 
					Join [MAS_CardVehicle] v on c.VehicleTypeId = v.VehicleTypeId and sp.ProjectCd = v.ProjectCd and sp.TypeId = v.[monthlyType]
				where sp.ProjectCd = @ProjectCd and v.CardVehicleId = @cardVehicleId)

		SELECT a.[CardVehicleId]
			  ,[AssignDate]
			  ,[CardId]
			  ,a.[CustId]
			  ,[VehicleNo]
			  ,[VehicleTypeId]
			  ,[VehicleName]
			  ,[VehicleColor]
			  ,[StartTime]
			  ,[EndTime]
			  ,[Status]
			  ,[ServiceId]
			  ,[RegCardVehicleId]
			  ,[RequestId]
			  ,[isVehicleNone]
			  ,[monthlyType]
			  ,convert(nvarchar(10),dateadd(day,1,isnull(isnull([lastReceivable],[EndTime]),[StartTime])),103) as StartDate
			  ,convert(nvarchar(10),@ToDt,103) as endDate
			  ,c.Quantity
			  ,c.Price
			  ,c.Amount
			  ,c.VehNum 
			  ,[ProjectCd]
			  ,[Reason]
			  ,b.FullName as customerName
			  --,N'Gia hạn xe: ' + [VehicleNo] + N' đến ' + convert(nvarchar(10),@ToDt,103) as remart 
			  ,c.Remart
		  FROM [dbo].[MAS_CardVehicle] a
			join MAS_Customers b on a.CustId = b.CustId 
			join [dbo].[fn_Hom_Vehicle_Payday_Get] (@CardVehicleId, @ToDt) c on a.CardVehicleId = c.CardVehicleId
		  WHERE a.CardVehicleId = @cardVehicleId 
			and ([monthlyType] = 1 or [monthlyType] = 2)
		


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Card_Vehicle_ByPay ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Vehicle_ByPay', 'Get', @SessionID, @AddlInfo
	end catch