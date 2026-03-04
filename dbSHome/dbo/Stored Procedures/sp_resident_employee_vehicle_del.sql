CREATE procedure [dbo].[sp_resident_employee_vehicle_del]
	@userId nvarchar(450),
	@cardVehicleId	bigint	
	
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(200) = N'Xóa thành công'	

	begin try		
		
		declare @vehicleNum int 
		declare @apartmentId int
		declare @vehicleTypeId int
		declare @cardId bigint
		declare @Receives TABLE 
		(
			ReceiveId bigint not null,
			ReceivbleId bigint not null
		)

		if not exists(select * from [MAS_CardVehicle] where cardVehicleId = @cardVehicleId)	--and (IsUsed = 0 or IsUsed is null)
			begin
				set @Valid = 0
				set @Messages = N'Không tìm thấy thông tin [' + cast(@cardVehicleId as varchar) + N'] trong hệ thống!' 
			end
		else if exists(select * from [MAS_CardVehicle] where cardVehicleId = @cardVehicleId and Status = 1)
			begin
				set @Valid = 0
				set @Messages = N'Mã thẻ [' + cast(@cardVehicleId as varchar) + N'] đã được sử dụng, Cần phải khóa lại trước khi xóa!' 
			end
		else
		BEGIN
			select @vehicleNum = vehiclenum, @apartmentId = ApartmentId, @vehicleTypeId = VehicleTypeId, @cardId = CardId
			FROM [MAS_CardVehicle]
			WHERE cardVehicleId = @cardVehicleId 
				
				INSERT INTO [mas_CardVehicle_H]
					   ([CardVehicleId]
					   ,[AssignDate]
					   ,[CardId]
					   ,[CustId]
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
					   ,[VehicleNum]
					   ,[lastReceivable]
					   ,[Mkr_Id]
					   ,[Mkr_Dt]
					   ,[Auth_id]
					   ,[Auth_Dt]
					   ,[ProjectCd]
					   ,[ApartmentId]
					   ,[Reason]
					   ,[SaveDate]
					   ,[SaveId]
					   ,SaveKey
					   ,ProcName)
				SELECT [CardVehicleId]
					  ,[AssignDate]
					  ,[CardId]
					  ,[CustId]
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
					  ,[VehicleNum]
					  ,[lastReceivable]
					  ,[Mkr_Id]
					  ,[Mkr_Dt]
					  ,[Auth_id]
					  ,[Auth_Dt]
					  ,[ProjectCd]
					  ,[ApartmentId]
					  ,'Delete'
					  ,getdate()
					  ,@UserId
					  ,'Delete'
					  ,'sp_Hom_Card_Vehicle_Del'
				  FROM [mas_CardVehicle]
				  WHERE cardVehicleId = @cardVehicleId

				-------SHOME----------
				DELETE FROM MAS_CardVehicle 
				WHERE cardVehicleId = @cardVehicleId 
				
				UPDATE t
				   SET [isVehicle] = case when (select count(cardVehicleId) from MAS_CardVehicle where CardId = t.CardId and status = 1) > 0 then 1 else 0 end
				FROM [MAS_Cards] t
				 WHERE CardId = @cardId 
				----------------------

		END
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Card_Vehicle_Del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''
		set @valid = 0
		set @messages = error_message()

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Vehicle', 'DEL', @SessionID, @AddlInfo
		
	end catch

	select @valid as valid
		  ,@messages as [messages]
end