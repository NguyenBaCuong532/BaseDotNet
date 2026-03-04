
CREATE PROCEDURE [dbo].[sp_res_card_vehicle_Set] @UserId NVARCHAR(50)
    , @CardVehicleId INT
    , @CardCd NVARCHAR(50)
    , @VehicleTypeId INT
    , @VehicleNo NVARCHAR(30)
    , @VehicleName NVARCHAR(100)
    , @ServiceId INT = 0
    , @StartTime NVARCHAR(10) = NULL
    , @EndTime NVARCHAR(10) = NULL
    , @Status INT = 0
    , @isVehicleNone BIT = 0
AS
BEGIN
    DECLARE @valid BIT = 1
    DECLARE @messages NVARCHAR(100)

    BEGIN TRY
        DECLARE @apartmentId INT
        DECLARE @roomCode NVARCHAR(30)

        --set @RequestTypeId = 18 --Cap bo sung
        SELECT @apartmentId = c.ApartmentId
            , @roomCode = a.RoomCode
        FROM MAS_Cards t2
        JOIN MAS_Apartment_Card c
            ON t2.CardId = c.CardId
        JOIN MAS_Apartments a
            ON t2.ApartmentId = a.ApartmentId
        WHERE CardCd = @CardCd

        SET @StartTime = isnull(@StartTime, convert(NVARCHAR(10), getdate(), 103))
        SET @Status = isnull(@Status, 0)

        IF (
                SELECT TOP 1 isnull(admin_st, 0)
                FROM Users a
                WHERE UserId = @UserID
                ) = 1
            SET @Status = 1

        IF @VehicleTypeId = 1
            SET @ServiceId = 5
        ELSE
            SET @ServiceId = 6

        IF @CardVehicleId = 0
        BEGIN
            IF @isVehicleNone = 0
                AND EXISTS (
                    SELECT *
                    FROM [MAS_CardVehicle]
                    WHERE VehicleNo LIKE @VehicleNo
                        AND [Status] < 3
                        AND isVehicleNone = 0
                    )
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Đã có đăng ký biển số xe [' + @VehicleNo + N'] trong hệ thống!'
            END
            ELSE IF @VehicleTypeId > 1
                AND NOT EXISTS (
                    SELECT [CardId]
                    FROM MAS_Cards b
                    WHERE b.CardCd = @CardCd
                        AND b.Card_St < 3
                    )
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Không tìm thấy thông tin mã thẻ [' + @CardCd + N']!'
            END
            ELSE IF @VehicleTypeId > 1
                AND EXISTS (
                    SELECT a.[CardId]
                    FROM [MAS_CardVehicle] a
                    JOIN MAS_Cards b
                        ON a.CardId = b.CardId
                    WHERE b.CardCd = @CardCd
                        AND a.[Status] < 3
                        AND a.VehicleTypeId > 1
                    )
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Không được cấp nhiều dịch vụ vào 1 thẻ [' + @CardCd + N']!'
            END
            ELSE IF @apartmentId > 0
                AND NOT EXISTS (
                    SELECT TOP 1 ApartmentId
                    FROM MAS_Apartments
                    WHERE ApartmentId = @ApartmentId
                        AND IsReceived = 1
                    )
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Chưa chuyển trạng thái nhận nhà! Không thể cấp xe'
            END
            ELSE IF @apartmentId > 0
                AND NOT EXISTS (
                    SELECT TOP 1 ApartmentId
                    FROM MAS_Apartments
                    WHERE ApartmentId = @ApartmentId
                        AND [isFeeStart] = 1
                    ) --and not @roomCode like 'G%'
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Chưa cập nhật trạng thái tính phí! Không thể cấp xe'
            END
            ELSE IF @apartmentId > 0
                AND NOT EXISTS (
                    SELECT TOP 1 ApartmentId
                    FROM MAS_Apartment_Service_Living a
                    WHERE ApartmentId = @ApartmentId
                        AND LivingTypeId = 1
                    ) --and (not @roomCode like 'G%' and not @roomCode like 'S%')
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Chưa cập nhật chỉ số công tơ ĐIỆN ! Không thể cấp xe'
            END
            ELSE IF @apartmentId > 0
                AND NOT EXISTS (
                    SELECT TOP 1 ApartmentId
                    FROM MAS_Apartment_Service_Living a
                    WHERE ApartmentId = @ApartmentId
                        AND LivingTypeId = 2
                    ) --and (not @roomCode like 'G%' and not @roomCode like 'S%')
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Chưa cập nhật chỉ số công tơ NƯỚC! Không thể cấp xe'
            END
            ELSE
            BEGIN
                INSERT INTO [dbo].[MAS_CardVehicle] (
                    [ProjectCd]
                    , [AssignDate]
                    , [CardId]
                    , [VehicleNo]
                    , [VehicleTypeId]
                    , [VehicleName]
                    , [StartTime]
                    , [EndTime]
                    , [Status]
                    , ServiceId
                    , RequestId
                    , isVehicleNone
                    , monthlyType
                    , CustId
                    , Mkr_Id
                    , Mkr_Dt
                    , ApartmentId
                    , VehicleNum
                    )
                SELECT ProjectCd
                    , getdate()
                    , t2.CardId
                    , @VehicleNo
                    , @VehicleTypeId
                    , @VehicleName
                    , convert(DATETIME, @StartTime, 103)
                    , convert(DATETIME, @EndTime, 103)
                    , @Status --case when @RequestId > 0 then 0 else @Status end
                    , @ServiceId
                    , 0
                    , @isVehicleNone
                    , monthlyType = CASE 
                        WHEN t2.CardTypeId = 2
                            THEN 0
                        ELSE CASE 
                                WHEN t2.CardTypeId = 1
                                    THEN 1
                                ELSE 2
                                END
                        END
                    , CustId
                    , @UserID
                    , getdate()
                    , c.ApartmentId
                    , isnull((
                            SELECT count(*)
                            FROM [MAS_CardVehicle] a
                            JOIN MAS_VehicleTypes b1
                                ON a.VehicleTypeId = b1.VehicleTypeId
                            JOIN MAS_VehicleTypes b2
                                ON b1.ServiceId = b2.ServiceId
                            WHERE ApartmentId = c.ApartmentId
                                AND b2.VehicleTypeId = @VehicleTypeId
                                AND a.STATUS = 1
                            ), 0) + 1
                FROM MAS_Cards t2
                LEFT JOIN MAS_Apartment_Card c
                    ON t2.CardId = c.CardId
                WHERE CardCd = @CardCd

                IF NOT EXISTS (
                        SELECT [ServiceId]
                        FROM [MAS_CardService] a
                        INNER JOIN MAS_Cards b
                            ON a.CardId = b.CardId
                        WHERE [ServiceId] = @ServiceId
                            AND b.CardCd = @CardCd
                        )
                    INSERT INTO [dbo].[MAS_CardService] (
                        [CardId]
                        , CardCd
                        , [ServiceId]
                        , [LinkDate]
                        , IsLock
                        )
                    SELECT CardId
                        , CardCd
                        , @ServiceId
                        , getdate()
                        , 0
                    FROM MAS_Cards
                    WHERE CardCd = @CardCd

                SET @valid = 1
                SET @messages = N'Thêm mới thành công'
            END
        END
        ELSE
        BEGIN
            IF @isVehicleNone = 0
                AND EXISTS (
                    SELECT *
                    FROM [MAS_CardVehicle]
                    WHERE VehicleNo LIKE @VehicleNo
                        AND [Status] < 3
                        AND CardVehicleId <> @CardVehicleId
                        AND isVehicleNone = 0
                    )
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Đã có đăng ký biển số xe [' + @VehicleNo + N'] trong hệ thống, không được cập nhật trùng thông tin!'
            END
            ELSE IF @apartmentId > 0
                AND NOT EXISTS (
                    SELECT TOP 1 ApartmentId
                    FROM MAS_Apartments
                    WHERE ApartmentId = @ApartmentId
                        AND IsReceived = 1
                    )
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Chưa chuyển trạng thái nhận nhà! Không thể cấp xe'
            END
            ELSE IF @apartmentId > 0
                AND NOT EXISTS (
                    SELECT TOP 1 ApartmentId
                    FROM MAS_Apartments
                    WHERE ApartmentId = @ApartmentId
                        AND [isFeeStart] = 1
                    ) --and not @roomCode like 'G%'
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Chưa cập nhật trạng thái tính phí! Không thể cấp xe'
            END
            ELSE IF @apartmentId > 0
                AND NOT EXISTS (
                    SELECT TOP 1 ApartmentId
                    FROM MAS_Apartment_Service_Living a
                    WHERE ApartmentId = @ApartmentId
                        AND LivingTypeId = 1
                    ) --and (not @roomCode like 'G%' and not @roomCode like 'S%')
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Chưa cập nhật chỉ số công tơ ĐIỆN ! Không thể cấp xe'
            END
            ELSE IF @apartmentId > 0
                AND NOT EXISTS (
                    SELECT TOP 1 ApartmentId
                    FROM MAS_Apartment_Service_Living a
                    WHERE ApartmentId = @ApartmentId
                        AND LivingTypeId = 2
                    ) --and (not @roomCode like 'G%' and not @roomCode like 'S%')
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Chưa cập nhật chỉ số công tơ NƯỚC! Không thể cấp xe'
            END
            ELSE
            BEGIN
                UPDATE t
                SET [AssignDate] = getdate()
                    , [VehicleNo] = @VehicleNo
                    , [VehicleName] = @VehicleName
                    , [StartTime] = convert(DATETIME, @StartTime, 103)
                    , ServiceId = @ServiceId
                    , isVehicleNone = @isVehicleNone
                    --,monthlyType = case when t2.CardTypeId = 2 then 0 else case when t2.CardTypeId = 1 then 1 else 2 end end
                    , Auth_id = @UserID
                    , Auth_Dt = getdate()
                    --,ApartmentId = c.ApartmentId
                    , CardId = isnull((
                            SELECT TOP 1 t1.cardid
                            FROM MAS_Cards t1
                            JOIN MAS_Apartment_Card c
                                ON t1.CardId = c.CardId
                                    AND c.ApartmentId = t.ApartmentId
                            WHERE CardCd = @CardCd
                            ), t.CardId)
                --,VehicleNum = isnull((select count(*) from [MAS_CardVehicle] a join MAS_VehicleTypes b1 on a.VehicleTypeId = b1.VehicleTypeId join MAS_VehicleTypes b2 on b1.ServiceId = b2.ServiceId where ApartmentId = t2.ApartmentId and b2.VehicleTypeId = @VehicleTypeId),0)+1
                FROM [dbo].[MAS_CardVehicle] t
                --left join MAS_Apartment_Card c on t.ApartmentId = c.ApartmentId 
                --left join MAS_Cards t2 on t.CardId = t2.CardId 
                WHERE CardVehicleId = @CardVehicleId

                SET @valid = 1
                SET @messages = N'Cập nhật thành công'
            END

            INSERT INTO [dbo].[MAS_CardVehicle_H] (
                [CardVehicleId]
                , [AssignDate]
                , [CardId]
                , [CustId]
                , [VehicleNo]
                , [VehicleTypeId]
                , [VehicleName]
                , [VehicleColor]
                , [StartTime]
                , [EndTime]
                , [Status]
                , [ServiceId]
                , [RegCardVehicleId]
                , [RequestId]
                , [isVehicleNone]
                , [monthlyType]
                , [VehicleNum]
                , [lastReceivable]
                , [Mkr_Id]
                , [Mkr_Dt]
                , [Auth_id]
                , [Auth_Dt]
                , [ProjectCd]
                , [ApartmentId]
                , [Reason]
                , [SaveDate]
                , [SaveId]
                , [endTime_Tmp]
                , [isCharginFee]
                , [SaveKey]
                , ProcName
                )
            SELECT [CardVehicleId]
                , [AssignDate]
                , [CardId]
                , [CustId]
                , [VehicleNo]
                , [VehicleTypeId]
                , [VehicleName]
                , [VehicleColor]
                , [StartTime]
                , [EndTime]
                , [Status]
                , [ServiceId]
                , [RegCardVehicleId]
                , [RequestId]
                , [isVehicleNone]
                , [monthlyType]
                , [VehicleNum]
                , [lastReceivable]
                , [Mkr_Id]
                , [Mkr_Dt]
                , [Auth_id]
                , [Auth_Dt]
                , [ProjectCd]
                , [ApartmentId]
                , [Reason]
                , getdate()
                , @UserID
                , [endTime_Tmp]
                , [isCharginFee]
                , 'SetUpCardVehicle'
                , 'sp_Hom_Card_Vehicle_Set'
            FROM MAS_CardVehicle
            WHERE CardVehicleId = @CardVehicleId

            DELETE
            FROM [MAS_CardService]
            WHERE EXISTS (
                    SELECT [CardId]
                    FROM MAS_Cards
                    WHERE CardCd = @CardCd
                        AND [CardId] = [MAS_CardService].CardId
                    )
                AND NOT EXISTS (
                    SELECT ServiceId
                    FROM [dbo].[MAS_CardVehicle] t
                    INNER JOIN MAS_Cards t2
                        ON t.CardId = t2.CardId
                    WHERE [ServiceId] = [MAS_CardService].ServiceId
                        AND t2.CardCd = @CardCd
                    )

            IF NOT EXISTS (
                    SELECT [ServiceId]
                    FROM [MAS_CardService] a
                    INNER JOIN MAS_Cards b
                        ON a.CardId = b.CardId
                    WHERE [ServiceId] = @ServiceId
                        AND b.CardCd = @CardCd
                    )
                INSERT INTO [dbo].[MAS_CardService] (
                    [CardId]
                    , CardCd
                    , [ServiceId]
                    , [LinkDate]
                    , IsLock
                    )
                SELECT CardId
                    , CardCd
                    , @ServiceId
                    , getdate()
                    , 0
                FROM MAS_Cards
                WHERE CardCd = @CardCd
        END
    END TRY

    BEGIN CATCH
        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(max)

        SET @ErrorNum = error_number()
        SET @ErrorMsg = 'sp_res_card_vehicle_Set ' + error_message()
        SET @ErrorProc = error_procedure()
        SET @AddlInfo = '@UserID ' + @CardCd
        SET @valid = 0
        SET @messages = error_message()

        EXEC utl_Insert_ErrorLog @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'CardVeh'
            , 'Aut'
            , @SessionID
            , @AddlInfo
    END CATCH

    SELECT @valid AS valid
        , @messages AS [messages]
END