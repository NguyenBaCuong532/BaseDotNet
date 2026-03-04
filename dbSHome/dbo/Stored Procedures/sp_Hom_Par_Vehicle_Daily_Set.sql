
CREATE procedure [dbo].[sp_Hom_Par_Vehicle_Daily_Set]
	@UserID				nvarchar(450),
	@VehicleDailyId		int,	
	@VehicleTypeId		int,
	@Block0				int,
	@Block1				int,
	@Price0				int,
	@Price1				int,
	@Price2				int,
	@Note0				nvarchar(150),      
	@Note1				nvarchar(150),   
	@Note2				nvarchar(150),   
	@isFree				bit ,
	@unit				nvarchar(50),
	@isUsed				int
as
	begin try	
		if exists (select VehicleDailyId from PAR_BlockVehicleDaily where VehicleDailyId = @VehicleDailyId)
			begin
				UPDATE t1
				 SET
					  VehicleTypeId = @VehicleTypeId
					  ,Block0 = @Block0
					  ,Block1 = @Block1
					  ,Price0 = @Price0
					  ,Price1 = @Price1
					  ,Price2 = @Price2
					  ,Note0 = @Note0
					  ,Note1 = @Note1
					  ,Note2 = @Note2
					  ,isFree = @isFree
					  ,Unit = @unit
					  ,IsUsed = @isUsed
				FROM PAR_BlockVehicleDaily t1
				WHERE t1.VehicleDailyId = @VehicleDailyId
			end
		else
			begin
				INSERT INTO [dbo].[PAR_BlockVehicleDaily]
					   ( 
					   [VehicleTypeId]
						  ,[Note0]
						  ,[Block0]
						  ,[Price0]
						  ,[Note1]
						  ,[Block1]
						  ,[Price1]
						  ,[Note2]
						  ,[Price2]
						  ,[IsFree]
						  ,[Unit],
						   [IsUsed])
			
					VALUES
					   (
							@VehicleTypeId,
							@Note0,
							@Block0,
							@Price0,
							@Note1, 
							@Block1,
							@Price1,
							@Note2, 
							@Price2,
							@isFree,
							@unit,
							@isUsed)
			end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Update_Par_Vehicle_Daily ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID --+ ' date' + @ReceiveDate

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentProject', 'Update', @SessionID, @AddlInfo


	end catch