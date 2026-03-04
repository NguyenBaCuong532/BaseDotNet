CREATE   PROCEDURE [dbo].[sp_res_apartment_profile_set]
    @UserID UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN',
    @Id NVARCHAR(50) = NULL,
    @Oid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID) - apartOid của MAS_Apartments
    @ApartmentId INT = NULL, -- Backward compatible
    @Name nvarchar(2000) = NULL,
    @AttackFile NVARCHAR(1000) = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- =============================================
    -- LẤY TENANT_OID TỪ USERS
    -- =============================================
    DECLARE @tenantOid UNIQUEIDENTIFIER = NULL;
    
    IF @UserID IS NOT NULL
    BEGIN
        SELECT @tenantOid = tenant_oid
        FROM Users
        WHERE userId = @UserID;
        
        -- Kiểm tra user có tenant_oid không
        IF @tenantOid IS NULL
        BEGIN
            SELECT 
                0 AS valid,
                N'Người dùng không có quyền truy cập' AS [messages];
            RETURN;
        END
    END

    DECLARE @valid BIT = 0,
            @messages NVARCHAR(250) = N'Có lỗi xảy ra';
    DECLARE @ActualOid UNIQUEIDENTIFIER = NULL;
    DECLARE @ActualApartmentId INT = NULL;

    -- Xác định ActualOid và ActualApartmentId từ Oid hoặc ApartmentId (có kiểm tra tenant_oid)
    IF @Oid IS NOT NULL
    BEGIN
        SELECT @ActualOid = @Oid, @ActualApartmentId = a.ApartmentId
        FROM MAS_Apartments a
        WHERE a.oid = @Oid
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END
    ELSE IF @ApartmentId IS NOT NULL
    BEGIN
        SELECT @ActualOid = a.oid, @ActualApartmentId = @ApartmentId
        FROM MAS_Apartments a
        WHERE a.ApartmentId = @ApartmentId
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END

    -- Kiểm tra căn hộ tồn tại
    IF @ActualOid IS NULL AND @ActualApartmentId IS NULL
    BEGIN
        SET @valid = 0;
        SET @messages = N'Không tìm thấy căn hộ hoặc không có quyền truy cập';
        SELECT @valid AS valid, @messages AS [messages];
        RETURN;
    END

    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM MAS_Apartment_Profile a
            INNER JOIN MAS_Apartments ap ON (a.ApartmentId = ap.ApartmentId OR a.apartOid = ap.oid)
            WHERE a.id = @id
              AND (@tenantOid IS NULL OR ap.tenant_oid = @tenantOid)
        )
        BEGIN		
            INSERT INTO [dbo].[MAS_Apartment_Profile]
            (
                Id,
                ApartmentId,
                apartOid,
                Name,
                AttackFile,
                RegDt
            )
            VALUES
            (
                ISNULL(@Id, NEWID()),
                @ActualApartmentId,
                @ActualOid,
                @Name,
                @AttackFile,
                GETDATE()
            );
            SET @valid = 1;
            SET @messages = N'Thêm mới thành công';
        END;
        ELSE
        BEGIN
            -- Kiểm tra quyền trước khi UPDATE
            IF NOT EXISTS(
                SELECT 1
                FROM MAS_Apartment_Profile a
                INNER JOIN MAS_Apartments ap ON (a.ApartmentId = ap.ApartmentId OR a.apartOid = ap.oid)
                WHERE a.Id = @Id
                  AND (@tenantOid IS NULL OR ap.tenant_oid = @tenantOid)
            )
            BEGIN
                SET @valid = 0;
                SET @messages = N'Không có quyền cập nhật hồ sơ căn hộ này';
                SELECT @valid AS valid, @messages AS [messages];
                RETURN;
            END

            UPDATE [dbo].[MAS_Apartment_Profile]
            SET ApartmentId = @ActualApartmentId,
                apartOid = @ActualOid,
                Name = @Name,
                AttackFile = @AttackFile
            WHERE Id = @Id
              AND (@tenantOid IS NULL OR EXISTS(
                  SELECT 1 FROM MAS_Apartments ap 
                  WHERE (ap.ApartmentId = @ActualApartmentId OR ap.oid = @ActualOid)
                    AND ap.tenant_oid = @tenantOid
              ));
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
    SET @ErrorMsg = 'sp_res_apartment_profile_set' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'MAS_Apartment_Profile',
                          'Set',
                          @SessionID,
                          @AddlInfo;
END CATCH;