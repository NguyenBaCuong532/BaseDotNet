



CREATE procedure [dbo].[sp_Hom_Card_Vehicle_Del]
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

	   
			INSERT INTO [dbo].[MAS_CardVehicle_H]
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
				  FROM [MAS_CardVehicle]
				  WHERE cardVehicleId = @cardVehicleId 

				 -- UPDATE [dbo].[MAS_CardVehicle]
				 --  SET [VehicleNum] = VehicleNum-1
				 --WHERE VehicleNum > @vehicleNum 
					--and ApartmentId = @apartmentId 
					--and VehicleTypeId = @vehicleTypeId
					--and [Status] = 1

				DELETE FROM MAS_CardVehicle 
				WHERE cardVehicleId = @cardVehicleId 

				UPDATE t
				   SET [isVehicle] =case when (select count(cardVehicleId) from MAS_CardVehicle where CardId = t.CardId and status = 1) > 0 then 1 else 0 end
				FROM [MAS_Cards] t
				 WHERE CardId = @cardId 

			exec sp_Hom_Service_Vehicle_Number_Again @UserID,@ApartmentId,@VehicleTypeId

			
			
			-- update lai hoa don chua thanh toan khi xoa xe
			insert into @Receives(ReceiveId,ReceivbleId)
			select r.[ReceiveId],r.ReceivableId FROM MAS_Service_Receivable r 
					join [MAS_Service_ReceiveEntry] e on r.ReceiveId = e.ReceiveId 
			where r.srcId = @CardVehicleId and r.[ServiceTypeId] = 2 and e.IsPayed = 0

			delete t from MAS_Service_Receivable t inner join @Receives b on t.ReceivableId = b.ReceivbleId and t.ReceiveId = b.ReceiveId

			update t
			set CommonFee = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 1)
				,VehicleAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 2)
				,LivingAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 3)
				,extendAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 4)
				,TotalAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId) + isnull(t.DebitAmt,0)
				--,PaidAmt = case when t.DebitAmt > 0 then (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId) -   else 0 end
			from MAS_Service_ReceiveEntry t inner join @Receives b on t.ReceiveId = b.ReceiveId
			

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