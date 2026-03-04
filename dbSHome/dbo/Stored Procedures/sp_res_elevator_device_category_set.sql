-- 5. SP Set
CREATE   PROCEDURE [dbo].[sp_res_elevator_device_category_set]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@Id int
	,@HardwareId nvarchar(50)
	,@ElevatorBank int
	,@ElevatorShaftName nvarchar(30)
	,@ElevatorShaftNumber int
	,@ProjectCd nvarchar(30)
	,@buildingCd nvarchar(30)
	,@IsActived bit
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
	BEGIN TRY
		DECLARE @valid BIT = 0;
		DECLARE @messages NVARCHAR(250);
		SET @HardwareId = LOWER(@HardwareId)

		IF EXISTS (SELECT Id FROM [dbo].[MAS_Elevator_Device_Category] WHERE Id = @Id)
		BEGIN
			IF EXISTS(SELECT 1 FROM [MAS_Elevator_Device_Category] WHERE [HardwareId] = @HardwareId AND id <> @Id)
			BEGIN
				SET @valid = 0
				SET @messages = N'Đã tồn tại mã thiết bị này rồi không thể sử dụng'
				GOTO FINAL
			END

			
			IF EXISTS(SELECT 1 FROM [MAS_Elevator_Device_Category] WHERE ProjectCd = @ProjectCd and buildingCd = @buildingCd and id <> @Id)
			BEGIN
				SET @valid = 0
				SET @messages = N'Đã tồn tại cấu hình cho dự án và tòa này rồi không thêm được'
				GOTO FINAL
			END

			UPDATE [dbo].[MAS_Elevator_Device_Category]
			SET [HardwareId] = @HardwareId
				,[ElevatorBank] = @ElevatorBank
				,[ElevatorShaftName] = @ElevatorShaftName
				,[ElevatorShaftNumber] = @ElevatorShaftNumber
				,[ProjectCd] = @ProjectCd
				,[buildingCd] = @buildingCd
				,[IsActived] = @IsActived
			WHERE Id = @Id
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT 1 FROM [MAS_Elevator_Device_Category] WHERE [HardwareId] = @HardwareId)
			BEGIN
				SET @valid = 0
				SET @messages = N'Đã tồn tại mã thiết bị này rồi không thể thêm'
				GOTO FINAL
			END

			IF EXISTS(SELECT 1 FROM [MAS_Elevator_Device_Category] WHERE ProjectCd = @ProjectCd and buildingCd = @buildingCd)
			BEGIN
				SET @valid = 0
				SET @messages = N'Đã tồn tại cấu hình cho dự án và tòa này rồi không thêm được'
				GOTO FINAL
			END

			INSERT INTO [dbo].[MAS_Elevator_Device_Category]
				([HardwareId],[ElevatorBank], [ElevatorShaftName], [ElevatorShaftNumber], [ProjectCd], [buildingCd], [IsActived], created_at)
			VALUES
				(@HardwareId, @ElevatorBank, @ElevatorShaftName, @ElevatorShaftNumber, @ProjectCd, @buildingCd, @IsActived, GETDATE())
			
			SET @Id = @@IDENTITY
		END

		SET @valid = 1
		SET @messages = N'Thành công!'

	END TRY
	BEGIN CATCH
		DECLARE @ErrorNum int, @ErrorMsg varchar(200), @ErrorProc varchar(50), @SessionID int, @AddlInfo varchar(max)
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = 'sp_res_elevator_device_category_set ' + ERROR_MESSAGE()
		SET @ErrorProc = ERROR_PROCEDURE()
		SET @valid = 0
		SET @messages = ERROR_MESSAGE()
		EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Elevator_Device_Category', 'SET', @SessionID, ''
	END CATCH
	FINAL:
	SELECT @valid AS valid, @messages AS [messages];
END