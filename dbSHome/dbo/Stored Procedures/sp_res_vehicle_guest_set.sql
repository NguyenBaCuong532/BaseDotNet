

CREATE PROCEDURE [dbo].[sp_res_vehicle_guest_set] 
	  @UserID NVARCHAR(50)
    , @projectCd NVARCHAR(30)
    , @CardVehicleId INT
    , @CardCd NVARCHAR(50)
    , @FullName NVARCHAR(200)
    , @Phone NVARCHAR(20)
    , @VehicleTypeId INT = 0
    , @VehicleNo NVARCHAR(10) = ''
    , @VehicleName NVARCHAR(50) = ''
    , @StartTime NVARCHAR(20) = ''
    , @EndTime NVARCHAR(20) = null
    , @isVehicleNone BIT = null
	, @Key nvarchar(50) = null
AS
BEGIN
    DECLARE @valid BIT = 1
    DECLARE @messages NVARCHAR(200) = N'Cập nhật thành công'

    BEGIN TRY
        DECLARE @CardId INT
        DECLARE @CustId NVARCHAR(50)

        SET @CustId = (
                SELECT TOP 1 CustId
                FROM MAS_Customers
                WHERE Phone = @Phone
                )
        
		IF (SELECT TOP 1 cardtypeid FROM dbo.MAS_Cards WHERE CardCd = @CardCd) = 4  --duongvt chủ thẻ khách không có custid --> không set được cardid đúng
		SET @CardId = isnull((
                    SELECT TOP 1 CardId
                    FROM MAS_Cards
                    WHERE CardCd = @CardCd
                        AND Card_St < 3
						), 0)
		ELSE																		----
		SET @CardId = isnull((
                    SELECT TOP 1 CardId
                    FROM MAS_Cards
                    WHERE CardCd = @CardCd
                        AND Card_St < 3
                        AND CustId = @CustId
                    ), 0)

        SET @projectCd = isnull(@projectCd, (
                    SELECT TOP 1 ProjectCd
                    FROM MAS_Cards
                    WHERE CardCd = @CardCd
                        AND Card_St < 3
                        AND CustId = @CustId
                    ))

        IF @CardVehicleId = 0
        BEGIN
            IF @ProjectCd IS NULL
                OR NOT EXISTS (
                    SELECT *
                    FROM MAS_Projects
                    WHERE projectCd = @ProjectCd
                    )
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Chưa chọn dự án!'
            END
            ELSE IF @isVehicleNone = 0
                AND EXISTS (
                    SELECT *
                    FROM [MAS_CardVehicle]
                    WHERE VehicleNo LIKE @VehicleNo
                        --AND [Status] = 1
                        --AND isVehicleNone = 0
                    )
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Đã có đăng ký biển số xe [' + @VehicleNo + N'] trong hệ thống!'
            END
            ELSE IF @isVehicleNone = 1
                AND @CardId = 0
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Cần phải cấp thẻ, hoặc mã thẻ chưa đúng người cấp'
            END
            ELSE IF @VehicleTypeId > 1
                AND EXISTS (
                    SELECT b.[CardId]
                    FROM MAS_Cards b
                    JOIN [MAS_CardVehicle] a
                        ON a.CardId = b.CardId
                    WHERE b.CardCd = @CardCd
                        AND b.Card_St < 3
                        AND b.CustId = @CustId
                    )
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Mã thẻ đã được cấp cho người khác [' + @CardCd + N']!'
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
            ELSE
            BEGIN
                IF EXISTS (
                        SELECT *
                        FROM MAS_CardBase
                        WHERE Code = @CardCd
                            AND (
                                IsUsed = 0
                                OR IsUsed IS NULL
                                )
                        )
                    AND NOT EXISTS (
                        SELECT *
                        FROM MAS_Cards
                        WHERE CardCd = @CardCd
                        )
                BEGIN
                    INSERT INTO [dbo].[MAS_Cards] (
                        [CardCd]
                        , [IssueDate]
                        , [Card_St]
                        , [IsClose]
                        , [IsDaily]
                        , [ProjectCd]
                        , [VehicleTypeId]
                        , IsVip
                        , CardTypeId
                        , IsGuest
                        , CustId
                        )
                    VALUES (
                        @CardCd
                        , Getdate()
                        , 1
                        , 0
                        , 0
                        , @ProjectCd
                        , @VehicleTypeId
                        , 0
                        , 3
                        , 1
                        , @CustId
                        )

                    UPDATE MAS_CardBase
                    SET IsUsed = 1
                    WHERE Code = @CardCd
                END

                SET @CardId = isnull((
                            SELECT TOP 1 CardId
                            FROM [MAS_Cards]
                            WHERE [CardCd] = @CardCd
                            ), 0)

                IF @ProjectCd IS NOT NULL
                    INSERT INTO [dbo].[MAS_CardVehicle] (
                        [AssignDate]
                        , [CardId]
                        , [VehicleNo]
                        , [VehicleTypeId]
                        , [VehicleName]
                        , [StartTime]
                        , [EndTime]
                        , [Status]
                        , [ServiceId]
                        , CustId
                        , ProjectCd
                        , monthlyType
                        , Mkr_Id
                        , Mkr_Dt
                        )
                    VALUES (
                        getdate()
                        , @CardId
                        , @VehicleNo
                        , @VehicleTypeId
                        , @VehicleName
                        , convert(DATETIME, @StartTime, 103)
                        , convert(DATETIME, @EndTime, 103)
                        , 1
                        , 0
                        , @CustId
                        , @projectCd
                        , 2
                        , @UserID
                        , Getdate()
                        )
                ELSE
                BEGIN
                    SET @Valid = 0
                    SET @Messages = N'Chưa chọn dự án!'
                END
            END
        END
        ELSE
        BEGIN
            IF @isVehicleNone = 0
                AND EXISTS (
                    SELECT *
                    FROM [MAS_CardVehicle]
                    WHERE VehicleNo LIKE @VehicleNo
                        AND [Status] = 1
                        AND isVehicleNone = 0
                        AND CardVehicleId <> @CardVehicleId
                    )
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Đã có đăng ký biển số xe [' + @VehicleNo + N'] trong hệ thống!'
            END
            ELSE IF @VehicleTypeId > 1
                AND @CardId = 0
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Mã thẻ không hợp lệ [' + isnull(@CardCd, '') + N']!'
            END
            ELSE
                UPDATE [dbo].[MAS_CardVehicle]
                SET [VehicleNo] = @VehicleNo
                    , [VehicleTypeId] = @VehicleTypeId
                    , [VehicleName] = @VehicleName
                    , [StartTime] = convert(DATETIME, @StartTime, 103)
                    , [EndTime] = convert(DATETIME, @EndTime, 103)
                    , CardId = @CardId
                    , Auth_id = @UserID
                    , Auth_Dt = getdate()
                WHERE CardVehicleId = @CardVehicleId
        END
    END TRY

    BEGIN CATCH
        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(max)

        SET @ErrorNum = error_number()
        SET @ErrorMsg = 'sp_res_vehicle_guest_set ' + error_message()
        SET @ErrorProc = error_procedure()
        SET @AddlInfo = '@Cif_no ' + @Phone
        SET @valid = 0
        SET @messages = error_message()

        EXEC utl_Insert_ErrorLog @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'CardGuestVeh'
            , 'Set'
            , @SessionID
            , @AddlInfo
    END CATCH

    SELECT @valid AS valid
        , @messages AS [messages]
END