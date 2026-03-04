



CREATE procedure [dbo].[sp_Hom_Card_Reg]
	@UserID	nvarchar(450),
	@ApartmentId int,
	@RequestId int,
	@CifNo nvarchar(50), 
	
	@CardType int,	
	@IsVehicle bit,

	@VehicleTypeId int = 0,
	@VehicleNo nvarchar(10) = '',
	@ServiceId int = 0,
	@VehicleName nvarchar(50) = '',

	@CifNo2 nvarchar(50) = '',
	@CreditLimit int = 0,
	@SalaryAvg int = 0,
	@IsSalaryTranfer int = 0,
	@ResidenProvince nvarchar(100) = '',
	@OutRequestId		int out
as
	begin try	
	declare @RequestTypeId int
	declare @ProjectCd nvarchar(30)
	declare @custId nvarchar(50)

	set @RequestTypeId = 17

	--declare @ApartmentId int
	if @ApartmentId is null or @ApartmentId = 0
		set @ApartmentId = (select top 1 ApartmentId from [dbo].[fn_Hom_User_Apartment] (@userId))
		
	set @custId = (select top 1 CustId from UserInfo where UserId = @UserId)

	set @ProjectCd = (select top 1 c.ProjectCd from MAS_Apartments a join MAS_Rooms b on a.RoomCode = b.RoomCode join MAS_Buildings c on b.BuildingCd = c.BuildingCd)

	IF NOT EXISTS(SELECT RequestId FROM MAS_Requests WHERE RequestId = @RequestId)
	BEGIN

		INSERT INTO [dbo].MAS_Requests
				(RequestKey
				,ApartmentId
				,[RequestDt]
				,RequestTypeId
				,[Status]
				,ProjectCd
				,requestUserId
				)
			VALUES
				(
				'CardRegister'
				,@ApartmentId
				,getdate()
				,@RequestTypeId
				,0
				,@ProjectCd
				,@UserID
				)	
		set @RequestId = @@IDENTITY

		INSERT INTO [dbo].TRS_Request_Card
			   (RequestId
			   ,CustId
			   ,[CardTypeId]
			   ,[IsVehicle]
			   ,[Status]
			   )
		 VALUES
				(@RequestId
				,isnull(@CifNo,@custId)
				,@CardType
				,@IsVehicle
				,0
				)


	END
	ELSE
			UPDATE TRS_Request_Card
			SET 				
			    [CardTypeId] = @CardType
			   ,[IsVehicle] = @IsVehicle
			   ,CardId = @CifNo
			WHERE RequestId = @RequestId

		IF @CardType = 1 OR @CardType = 2
		BEGIN
			if @IsVehicle = 1
			begin
				if isnull(@ServiceId,0) = 0
					if @VehicleTypeId = 1 
						set @ServiceId = 5
					else
						set @ServiceId = 6	

				IF NOT EXISTS(SELECT RequestId FROM [TRS_RegCardVehicle] WHERE RequestId = @RequestId)
					INSERT INTO [dbo].[TRS_RegCardVehicle]
					   (RequestId
					   ,[VehicleTypeId]
					   ,[VehicleNo]
					   ,ServiceId
					   ,[VehicleName]
					   )
					VALUES
					   (@RequestId
					   ,@VehicleTypeId
					   ,@VehicleNo
					   ,@ServiceId
					   ,@VehicleName
					   )
				ELSE
					UPDATE [dbo].[TRS_RegCardVehicle]
					SET [VehicleTypeId] = @VehicleTypeId
					  ,[VehicleNo] = @VehicleNo
					  ,ServiceId = @ServiceId
					  ,VehicleName = @VehicleName
					WHERE RequestId = @RequestId
				end
		END
		ELSE 
		IF NOT EXISTS(SELECT RequestId FROM [TRS_RegCardCredit] WHERE RequestId = @RequestId)
			INSERT INTO [dbo].[TRS_RegCardCredit]
			   (RequestId
			   ,[Cif_No2]
			   ,[CreditLimit]
			   ,[SalaryAvg]
			   ,[isSalaryTranfer]
			   ,[ResidenProvince])
			VALUES
			   (@RequestId
			   ,@CifNo2
			   ,@CreditLimit
			   ,@SalaryAvg
			   ,@IsSalaryTranfer
			   ,@ResidenProvince
			   )
		ELSE
			UPDATE [dbo].[TRS_RegCardCredit]
			 SET 
				   [Cif_No2] = @CifNo2
				  ,[CreditLimit] = @CreditLimit
				  ,[SalaryAvg] = @SalaryAvg
				  ,[isSalaryTranfer] = @isSalaryTranfer
				  ,[ResidenProvince] = @ResidenProvince
			 WHERE RequestId = @RequestId

		set @OutRequestId = @RequestId
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Insert_Card_Register ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Cif_no ' + @Cifno 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardReg', 'Insert', @SessionID, @AddlInfo
	end catch