-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	set details of card reg
-- Output:
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_card_reg_set] 
	  @UserId UNIQUEIDENTIFIER
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
	, @CardVehicleId INT = NULL
    , @CardCd NVARCHAR(20)
    , @VehicleTypeId INT = NULL
    , @VehicleNo NVARCHAR(10)
    , @VehicleName NVARCHAR(50)
    , @VehicleColor NVARCHAR(50)
    , @idCardAttach UNIQUEIDENTIFIER
    , @vehicleNoAttach UNIQUEIDENTIFIER
    , @vehicleLicenseAttach UNIQUEIDENTIFIER
AS
BEGIN
    DECLARE @valid BIT = 0
    DECLARE @messages NVARCHAR(100) = ''

    BEGIN TRY
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
        IF @CardVehicleId IS NULL
            OR NOT EXISTS (
                SELECT CardVehicleId
                FROM MAS_CardVehicle
                WHERE CardVehicleId = @CardVehicleId
                )
        BEGIN
            BEGIN TRAN

            INSERT INTO [MAS_CardVehicle] (
                [AssignDate]
                , CustId
                , [VehicleNo]
                , [VehicleTypeId]
                , [VehicleName]
                , VehicleColor
                , StartTime
                , [Status]
                , [ServiceId]
                , monthlyType
                , ProjectCd
                , Reason
                , CardId
                , Mkr_Id
                , Mkr_Dt
                , IdCardAttach
                , VehicleNoAttach
                , VehicleLicenseAttach
                )
            VALUES (
                getdate()
                , @CustId
                , @VehicleNo
                , @VehicleTypeId
                , @VehicleName
                , @VehicleColor
                , getdate()
                , 0
                , 0
                , 0
                , NULL
                , 'Register from APP'
                , @cardId
                , @UserId
                , getdate()
                , @idCardAttach
                , @vehicleNoAttach
                , @vehicleLicenseAttach
                )

            SET @CardVehicleId = SCOPE_IDENTITY()

            INSERT INTO [MAS_CardVehicle_Image] (
                CardVehicleId
                , ImageLink
                , ImageType
                )
            SELECT @CardVehicleId
                , [Url] = a.file_url
                , [type] = CASE a.sourceOid
                    WHEN @idCardAttach
                        THEN 'IDENTITY_CARD'
                    WHEN @vehicleNoAttach
                        THEN 'LICENSE_PLATE'
                    WHEN @vehicleLicenseAttach
                        THEN 'LICENSE'
                    END
            FROM meta_info a
            WHERE a.sourceOid IN (@idCardAttach, @vehicleNoAttach, @vehicleLicenseAttach)

            COMMIT

            SET @valid = 1
            SET @messages = N'Đã gửi yêu cầu đăng ký phương tiện thành công'
        END
        ELSE
        BEGIN
            BEGIN TRAN

            UPDATE [MAS_CardVehicle]
            SET [VehicleNo] = @VehicleNo
                , [VehicleTypeId] = @VehicleTypeId
                , [VehicleName] = @VehicleName
                , VehicleColor = @VehicleColor
                , Auth_id = @UserId
                , Auth_Dt = getdate()
                , IdCardAttach = @idCardAttach
                , VehicleNoAttach = @vehicleNoAttach
                , VehicleLicenseAttach = @vehicleLicenseAttach
            WHERE CardVehicleId = @CardVehicleId

            --
            DELETE
            FROM dbSHOME.dbo.[MAS_CardVehicle_Image]
            WHERE CardVehicleId = @CardVehicleId

            INSERT INTO [MAS_CardVehicle_Image] (
                CardVehicleId
                , ImageLink
                , ImageType
                )
            SELECT @CardVehicleId
                , [Url] = a.file_url
                , [type] = CASE a.sourceOid
                    WHEN @idCardAttach
                        THEN 'IDENTITY_CARD'
                    WHEN @vehicleNoAttach
                        THEN 'LICENSE_PLATE'
                    WHEN @vehicleLicenseAttach
                        THEN 'LICENSE'
                    END
            FROM meta_info a
            WHERE a.sourceOid IN (@idCardAttach, @vehicleNoAttach, @vehicleLicenseAttach)

            COMMIT

            SET @valid = 1
            SET @messages = N'Cập nhật yêu cầu thành công'
        END
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK

        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(max)

        SET @ErrorNum = error_number()
        SET @ErrorMsg = error_message()
        SET @ErrorProc = error_procedure()
        SET @AddlInfo = '@userId ' --+ @userId
        SET @valid = 0
        SET @messages = error_message()

        EXEC utl_errorLog_set @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , '[HRM_CardVehicle]'
            , 'SET'
            , @SessionID
            , @AddlInfo
    END CATCH

    FINAL:

    SELECT valid = @valid
        , [Data] = @VehicleTypeId
        , [messages] = @messages 
END