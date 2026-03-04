CREATE PROCEDURE [dbo].[sp_res_apartment_household_set]
    @UserId UNIQUEIDENTIFIER,
    @CustId NVARCHAR(50),
    @IsResident BIT,
    @ResAdd1 NVARCHAR(250),
    @ContactAdd1 NVARCHAR(250),
    @PassNo NVARCHAR(50),
    @PassDate NVARCHAR(10),
    @PassPlace NVARCHAR(100),
    @ApartmentId INT = NULL, -- Backward compatible
    @Oid UNIQUEIDENTIFIER = NULL, -- Oid của MAS_Customer_Household (nếu UPDATE)
    @apartOid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID) của MAS_Apartments
	@acceptLanguage nvarchar(50) = 'vi-VN',
	@AvatarUrl nvarchar(250) = null,
	@birthday nvarchar = null,
	@Email nvarchar(250) = null,
	@FullName nvarchar(250) = null,
	@IsForeign int = null,
	@IsHost int = null,
	@IsSex int = null,
	@Phone nvarchar = null,
	@RelationId nvarchar = null
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @valid BIT = 0,
            @messages NVARCHAR(250) = N'';

    DECLARE @tenantOid UNIQUEIDENTIFIER = NULL;
    IF @UserId IS NOT NULL
    BEGIN
        SELECT @tenantOid = tenant_oid FROM Users WHERE userId = @UserId;
    END

    DECLARE @ActualApartmentId INT = NULL;
    DECLARE @ActualApartOid UNIQUEIDENTIFIER = NULL;

    -- Resolve @ActualApartmentId and @ActualApartOid
    IF @apartOid IS NOT NULL
    BEGIN
        SELECT @ActualApartmentId = ApartmentId, @ActualApartOid = oid
        FROM MAS_Apartments
        WHERE oid = @apartOid AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
    END
    ELSE IF @ApartmentId IS NOT NULL
    BEGIN
        SELECT @ActualApartmentId = ApartmentId, @ActualApartOid = oid
        FROM MAS_Apartments
        WHERE ApartmentId = @ApartmentId AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
    END

    IF @ActualApartmentId IS NULL
    BEGIN
        SET @valid = 0;
        SET @messages = N'Không tìm thấy căn hộ hoặc không có quyền truy cập.';
        SELECT @valid AS valid, @messages AS [messages];
        RETURN;
    END

    DECLARE @HouseholdOid UNIQUEIDENTIFIER = NULL;

    -- Ưu tiên tìm theo @Oid nếu được cung cấp
    IF @Oid IS NOT NULL
    BEGIN
        SELECT @HouseholdOid = h.oid
        FROM MAS_Customer_Household h
        INNER JOIN MAS_Apartments a ON h.ApartmentId = a.ApartmentId
        WHERE h.oid = @Oid
          AND h.CustId = @CustId
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END
    ELSE
    BEGIN
        -- Tìm theo CustId và ApartmentId
        SELECT @HouseholdOid = h.oid
        FROM MAS_Customer_Household h
        INNER JOIN MAS_Apartments a ON h.ApartmentId = a.ApartmentId
        WHERE h.CustId = @CustId
          AND h.ApartmentId = @ActualApartmentId
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END

    IF @HouseholdOid IS NULL
    BEGIN
        -- THÊM MỚI
        SET @HouseholdOid = NEWID();
        INSERT INTO [dbo].MAS_Customer_Household
        (
            oid,
            [ApartmentId],
            apartOid,
            tenant_oid,
            CustId,
            [IsResident],
            [ResAdd1],
            [ContactAdd1],
            [Pass_No],
            [Pass_I_Dt],
            [Pass_I_Plc],
            [sysDate]
        )
        VALUES
        (@HouseholdOid, @ActualApartmentId, @ActualApartOid, @tenantOid, @CustId, @IsResident, @ResAdd1, @ContactAdd1, @PassNo, CONVERT(DATETIME, @PassDate, 103),
         @PassPlace, GETDATE());
        --
        SET @valid = 1;
        SET @messages = N'Thêm mới thành công';
    END
    ELSE
    BEGIN
        -- CẬP NHẬT
        UPDATE t
        SET
            [IsResident] = @IsResident,
            [ResAdd1] = @ResAdd1,
            [ContactAdd1] = @ContactAdd1,
            [Pass_No] = @PassNo,
            [Pass_I_Dt] = CONVERT(DATETIME, @PassDate, 103),
            [Pass_I_Plc] = @PassPlace,
            apartOid = ISNULL(@ActualApartOid, apartOid),
            tenant_oid = ISNULL(@tenantOid, t.tenant_oid)
        FROM MAS_Customer_Household t
            INNER JOIN MAS_Apartments a ON t.ApartmentId = a.ApartmentId
        WHERE t.oid = @HouseholdOid
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
        --
        SET @valid = 1;
        SET @messages = N'Cập nhật thành công';
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
    SET @ErrorMsg = 'sp_res_apartment_household_set' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '@UserId: ' + ISNULL(CAST(@UserId AS NVARCHAR(50)), N'NULL');

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_household',
                          'Set',
                          @SessionID,
                          @AddlInfo;
END CATCH;