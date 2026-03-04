CREATE PROCEDURE [dbo].[sp_res_apartment_service_living_set]
    @UserID NVARCHAR(450),
    @ApartmentId BIGINT,
    @LivingId BIGINT,
    @LivingType INT,
    @ContractNo NVARCHAR(50),
    @ContractDate NVARCHAR(10),
    @MeterSerial NVARCHAR(50),
    @MeterNumber BIGINT,
    @StartDate NVARCHAR(10),
    @EmployeeCd NVARCHAR(50),
    @DeliverName NVARCHAR(100),
    @CustId NVARCHAR(50),
    --@CustName NVARCHAR(100),
    @CustPhone NVARCHAR(20),
    @Note NVARCHAR(200),
    @ProviderCd NVARCHAR(50),
    @NumPersonWater INT
AS
BEGIN TRY

    DECLARE @valid BIT = 0,
            @messages NVARCHAR(250) = N'Có lỗi xảy ra';

	IF @LivingId IS NULL
	SET @LivingId = 0
    BEGIN
        DECLARE @ProjectCd NVARCHAR(30);
        SET @ProjectCd =
        (
            SELECT a.projectCd
            FROM MAS_Apartments a
            WHERE a.ApartmentId = @ApartmentId
        );
        IF NOT EXISTS
        (
            SELECT LivingId
            FROM MAS_Apartment_Service_Living a
                JOIN MAS_Apartments b
                    ON a.ApartmentId = b.ApartmentId
            WHERE LivingId = @LivingId
        )
        BEGIN
			-- comment bởi Triều Dương: đối với khách hàng có nhiều căn hộ thi hoàn toàn tạo mới dịch vụ điện nước > 2
            --IF EXISTS(SELECT TOP 1 1 FROM MAS_Apartment_Service_Living WHERE CustId = @CustId AND LivingTypeId = @LivingType)
            --BEGIN
            --    DECLARE @type_name NVARCHAR(100)
            --    SELECT @type_name = LOWER(LivingTypeName) FROM MAS_LivingTypes WHERE LivingTypeId = @LivingType
            --    SET @messages = N'Hợp đồng ' + @type_name + N'đã tồn tại'
            --    GOTO FINAL;
            --END
            INSERT INTO [dbo].[MAS_Apartment_Service_Living]
            (
                [LivingTypeId],
                [ProjectCd],
                [ProviderCd],
                [ApartmentId],
                [ContractNo],
                [ContractDt],
                [EmployeeCd],
                [DeliverName],
                [CustId],
                --[CustName],
                [CustPhone],
                [Note],
                [MeterSeri],
                [MeterDate],
                [MeterNum],
                MeterLastDt,
                MeterLastNum,
                [sysDate],
                NumPersonWater
            )
            VALUES
            (@LivingType, @ProjectCd, @ProviderCd, @ApartmentId, @ContractNo, CONVERT(DATETIME, @ContractDate, 103),
             @EmployeeCd, @DeliverName, @CustId, --@CustName, 
			 @CustPhone, @Note, @MeterSerial,
             CONVERT(DATETIME, @StartDate, 103), @MeterNumber, CONVERT(DATETIME, @StartDate, 103), @MeterNumber,
             GETDATE(), @NumPersonWater);
            -- 
            SET @valid = 1;
            SET @messages = N'Thêm mới thành công';
        END;
        ELSE
        BEGIN
            UPDATE [dbo].[MAS_Apartment_Service_Living]
            SET [LivingTypeId] = @LivingType,
                [ProjectCd] = @ProjectCd,
                [ProviderCd] = @ProviderCd,
                [ApartmentId] = @ApartmentId,
                [ContractNo] = @ContractNo,
                [ContractDt] = CONVERT(DATETIME, @ContractDate, 103),
                [EmployeeCd] = @EmployeeCd,
                [DeliverName] = @DeliverName,
                [CustId] = @CustId,
                --[CustName] = @CustName,
                [CustPhone] = @CustPhone,
                [Note] = @Note,
                [MeterSeri] = @MeterSerial,
                [MeterDate] = CONVERT(DATETIME, @StartDate, 103),
                [MeterNum] = @MeterNumber,
                MeterLastDt = CONVERT(DATETIME, @StartDate, 103),
                MeterLastNum = @MeterNumber,
                NumPersonWater = @NumPersonWater
            WHERE LivingId = @LivingId;
            -- 
            SET @valid = 1;
            SET @messages = N'Cập nhật thành công';
        END;

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
    SET @ErrorMsg = 'sp_res_apartment_service_living_set' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '@userId' + @UserID;

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'vehicle_paymentByDay_set',
                          'Set',
                          @SessionID,
                          @AddlInfo;
END CATCH;