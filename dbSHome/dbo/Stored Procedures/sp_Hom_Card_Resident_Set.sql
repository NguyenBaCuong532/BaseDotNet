



CREATE procedure [dbo].[sp_Hom_Card_Resident_Set]
	@UserID	nvarchar(450),
	@CardCd nvarchar(50),
	@RoomCd nvarchar(30),
	@CustId nvarchar(50), 
	@CardTypeId int,	
	
	@IsVehicle int,
	@VehicleTypeId int = 0,
	@VehicleNo nvarchar(10) = '',
	@ServiceId int = 0,
	@VehicleName nvarchar(50) = '',
	@isVehicleNone bit = 0,
	@startTime nvarchar(20) = null,

	@isCredit bit = 0,
	@CifNo2 nvarchar(50) = '',
	@CreditLimit int = 0,
	@SalaryAvg int = 0,
	@IsSalaryTranfer int = 0,
	@ResidenProvince nvarchar(100) = ''

as
begin
	declare @valid bit = 1
	declare @messages nvarchar(200) = N'Cập nhật thành công'

	begin try	
	
	--declare @errmessage nvarchar(100)
	declare @ApartmentId int
	declare @CardId int
	declare @projectCd nvarchar(30)
	declare @startDt datetime

	if @startTime is null or @startTime = ''
		set @startDt = getdate()
	else
		set @startDt = convert(datetime,@startTime,103)

	if @CardTypeId = 3
		set @IsVehicle = 1
	--set @errmessage = 'This Card: ' + @CardCd + ' is not exists or used!'
	select @ApartmentId = ApartmentId, @projectCd = projectCd from MAS_Apartments where RoomCode = @RoomCd
	

	set @isVehicleNone = isnull(@isVehicleNone,0)

	if @VehicleTypeId = 3 and len(@vehicleno)<9
		set @VehicleNo ='P-'+ right('0000' + cast((select count(*) from [MAS_CardVehicle] where VehicleTypeId =3) as varchar),5)
	
	if not exists(select Code from MAS_CardBase where Code = @CardCd)	--and (IsUsed = 0 or IsUsed is null)
		begin
			set @Valid = 0
			set @Messages = N'Không tìm thấy thông mã thẻ [' + @CardCd + N'] trong kho số!' 
		end
	else if exists(select Code from MAS_CardBase where Code = @CardCd and IsUsed = 1)
		begin
			set @Valid = 0
			set @Messages = N'Mã thẻ [' + @CardCd + N'] đã được sử dụng!' 
		end
	else if @ApartmentId is null or @ApartmentId = 0
		begin
			set @Valid = 0
			set @Messages = N'Không tìm thấy thông tin căn hộ [' + @RoomCd + N']!' 
		end
	else if not exists(select top 1 ApartmentId from MAS_Apartments where ApartmentId = @ApartmentId and IsReceived = 1) 
		begin
			set @Valid = 0
			set @Messages = N'Chưa chuyển trạng thái nhận nhà căn [' + @RoomCd + N']! Không thể cấp thẻ' 
		end
	else if not exists(select top 1 ApartmentId from MAS_Apartments where ApartmentId = @ApartmentId and [isFeeStart] = 1) --and (not @RoomCd like 'A1.%' and not @RoomCd like 'A2.%')
		begin
			set @Valid = 0
			set @Messages = N'Chưa cập nhật trạng thái TÍNH PHÍ DỊCH VỤ [' + @RoomCd + N']! Không thể cấp thẻ' 
		end
	else if not exists(select top 1 ApartmentId from MAS_Apartment_Service_Living a where ApartmentId = @ApartmentId and LivingTypeId = 1) --and (not @RoomCd like 'A1.%' and not @RoomCd like 'A2.%')
		begin
			set @Valid = 0
			set @Messages = N'Chưa cập nhật chỉ số công tơ ĐIỆN căn [' + @RoomCd + N']! Không thể cấp thẻ' 
		end
	else if not exists(select top 1 ApartmentId from MAS_Apartment_Service_Living a where ApartmentId = @ApartmentId and LivingTypeId = 2) --and (not @RoomCd like 'A1.%' and not @RoomCd like 'A2.%')
		begin
			set @Valid = 0
			set @Messages = N'Chưa cập nhật chỉ số công tơ NƯỚC căn [' + @RoomCd + N']! Không thể cấp thẻ' 
		end
	else if not exists (select custid from MAS_Customers where CustId = @CustId)
		begin
			set @Valid = 0
			set @Messages = N'Không tìm thấy thông tin thành viên [' + @CustId + N']!' 
		end
	else
	
	begin
		--create new card
		INSERT INTO [dbo].[MAS_Cards]
			   ([ApartmentId]
			   ,[CardCd]
			   ,[IssueDate]
			   ,[ExpireDate]
			   ,CustId
			   ,[CardTypeId]
			   ,[ImageUrl]
			   ,[Card_St]
			   ,IsDaily 
			   ,ProjectCd
			   ,isVehicle
			   ,isCredit
			   ,created_by
			   )
		SELECT 
			   @ApartmentId
			  ,@CardCd
			  ,getdate()
			  ,null
			  ,@CustId
			  ,@CardTypeId
			  ,null
			  ,1
			  ,0
			  ,@projectCd
			  ,@IsVehicle
			  ,@isCredit
			  ,@UserID

		--SELECT @CardId = @@IDENTITY
		SET @CardId = isnull((SELECT top 1 CardId FROM [MAS_Cards] WHERE [CardCd] = @CardCd),0)

		UPDATE MAS_CardBase Set IsUsed = 1 
		WHERE Code = @CardCd 

		INSERT INTO [dbo].[MAS_Apartment_Card]
			   ([ApartmentId]
			   ,[CardId])
			select
				@ApartmentId
			   ,CardId
			 FROM [MAS_Cards] 
			   WHERE CardCd = @CardCd 
		   and not exists(select cardId from [MAS_Apartment_Card] where CardId = MAS_Cards.CardId and ApartmentId = MAS_Cards.ApartmentId)


		if @IsVehicle = 1
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
					   ,isVehicleNone
					   ,monthlyType
					   ,CustId
					   ,ProjectCd 
					   ,ApartmentId
					   ,VehicleNum 
					   )
				SELECT getdate()
					  ,@CardId
					  ,@VehicleNo
					  ,@VehicleTypeId
					  ,@VehicleName
					  ,@startDt
					  ,@startDt
					  ,1
					  ,@ServiceId
					  ,@isVehicleNone
					  ,case when @CardTypeId = 2 then 0 else case when @CardTypeId = 1 then 1 else 2 end end
					  ,@CustId
					  ,@projectCd
					  ,@ApartmentId
					  ,isnull((select count(*) from [MAS_CardVehicle] a 
							join MAS_VehicleTypes b1 on a.VehicleTypeId = b1.VehicleTypeId 
							join MAS_VehicleTypes b2 on b1.ServiceId = b2.ServiceId 
							where ApartmentId = @ApartmentId and b2.VehicleTypeId = @VehicleTypeId and a.Status = 1),0)+1

		 if @isCredit = 1
			INSERT INTO [dbo].[MAS_CardCredit]
				   ([CardId]
				   ,[Cif_No2]
				   ,[CreditLimit]
				   ,[SalaryAvg]
				   ,[IsSalaryTranfer]
				   ,[ResidenProvince]
				   ,[AsignDate]
				   ,[Status])
				SELECT 
					@CardId
				   ,@CifNo2
				   ,@CreditLimit
				   ,@SalaryAvg
				   ,@IsSalaryTranfer
				   ,@ResidenProvince
				   ,Getdate()
				   ,1


	end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Insert_Card ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@CustId ' + @CustId + ' @RoomCd ' +@RoomCd+ ' cardCd' + @CardCd + ': ' + @startTime

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'Insert', @SessionID, @AddlInfo
		set @valid = 0
		set @messages = error_message()
		

	end catch

	select @valid as valid
		  ,@messages as [messages]

end