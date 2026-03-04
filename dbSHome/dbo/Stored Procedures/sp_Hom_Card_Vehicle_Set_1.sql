




CREATE procedure [dbo].[sp_Hom_Card_Vehicle_Set]
	@UserID	nvarchar(450),
	@CardVehicleId int,
	@CardCd nvarchar(50),
	@VehicleTypeId int,
	@VehicleNo nvarchar(30),
	@VehicleName nvarchar(100),
	@ServiceId int = 0,
	@StartTime nvarchar(10) = null,
	@EndTime nvarchar(10) = null,
	@Status int = 0,
	@isVehicleNone bit = 0
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(100) = 'Cập nhật thành công'	
	begin try	
		
		declare @apartmentId int 
		declare @roomCode nvarchar(30)
		
		--set @RequestTypeId = 18 --Cap bo sung
		select @apartmentId = c.ApartmentId, @roomCode = a.RoomCode 
				from MAS_Cards t2 
					join MAS_Apartment_Card c on t2.CardId = c.CardId 
					join MAS_Apartments a on t2.ApartmentId = a.ApartmentId
					WHERE CardCd = @CardCd 

		set @StartTime = isnull(@StartTime,convert(nvarchar(10),getdate(),103))
		
		set @Status = isnull(@Status,0)
		
		if (SELECT top 1 isnull(admin_st,0) FROM Users a Where UserId = @UserID) = 1
			set @Status = 1

			if @VehicleTypeId = 1 
				set @ServiceId = 5
			else
				set @ServiceId = 6

		
		if @CardVehicleId = 0
		begin
			if @isVehicleNone = 0 and exists(select * from [MAS_CardVehicle] where VehicleNo like @VehicleNo and [Status] < 3 and isVehicleNone = 0)
			begin
				set @Valid = 0
				set @Messages = N'Đã có đăng ký biển số xe [' + @VehicleNo + N'] trong hệ thống!' 
			end
			else if @VehicleTypeId > 1 and not exists(select [CardId] FROM MAS_Cards b 
					where b.CardCd = @CardCd and b.Card_St < 3)
			begin
				set @Valid = 0
				set @Messages = N'Không tìm thấy thông tin mã thẻ [' + @CardCd + N']!' 
			end
			else  if @VehicleTypeId > 1 and exists(select a.[CardId] FROM [MAS_CardVehicle] a join MAS_Cards b on a.CardId = b.CardId 
					where b.CardCd = @CardCd and a.[Status] < 3 and a.VehicleTypeId > 1)
			begin
				set @Valid = 0
				set @Messages = N'Không được cấp nhiều dịch vụ vào 1 thẻ [' + @CardCd + N']!' 
			end
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartments where ApartmentId = @ApartmentId and IsReceived = 1)
			begin
				set @Valid = 0
				set @Messages = N'Chưa chuyển trạng thái nhận nhà! Không thể cấp xe' 				
			end
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartments where ApartmentId = @ApartmentId and [isFeeStart] = 1) --and not @roomCode like 'G%'
				begin
					set @Valid = 0
					set @Messages = N'Chưa cập nhật trạng thái tính phí! Không thể cấp xe' 
						
				end
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartment_Service_Living a where ApartmentId = @ApartmentId and LivingTypeId = 1) --and (not @roomCode like 'G%' and not @roomCode like 'S%')
				begin
					set @Valid = 0
					set @Messages = N'Chưa cập nhật chỉ số công tơ ĐIỆN ! Không thể cấp xe' 
						
				end
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartment_Service_Living a where ApartmentId = @ApartmentId and LivingTypeId = 2) --and (not @roomCode like 'G%' and not @roomCode like 'S%')
				begin
					set @Valid = 0
					set @Messages = N'Chưa cập nhật chỉ số công tơ NƯỚC! Không thể cấp xe' 
						
				end
			else
			begin
				INSERT INTO [dbo].[MAS_CardVehicle]
						([AssignDate]
						,[CardId]
						,[VehicleNo]
						,[VehicleTypeId]
						,[VehicleName]
						,[StartTime]
						,[EndTime]
						,[Status]
						,ServiceId
						,RequestId
						,isVehicleNone
						,monthlyType
						,CustId
						,Mkr_Id 
						,Mkr_Dt 
						,ApartmentId
						,VehicleNum
						)
					SELECT
						getdate()
						,t2.CardId
						,@VehicleNo
						,@VehicleTypeId
						,@VehicleName
						,convert(datetime,@StartTime,103)
						,convert(datetime,@EndTime,103)
						,@Status --case when @RequestId > 0 then 0 else @Status end
						,@ServiceId
						,0
						,@isVehicleNone
						,monthlyType = case when t2.CardTypeId = 2 then 0 else case when t2.CardTypeId = 1 then 1 else 2 end end
						,CustId
						,@UserID 
						,getdate()
						,c.ApartmentId 
						,isnull((select count(*) from [MAS_CardVehicle] a join MAS_VehicleTypes b1 on a.VehicleTypeId = b1.VehicleTypeId join MAS_VehicleTypes b2 on b1.ServiceId = b2.ServiceId where ApartmentId = c.ApartmentId and b2.VehicleTypeId = @VehicleTypeId and a.Status = 1),0)+1
					FROM MAS_Cards t2 
						left join MAS_Apartment_Card c on t2.CardId = c.CardId 
					WHERE CardCd = @CardCd

					IF NOT EXISTS(SELECT [ServiceId] FROM [MAS_CardService] a inner join MAS_Cards b on a.CardId = b.CardId WHERE [ServiceId] = @ServiceId and b.CardCd = @CardCd)
						INSERT INTO [dbo].[MAS_CardService]
						   ([CardId]
						   ,CardCd
						   ,[ServiceId]
						   ,[LinkDate]
						   ,IsLock)
						SELECT
						   CardId
						  ,CardCd
						  ,@ServiceId
						  ,getdate()
						  ,0
						FROM MAS_Cards WHERE CardCd = @CardCd

			end
		
		end
		else
		begin
			if @isVehicleNone = 0 and exists(select * from [MAS_CardVehicle] where VehicleNo like @VehicleNo and [Status] < 3 and CardVehicleId <> @CardVehicleId and isVehicleNone = 0)
			begin
				set @Valid = 0
				set @Messages = N'Đã có đăng ký biển số xe [' + @VehicleNo + N'] trong hệ thống, không được cập nhật trùng thông tin!' 
			end
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartments where ApartmentId = @ApartmentId and IsReceived = 1)
			begin
				set @Valid = 0
				set @Messages = N'Chưa chuyển trạng thái nhận nhà! Không thể cấp xe' 				
			end
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartments where ApartmentId = @ApartmentId and [isFeeStart] = 1) --and not @roomCode like 'G%'
				begin
					set @Valid = 0
					set @Messages = N'Chưa cập nhật trạng thái tính phí! Không thể cấp xe' 
						
				end
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartment_Service_Living a where ApartmentId = @ApartmentId and LivingTypeId = 1) --and (not @roomCode like 'G%' and not @roomCode like 'S%')
				begin
					set @Valid = 0
					set @Messages = N'Chưa cập nhật chỉ số công tơ ĐIỆN ! Không thể cấp xe' 
						
				end
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartment_Service_Living a where ApartmentId = @ApartmentId and LivingTypeId = 2) --and (not @roomCode like 'G%' and not @roomCode like 'S%')
				begin
					set @Valid = 0
					set @Messages = N'Chưa cập nhật chỉ số công tơ NƯỚC! Không thể cấp xe' 
						
				end
			else
			UPDATE t
			   SET [AssignDate] = getdate()
				  ,[VehicleNo] = @VehicleNo
				  ,[VehicleName] = @VehicleName
				  ,[StartTime] = convert(datetime,@StartTime,103)
				  ,ServiceId = @ServiceId
				  ,isVehicleNone = @isVehicleNone
				  --,monthlyType = case when t2.CardTypeId = 2 then 0 else case when t2.CardTypeId = 1 then 1 else 2 end end
				  ,Auth_id = @UserID
				  ,Auth_Dt = getdate()
				  --,ApartmentId = c.ApartmentId
				  ,CardId = isnull((select top 1 t1.cardid from MAS_Cards t1 join MAS_Apartment_Card c on t1.CardId = c.CardId and c.ApartmentId = t.ApartmentId where CardCd = @CardCd),t.CardId)
				  --,VehicleNum = isnull((select count(*) from [MAS_CardVehicle] a join MAS_VehicleTypes b1 on a.VehicleTypeId = b1.VehicleTypeId join MAS_VehicleTypes b2 on b1.ServiceId = b2.ServiceId where ApartmentId = t2.ApartmentId and b2.VehicleTypeId = @VehicleTypeId),0)+1
				FROM [dbo].[MAS_CardVehicle] t 
					--left join MAS_Apartment_Card c on t.ApartmentId = c.ApartmentId 
					--left join MAS_Cards t2 on t.CardId = t2.CardId 
					
			 WHERE CardVehicleId = @CardVehicleId 

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
					   ,[endTime_Tmp]
					   ,[isCharginFee]
					   ,[SaveKey]
					   ,ProcName)
			select     [CardVehicleId]
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
					   ,getdate()
					   ,@UserID
					   ,[endTime_Tmp]
					   ,[isCharginFee]
					   ,'SetUpCardVehicle'
					   ,'sp_Hom_Card_Vehicle_Set'
				from MAS_CardVehicle 
				where CardVehicleId = @CardVehicleId

			 delete from [MAS_CardService] where exists(select [CardId] FROM MAS_Cards WHERE CardCd = @CardCd and [CardId] = [MAS_CardService].CardId)
				and not exists(select ServiceId from [dbo].[MAS_CardVehicle] t inner join MAS_Cards t2 on t.CardId = t2.CardId 
				where [ServiceId] = [MAS_CardService].ServiceId and t2.CardCd = @CardCd)

			 IF NOT EXISTS(SELECT [ServiceId] FROM [MAS_CardService] a inner join MAS_Cards b on a.CardId = b.CardId WHERE [ServiceId] = @ServiceId and b.CardCd = @CardCd)
				INSERT INTO [dbo].[MAS_CardService]
				   ([CardId]
				   ,CardCd
				   ,[ServiceId]
				   ,[LinkDate]
				   ,IsLock)
				SELECT
				   CardId
				  ,CardCd
				  ,@ServiceId
				  ,getdate()
				  ,0
				FROM MAS_Cards WHERE CardCd = @CardCd
		end
		
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Card_Vehicle_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID '  + @CardCd

		set @valid = 0
		set @messages = error_message()

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardVeh', 'Aut', @SessionID, @AddlInfo
		
	end catch

	select @valid as valid
		  ,@messages as [messages]
end