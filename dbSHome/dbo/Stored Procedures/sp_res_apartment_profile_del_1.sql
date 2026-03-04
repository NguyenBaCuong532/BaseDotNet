CREATE   PROCEDURE [dbo].[sp_res_apartment_profile_del]
    @userId UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN',
    @id nvarchar(50)
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
        
        -- Kiểm tra user có tenant_oid không
        IF @tenantOid IS NULL
        BEGIN
            SELECT 
                0 AS valid,
                N'Người dùng không có quyền truy cập' AS [messages];
            RETURN;
        END
    END

    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(200) = N'Có lỗi xảy ra';

    -- Kiểm tra hồ sơ tồn tại và thuộc tenant của user (có kiểm tra tenant_oid)
    IF EXISTS
    (
        SELECT 1
        FROM MAS_Apartment_Profile p
        INNER JOIN MAS_Apartments a ON (p.ApartmentId = a.ApartmentId OR p.apartOid = a.oid)
        WHERE p.id = @id
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid)
    )
	BEGIN
	    DELETE p
        FROM MAS_Apartment_Profile p
        INNER JOIN MAS_Apartments a ON (p.ApartmentId = a.ApartmentId OR p.apartOid = a.oid)
        WHERE p.id = @id
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
		--
		SET @valid = 1;
        SET @messages = N'Xóa thành công';
	END  
    ELSE
    BEGIN
        SET @valid = 0;
        SET @messages = N'Không tìm thấy hồ sơ hoặc không có quyền truy cập';
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
    SET @ErrorMsg = 'sp_res_apartment_profile_del' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'MAS_Apartment_Profile',
                             'DEL',
                             @SessionID,
                             @AddlInfo;
END CATCH;