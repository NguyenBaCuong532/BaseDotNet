





CREATE procedure [dbo].[sp_Hom_Service_Vehicle_Set]
	@UserID	nvarchar(450),
	@ApartmentId bigint,
	@CardVehicleId bigint,
	@CardCd nvarchar(50),
	@CustId nvarchar(50),
	@VehicleTypeId int,
	@isVehicleNone bit,
	@VehicleNo nvarchar(30),
	@VehicleName nvarchar(100),
	@StartTime nvarchar(10) = null,
	@EndTime nvarchar(10) = null,
	@isCharginFee bit
	--@Status int = 0,
	
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(100) = 'Cập nhật thành công'	

	begin try	
		

		declare @roomCode nvarchar(50)
		declare @RequestTypeId int
		declare @RequestId int
		declare @Status int
		declare @monthlyType int

		set @RequestTypeId = 18 --Cap bo sung
		set @StartTime = isnull(@StartTime,convert(nvarchar(10),getdate(),103))
		set @Status = isnull(@Status,0)
		set @roomCode = isnull((select top 1 RoomCode from MAS_Apartments where ApartmentId = @ApartmentId),'')

		if (SELECT top 1 isnull(admin_st,0) FROM Users a Where UserId = @UserID) = 1
			set @Status = 1
		
		
		if @CardVehicleId = 0
			begin
			if not exists(select a.CustId from [MAS_Customers] a where CustId = @CustId)
			begin
				set @Valid = 0
				set @Messages = N'Không tìm thấy thông tin chủ xe!' 
			end
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartment_Member where ApartmentId = @ApartmentId and CustId = @CustId) 
				begin
					set @Valid = 0
					set @Messages = N'Không tìm thấy thành viên trong căn hộ!' 
						
				end
			else if @isVehicleNone = 0 and exists(select * from [MAS_CardVehicle] where VehicleNo like @VehicleNo and [Status] < 3 and isVehicleNone = 0)
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
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartments where ApartmentId = @ApartmentId and [isFeeStart] = 1) and not @roomCode like 'G%'
				begin
					set @Valid = 0
					set @Messages = N'Chưa cập nhật trạng thái tính phí! Không thể cấp xe' 
						
				end
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartment_Service_Living a where ApartmentId = @ApartmentId and LivingTypeId = 1) and (not @roomCode like 'G%' and not @roomCode like 'S%')
				begin
					set @Valid = 0
					set @Messages = N'Chưa cập nhật chỉ số công tơ ĐIỆN ! Không thể cấp xe' 
						
				end
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartment_Service_Living a where ApartmentId = @ApartmentId and LivingTypeId = 2) and (not @roomCode like 'G%' and not @roomCode like 'S%')
				begin
					set @Valid = 0
					set @Messages = N'Chưa cập nhật chỉ số công tơ NƯỚC! Không thể cấp xe' 
						
				end
			else
				if @VehicleTypeId = 1
					begin
					if exists(select a.CustId from [MAS_Customers] a 
						where CustId = @CustId)
					begin
					if not exists(select * from [MAS_CardVehicle] where VehicleNo like @VehicleNo and [Status] < 3) or @isVehicleNone = 1
						begin
						--if exists(select a.CustId from [MAS_Customers] a join [].[dbo].[Employees] b on a.CustId = b.CustId
						--	where a.CustId = @CustId and b.IsApproved = 1) and (@ApartmentId = 0 or @ApartmentId is null)
						--	set @monthlyType = 0
						--else 
						if exists(select a.CustId from [MAS_Customers] a join MAS_Apartment_Member b on a.CustId = b.CustId
							where a.CustId = @CustId and b.ApartmentId = @ApartmentId)
							set @monthlyType = 1
						else
							set @monthlyType = 2

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
								,isCharginFee
								)
							SELECT
								getdate()
								,isnull((select top 1 t2.CardId FROM MAS_Cards t2 WHERE CardCd = @CardCd),0)
								,@VehicleNo
								,@VehicleTypeId
								,@VehicleName
								,convert(datetime,@StartTime,103)
								,convert(datetime,@EndTime,103)
								,1
								,0
								,@RequestId
								,@isVehicleNone
								,@monthlyType --= case when t2.CardTypeId = 2 then 0 else case when t2.CardTypeId = 1 then 1 else 2 end end
								,@CustId
								,@UserID 
								,getdate()
								,@ApartmentId 
								,isnull((select count(*) from [MAS_CardVehicle] a join MAS_VehicleTypes b1 on a.VehicleTypeId = b1.VehicleTypeId join MAS_VehicleTypes b2 on b1.ServiceId = b2.ServiceId where ApartmentId = @ApartmentId and b2.VehicleTypeId = @VehicleTypeId and a.Status = 1),0)+1
								,@isCharginFee
								--left join MAS_Apartment_Card c on t2.CardId = c.CardId 
						end
					end
					end
				else
					begin
				if not exists(select a.[CardId] from [MAS_CardVehicle] a inner join MAS_Cards b on a.CardId = b.CardId 
						where b.CardCd = @CardCd and [Status] <> 3)
					begin
					if not exists(select * from [MAS_CardVehicle] where VehicleNo like @VehicleNo and [Status] < 3) or @isVehicleNone = 1
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
								,isCharginFee
								)
							SELECT
								getdate()
								,t2.CardId
								,@VehicleNo
								,@VehicleTypeId
								,@VehicleName
								,convert(datetime,@StartTime,103)
								,convert(datetime,@EndTime,103)
								,1
								,0
								,@RequestId
								,@isVehicleNone
								,monthlyType = case when t2.CardTypeId = 2 then 0 else case when t2.CardTypeId = 1 then 1 else 2 end end
								,CustId
								,@UserID 
								,getdate()
								,@ApartmentId 
								,isnull((select count(*) from [MAS_CardVehicle] a join MAS_VehicleTypes b1 on a.VehicleTypeId = b1.VehicleTypeId join MAS_VehicleTypes b2 on b1.ServiceId = b2.ServiceId where ApartmentId = @ApartmentId and b2.VehicleTypeId = @VehicleTypeId and a.Status = 1),0)+1
								,@isCharginFee
							FROM MAS_Cards t2 
								--left join MAS_Apartment_Card c on t2.CardId = c.CardId 
							WHERE CardCd = @CardCd
						end
					end
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
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartments where ApartmentId = @ApartmentId and [isFeeStart] = 1) and not @roomCode like 'G%'
				begin
					set @Valid = 0
					set @Messages = N'Chưa cập nhật trạng thái tính phí! Không thể cấp xe' 
						
				end
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartment_Service_Living a where ApartmentId = @ApartmentId and LivingTypeId = 1) and (not @roomCode like 'G%' and not @roomCode like 'S%')
				begin
					set @Valid = 0
					set @Messages = N'Chưa cập nhật chỉ số công tơ ĐIỆN ! Không thể cấp xe' 
						
				end
			else if @apartmentId > 0 and not exists(select top 1 ApartmentId from MAS_Apartment_Service_Living a where ApartmentId = @ApartmentId and LivingTypeId = 2) and (not @roomCode like 'G%' and not @roomCode like 'S%')
				begin
					set @Valid = 0
					set @Messages = N'Chưa cập nhật chỉ số công tơ NƯỚC! Không thể cấp xe' 
						
				end
			else
				--if not exists(select * from [MAS_CardVehicle] where VehicleNo like @VehicleNo and [Status] < 3 and CardVehicleId <> @CardVehicleId) or @isVehicleNone = 1
					begin
					UPDATE t
					   SET t.[AssignDate] = getdate()
						  ,t.[VehicleNo] = @VehicleNo
						  ,t.lastReceivable = convert(datetime,@EndTime,103)
						  --,[VehicleTypeId] = @VehicleTypeId
						  ,t.[VehicleName] = @VehicleName
						  ,t.[StartTime] = convert(datetime,@StartTime,103)
						  ,t.[EndTime] = convert(datetime,@EndTime,103)
						  ,isVehicleNone = @isVehicleNone
						  --,monthlyType = case when t2.CardTypeId = 2 then 0 else case when t2.CardTypeId = 1 then 1 else 2 end end
						  ,t.Auth_id = @UserID
						  ,t.Auth_Dt = getdate()
						  ,t.ApartmentId = @ApartmentId
						  ,t.isCharginFee = @isCharginFee
						  --,VehicleNum = isnull((select count(*) from [MAS_CardVehicle] a join MAS_VehicleTypes b1 on a.VehicleTypeId = b1.VehicleTypeId join MAS_VehicleTypes b2 on b1.ServiceId = b2.ServiceId where ApartmentId = @ApartmentId and b2.VehicleTypeId = @VehicleTypeId),0)+1
						FROM [dbo].[MAS_CardVehicle] t 
					 WHERE t.CardVehicleId = @CardVehicleId 
					end
			end
		
		    exec sp_Hom_Service_Vehicle_Number_Again @UserID,@ApartmentId,@VehicleTypeId
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Insert_Service_Vehicle ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID '  + @CardCd
		set @valid = 0
		set @messages = error_message()

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServiceVeh', 'Aut', @SessionID, @AddlInfo
	end catch

	select @valid as valid
		  ,@messages as [messages]

end