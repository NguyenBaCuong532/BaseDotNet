



CREATE procedure [dbo].[sp_Hom_Card_Auth]
	@UserID	nvarchar(450),
	@RequestId int,
	@CardCd nvarchar(50),
	@Status int
	
as
	begin try		
		declare @CardId int
		declare @IsVehicle bit 
		declare @CardTypeId int
		--

		SELECT	@IsVehicle = IsVehicle, 
				@CardTypeId = CardTypeId 
		FROM TRS_Request_Card
			WHERE RequestId = @RequestId 

IF @Status = 2
BEGIN
		UPDATE t1
			SET [Status] = 3
		 FROM MAS_Requests t1 
		 WHERE RequestId = @RequestId

		UPDATE t1
		   SET t1.[Auth_St] = 1
			  ,t1.[Auth_Dt] = getdate()
			  ,t1.Auth_Id = @UserID
			  ,t1.Status = 2
		 FROM TRS_Request_Card t1
		 WHERE RequestId = @RequestId

END
ELSE
BEGIN

	IF NOT EXISTS(SELECT CardCd FROM [MAS_Cards] WHERE RequestId = @RequestId) and EXISTS(SELECT Code FROM MAS_CardBase WHERE Code = @CardCd)
	BEGIN
		
		--create new card
		INSERT INTO [dbo].[MAS_Cards]
			   (RequestId
			   ,[ApartmentId]
			   ,[CardCd]
			   ,[IssueDate]
			   ,[ExpireDate]
			   ,CustId
			   ,[CardTypeId]
			   ,[ImageUrl]
			   ,[Card_St]
			   ,IsDaily 
			   )
		SELECT a.RequestId
			  ,[ApartmentId]
			  ,@CardCd
			  ,[RequestDt]
			  ,null
			  ,CustId
			  ,[CardTypeId]
			  ,null
			  ,1
			  ,0
		  FROM TRS_Request_Card a 
			INNER JOIN MAS_Requests b on a.RequestId = b.RequestId 
		WHERE a.RequestId = @RequestId

		UPDATE MAS_CardBase Set IsUsed = 1 
		WHERE Code = @CardCd 

		SELECT @CardId = @@IDENTITY

		INSERT INTO [dbo].[MAS_Apartment_Card]
           ([ApartmentId]
           ,[CardId])
		select
			ApartmentId
           ,CardId
		 FROM [MAS_Cards] 
		   WHERE CardCd = @CardCd 
		   and not exists(select cardId from [MAS_Apartment_Card] where CardId = MAS_Cards.CardId and ApartmentId = MAS_Cards.ApartmentId)

		UPDATE t1
			SET [Status] = 2
		 FROM MAS_Requests t1 
		 WHERE RequestId = @RequestId
		--update status register
		UPDATE t1
		   SET t1.[Auth_St] = 1
			  ,t1.[Auth_Dt] = getdate()
			  ,t1.Auth_Id = @UserID
			  ,t1.Status = 1
			  ,t1.CardId = @CardId
		 FROM TRS_Request_Card t1
		 WHERE RequestId = @RequestId

		IF @CardTypeId = 1
		BEGIN
			INSERT INTO [dbo].[MAS_CardService]
			   ([CardId]
			   ,[ServiceId]
			   ,[LinkDate])
			SELECT 
			   @CardId
			  ,[ServiceId]
			  ,getdate()
		    FROM [MAS_Services]
			WHERE [ServiceTypeId] = 1
			
			IF @IsVehicle = 1 and not exists(select * from [MAS_CardVehicle] where VehicleNo in (select [VehicleNo] FROM [TRS_RegCardVehicle]
				  WHERE RequestId = @RequestId) and [Status] < 3)
			BEGIN
				INSERT INTO [dbo].[MAS_CardService]
				   ([CardId]
				   ,CardCd
				   ,[ServiceId]
				   ,[LinkDate])
				SELECT 
				   @CardId
				  ,@CardCd
				  ,[ServiceId]
				  ,getdate()
				FROM [TRS_RegCardVehicle]
				WHERE RequestId = @RequestId

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
					   ,RegCardVehicleId
					   ,RequestId
					   ,monthlyType
					   ,ApartmentId
					   ,ProjectCd
					   ,VehicleNum
					   )
				   SELECT
					   getdate()
					  ,@CardId
					  ,[VehicleNo]
					  ,[VehicleTypeId]
					  ,[VehicleName]
					  ,getdate()
					  ,DATEADD(month,1,getdate())
					  ,1
					  ,ServiceId
					  ,RegCardVehicleId
					  ,a.RequestId
					  ,1
					  ,ApartmentId
					  ,b.ProjectCd
					  ,isnull((select count(*) from [MAS_CardVehicle] a join MAS_VehicleTypes b1 on a.VehicleTypeId = b1.VehicleTypeId join MAS_VehicleTypes b2 on b1.ServiceId = b2.ServiceId where ApartmentId = a.ApartmentId and b2.VehicleTypeId = a.VehicleTypeId and a.Status = 1),0)+1
				  FROM [TRS_RegCardVehicle] a
				  INNER JOIN MAS_Requests b on a.RequestId = b.RequestId 
				  WHERE a.RequestId = @RequestId

			END
		END
		ELSE IF @CardTypeId = 2 and not exists(select * from [MAS_CardVehicle] where VehicleNo in (select [VehicleNo] FROM [TRS_RegCardVehicle]
				  WHERE RequestId = @RequestId) and [Status] < 3)
		BEGIN
			INSERT INTO [dbo].[MAS_CardService]
			   ([CardId]
			   ,[ServiceId]
			   ,[LinkDate])
			SELECT 
			   @CardId
			  ,[ServiceId]
			  ,getdate()
		    FROM [TRS_RegCardVehicle]
			WHERE RequestId = @RequestId

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
				   ,RegCardVehicleId
				   ,RequestId
				   ,monthlyType
				   ,ApartmentId
				   ,ProjectCd
				   ,VehicleNum
				   )
				SELECT
					 getdate()
					,@CardId
					,[VehicleNo]
					,[VehicleTypeId]
					,[VehicleName]
					,getdate()
					,DATEADD(month,1,getdate())
					,1
					,ServiceId
					,RegCardVehicleId
					,a.RequestId
					,1
					,b.ApartmentId
					,b.ProjectCd
					,isnull((select count(*) from [MAS_CardVehicle] a join MAS_VehicleTypes b1 on a.VehicleTypeId = b1.VehicleTypeId join MAS_VehicleTypes b2 on b1.ServiceId = b2.ServiceId where ApartmentId = b.ApartmentId and b2.VehicleTypeId = a.VehicleTypeId and a.Status = 1),0)+1
				FROM [TRS_RegCardVehicle] a
				INNER JOIN MAS_Requests b on a.RequestId = b.RequestId 
				WHERE a.RequestId = @RequestId
		END
		ELSE IF @CardTypeId = 3
		BEGIN
			INSERT INTO [dbo].[MAS_CardService]
			   ([CardId]
			   ,[ServiceId]
			   ,[LinkDate])
			SELECT 
			   @CardId
			  ,[ServiceId]
			  ,getdate()
		    FROM MAS_Services
			WHERE ServiceTypeId = 6

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
			  ,[Cif_No2]
			  ,[CreditLimit]
			  ,[SalaryAvg]
			  ,[IsSalaryTranfer]
			  ,[ResidenProvince]
			  ,Getdate()
			  ,1
		  FROM [TRS_RegCardCredit]
		  WHERE RequestId = @RequestId

		END
	END
END		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Insert_AuthCard ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'Aut', @SessionID, @AddlInfo
	end catch