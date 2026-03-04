CREATE   procedure [dbo].[sp_res_apartment_household_field] 
    @CustId NVARCHAR(450) = NULL,
    @ApartmentId INT = NULL, -- Backward compatible
    @Oid UNIQUEIDENTIFIER = NULL, -- Oid của MAS_Customer_Household
    @apartOid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID) của MAS_Apartments
    @UserId UNIQUEIDENTIFIER = NULL,
    @AcceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

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

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'apartment_household';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        CustId = @CustId,
        ApartmentId = @ActualApartmentId,
        apartOid = @ActualApartOid,
        Oid = @Oid,
        tableKey = @tableKey, 
        groupKey = @groupKey;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@groupKey, @AcceptLanguage)
    ORDER BY intOrder;

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu field với columnValue động
    -- =============================================
    
    -- Tạo temp table để lưu dữ liệu với các JOIN cần thiết
    IF OBJECT_ID(N'tempdb..#tempIn') IS NOT NULL 
        DROP TABLE #tempIn;

    -- Tạo temp table để lưu dữ liệu
    IF OBJECT_ID(N'tempdb..#tempIn') IS NOT NULL
        DROP TABLE #tempIn;

    SELECT TOP 0
        CustId,
        FullName,
        Phone,
        Email,
        AvatarUrl,
        birthday,
        ResAdd1,
        ContactAdd1,
        PassNo,
        PassPlace,
        PassDate,
        IsResident,
        sysDate,
        ApartmentId,
        apartOid,
        Oid
    INTO #tempIn
    FROM (
        SELECT TOP 1
            a.CustId,
            a.[FullName],
            a.[Phone],
            a.[Email],
            a.[AvatarUrl],
            a.birthday,
            b.[ResAdd1],
            b.[ContactAdd1],
            b.[Pass_No] AS PassNo,
            b.[Pass_I_Plc] AS PassPlace,
            b.[Pass_I_Dt] AS PassDate,
            b.IsResident,
            b.sysDate,
            c.ApartmentId,
            ap.oid as apartOid,
            b.oid as Oid
        FROM [MAS_Customers] a 
            LEFT JOIN [MAS_Customer_Household] b ON a.CustId = b.CustId 
                AND (@ActualApartmentId IS NULL OR b.ApartmentId = @ActualApartmentId)
                AND (@Oid IS NULL OR b.oid = @Oid)
            JOIN MAS_Apartment_Member c ON a.CustId = c.CustId 
            JOIN MAS_Apartments ap ON c.ApartmentId = ap.ApartmentId
        WHERE a.CustId = @CustId
          AND (@ActualApartmentId IS NULL OR c.ApartmentId = @ActualApartmentId)
          AND (@tenantOid IS NULL OR ap.tenant_oid = @tenantOid)
        ORDER BY b.sysDate DESC
    ) src;
    
    -- Insert dữ liệu vào #tempIn
    INSERT INTO #tempIn
    SELECT TOP 1
        a.CustId,
        a.[FullName],
        a.[Phone],
        a.[Email],
        a.[AvatarUrl],
        a.birthday,
        b.[ResAdd1],
        b.[ContactAdd1],
        b.[Pass_No] AS PassNo,
        b.[Pass_I_Plc] AS PassPlace,
        b.[Pass_I_Dt] AS PassDate,
        b.IsResident,
        b.sysDate,
        c.ApartmentId,
        ap.oid as apartOid,
        b.oid as Oid
    FROM [MAS_Customers] a 
        LEFT JOIN [MAS_Customer_Household] b ON a.CustId = b.CustId 
            AND (@ActualApartmentId IS NULL OR b.ApartmentId = @ActualApartmentId)
            AND (@Oid IS NULL OR b.oid = @Oid)
        JOIN MAS_Apartment_Member c ON a.CustId = c.CustId 
        JOIN MAS_Apartments ap ON c.ApartmentId = ap.ApartmentId
    WHERE a.CustId = @CustId
      AND (@ActualApartmentId IS NULL OR c.ApartmentId = @ActualApartmentId)
      AND (@tenantOid IS NULL OR ap.tenant_oid = @tenantOid)
    ORDER BY b.sysDate DESC;

    IF NOT EXISTS(SELECT 1 FROM #tempIn)
    BEGIN
        -- Insert một row NULL để CROSS JOIN hoạt động
        INSERT INTO #tempIn (CustId, FullName, Phone, Email, AvatarUrl, birthday, ResAdd1, ContactAdd1, PassNo, PassPlace, PassDate, IsResident, sysDate, ApartmentId, apartOid, Oid)
        VALUES (@CustId, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @ActualApartmentId, @ActualApartOid, NULL);
    END
    

    -- Trả về dữ liệu field với columnValue được format
    SELECT
          s.id
        , s.table_name
        , s.field_name
        , s.view_type
        , s.data_type
        , s.ordinal
        , s.columnLabel
        , s.group_cd
        , columnValue = ISNULL(
            CASE s.field_name
                WHEN 'Oid' THEN LOWER(CONVERT(NVARCHAR(100), b.Oid))
                WHEN 'apartOid' THEN LOWER(CONVERT(NVARCHAR(100), b.apartOid))
                WHEN 'CustId' THEN b.CustId
                WHEN 'FullName' THEN b.[FullName]
                WHEN 'Phone' THEN b.[Phone]
                WHEN 'Email' THEN b.[Email]
                WHEN 'AvatarUrl' THEN b.[AvatarUrl]
                WHEN 'ResAdd1' THEN b.[ResAdd1]
                WHEN 'ContactAdd1' THEN b.[ContactAdd1]
                WHEN 'PassNo' THEN b.PassNo
                WHEN 'PassPlace' THEN b.PassPlace
                WHEN 'birthday' THEN CONVERT(NVARCHAR(10), b.birthday, 103)
                WHEN 'PassDate' THEN CONVERT(NVARCHAR(10), b.PassDate, 103)
                WHEN 'ApartmentId' THEN CAST(ISNULL(b.ApartmentId, 0) AS NVARCHAR(50))
                WHEN 'IsResident' THEN CAST(ISNULL(b.IsResident, 0) AS NVARCHAR(50))
            END,
            s.columnDefault
        )
        , s.columnClass
        , s.columnType
        , s.columnObject
        , s.isSpecial
        , s.isRequire
        , s.isDisable
        , s.IsVisiable
        , s.isEmpty
        , columnTooltip = ISNULL(s.columnTooltip, s.columnLabel)
        , s.columnDisplay
        , s.isIgnore
    FROM dbo.fn_config_form_gets(@tableKey, @AcceptLanguage) s
    CROSS JOIN #tempIn b
    WHERE s.table_name = @tableKey
      AND (s.IsVisiable = 1 OR s.isRequire = 1)
    ORDER BY s.ordinal;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_household_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_household',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;