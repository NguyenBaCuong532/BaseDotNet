

CREATE PROCEDURE [dbo].[sp_res_apartment_family_member_del]
    @UserId UNIQUEIDENTIFIER = NULL,
    @CustId NVARCHAR(50) = NULL, -- Backward compatible
    @apartmentId INT = NULL, -- Backward compatible
    @Oid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID) - Oid của MAS_Apartment_Member
    @apartOid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID) - apartOid của MAS_Apartments
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
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
                0 AS valid,
                N'Người dùng không có quyền truy cập' AS [messages];
            RETURN;
        END
    END

    -- =============================================
    -- XÁC ĐỊNH MEMBER OID
    -- =============================================
    DECLARE @MemberOid UNIQUEIDENTIFIER = NULL;
    DECLARE @ActualApartmentId INT = NULL;
    
    IF @Oid IS NOT NULL
    BEGIN
        SELECT @MemberOid = m.Oid, @ActualApartmentId = m.ApartmentId
        FROM MAS_Apartment_Member m
        INNER JOIN MAS_Apartments a ON m.ApartmentId = a.ApartmentId
        WHERE m.Oid = @Oid
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END
    ELSE IF @CustId IS NOT NULL AND @apartmentId IS NOT NULL
    BEGIN
        SELECT @MemberOid = m.Oid, @ActualApartmentId = m.ApartmentId
        FROM MAS_Apartment_Member m
        INNER JOIN MAS_Apartments a ON m.ApartmentId = a.ApartmentId
        WHERE m.CustId = @CustId AND m.ApartmentId = @apartmentId
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END
    ELSE IF @CustId IS NOT NULL AND @apartOid IS NOT NULL
    BEGIN
        SELECT @MemberOid = m.Oid, @ActualApartmentId = m.ApartmentId
        FROM MAS_Apartment_Member m
        INNER JOIN MAS_Apartments a ON m.apartOid = a.oid
        WHERE m.CustId = @CustId AND m.apartOid = @apartOid
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END

    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(100) = N'Có lỗi xảy ra';
    DECLARE @member_st INT;
    
    -- Kiểm tra bản ghi tồn tại và lấy trạng thái
    IF @MemberOid IS NULL
    BEGIN
        SET @valid = 0;
        SET @messages = N'Bản ghi không tìm thấy hoặc không có quyền truy cập';
        SELECT @valid AS valid,
               @messages AS [messages];
        RETURN;
    END
    
    SELECT @member_st = member_st
    FROM MAS_Apartment_Member
    WHERE Oid = @MemberOid;
    
    -- Kiểm tra trạng thái: chỉ cho phép xóa khi member_st = 0 (chờ duyệt)
    -- Nếu member_st là NULL hoặc != 0 thì không cho phép xóa
    IF @member_st IS NULL OR @member_st != 0
    BEGIN
        SET @valid = 0;
        SET @messages = N'Trạng thái đã duyệt không thể xóa';
        SELECT @valid AS valid,
               @messages AS [messages];
        RETURN;
    END
    
    -- Lấy CustId từ MemberOid nếu chưa có
    IF @CustId IS NULL
    BEGIN
        SELECT @CustId = CustId
        FROM MAS_Apartment_Member
        WHERE Oid = @MemberOid;
    END

	IF EXISTS
         (
             SELECT CustId
             FROM MAS_Cards a
             WHERE CustId = @CustId
                   AND a.Card_St < 3
                   AND a.ApartmentId = @ActualApartmentId
         )
         --   OR EXISTS duongvt trùng
         --(
         --    SELECT CustId
         --    FROM MAS_Cards a
         --    WHERE CustId = @CustId
         --          AND a.Card_St < 3
         --          AND ApartmentId = @apartmentId
         --)
    BEGIN
        SET @valid = 0;
        SET @messages = N'Thành viên là đang được cấp thẻ cần Khóa thẻ trước!';
    END
    ELSE
    BEGIN
        -- Xóa thành viên trực tiếp khỏi bảng (chỉ khi member_st = 0)
        DELETE FROM MAS_Apartment_Member
        WHERE Oid = @MemberOid
              AND member_st = 0;

		SET @valid = 1;
		SET @messages = N'Xóa thành công';	
    END;
		
    SELECT @valid AS valid,
           @messages AS [messages];

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_family_member_del' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = N'@UserId: ' + cast(@UserId as varchar(50)) + N', @CustId: ' + ISNULL(@CustId, N'NULL') + N', @apartmentId: ' + ISNULL(CAST(@apartmentId AS NVARCHAR(50)), N'NULL');

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'FamilyMember',
                          'DEL',
                          @SessionID,
                          @AddlInfo;
 
END CATCH;