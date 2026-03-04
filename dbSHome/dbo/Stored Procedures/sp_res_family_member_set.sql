
CREATE PROCEDURE [dbo].[sp_res_family_member_set]
    @UserId UNIQUEIDENTIFIER = NULL,
    @CustId NVARCHAR(50) = NULL,
    @FullName NVARCHAR(250) = NULL,
    @Phone NVARCHAR(30) = NULL,
    @Email NVARCHAR(150) = NULL,
    @AvatarUrl NVARCHAR(250) = NULL,
    @Birthday NVARCHAR(10) = NULL,
    @IsSex BIT = 0,
    @ApartmentId INT = NULL, -- Backward compatible
    @apartOid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID)
    @Oid UNIQUEIDENTIFIER = NULL, -- Oid của MAS_Apartment_Member (nếu UPDATE)
    @RelationId INT = 0,
    @IsForeign BIT = 0,
    @IsNotification BIT = 0,
    @CountryCd NVARCHAR(50) = 'VN',
    @cifNo NVARCHAR(50) = NULL,
    @Id NVARCHAR(50) = NULL,
    @EffectiveDate NVARCHAR(50) = NULL,
    @note NVARCHAR(MAX) = NULL,
    @householdHead NVARCHAR(150) = NULL,
    @EffectiveDateEnd NVARCHAR(50) = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
    SET NOCOUNT ON;

    -- =============================================
    -- LẤY TENANT_OID TỪ USERS
    -- =============================================
    DECLARE @tenantOid UNIQUEIDENTIFIER = NULL;
    
    IF @UserId IS NOT NULL
    BEGIN
        SELECT @tenantOid = tenant_oid
        FROM Users
        WHERE userId = @UserId;
        
        -- Kiểm tra user có tenant_oid không
        IF @tenantOid IS NULL
        BEGIN
            SELECT 
                0 AS valid,
                N'Người dùng không có quyền truy cập' AS [messages];
            RETURN;
        END
    END

    -- =============================================
    -- XÁC ĐỊNH ACTUAL APARTMENT ID VÀ OID
    -- =============================================
    DECLARE @ActualApartmentId INT = NULL;
    DECLARE @ActualApartOid UNIQUEIDENTIFIER = NULL;
    
    IF @apartOid IS NOT NULL
    BEGIN
        SELECT @ActualApartmentId = a.ApartmentId, @ActualApartOid = a.oid
        FROM MAS_Apartments a
        WHERE a.oid = @apartOid
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END
    ELSE IF @ApartmentId IS NOT NULL
    BEGIN
        SELECT @ActualApartmentId = a.ApartmentId, @ActualApartOid = a.oid
        FROM MAS_Apartments a
        WHERE a.ApartmentId = @ApartmentId
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END

    -- Kiểm tra căn hộ tồn tại
    IF @ActualApartmentId IS NULL
    BEGIN
        SELECT 
            0 AS valid,
            N'Không tìm thấy căn hộ hoặc không có quyền truy cập' AS [messages];
        RETURN;
    END

    DECLARE @valid BIT = 1,
            @messages NVARCHAR(250),
            @CategoryCd NVARCHAR(50),
            @BirthdayDt DATETIME = NULL,
            @EffectiveDt DATETIME = NULL,
            @EffectiveDtEnd DATETIME = NULL,
            @UserLoginForHistory NVARCHAR(100),
            @IsNew BIT = 0;

    BEGIN TRY
        BEGIN TRAN Apartment_Family_Member_Set;

        SET @IsForeign = ISNULL(@IsForeign, 0);

        -- Chuẩn hóa ngày
        IF ISNULL(@Birthday,'') <> ''
            SET @BirthdayDt = CONVERT(DATETIME, @Birthday, 103);

        IF ISNULL(@EffectiveDate,'') <> ''
            SET @EffectiveDt = CONVERT(DATETIME, @EffectiveDate, 103);
        ELSE
            SET @EffectiveDt = GETDATE();

        IF ISNULL(@EffectiveDateEnd,'') <> ''
            SET @EffectiveDtEnd = CONVERT(DATETIME, @EffectiveDateEnd, 103);

        -- Kiểm tra quyền admin
        IF dbo.[fn_Hom_User_admin](@UserId) <> 1
        BEGIN
            SET @valid = 0;
            SET @messages = N'Bạn không có quyền tạo, sửa thành viên';
            SELECT @valid AS valid, @messages AS [messages];
            RETURN;
        END

        -- Lấy projectCd
        SET @CategoryCd = (
            SELECT c.projectCd
            FROM MAS_Apartments c
            WHERE c.ApartmentId = @ActualApartmentId
        );

        -- ====== THÊM THÀNH VIÊN MỚI ======
        IF ISNULL(LTRIM(RTRIM(@CustId)),'') = ''
        BEGIN
            SET @IsNew = 1;   -- Đánh dấu thêm mới

            -- Thử lấy CustId từ Phone nếu có
            IF ISNULL(LTRIM(RTRIM(@Phone)),'') <> ''
            BEGIN
                SELECT TOP 1 @CustId = CustId
                FROM MAS_Customers
                WHERE Phone = @Phone;
                
                -- Nếu tìm thấy CustId từ Phone, cập nhật thông tin
                IF ISNULL(LTRIM(RTRIM(@CustId)),'') <> ''
                BEGIN
                    UPDATE MAS_Customers
                    SET FullName = ISNULL(@FullName, FullName),
                        Phone = ISNULL(@Phone, Phone),
                        Email = ISNULL(@Email, Email),
                        AvatarUrl = ISNULL(@AvatarUrl, AvatarUrl),
                        IsSex = ISNULL(@IsSex, IsSex),
                        Birthday = CASE WHEN @BirthdayDt IS NOT NULL THEN @BirthdayDt ELSE Birthday END,
                        IsForeign = ISNULL(@IsForeign, IsForeign),
                        CountryCd = ISNULL(@CountryCd, CountryCd)
                    WHERE CustId = @CustId;
                END
            END

            -- Nếu vẫn không có → tạo mới
            IF ISNULL(LTRIM(RTRIM(@CustId)),'') = ''
            BEGIN
                SET @CustId = NEWID();

                INSERT INTO MAS_Customers (
                    FullName, Phone, Email, ApartmentId,
                    AvatarUrl, IsSex, Birthday, sysDate,
                    IsForeign, CustId, CountryCd
                )
                VALUES (
                    @FullName,
                    CASE WHEN ISNULL(LTRIM(RTRIM(@Phone)),'')='' THEN NULL ELSE @Phone END,
                    @Email, @ActualApartmentId,
                    @AvatarUrl, @IsSex, @BirthdayDt, GETDATE(),
                    @IsForeign, @CustId, @CountryCd
                );
            END
        END

        -- ====== THÊM HOẶC CẬP NHẬT MEMBER ======
        DECLARE @MemberOid UNIQUEIDENTIFIER = NULL;
        DECLARE @IsUpdate BIT = 0;
        
        -- Ưu tiên sử dụng @Oid nếu được truyền vào (Primary Key)
        IF @Oid IS NOT NULL
        BEGIN
            -- Kiểm tra @Oid có tồn tại trong DB và thuộc tenant của user không
            SELECT @MemberOid = m.Oid
            FROM MAS_Apartment_Member m
            INNER JOIN MAS_Apartments a ON m.ApartmentId = a.ApartmentId
            WHERE m.Oid = @Oid
              --AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
            
            IF @MemberOid IS NOT NULL
            BEGIN
                SET @IsUpdate = 1; -- Đánh dấu là UPDATE
            END
            ELSE
            BEGIN
                -- @Oid được truyền vào nhưng không tồn tại hoặc không thuộc tenant
                SET @valid = 0;
                SET @messages = N'Không tìm thấy thành viên với Oid được cung cấp hoặc không có quyền truy cập';
                SELECT @valid AS valid, @messages AS [messages];
                ROLLBACK TRAN Apartment_Family_Member_Set;
                RETURN;
            END
        END
        -- Nếu không có @Oid, tìm từ CustId + ApartmentId (backward compatible)
        ELSE IF @CustId IS NOT NULL AND @ActualApartmentId IS NOT NULL
        BEGIN
            SELECT @MemberOid = m.Oid
            FROM MAS_Apartment_Member m
            INNER JOIN MAS_Apartments a ON m.ApartmentId = a.ApartmentId
            WHERE m.CustId = @CustId AND m.ApartmentId = @ActualApartmentId
              AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
            
            IF @MemberOid IS NOT NULL
            BEGIN
                SET @IsUpdate = 1; -- Đánh dấu là UPDATE
            END
        END

        IF @MemberOid IS NULL
        BEGIN
            -- THÊM MỚI THÀNH VIÊN
            -- Nếu @Oid được truyền vào nhưng không tồn tại, sử dụng nó (cho phép tạo mới với Oid cụ thể)
            IF @Oid IS NOT NULL
            BEGIN
                SET @MemberOid = @Oid;
            END
            ELSE
            BEGIN
                SET @MemberOid = NEWID();
            END
            
            INSERT INTO MAS_Apartment_Member (
                Oid, ApartmentId, apartOid, tenant_oid, CustId, RegDt, approveDt,
                RelationId, isNotification, memberUserId, member_st
            )
            VALUES (
                @MemberOid, @ActualApartmentId, @ActualApartOid, @tenantOid, @CustId, GETDATE(), @EffectiveDt,
                @RelationId, @IsNotification, @UserId, 1
            );

            SET @IsNew = 1;
            SET @messages = N'Thêm mới thành viên thành công';
        END
        ELSE
        BEGIN
            -- CẬP NHẬT THÀNH VIÊN ĐÃ CÓ (sử dụng @MemberOid làm Primary Key)
            UPDATE MAS_Apartment_Member
            SET RelationId = @RelationId,
                isNotification = @IsNotification,
                memberUserId = @UserId,
                apartOid = ISNULL(@ActualApartOid, apartOid),
                tenant_oid = ISNULL(@tenantOid, tenant_oid),
                approveDt = CASE WHEN ISNULL(@EffectiveDate,'')<>'' 
                                 THEN CONVERT(DATETIME,@EffectiveDate,103) 
                                 ELSE approveDt END
            WHERE Oid = @MemberOid;

            SET @IsNew = 0;
            SET @messages = N'Cập nhật thông tin thành viên thành công';
        END

            UPDATE MAS_Customers
            SET FullName = ISNULL(@FullName, FullName),
                Phone = ISNULL(@Phone, Phone),
                Email = ISNULL(@Email, Email),
                AvatarUrl = ISNULL(@AvatarUrl, AvatarUrl),
                IsSex = ISNULL(@IsSex, IsSex),
                Birthday = CASE WHEN @Birthday IS NULL 
                                THEN Birthday ELSE CONVERT(DATETIME,@Birthday,103) END,
                IsForeign = @IsForeign,
                CountryCd = @CountryCd
            WHERE CustId = @CustId;

        -- ====== GHI LỊCH SỬ VÀO MAS_Apartment_Member_H ======
        SELECT TOP 1 @UserLoginForHistory = loginName 
        FROM UserInfo WHERE userId = @UserId;

        -- Lấy đầy đủ thông tin từ MAS_Customers để lưu vào lịch sử
        -- Ưu tiên giá trị từ tham số, nếu không có mới lấy từ database
        DECLARE @CustFullName NVARCHAR(200) = NULL;
        DECLARE @CustPhone NVARCHAR(50) = NULL;
        DECLARE @CustEmail NVARCHAR(150) = NULL;
        DECLARE @CustBirthday DATETIME = NULL;
        DECLARE @CustIsSex BIT = NULL;
        DECLARE @CustCountryCd NVARCHAR(50) = NULL;
        DECLARE @RelationName NVARCHAR(100) = NULL;
        DECLARE @HostFullNameAtTime NVARCHAR(200) = NULL;
        DECLARE @MemberSt INT = NULL; -- Trạng thái thành viên

        -- Lấy thông tin từ database
        SELECT TOP 1
               @CustFullName = FullName,
               @CustPhone = Phone,
               @CustEmail = Email,
               @CustBirthday = Birthday,
               @CustIsSex = IsSex,
               @CustCountryCd = CountryCd
        FROM MAS_Customers WITH (NOLOCK)
        WHERE CustId = @CustId;

        -- Lấy trạng thái thành viên từ MAS_Apartment_Member
        SELECT TOP 1 @MemberSt = member_st
        FROM MAS_Apartment_Member WITH (NOLOCK)
        WHERE Oid = @MemberOid;

        -- Ưu tiên giá trị từ tham số nếu có
        IF @FullName IS NOT NULL AND LEN(LTRIM(RTRIM(@FullName))) > 0
            SET @CustFullName = @FullName;
        IF @Phone IS NOT NULL AND LEN(LTRIM(RTRIM(@Phone))) > 0
            SET @CustPhone = @Phone;
        IF @Email IS NOT NULL AND LEN(LTRIM(RTRIM(@Email))) > 0
            SET @CustEmail = @Email;
        IF @BirthdayDt IS NOT NULL
            SET @CustBirthday = @BirthdayDt;
        IF @IsSex IS NOT NULL
            SET @CustIsSex = @IsSex;
        IF @CountryCd IS NOT NULL AND LEN(LTRIM(RTRIM(@CountryCd))) > 0
            SET @CustCountryCd = @CountryCd;

        -- Lấy RelationName từ RelationId
        IF @RelationId IS NOT NULL AND @RelationId <> 0
        BEGIN
            SELECT TOP 1 @RelationName = RelationName
            FROM MAS_Customer_Relation WITH (NOLOCK)
            WHERE RelationId = @RelationId;
        END

        -- Lấy tên chủ hộ hiện tại của căn hộ
        SELECT TOP 1 @HostFullNameAtTime = c.FullName
        FROM MAS_Apartment_Member am WITH (NOLOCK)
        LEFT JOIN MAS_Customers c WITH (NOLOCK) ON c.CustId = am.CustId
        WHERE am.ApartmentId = @ActualApartmentId
          AND am.RelationId = 0
        ORDER BY ISNULL(am.approveDt, am.RegDt) DESC;

        -- Luôn INSERT mới bản ghi lịch sử (không UPDATE bản ghi cũ)
        -- Để đảm bảo có đầy đủ lịch sử thay đổi
        INSERT INTO [dbo].[MAS_Apartment_Member_H]
            ([Oid],[ApartmentId],[CustId],[OldCustId],[NewCustId],
             [FullName],[Phone],[Email],[Birthday],[IsSex],[Gender],
             [RelationId],[RelationName],[IsOwner],[IsForeign],[IsForeigner],[CountryCd],[Nationality],
             [HostFullName],
             [ApproveDt],[ApproveDtEnd],[ContractDate],[EffectiveDate],[ExpiredDate],
             [member_st],[Note],[UserLogin],[PerformedByUserId],[PerformedAt],[CreatedBy],[CreatedDate],[IsNotification])
        VALUES
            (NEWID(),
             @ActualApartmentId,
             @CustId,
             CASE WHEN @IsNew = 1 THEN NULL ELSE @CustId END, -- OldCustId
             @CustId, -- NewCustId
             @CustFullName, -- FullName
             @CustPhone, -- Phone
             @CustEmail, -- Email
             @CustBirthday, -- Birthday
             @CustIsSex, -- IsSex
             CASE WHEN @CustIsSex = 1 THEN 1 WHEN @CustIsSex = 0 THEN 0 ELSE NULL END, -- Gender
             CASE WHEN @RelationId = 0 THEN NULL ELSE @RelationId END, -- RelationId
             @RelationName, -- RelationName
             CASE WHEN @RelationId = 0 THEN 1 ELSE 0 END, -- IsOwner
             @IsForeign, -- IsForeign
             @IsForeign, -- IsForeigner
             @CustCountryCd, -- CountryCd
             @CustCountryCd, -- Nationality
             @HostFullNameAtTime, -- HostFullName
             @EffectiveDt, -- ApproveDt
             @EffectiveDtEnd, -- ApproveDtEnd
             CAST(@EffectiveDt AS DATE), -- ContractDate
             CAST(@EffectiveDt AS DATE), -- EffectiveDate
             CAST(@EffectiveDtEnd AS DATE), -- ExpiredDate
             ISNULL(@MemberSt, 1), -- member_st: trạng thái duyệt (mặc định = 1)
             CASE WHEN @IsNew = 1 THEN ISNULL(@note, N'Thêm mới thành viên')
                  ELSE ISNULL(@note, N'Cập nhật thông tin thành viên') END, -- Note
             @UserLoginForHistory, -- UserLogin
             @UserId, -- PerformedByUserId
             GETDATE(), -- PerformedAt
             @UserId, -- CreatedBy
             GETDATE(), -- CreatedDate
             @IsNotification); -- IsNotification

        SET @valid = 1;

        COMMIT TRAN Apartment_Family_Member_Set;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN Apartment_Family_Member_Set;

        DECLARE @ErrorNum INT,
                @ErrorMsg VARCHAR(200),
                @ErrorProc VARCHAR(50),
                @SessionID INT,
                @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_family_member_set ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo = '';

        EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'FamilyMember', 'SET', @SessionID, @AddlInfo;

        SET @valid = 0;
        SET @messages = @ErrorMsg;
    END CATCH;

    SELECT @valid AS valid, @messages AS [messages];
END