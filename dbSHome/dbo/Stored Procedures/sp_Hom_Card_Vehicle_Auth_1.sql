


CREATE procedure [dbo].[sp_Hom_Card_Vehicle_Auth]
	@UserID	nvarchar(450) = NULL,
	@RequestId int,
	@CardVehicleId int,
	@Status int
as
	begin try	
	if @CardVehicleId is null or @CardVehicleId = 0
	begin
		if @Status = 1
		begin
			UPDATE t1
				SET [Status] = @Status
					,VehicleNum = isnull((select count(*) from [MAS_CardVehicle] a join MAS_VehicleTypes b1 on a.VehicleTypeId = b1.VehicleTypeId join MAS_VehicleTypes b2 on b1.ServiceId = b2.ServiceId where ApartmentId = t1.ApartmentId and b2.VehicleTypeId = t1.VehicleTypeId and a.Status = 1),0)+1
			 FROM MAS_CardVehicle t1
			 WHERE t1.RequestId = @RequestId

			 UPDATE t1
				SET [Status] = @Status
			 FROM MAS_Requests t1 
				inner join MAS_CardVehicle t2 on t1.RequestId = t2.RequestId
			 WHERE t2.RequestId = @RequestId
		 end
		 else
		 begin
			 UPDATE t1
				SET [Status] = 3
			 FROM MAS_CardVehicle t1
			 WHERE t1.RequestId = @RequestId

			 UPDATE t1
				SET [Status] = 3
			 FROM MAS_Requests t1 
				inner join MAS_CardVehicle t2 on t1.RequestId = t2.RequestId
			 WHERE t2.RequestId = @RequestId
		 end
	end
	else
	begin
		if @Status = 1
		begin
			UPDATE t1
				SET [Status] = @Status
					,VehicleNum = isnull((select count(*) from [MAS_CardVehicle] a join MAS_VehicleTypes b1 on a.VehicleTypeId = b1.VehicleTypeId join MAS_VehicleTypes b2 on b1.ServiceId = b2.ServiceId where ApartmentId = t1.ApartmentId and b2.VehicleTypeId = t1.VehicleTypeId and a.Status = 1),0)+1
			 FROM MAS_CardVehicle t1
			 WHERE t1.CardVehicleId = @CardVehicleId

			 UPDATE t1
				SET [Status] = @Status
			 FROM MAS_Requests t1 
				inner join MAS_CardVehicle t2 on t1.RequestId = t2.RequestId
			 WHERE t2.CardVehicleId = @CardVehicleId
		 end
		 else
		 begin
			 UPDATE t1
				SET [Status] = 3
			 FROM MAS_CardVehicle t1
			 WHERE t1.CardVehicleId = @CardVehicleId

			 UPDATE t1
				SET [Status] = 3
			 FROM MAS_Requests t1 
				inner join MAS_CardVehicle t2 on t1.RequestId = t2.RequestId
			 WHERE t2.CardVehicleId = @CardVehicleId
		 end
	end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Insert_AuthCard_Vehicle ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'Update', @SessionID, @AddlInfo
	end catch