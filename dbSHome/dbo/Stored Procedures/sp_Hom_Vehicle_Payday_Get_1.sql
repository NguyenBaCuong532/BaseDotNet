CREATE procedure [dbo].[sp_Hom_Vehicle_Payday_Get]
	@UserID	nvarchar(450),
	@ProjectCd nvarchar(10),
	@cardVehicleId nvarchar(100),
	@startDate nvarchar(10),
	@endDate nvarchar(10)
as
	begin try	
	--declare @StartDt datetime
	declare @ToDt datetime
	set @ToDt = convert(datetime,@endDate,103)

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
			  ,convert(nvarchar(10),c.StartDate,103) as StartDate
			  ,convert(nvarchar(10),@ToDt,103) as endDate
			  ,c.Quantity
			  ,c.Price
			  ,c.Amount
			  ,c.VehNum 
			  ,[ProjectCd]
			  ,[Reason]
			  ,b.FullName as customerName
			  ,c.remart 
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
		set @ErrorMsg					= 'sp_Hom_Get_Card_Vehicle_ByPayDay ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Vehicle_ByPayDay', 'Get', @SessionID, @AddlInfo
	end catch