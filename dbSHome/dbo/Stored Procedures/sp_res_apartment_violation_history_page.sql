CREATE OR ALTER PROCEDURE [dbo].[sp_res_apartment_violation_history_page]
    @userId UNIQUEIDENTIFIER,
    @acceptLanguage NVARCHAR(50) = N'vi-VN',
    @filter NVARCHAR(30) = NULL,
    @apartOid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID) - apartOid của MAS_Apartments
    @ApartmentId INT = NULL, -- Backward compatible
    @gridWidth int = 0,
    @Offset INT = 0,
    @PageSize INT = 10
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- =============================================
    -- LẤY TENANT_OID TỪ USERS
    -- =============================================
    DECLARE @tenantOid UNIQUEIDENTIFIER = NULL;
    
    IF @userId IS NOT NULL
    BEGIN
        SELECT @tenantOid = tenant_oid
        FROM Users
        WHERE userId = @userId;
    END

    declare @Total		bigint
    declare @GridKey	nvarchar(100) = 'view_apartment_violation_page'
    DECLARE @ActualOid UNIQUEIDENTIFIER = NULL;
    DECLARE @ActualApartmentId INT = NULL;

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

    -- Xác định ActualOid và ActualApartmentId từ apartOid hoặc ApartmentId (có kiểm tra tenant_oid)
    IF @apartOid IS NOT NULL
    BEGIN
        SELECT @ActualOid = @apartOid, @ActualApartmentId = a.ApartmentId
        FROM MAS_Apartments a
        WHERE a.oid = @apartOid
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END
    ELSE IF @ApartmentId IS NOT NULL AND @ApartmentId > 0
    BEGIN
        SELECT @ActualOid = a.oid, @ActualApartmentId = @ApartmentId
        FROM MAS_Apartments a
        WHERE a.ApartmentId = @ApartmentId
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END
    ELSE
    BEGIN
        -- Lấy từ UserInfo nếu không có
        SELECT TOP 1 @ActualOid = c.oid, @ActualApartmentId = c.ApartmentId
        FROM UserInfo a 
        INNER JOIN MAS_Apartments c ON a.loginName = c.UserLogin
        WHERE a.UserId = @userId
          AND (@tenantOid IS NULL OR c.tenant_oid = @tenantOid);
    END

    IF @PageSize = 0 SET @PageSize = 10;
    IF @Offset < 0 SET @Offset = 0;

    SELECT @Total = COUNT(1)
    FROM MAS_Apartment_Violation a
         JOIN MAS_Apartments b ON (a.ApartmentId = b.ApartmentId OR a.apartOid = b.oid)
    WHERE ((@ActualOid IS NOT NULL AND (a.apartOid = @ActualOid OR b.oid = @ActualOid))
        OR (@ActualApartmentId IS NOT NULL AND a.ApartmentId = @ActualApartmentId))
      AND (@tenantOid IS NULL OR b.tenant_oid = @tenantOid)

    --root	
    select recordsTotal = @Total
          ,recordsFiltered = @Total
          ,gridKey = @GridKey
          ,valid = 1
          
    --grid config
    IF @Offset = 0
        SELECT * FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage) ORDER BY [ordinal];

    -- Data
    SELECT
    a.*,
	(
    SELECT COUNT(1)
    FROM meta_info m2
    WHERE m2.sourceOid = a.AttackFile
	) AS AttackFile
    FROM MAS_Apartment_Violation a
         JOIN MAS_Apartments b ON (a.ApartmentId = b.ApartmentId OR a.apartOid = b.oid)
    WHERE ((@ActualOid IS NOT NULL AND (a.apartOid = @ActualOid OR b.oid = @ActualOid))
        OR (@ActualApartmentId IS NOT NULL AND a.ApartmentId = @ActualApartmentId))
      AND (@tenantOid IS NULL OR b.tenant_oid = @tenantOid)
    ORDER BY a.RegDt OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_violation_page' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'MAS_Apartment_Violation',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;