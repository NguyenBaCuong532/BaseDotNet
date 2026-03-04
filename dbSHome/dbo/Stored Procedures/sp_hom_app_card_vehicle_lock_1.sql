




CREATE procedure [dbo].[sp_hom_app_card_vehicle_lock]
	@userId NVARCHAR(50)
	,@CardVehicleId INT = NULL
	,@reason nvarchar(100) = NULL
	,@status int = NULL
AS
BEGIN
	DECLARE @valid BIT = 0
	DECLARE @messages NVARCHAR(100)

	BEGIN TRY
		
		--DECLARE @CustId UNIQUEIDENTIFIER = (
		--		SELECT TOP 1 CustId
		--		FROM dbSHRM.dbo.Employees
		--		WHERE UserId = @UserId
		--		)
		IF NOT EXISTS(SELECT 1 FROM MAS_CardVehicle WHERE CardVehicleId = @CardVehicleId)
		BEGIN
			SET @messages = N'Không tồn tại phương tiện'
			GOTO FINAL
		END

		IF @status =3
		BEGIN
			BEGIN TRAN
				INSERT INTO [MAS_CardVehicle_H]
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
					   ,[SaveId])
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
					  ,'Locked'
					  ,getdate()
					  ,@UserId
				  FROM [dbSHome].[dbo].[MAS_CardVehicle]
				  WHERE cardVehicleId = @cardVehicleId 

				UPDATE t1
					SET [Status] = 3
						,[lock_reason] = @reason
					   ,locked_dt = getdate()
				FROM MAS_CardVehicle t1 --INNER JOIN MAS_Cards t2 on t1.CardId = t2.CardId 
				WHERE CardVehicleId = @CardVehicleId

				UPDATE t
				   SET [VehicleNum] = t.VehicleNum - 1
				FROM [MAS_CardVehicle] t 
					join [MAS_CardVehicle] a on t.ApartmentId = a.ApartmentId and t.VehicleTypeId = a.VehicleTypeId 
				  and t.VehicleNum > a.VehicleNum 
				WHERE t.[Status] = 1
					and a.CardVehicleId = @CardVehicleId
			COMMIT
			SET @valid = 1
			SET @messages = N'Khóa phương tiện thành công'
		END
		ELSE IF @status = 1
		BEGIN

			UPDATE MAS_CardVehicle
			SET Status = @status
			WHERE CardVehicleId = @CardVehicleId

			SET @valid = 1
			SET @messages = N'Yêu cầu mở khóa phương tiện thành công'
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
		SET @ErrorMsg = 'sp_hom_app_card_vehicle_lock ' + error_message()
		SET @ErrorProc = error_procedure()
		SET @AddlInfo = '@userId ' + @userId
		SET @valid = 0
		SET @messages = error_message()

		EXEC utl_errorLog_set @ErrorNum
			,@ErrorMsg
			,@ErrorProc
			,'[MAS_CardVehicle]'
			,'SET'
			,@SessionID
			,@AddlInfo
	END CATCH

	FINAL:

	SELECT @valid AS valid
		,@messages AS [messages]
END