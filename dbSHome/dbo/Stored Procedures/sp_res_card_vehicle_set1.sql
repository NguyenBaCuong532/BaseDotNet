CREATE PROCEDURE [dbo].[sp_res_card_vehicle_set1]
    @UserID        nvarchar(450) = null,
    @CardVehicleId INT = 0,
    @ApartmentId   INT = null,
    @CustomersOid  nvarchar(50) = null,
    @AssignDate    nvarchar(50) = null,
    @AuthDate      nvarchar(50) = null,
    @AuthName      nvarchar(50) = null,
    @CardCd        nvarchar(50) = null,
    @VehicleTypeID int = null,
    @VehicleTypeName nvarchar(100) = null,
    @VehicleNo     nvarchar(30) = null,
    @VehicleName   nvarchar(100) = null,
    @ServiceId     int = 0,
    @ServiceName   nvarchar(100) = null,
    @StartTime     nvarchar(10) = null,
    @EndTime       nvarchar(10) = null,
    @Status        int = NULL,
    @VehicleCardStatusName nvarchar(50) = null,
    @VehicleStatusName nvarchar(50) = null,
    @projectCd     nvarchar(50) = null,
    @VehicleColor  nvarchar(50) = null,
    @RadioButton   bit = 0,
    @RadioButton1  bit = 0,
    @DueDate       nvarchar(50) = null,

    @ImageUrl      nvarchar(500) = NULL,
    @ImageUrl2     nvarchar(500) = NULL,
    @ImageUrl3     nvarchar(500) = NULL,
    @ImageUrl4     nvarchar(500) = NULL,
    @ImageUrl5     nvarchar(500) = NULL,

    @ImgHeader     nvarchar(500) = NULL,
    @GroupFileId   nvarchar(500) = NULL
AS
BEGIN
BEGIN TRY
    SET NOCOUNT ON;
    DECLARE @valid BIT = 0,
            @messages NVARCHAR(250) = N'Có lỗi xảy ra',
