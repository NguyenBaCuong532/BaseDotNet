




CREATE procedure [dbo].[sp_hom_app_card_vehicle_reg] @UserId NVARCHAR(450)
	,@CardVehicleId INT = NULL
	,@CardCd NVARCHAR(20)
	,@VehicleTypeId INT = NULL
	,@VehicleNo NVARCHAR(10)
	,@VehicleName NVARCHAR(50)
	,@VehicleColor NVARCHAR(50)
	,@note NVARCHAR(250) = NULL
	,@ImageLinks VehicleImageType readonly
	--,@licenseImages NVARCHAR(MAX)
	--,@licensePlates NVARCHAR(4000)
AS
BEGIN
	DECLARE @valid BIT = 0
	DECLARE @messages NVARCHAR(100) = ''
	declare @cardVehicleIdForHrm int
	DECLARE @OutputTbl TABLE (ID INT)

	BEGIN TRY

		--DECLARE @CustId NVARCHAR(450) = (
		--		SELECT TOP 1 CustId
		--		FROM dbSHRM.dbo.Employees
		--		WHERE UserId = @UserId
		--		)

		DECLARE @CustId NVARCHAR(450) = (
				SELECT TOP 1 CustId
				FROM MAS_Cards
				WHERE CardCd = @CardCd
				)

		DECLARE @cardId INT = (
					SELECT TOP 1 CardId
					FROM MAS_Cards
					WHERE CustId = @CustId
					AND cardCd = @CardCd
					)

	--
	IF NOT EXISTS (
			SELECT CardVehicleId
			FROM MAS_CardVehicle
			WHERE CardVehicleId = @CardVehicleId
			)
	BEGIN
		BEGIN TRAN
			-------SHOME Start---
			INSERT INTO [MAS_CardVehicle] (
				[AssignDate]
				,CustId
				,[VehicleNo]
				,[VehicleTypeId]
				,[VehicleName]
				,VehicleColor
				,StartTime
				,[Status]
				,[ServiceId]
				,monthlyType
				,ProjectCd
				,Reason
				,CardId
				,Mkr_Id
				,Mkr_Dt
				,note
				)
				OUTPUT INSERTED.CardVehicleId INTO @OutputTbl
			VALUES (
				getdate()
				,@CustId
				,@VehicleNo
				,@VehicleTypeId
				,@VehicleName
				,@VehicleColor
				,getdate()
				,0
				,0
				,0
				,NULL
				,'Register from APP'
				,@cardId
				,@UserId
				,getdate()
				,@note
				)

			--SET @CardVehicleId = @@IDENTITY
			select top(1) @cardVehicleIdForHrm = id
				FROM @OutputTbl


			INSERT INTO [MAS_CardVehicle_Image] (
				CardVehicleId
				,ImageLink
				,ImageType
				)
			SELECT @cardVehicleIdForHrm
				,[Url]
				,[type]
			FROM @ImageLinks

			------SHOME END -----
						
		COMMIT
		SET @valid = 1
		SET @messages = N'Thêm mới thành công'
	END
	ELSE
	BEGIN
		
		BEGIN TRAN
			-------SHOME Start---
			UPDATE [MAS_CardVehicle]
			SET [VehicleNo] = @VehicleNo
				,[VehicleTypeId] = @VehicleTypeId
				,[VehicleName] = @VehicleName
				,VehicleColor = @VehicleColor
				,Auth_id = @UserId
				,Auth_Dt = getdate()
				,note = @note
			WHERE CardVehicleId = @CardVehicleId
			--
			--DELETE FROM dbSHOME.dbo.[MAS_CardVehicle_Image] WHERE CardVehicleId = @CardVehicleId
			UPDATE a
			SET a.ImageLink = b.[Url]
			FROM [MAS_CardVehicle_Image] a
			INNER JOIN @ImageLinks b ON a.Id = b.Id

			INSERT INTO [MAS_CardVehicle_Image](CardVehicleId,ImageLink,ImageType)
			SELECT @CardVehicleId,[Url],[type]
			FROM @ImageLinks
			WHERE Id IS NULL
			-------SHOME End---

		COMMIT
		SET @valid = 1
		SET @messages = N'Cập nhật thành công'
	END

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK
		DECLARE @ErrorNum INT
			,@ErrorMsg VARCHAR(200)
			,@ErrorProc VARCHAR(50)
			,@SessionID INT
			,@AddlInfo VARCHAR(max)

		SET @ErrorNum = error_number()
		SET @ErrorMsg = 'sp_hrm_app_vehicle_reg ' + error_message()
		SET @ErrorProc = error_procedure()
		SET @AddlInfo = '@Cif_no ' + @userId
		SET @valid = 0
		SET @messages = error_message()

		EXEC utl_errorLog_set @ErrorNum
			,@ErrorMsg
			,@ErrorProc
			,'[HRM_CardVehicle]'
			,'SET'
			,@SessionID
			,@AddlInfo
	END CATCH

	FINAL:

	SELECT @valid AS valid
		,@messages AS [messages]
		,@cardVehicleIdForHrm as cardVehIdForHrm
END