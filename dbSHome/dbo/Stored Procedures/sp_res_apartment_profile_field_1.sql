CREATE   PROCEDURE [dbo].[sp_res_apartment_profile_field]
    @UserId UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN',
    @Oid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID) - apartOid của MAS_Apartments
    @ApartmentId INT = NULL, -- Backward compatible
    @Id NVARCHAR(50) = NULL
AS
BEGIN TRY
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
                Id = NULL,
                ApartmentId = NULL,
                apartOid = NULL,
                tableKey = N'apartment_profile',
                groupKey = N'common_group';
            RETURN;
        END
    END

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'apartment_profile';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';
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

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        Id = @Id,
        ApartmentId = @ActualApartmentId,
        apartOid = @ActualOid,
        tableKey = @tableKey, 
        groupKey = @groupKey;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
    ORDER BY intOrder;

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu field với columnValue động
    -- =============================================
    
    -- =============================================
    -- TẠO DỮ LIỆU #tempIn TRƯỚC
    -- =============================================
    -- Tạo temp table để lưu dữ liệu
    IF OBJECT_ID(N'tempdb..#tempIn') IS NOT NULL 
        DROP TABLE #tempIn;

    SELECT TOP 0 *
    INTO #tempIn
    FROM MAS_Apartment_Profile;

    -- Lấy dữ liệu nếu có (có kiểm tra tenant_oid thông qua MAS_Apartments)
    IF @Id IS NOT NULL
    BEGIN
        INSERT INTO #tempIn
        SELECT p.*
        FROM MAS_Apartment_Profile p
        INNER JOIN MAS_Apartments a ON (p.ApartmentId = a.ApartmentId OR p.apartOid = a.oid)
        WHERE p.Id = @Id
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END

    -- Nếu không có dữ liệu, tạo record mới
    IF NOT EXISTS (SELECT 1 FROM #tempIn)
    BEGIN
        INSERT INTO #tempIn (Id, ApartmentId, apartOid) 
        VALUES (ISNULL(@Id, NEWID()), @ActualApartmentId, @ActualOid);
    END

    -- Trả về dữ liệu field với columnValue được format
    SELECT
          a.id
        , a.table_name
        , a.field_name
        , a.view_type
        , a.data_type
        , a.ordinal
        , a.columnLabel
        , a.group_cd
        , columnValue = ISNULL(
            CASE a.field_name
                WHEN 'Id' THEN CONVERT(NVARCHAR(50), b.Id)
                WHEN 'Name' THEN b.Name
                WHEN 'AttackFile' THEN b.AttackFile
                WHEN 'ApartmentId' THEN CAST(ISNULL(b.ApartmentId, @ActualApartmentId) AS VARCHAR(50))
                WHEN 'apartOid' THEN LOWER(CONVERT(NVARCHAR(100), ISNULL(b.apartOid, @ActualOid)))
            END,
            a.columnDefault
        )
        , a.columnClass
        , a.columnType
        , columnObject = CASE
            WHEN a.field_name = 'AttackFile' THEN CONCAT(a.columnObject, b.AttackFile)
            ELSE a.columnObject
        END
        , a.isSpecial
        , a.isRequire
        , a.isDisable
        , a.IsVisiable
        , a.isEmpty
        , columnTooltip = ISNULL(a.columnTooltip, a.columnLabel)
        , a.columnDisplay
        , a.isIgnore
    FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
    CROSS JOIN #tempIn b
    WHERE a.table_name = @tableKey
      AND (a.IsVisiable = 1 OR a.isRequire = 1)
    ORDER BY a.ordinal;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_profile_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'MAS_Apartment_Profile',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;