--          @apartmentId INT,
            @roomCode NVARCHAR(30),
            @CardTypeId INT,
            @CardId INT;

    IF @RadioButton IS NULL
        SET @DueDate = NULL;
      
    IF @VehicleTypeID IS NULL AND @VehicleTypeID <> 1
    BEGIN
        SET @valid = 0;
        SET @messages = N'Vui lòng chọn loại xe.';
        GOTO FINAL;
    END
    
    -- Kiểm tra và tự động lấy thông tin để gán thẻ cho căn hộ trước (nếu là xe cư dân)
    IF(@VehicleTypeID <> 1 AND NOT EXISTS(SELECT TOP 1 1 FROM MAS_Cards WHERE CardCd = @CardCd))
    BEGIN
        -- Kiểm tra thông tin thẻ có đang tồn tại hay không
        IF NOT EXISTS(SELECT TOP 1 1 FROM MAS_CardBase WHERE Code = @CardCd AND (ProjectCode IS NULL OR TRIM(ProjectCode) = '' OR ProjectCode = @projectCd) AND IsUsed <> 1)
        BEGIN
            SET @valid = 0;
            SET @messages = N'Không tìm thấy thông tin thẻ hoặc đã được sử dụng.';
            GOTO FINAL;
        END
        
        INSERT INTO MAS_Cards(ApartmentId, CardTypeId, CardCd, CustId, IsDaily, oid)
        VALUES(@apartmentId, 3, @CardCd, @CustomersOid, 0, NEWID());
        
        DECLARE @CardIdNew INT = (SELECT SCOPE_IDENTITY());
        
        INSERT INTO MAS_Apartment_Card(ApartmentId, CardId)
        VALUES(@apartmentId, @CardIdNew)
    END
    
    -- Lấy thông tin thẻ + CardId
    SELECT
        @apartmentId = c.ApartmentId,
        @roomCode = a.RoomCode,
        @CardTypeId = t2.CardTypeId,
        @CardId = t2.CardId
    FROM
        MAS_Cards t2
        JOIN MAS_Apartment_Card c ON t2.CardId = c.CardId
        JOIN MAS_Apartments a ON t2.ApartmentId = a.ApartmentId
    WHERE t2.CardCd = @CardCd;
    
    IF @CardId IS NULL AND @VehicleTypeID <> 1
    BEGIN
        SET @valid = 0;
        SET @messages = N'Không tìm thấy thông tin thẻ hoặc thẻ đã được sử dụng';
        GOTO FINAL;
    END

    SET @StartTime = ISNULL(@StartTime, CONVERT(NVARCHAR(10), GETDATE(), 103));

    IF @VehicleTypeID = 1
        SET @ServiceId = 5;
    ELSE
        SET @ServiceId = 6;
    
    SET @CardVehicleId = ISNULL(@CardVehicleId, 0);
    
    IF EXISTS(SELECT 1
              FROM dbo.MAS_CardVehicle cv
              WHERE cv.CardId = @CardId
                  AND cv.isVehicleNone = 0
                  AND cv.[Status] < 3
                  AND (@CardVehicleId = 0 OR cv.CardVehicleId <> @CardVehicleId))
    BEGIN
        SET @valid = 0;
        SET @messages = N'Thẻ này đã được gán cho một phương tiện khác (đang hoạt động)!';
        GOTO FINAL;
    END

    DECLARE @ImgTbl TABLE (Url NVARCHAR(600));

    INSERT INTO @ImgTbl(Url)
    SELECT @ImageUrl  WHERE ISNULL(@ImageUrl,'')  <> '' UNION ALL
    SELECT @ImageUrl2 WHERE ISNULL(@ImageUrl2,'') <> '' UNION ALL
    SELECT @ImageUrl3 WHERE ISNULL(@ImageUrl3,'') <> '' UNION ALL
    SELECT @ImageUrl4 WHERE ISNULL(@ImageUrl4,'') <> '' UNION ALL
    SELECT @ImageUrl5 WHERE ISNULL(@ImageUrl5,'') <> '';

    IF @CardVehicleId = 0
    BEGIN
        SET @Status = 0; -- thêm mới luôn 0

        -- Validate biển số
        IF EXISTS (
            SELECT 1
            FROM MAS_CardVehicle
            WHERE VehicleNo LIKE @VehicleNo
              AND [Status] < 3
              AND isVehicleNone = 0
              AND ProjectCd = @projectCd
        )
        BEGIN
            SET @valid = 0;
            SET @messages = N'Biển số xe trùng!';
            GOTO FINAL;
        END

        BEGIN TRAN;

        DECLARE @OutputTbl TABLE (ID INT);
        DECLARE @NewCardVehicleId INT;

        INSERT INTO dbo.MAS_CardVehicle
            (AssignDate, CardId, VehicleNo, VehicleTypeId, VehicleName, StartTime, Status, ServiceId, RequestId, isVehicleNone,
             monthlyType, CustId, Mkr_Id, Mkr_Dt, ApartmentId, VehicleNum, ProjectCd, VehicleColor, IsMonthlyScripts, DueDate,
             ImageUrl, ImageUrl2, ImageUrl3, ImageUrl4, ImageUrl5)
        OUTPUT INSERTED.CardVehicleId INTO @OutputTbl
        SELECT
            GETDATE(),
            @CardId,
            @VehicleNo,
            @VehicleTypeID,
            @VehicleName,
            CONVERT(DATETIME, @StartTime, 103),
            @Status,
            @ServiceId,
            0,
            0,
            CASE WHEN t2.CardTypeId = 2 THEN 0 ELSE CASE WHEN t2.CardTypeId = 1 THEN 1 ELSE 2 END END,
            t2.CustId,
            @UserID,
            GETDATE(),
            c.ApartmentId,
            ISNULL((SELECT COUNT(*) FROM MAS_CardVehicle WHERE ApartmentId = c.ApartmentId AND VehicleTypeId = @VehicleTypeID AND Status = 1), 0) + 1,
            @projectCd,
            @VehicleColor,
            @RadioButton,
            CASE WHEN @RadioButton = 1 THEN NULL ELSE @DueDate END,
            @ImageUrl, @ImageUrl2, @ImageUrl3, @ImageUrl4, @ImageUrl5
        FROM MAS_Cards t2
            LEFT JOIN MAS_Apartment_Card c ON t2.CardId = c.CardId
        WHERE t2.CardCd = @CardCd;

        SELECT TOP 1 @NewCardVehicleId = ID FROM @OutputTbl;
        
        DELETE FROM dbo.MAS_CardVehicle_Image
        WHERE CardVehicleId = @NewCardVehicleId;

        INSERT INTO dbo.MAS_CardVehicle_Image (CardVehicleId, ImageLink, ImageType, created)
        SELECT @NewCardVehicleId, Url, NULL, GETDATE()
        FROM @ImgTbl;

        IF NOT EXISTS (SELECT 1 FROM MAS_CardService WHERE ServiceId = @ServiceId AND CardCd = @CardCd)
        BEGIN
            INSERT INTO dbo.MAS_CardService ([CardId], CardCd, [ServiceId], [LinkDate], IsLock)
            SELECT CardId, CardCd, @ServiceId, GETDATE(), 0
            FROM MAS_Cards
            WHERE CardCd = @CardCd;
        END

        COMMIT;

        SET @valid = 1;
        SET @messages = N'Thêm mới thành công';
    END
      
        ELSE
        BEGIN
            BEGIN TRAN;

            UPDATE dbo.MAS_CardVehicle
            SET
                VehicleNo = @VehicleNo,
                VehicleTypeId = @VehicleTypeID,
                VehicleName = @VehicleName,
                StartTime = CONVERT(DATETIME, @StartTime, 103),
                Status = COALESCE(@Status, Status),
                ServiceId = @ServiceId,
                VehicleColor = @VehicleColor,
                IsMonthlyScripts = @RadioButton,
                DueDate = CASE WHEN @RadioButton = 1 THEN NULL ELSE @DueDate END,

                ImageUrl  = COALESCE(NULLIF(@ImageUrl , ''), ImageUrl),
                ImageUrl2 = COALESCE(NULLIF(@ImageUrl2, ''), ImageUrl2),
                ImageUrl3 = COALESCE(NULLIF(@ImageUrl3, ''), ImageUrl3),
                ImageUrl4 = COALESCE(NULLIF(@ImageUrl4, ''), ImageUrl4),
                ImageUrl5 = COALESCE(NULLIF(@ImageUrl5, ''), ImageUrl5),

                Edit_Id = @UserID,
                Edit_Dt = GETDATE()
            WHERE CardVehicleId = @CardVehicleId;

            DELETE FROM dbo.MAS_CardVehicle_Image
            WHERE CardVehicleId = @CardVehicleId;

            INSERT INTO dbo.MAS_CardVehicle_Image (CardVehicleId, ImageLink, ImageType, created)
            SELECT @CardVehicleId, v.Url, NULL, GETDATE()
            FROM (
                SELECT NULLIF(ImageUrl , '') AS Url
                FROM dbo.MAS_CardVehicle
                WHERE CardVehicleId = @CardVehicleId

                UNION ALL
                SELECT NULLIF(ImageUrl2, '')
                FROM dbo.MAS_CardVehicle
                WHERE CardVehicleId = @CardVehicleId

                UNION ALL
                SELECT NULLIF(ImageUrl3, '')
                FROM dbo.MAS_CardVehicle
                WHERE CardVehicleId = @CardVehicleId

                UNION ALL
                SELECT NULLIF(ImageUrl4, '')
                FROM dbo.MAS_CardVehicle
                WHERE CardVehicleId = @CardVehicleId

                UNION ALL
                SELECT NULLIF(ImageUrl5, '')
                FROM dbo.MAS_CardVehicle
                WHERE CardVehicleId = @CardVehicleId
            ) v
            WHERE v.Url IS NOT NULL;

            COMMIT;

            SET @valid = 1;
            SET @messages = N'Cập nhật thành công';
        END

FINAL:
        SELECT @valid AS valid, @messages AS [messages];
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        
        IF ERROR_NUMBER() IN (2601, 2627)
            SELECT 0 AS valid, N'Thẻ này đã được gán cho một phương tiện khác (đang hoạt động)!' AS [messages];
        ELSE
            SELECT 0 AS valid, ERROR_MESSAGE() AS [messages];
    END CATCH
END