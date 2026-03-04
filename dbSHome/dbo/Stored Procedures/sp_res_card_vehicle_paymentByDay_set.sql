CREATE PROCEDURE [dbo].[sp_res_card_vehicle_paymentByDay_set]
    @UserId NVARCHAR(450) = null,
    @CardVehicleId INT = null,
    @VehNum INT = null,
    @Price DECIMAL = null,
    @Quantity DECIMAL = null,
    @Amount DECIMAL = null,
    @StartDate NVARCHAR(30) = null,
    @EndDate NVARCHAR(30) = null,
    @Remart NVARCHAR(200) = null,
	@CustId nvarchar(50) = null,
	@VehiclePayId int = null,
	@CustName nvarchar(50) = null,
	@ExtraTime nvarchar(50) = null

AS
BEGIN TRY

    DECLARE @valid BIT = 0,
            @messages NVARCHAR(250) = N'';
    --declare @errmessage nvarchar(100)
    DECLARE @StartDt DATETIME;
    DECLARE @ReceiveId BIGINT;
    --declare @PreReceiveId bigint 
    DECLARE @Receives TABLE
    (
        ReceiveId BIGINT NOT NULL
    );
    DECLARE @ToDt DATETIME;
    SET @ToDt = CONVERT(DATETIME, @EndDate, 103);
    DECLARE @ApartmentId BIGINT;

    IF EXISTS
    (
        SELECT CardVehicleId
        FROM MAS_CardVehicle v
        WHERE v.CardVehicleId = @CardVehicleId
              AND ISNULL(v.EndTime, v.StartTime) >= @ToDt
    )
    BEGIN
        SET @valid = 0;
        SET @messages = N'Ngày gia hạn phải lớn hơn ngày [' + @EndDate + N']!';
    END;
    ELSE IF EXISTS
    (
        SELECT CardVehicleId
        FROM MAS_CardVehicle v
        WHERE v.CardVehicleId = @CardVehicleId
              AND monthlyType > 0
    )
    BEGIN

        SET @Price =
        (
            SELECT TOP 1
                   CASE sp.ServiceId
                       WHEN 5 THEN
                           CASE
                               WHEN ISNULL(v.VehicleNum, 1) <= 1 THEN
                                   Price
                               ELSE
                                   Price2
                           END
                       WHEN 6 THEN
                           CASE
                               WHEN v.VehicleNum < 3 THEN
                                   Price
                               ELSE
                                   Price2
                           END
                       WHEN 7 THEN
                           Price
                   END
            FROM [PAR_ServicePrice] sp
                JOIN MAS_VehicleTypes c
                    ON sp.ServiceId = c.ServiceId
                JOIN [MAS_CardVehicle] v
                    ON c.VehicleTypeId = v.VehicleTypeId
                       AND sp.TypeId = v.[monthlyType]
                LEFT JOIN MAS_Apartments a
                    ON v.ApartmentId = a.ApartmentId
                       AND sp.ProjectCd = ISNULL(a.projectCd, v.ProjectCd)
            WHERE v.CardVehicleId = @CardVehicleId
        );

        INSERT INTO @Receives
        SELECT r.[ReceiveId]
        FROM MAS_Service_Receivable r
            JOIN [MAS_Service_ReceiveEntry] e
                ON r.ReceiveId = e.ReceiveId
        WHERE r.srcId = @CardVehicleId
              AND r.[ServiceTypeId] = 2
              AND e.IsPayed = 0;

        INSERT INTO [dbo].[MAS_Service_ReceiveEntry]
        (
            [ApartmentId],
            [ReceiveDt],
            --,[FromDt]
            [ToDt],
            [SysDate],
            ProjectCd,
            IsPayed,
            Remart,
            createId,
            isExpected
        )
        SELECT a.ApartmentId,
               GETDATE(),
               --,convert(date,@StartDate,103)
               @ToDt,
               GETDATE(),
               a.ProjectCd,
               0,
               CASE
                   WHEN @Remart = ''
                        OR @Remart IS NULL THEN
                       N'Gia hạn vé xe: ' + CASE
                                                WHEN a.isVehicleNone = 1 THEN
                                                    a.VehicleName
                                                ELSE
                                                    a.VehicleNo
                                            END + N' đến ' + FORMAT(@ToDt, 'dd/MM/yyyy')
                   ELSE
                       @Remart
               END,
               @UserId,
               0
        FROM MAS_CardVehicle a
        WHERE CardVehicleId = @CardVehicleId;

        SET @ReceiveId = @@IDENTITY;

        INSERT INTO MAS_Service_Receivable
        (
            [ReceiveId],
            [ServiceTypeId],
            [ServiceObject],
            [Amount],
            VatAmt,
            TotalAmt,
            fromDt,
            [ToDt],
            [Quantity],
            Price,
            srcId
        )
        SELECT @ReceiveId,
               2,
               v.VehicleNo,
               b.Amount - ROUND(b.Amount / 11, 0),
               ROUND(b.Amount / 11, 0),
               b.Amount,
               b.StartDate,
               @ToDt,
               b.Quantity,
               b.Price,
               v.CardVehicleId
        FROM MAS_CardVehicle v
            JOIN [dbo].[fn_Hom_Vehicle_Payday_Get](@CardVehicleId, @ToDt) b
                ON v.CardVehicleId = b.CardVehicleId
        WHERE v.CardVehicleId = @CardVehicleId;

        SET @ApartmentId =
        (
            SELECT TOP 1
                   ApartmentId
            FROM MAS_CardVehicle
            WHERE CardVehicleId = @CardVehicleId
        );

        UPDATE t1
        SET t1.EndTime = @ToDt,
            t1.lastReceivable = @ToDt,
            t1.Auth_id = @UserId,
            t1.Auth_Dt = GETDATE()
        FROM MAS_CardVehicle t1
        WHERE t1.CardVehicleId = @CardVehicleId;

        UPDATE t1
        SET t1.lastReceivable = t1.endTime_Tmp,
            t1.Auth_id = @UserId,
            t1.Auth_Dt = GETDATE()
        FROM MAS_CardVehicle t1
        WHERE t1.CardVehicleId <> @CardVehicleId
              AND ApartmentId = @ApartmentId;

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
            ),
            --,ToDt = @ToDt
            [ExpireDate] = DATEADD(DAY, 10, ToDt),
            IsPayed = 1,
            PaidAmt =
            (
                SELECT SUM(TotalAmt)
                FROM [MAS_Service_Receivable]
                WHERE [ReceiveId] = t.ReceiveId
            )
        FROM MAS_Service_ReceiveEntry t
        WHERE t.ReceiveId = @ReceiveId;


        INSERT INTO [dbo].MAS_Service_Receipts
        (
            [ReceiptNo],
            [ReceiptDt],
            [CustId],
            [ApartmentId],
            [ReceiveId],
            [TranferCd],
            [Object],
            [Pass_No],
            [Pass_dt],
            [Pass_Plc],
            [Address],
            [Contents],
            [Attach],
            [IsDBCR],
            [Amount],
            [CreatorCd],
            [CreateDate],
            --,[AccountLeft]
            --,[AccountRight]
            [ProjectCd]
        )
        SELECT 'H' + RIGHT('000' + CAST(DATEPART(ms, GETDATE()) AS VARCHAR), 3)
               + CAST(DATEDIFF(ss, '2018-01-01', GETUTCDATE()) AS VARCHAR),
               GETDATE(),
               t1.CustId,
               ISNULL(t1.ApartmentId, 0),
               @ReceiveId,
               'Cash',
               c.FullName,
               c.Pass_No,
               c.Pass_Dt,
               c.Pass_Plc,
               c.[Address],
               @Remart,
               '',
               1,
               @Amount,
               @UserId,
               GETDATE(),
               --,@AccountLeft
               --,@AccountRight
               t1.ProjectCd
        FROM MAS_CardVehicle t1
            LEFT JOIN MAS_Customers c
                ON t1.CustId = c.CustId
        WHERE CardVehicleId = @CardVehicleId;
		--
		SET @valid = 1;
        SET @messages = N'Gia hạn thẻ thành công';
    END;
    ELSE
    BEGIN
        INSERT INTO [dbo].[MAS_CardVehicle_Pay]
        (
            [CardVehicleId],
            [PayDt],
            [empUserId],
            [Amount],
            [StartDt],
            [EndDt],
            [Remart]
        )
        SELECT @CardVehicleId,
               GETDATE(),
               @UserId,
               @Amount,
               CONVERT(DATE, @StartDate, 103),
               CONVERT(DATE, @EndDate, 103),
               @Remart
        FROM MAS_CardVehicle
        WHERE CardVehicleId = @CardVehicleId;

        UPDATE t1
        SET EndTime = @ToDt,
            lastReceivable = @ToDt,
            Auth_id = @UserId,
            Auth_Dt = GETDATE()
        FROM MAS_CardVehicle t1
        WHERE CardVehicleId = @CardVehicleId;
		--
		SET @valid = 1;
        SET @messages = N'Gia hạn thẻ thành công';
    END;
    FINAL:
    SELECT @valid valid,
           @messages AS [messages];

END TRY
BEGIN CATCH
    SELECT @messages AS [messages];
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_vehicle_paymentByDay_set' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '@userId' + @UserId;

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'vehicle_paymentByDay_set',
                          'Set',
                          @SessionID,
                          @AddlInfo;
END CATCH;