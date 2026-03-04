




CREATE procedure [dbo].[sp_Hom_Card_Vehicle_Get]
	@CardVehicleId	int
as
	begin try	
	
			
		--1
		SELECT a.CardVehicleId
			  ,convert(nvarchar(10),a.[AssignDate],103) [AssignDate]
			  ,a.[VehicleNo]
			  ,a.[VehicleTypeID]
			  ,[VehicleName]
			  ,a.VehicleColor 
			  ,convert(nvarchar(10),a.[StartTime],103) [StartTime]
			  ,convert(nvarchar(10),a.[EndTime],103) [EndTime]
			  --,a.[EndTime]
			  ,a.ServiceId
			  --,b.ServiceName
			  ,a.[Status]
			  ,mv.StatusName 
			  --,c.IsLock 
			  ,d.[CardCd]
			  ,a.isVehicleNone
			  ,mc.FullName 
			  ,a.CustId
			  ,a.ProjectCd
	  FROM [dbo].[MAS_CardVehicle] a 
		join MAS_VehicleStatus mv on a.Status = mv.StatusId 
		join MAS_Customers mc on a.CustId = mc.CustId 
		--left JOIN MAS_Services b On a.ServiceId = b.ServiceId
		--left join MAS_CardService c on a.CardId = c.CardId and b.ServiceId = c.ServiceId
		left JOIN [MAS_Cards] d on a.CardId = d.CardId
	  WHERE CardVehicleId = @CardVehicleId



	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Card_Vehicle_ById ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardVehicle', 'GET', @SessionID, @AddlInfo
	end catch