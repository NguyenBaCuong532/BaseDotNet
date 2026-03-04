

CREATE PROCEDURE [dbo].[sp_res_vehicle_resident_set]
    @UserId                nvarchar(450) = NULL,
    @CardVehicleId         int,
    @Action                nvarchar(20) = NULL,   -- 'cancel' | future actions
    @CancelDate            nvarchar(10) = NULL,   -- dd/MM/yyyy
    @Reason                nvarchar(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @valid bit = 1;
    DECLARE @messages nvarchar(250) = N'Thành công';

    BEGIN TRY
        -- Only implement cancel flow for now
        IF LOWER(ISNULL(@Action, '')) = 'cancel'
        BEGIN
            -- Validate target exists and active
            IF NOT EXISTS (SELECT 1 FROM dbo.MAS_CardVehicle WHERE CardVehicleId = @CardVehicleId)
            BEGIN
                SET @valid = 0;
                SET @messages = N'Không tìm thấy thẻ xe';
                GOTO FINISH;
            END;

            IF NOT EXISTS (SELECT 1 FROM dbo.MAS_CardVehicle WHERE CardVehicleId = @CardVehicleId AND [Status] = 1)
            BEGIN
                SET @valid = 0;
                SET @messages = N'Thẻ không ở trạng thái hoạt động, không thể hủy';
                GOTO FINISH;
            END;

            DECLARE @apartmentId int, @vehicleTypeId int, @cardId bigint, @vehicleNum int;
            SELECT @apartmentId = ApartmentId,
                   @vehicleTypeId = VehicleTypeId,
                   @cardId = CardId,
                   @vehicleNum = VehicleNum
            FROM dbo.MAS_CardVehicle
            WHERE CardVehicleId = @CardVehicleId;

            -- Persist history BEFORE changing
            INSERT INTO dbo.MAS_CardVehicle_H (
                [CardVehicleId],[AssignDate],[CardId],[CustId],[VehicleNo],[VehicleTypeId],[VehicleName],[VehicleColor],
                [StartTime],[EndTime],[Status],[ServiceId],[RegCardVehicleId],[RequestId],[isVehicleNone],[monthlyType],
                [VehicleNum],[lastReceivable],[Mkr_Id],[Mkr_Dt],[Auth_id],[Auth_Dt],[ProjectCd],[ApartmentId],
                [Reason],[SaveDate],[SaveId],[endTime_Tmp],[isCharginFee],[SaveKey],[ProcName]
            )
            SELECT [CardVehicleId],[AssignDate],[CardId],[CustId],[VehicleNo],[VehicleTypeId],[VehicleName],[VehicleColor],
                   [StartTime],[EndTime],[Status],[ServiceId],[RegCardVehicleId],[RequestId],[isVehicleNone],[monthlyType],
                   [VehicleNum],[lastReceivable],[Mkr_Id],[Mkr_Dt],[Auth_id],[Auth_Dt],[ProjectCd],[ApartmentId],
                   ISNULL(@Reason, N'Cancel'), GETDATE(), @UserId, [endTime_Tmp],[isCharginFee], 'Cancel', 'sp_res_vehicle_resident_set'
            FROM dbo.MAS_CardVehicle
            WHERE CardVehicleId = @CardVehicleId;

            -- Cancel the vehicle card: set status 3, set end dates and reasons
            UPDATE t
            SET [Status] = 3,
                [EndTime] = CASE WHEN NULLIF(@CancelDate, '') IS NOT NULL THEN CONVERT(datetime, @CancelDate, 103) ELSE ISNULL([EndTime], GETDATE()) END,
                [locked_dt] = GETDATE(),
                [lock_reason] = @Reason,
                [card_return_date] = CASE WHEN NULLIF(@CancelDate, '') IS NOT NULL THEN CONVERT(datetime, @CancelDate, 103) ELSE ISNULL([card_return_date], GETDATE()) END,
                [Auth_id] = @UserId,
                [Auth_Dt] = GETDATE()
            FROM dbo.MAS_CardVehicle t
            WHERE t.CardVehicleId = @CardVehicleId;

            -- Re-number remaining active vehicles in the same apartment and type
            -- Decrement VehicleNum where greater than the canceled one
            UPDATE t
            SET [VehicleNum] = t.VehicleNum - 1
            FROM dbo.MAS_CardVehicle t
            JOIN dbo.MAS_CardVehicle a
              ON t.ApartmentId = a.ApartmentId
             AND t.VehicleTypeId = a.VehicleTypeId
             AND t.VehicleNum > a.VehicleNum
            WHERE t.[Status] = 1
              AND a.CardVehicleId = @CardVehicleId;

            -- Maintain card flag isVehicle
            UPDATE c
            SET c.[isVehicle] = CASE WHEN EXISTS (
                        SELECT 1 FROM dbo.MAS_CardVehicle v WHERE v.CardId = c.CardId AND v.[Status] = 1
                    ) THEN 1 ELSE 0 END
            FROM dbo.MAS_Cards c
            WHERE c.CardId = @cardId;

            -- Optional: recalc per-apartment numbering/fees via helper proc if exists
            IF OBJECT_ID('dbo.sp_Hom_Service_Vehicle_Number_Again') IS NOT NULL
            BEGIN
                EXEC dbo.sp_Hom_Service_Vehicle_Number_Again @UserId, @apartmentId, @vehicleTypeId;
            END;

            SET @messages = N'Hủy thẻ thành công';
            SET @valid = 1;
        END
        ELSE
        BEGIN
            SET @valid = 0;
            SET @messages = N'Hành động không được hỗ trợ';
        END

    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum int, @ErrorMsg nvarchar(4000), @ErrorProc nvarchar(200), @SessionID int, @AddlInfo nvarchar(max);
        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_vehicle_resident_set ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo = '@CardVehicleId=' + CAST(ISNULL(@CardVehicleId, 0) AS nvarchar(20));
        SET @valid = 0;
        SET @messages = ERROR_MESSAGE();
        IF OBJECT_ID('dbo.utl_Insert_ErrorLog') IS NOT NULL
            EXEC dbo.utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Vehicle', 'SET', @SessionID, @AddlInfo;
    END CATCH

FINISH:
    SELECT @valid AS valid, @messages AS [messages];
END