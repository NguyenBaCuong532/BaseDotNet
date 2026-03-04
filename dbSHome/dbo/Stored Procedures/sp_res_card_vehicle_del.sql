
CREATE PROCEDURE [dbo].[sp_res_card_vehicle_del]
    @UserId UNIQUEIDENTIFIER = NULL,
    @cardVehicleId BIGINT,
    @cardVehicleOid UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
    IF @cardVehicleOid IS NOT NULL
        SET @cardVehicleId = (SELECT CardVehicleId FROM MAS_CardVehicle WHERE oid = @cardVehicleOid);
    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(200) = N'Xóa thành công';

    BEGIN TRY

        DECLARE @vehicleNum INT;
        DECLARE @apartmentId INT;
        DECLARE @vehicleTypeId INT;
        DECLARE @cardId BIGINT;
        DECLARE @Receives TABLE
        (
            ReceiveId BIGINT NOT NULL,
            ReceivbleId BIGINT NOT NULL
        );

        IF NOT EXISTS
        (
            SELECT *
            FROM [MAS_CardVehicle]
            WHERE CardVehicleId = @cardVehicleId
        ) --and (IsUsed = 0 or IsUsed is null)
        BEGIN
            SET @valid = 0;
            SET @messages = N'Không tìm thấy thông tin [' + CAST(@cardVehicleId AS VARCHAR) + N'] trong hệ thống!';
        END;
        ELSE IF EXISTS
        (
            SELECT *
            FROM [MAS_CardVehicle]
            WHERE CardVehicleId = @cardVehicleId
                  AND Status = 1
        )
        BEGIN
            SET @valid = 0;
            SET @messages
                = N'Mã thẻ [' + CAST(@cardVehicleId AS VARCHAR)
                  + N'] đã được sử dụng, Cần phải khóa lại trước khi xóa!';
        END;
        ELSE
        BEGIN
            SELECT @vehicleNum = VehicleNum,
                   @apartmentId = ApartmentId,
                   @vehicleTypeId = VehicleTypeId,
                   @cardId = CardId
            FROM [MAS_CardVehicle]
            WHERE CardVehicleId = @cardVehicleId;

            INSERT INTO [dbo].[MAS_CardVehicle_H]
            (
                [CardVehicleId],
                [AssignDate],
                [CardId],
                [CustId],
                [VehicleNo],
                [VehicleTypeId],
                [VehicleName],
                [VehicleColor],
                [StartTime],
                [EndTime],
                [Status],
                [ServiceId],
                [RegCardVehicleId],
                [RequestId],
                [isVehicleNone],
                [monthlyType],
                [VehicleNum],
                [lastReceivable],
                [Mkr_Id],
                [Mkr_Dt],
                [Auth_id],
                [Auth_Dt],
                [ProjectCd],
                [ApartmentId],
                [Reason],
                [SaveDate],
                [SaveId],
                SaveKey,
                ProcName
            )
            SELECT [CardVehicleId],
                   [AssignDate],
                   [CardId],
                   [CustId],
                   [VehicleNo],
                   [VehicleTypeId],
                   [VehicleName],
                   [VehicleColor],
                   [StartTime],
                   [EndTime],
                   [Status],
                   [ServiceId],
                   [RegCardVehicleId],
                   [RequestId],
                   [isVehicleNone],
                   [monthlyType],
                   [VehicleNum],
                   [lastReceivable],
                   [Mkr_Id],
                   [Mkr_Dt],
                   [Auth_id],
                   [Auth_Dt],
                   [ProjectCd],
                   [ApartmentId],
                   'Delete',
                   GETDATE(),
                   CAST(@UserId AS NVARCHAR(50)),
                   'Delete',
                   'sp_res_vehicle_card_del'
            FROM [MAS_CardVehicle]
            WHERE CardVehicleId = @cardVehicleId;

            -- UPDATE [dbo].[MAS_CardVehicle]
            --  SET [VehicleNum] = VehicleNum-1
            --WHERE VehicleNum > @vehicleNum 
            --and ApartmentId = @apartmentId 
            --and VehicleTypeId = @vehicleTypeId
            --and [Status] = 1

            DELETE FROM MAS_CardVehicle
            WHERE CardVehicleId = @cardVehicleId;

            UPDATE t
            SET [isVehicle] = CASE
                                  WHEN
                                  (
                                      SELECT COUNT(CardVehicleId)
                                      FROM MAS_CardVehicle
                                      WHERE CardId = t.CardId
                                            AND Status = 1
                                  ) > 0 THEN
                                      1
                                  ELSE
                                      0
                              END
            FROM [MAS_Cards] t
            WHERE CardId = @cardId;

            EXEC sp_Hom_Service_Vehicle_Number_Again @UserId,
                                                     @apartmentId,
                                                     @vehicleTypeId;

            -- update lai hoa don chua thanh toan khi xoa xe
            INSERT INTO @Receives
            (
                ReceiveId,
                ReceivbleId
            )
            SELECT r.[ReceiveId],
                   r.ReceivableId
            FROM MAS_Service_Receivable r
                JOIN [MAS_Service_ReceiveEntry] e
                    ON r.ReceiveId = e.ReceiveId
            WHERE r.srcId = @cardVehicleId
                  AND r.[ServiceTypeId] = 2
                  AND e.IsPayed = 0;

            DELETE t
            FROM MAS_Service_Receivable t
                INNER JOIN @Receives b
                    ON t.ReceivableId = b.ReceivbleId
                       AND t.ReceiveId = b.ReceiveId;

            UPDATE t
            SET CommonFee =
                (
                    SELECT SUM(TotalAmt)
                    FROM [MAS_Service_Receivable]
                    WHERE [ReceiveId] = t.ReceiveId
                          AND ServiceTypeId = 1
                ),
                VehicleAmt =
                (
                    SELECT SUM(TotalAmt)
                    FROM [MAS_Service_Receivable]
                    WHERE [ReceiveId] = t.ReceiveId
                          AND ServiceTypeId = 2
                ),
                LivingAmt =
                (
                    SELECT SUM(TotalAmt)
                    FROM [MAS_Service_Receivable]
                    WHERE [ReceiveId] = t.ReceiveId
                          AND ServiceTypeId = 3
                ),
                ExtendAmt =
                (
                    SELECT SUM(TotalAmt)
                    FROM [MAS_Service_Receivable]
                    WHERE [ReceiveId] = t.ReceiveId
                          AND ServiceTypeId = 4
                ),
                TotalAmt =
                (
                    SELECT SUM(TotalAmt)
                    FROM [MAS_Service_Receivable]
                    WHERE [ReceiveId] = t.ReceiveId
                ) + ISNULL(t.DebitAmt, 0)
            --,PaidAmt = case when t.DebitAmt > 0 then (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId) -   else 0 end
            FROM MAS_Service_ReceiveEntry t
                INNER JOIN @Receives b
                    ON t.ReceiveId = b.ReceiveId;

        END;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum INT,
                @ErrorMsg VARCHAR(200),
                @ErrorProc VARCHAR(50),
                @SessionID INT,
                @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_vehicle_card_del' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();

        SET @AddlInfo = '';
        SET @valid = 0;
        SET @messages = ERROR_MESSAGE();

        EXEC utl_Insert_ErrorLog @ErrorNum,
                                 @ErrorMsg,
                                 @ErrorProc,
                                 'Vehicle',
                                 'DEL',
                                 @SessionID,
                                 @AddlInfo;

    END CATCH;

    SELECT @valid AS valid,
           @messages AS [messages];
END;