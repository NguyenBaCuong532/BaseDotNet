CREATE PROCEDURE [dbo].[sp_res_card_set]
    @UserID UNIQUEIDENTIFIER,
    @CardCd NVARCHAR(50),
    @RoomCd NVARCHAR(30),
    @CustId NVARCHAR(50),
    @CardTypeId INT,
    @IsVehicle BIT = 0,
    @VehicleTypeId INT = 0,
    @VehicleNo NVARCHAR(10) = '',
    @ServiceId INT = 0,
    @VehicleName NVARCHAR(50) = '',
    @isVehicleNone BIT = NULL,
    @startTime NVARCHAR(20) = NULL,
    @isCredit BIT = 0,
    @CifNo2 NVARCHAR(50) = '',
    @CreditLimit INT = 0,
    @SalaryAvg INT = 0,
    @IsSalaryTranfer BIT = 0,
    @ResidenProvince NVARCHAR(100) = '',
    @requestId INT = NULL
AS
BEGIN
DECLARE @valid BIT = 0;
DECLARE @messages NVARCHAR(200) = N'Có lỗi xảy ra';
BEGIN TRY

    --declare @errmessage nvarchar(100)
    DECLARE @ApartmentId INT;
    DECLARE @CardId INT;
    DECLARE @projectCd NVARCHAR(30);
    DECLARE @startDt DATETIME;

		--duongvt cập nhật serviceid, nếu mặc định serviceid = 0 thì không tính được phí
		IF @VehicleTypeId = 1
        SET @ServiceId= 5
		ELSE
        IF @VehicleTypeId = 2 OR @VehicleTypeId = 3 
            SET @ServiceId = 6
        ELSE SET @ServiceId = 7

        IF @startTime IS NULL OR @startTime = ''
            SET @startDt = GETDATE();
        ELSE
            SET @startDt = CONVERT(DATETIME, @startTime, 103);

        IF @CardTypeId = 3
            SET @IsVehicle = 1;
        --set @errmessage = 'This Card: ' + @CardCd + ' is not exists or used!'
        SELECT @ApartmentId = ApartmentId,
               @projectCd = projectCd
        FROM MAS_Apartments
        WHERE RoomCode = @RoomCd;
        
        IF(@ApartmentId IS NULL OR @ApartmentId = 0)
        BEGIN
            SELECT @ApartmentId = a.ApartmentId,
                   @projectCd = a.projectCd
            FROM
                MAS_Apartments a
            WHERE a.RoomCode = @RoomCd OR a.RoomCodeView = @RoomCd;
        END


        SET @isVehicleNone = ISNULL(@isVehicleNone, 0);

        IF @VehicleTypeId = 3 AND LEN(@VehicleNo) < 9
            SET @VehicleNo
                = 'P-'
                  + RIGHT('0000' + CAST(
                                   (
                                       SELECT COUNT(*) FROM [MAS_CardVehicle] WHERE VehicleTypeId = 3
                                   ) AS VARCHAR), 5);

        IF NOT EXISTS (SELECT Code FROM MAS_CardBase WHERE Code = @CardCd) --and (IsUsed = 0 or IsUsed is null)
        BEGIN
            SET @valid = 0;
            SET @messages = N'Không tìm thấy thông tin mã thẻ [' + @CardCd + N'] trong kho số!';
        END;
        ELSE IF EXISTS (SELECT Code FROM MAS_CardBase WHERE Code = @CardCd AND IsUsed = 1)
        BEGIN
            SET @valid = 0;
            SET @messages = N'Mã thẻ [' + @CardCd + N'] đã được sử dụng!';
        END;
        ELSE IF @ApartmentId IS NULL OR @ApartmentId = 0
        BEGIN
            SET @valid = 0;
            SET @messages = N'Không tìm thấy thông tin căn hộ [' + @RoomCd + N']!';
        END;
        ELSE IF NOT EXISTS(SELECT TOP 1 ApartmentId FROM MAS_Apartments WHERE ApartmentId = @ApartmentId AND IsReceived = 1)
        BEGIN
            SET @valid = 0;
            SET @messages = N'Chưa chuyển trạng thái nhận nhà căn [' + @RoomCd + N']! Không thể cấp thẻ';
        END;
        ELSE IF NOT EXISTS(SELECT TOP 1 ApartmentId FROM MAS_Apartments WHERE ApartmentId = @ApartmentId AND [isFeeStart] = 1)
        BEGIN
            SET @valid = 0;
            SET @messages = N'Chưa cập nhật trạng thái TÍNH PHÍ DỊCH VỤ [' + @RoomCd + N']! Không thể cấp thẻ';
        END;
        ELSE IF NOT EXISTS (SELECT CustId FROM MAS_Customers WHERE CustId = @CustId)
        BEGIN
            SET @valid = 0;
            SET @messages = N'Không tìm thấy thông tin thành viên [' + @CustId + N']!';
        END
        ELSE
        BEGIN
            if exists (select 1 from MAS_Cards where CardCd = @CardCd)
            BEGIN
                UPDATE [dbo].[MAS_Cards]
                SET 
                    [CardCd] = @CardCd,
                    [IssueDate] = GETDATE(),
                    [ExpireDate] = NULL,
                    CustId = @CustId,
                    [CardTypeId] = @CardTypeId,
                    [ImageUrl] = NULL,
                    [Card_St] = 1,
                    IsDaily = 0,
                    ProjectCd = @ProjectCd,
                    isVehicle = @IsVehicle,
                    isCredit = @isCredit,
                    created_by = @UserID,
                    ApartmentId = @ApartmentId
                where [CardCd] = @CardCd
            END
            else
            Begin
               INSERT INTO [dbo].[MAS_Cards]
                      (
                        [ApartmentId],
                        [CardCd],
                        [IssueDate],
                        [ExpireDate],
                        CustId,
                        [CardTypeId],
                        [ImageUrl],
                        [Card_St],
                        IsDaily,
                        ProjectCd,
                        isVehicle,
                        isCredit,
                        created_by
                      )
                      SELECT @ApartmentId,
                           @CardCd,
                           GETDATE(),
                           NULL,
                           @CustId,
                           @CardTypeId,
                           NULL,
                           1,
                           0,
                           @projectCd,
                           @IsVehicle,
                           @isCredit,
                           @UserID;
            end

            SET @CardId = ISNULL((SELECT TOP 1 CardId FROM [MAS_Cards] WHERE [CardCd] = @CardCd), 0);

            UPDATE MAS_CardBase
            SET IsUsed = 1
            WHERE Code = @CardCd;

            INSERT INTO [dbo].[MAS_Apartment_Card]
            (
                [ApartmentId],
                [CardId]
            )
            SELECT @ApartmentId,
                   CardId
            FROM [MAS_Cards]
            WHERE CardCd = @CardCd
                  AND NOT EXISTS
                  (SELECT CardId FROM [MAS_Apartment_Card] WHERE CardId = MAS_Cards.CardId AND ApartmentId = MAS_Cards.ApartmentId);


            IF @IsVehicle = 1
                INSERT INTO [dbo].[MAS_CardVehicle]
                (
                    [AssignDate],
                    [CardId],
                    [VehicleNo],
                    [VehicleTypeId],
                    [VehicleName],
                    [StartTime],
                    [EndTime],
                    [Status],
                    ServiceId,
                    isVehicleNone,
                    monthlyType,
                    CustId,
                    ProjectCd,
                    ApartmentId,
                    VehicleNum
                )
                SELECT GETDATE(),
                       @CardId,
                       @VehicleNo,
                       @VehicleTypeId,
                       @VehicleName,
                       @startDt,
                       @startDt,
                       1,
                       @ServiceId,
                       @isVehicleNone,
                       CASE
                           WHEN @CardTypeId = 2 THEN 0
                           ELSE CASE WHEN @CardTypeId = 1 THEN 1 ELSE 2 END
                       END,
                       @CustId,
                       @projectCd,
                       @ApartmentId,
                       ISNULL((SELECT COUNT(*)
                               FROM
                                  [MAS_CardVehicle] a
                                  JOIN MAS_VehicleTypes b1 ON a.VehicleTypeId = b1.VehicleTypeId
                                  JOIN MAS_VehicleTypes b2 ON b1.ServiceId = b2.ServiceId
                                WHERE
                                    ApartmentId = @ApartmentId
                                    AND b2.VehicleTypeId = @VehicleTypeId
                                    AND a.Status = 1),
                                0 ) + 1;

            IF @isCredit = 1
                INSERT INTO [dbo].[MAS_CardCredit]
                (
                    [CardId],
                    [Cif_No2],
                    [CreditLimit],
                    [SalaryAvg],
                    [IsSalaryTranfer],
                    [ResidenProvince],
                    [AsignDate],
                    [Status]
                )
                SELECT @CardId,
                       @CifNo2,
                       @CreditLimit,
                       @SalaryAvg,
                       @IsSalaryTranfer,
                       @ResidenProvince,
                       GETDATE(),
                       1;
          SET @valid = 1;
            SET @messages = N'Thêm mới thành công';

        END;
    
    FINAL:
        SELECT @valid valid,
           @messages AS [messages];
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_set ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '@CustId ' + @CustId + ' @RoomCd ' + @RoomCd + ' cardCd' + @CardCd + ': ' + @startTime;

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'Insert', @SessionID, @AddlInfo;
    SET @valid = 0;
    SET @messages = ERROR_MESSAGE();


END CATCH;

  SELECT @valid AS valid,
         @messages AS [messages];

END;