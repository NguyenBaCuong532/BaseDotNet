-- =============================================
-- Author:		System
-- Create date: 2025-01-29
-- Description:	Tạo/Cập nhật bảng MAS_Apartments
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[sp_res_apartment_set]
     @userId         UNIQUEIDENTIFIER = NULL
    ,@acceptLanguage NVARCHAR(50) = N'vi-VN'
    ,@oid            UNIQUEIDENTIFIER = NULL
    ,@ApartmentId   INT = NULL -- Backward compatible
    ,@WaterwayArea   FLOAT = NULL
AS
BEGIN
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
                N'Người dùng không có quyền truy cập' AS [messages],
                NULL AS id,
                N'ERROR' AS action;
            RETURN;
        END
    END
    
    -- Khai báo biến
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);
    DECLARE @action NVARCHAR(20);
    DECLARE @ActualOid UNIQUEIDENTIFIER = NULL;
    DECLARE @ActualApartmentId INT = NULL;

    -- =============================================
    -- VALIDATION - Kiểm tra dữ liệu đầu vào
    -- =============================================
    
    -- Xác định Oid từ ApartmentId nếu có (có kiểm tra tenant_oid)
    IF @ApartmentId IS NOT NULL AND @oid IS NULL
    BEGIN
        SELECT @ActualOid = oid, @ActualApartmentId = @ApartmentId
        FROM MAS_Apartments
        WHERE ApartmentId = @ApartmentId
          AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
    END
    ELSE IF @oid IS NOT NULL
    BEGIN
        SELECT @ActualOid = @oid, @ActualApartmentId = ApartmentId
        FROM MAS_Apartments
        WHERE oid = @oid
          AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
    END
    
    -- Kiểm tra INSERT hay UPDATE
    IF @ActualOid IS NOT NULL AND EXISTS (SELECT 1 FROM MAS_Apartments WHERE oid = @ActualOid)
    BEGIN
        -- =============================================
        -- UPDATE - Cập nhật bản ghi
        -- =============================================
        SET @action = N'UPDATE';
        
        -- Kiểm tra tenant_oid trước khi UPDATE
        IF NOT EXISTS(SELECT 1 FROM MAS_Apartments WHERE oid = @ActualOid AND (@tenantOid IS NULL OR tenant_oid = @tenantOid))
        BEGIN
            SET @valid = 0;
            SET @messages = N'Không có quyền cập nhật căn hộ này';
            SET @action = N'PERMISSION_DENIED';
            SELECT 
                @valid AS valid, 
                @messages AS [messages],
                @ActualOid AS id,
                @action AS action;
            RETURN;
        END
        
        -- Thực hiện UPDATE
        UPDATE MAS_Apartments
        SET WaterwayArea = @WaterwayArea
        WHERE oid = @ActualOid
          AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);

        SET @valid = 1;
        SET @messages = N'Cập nhật thành công';
    END
    ELSE
    BEGIN
        -- =============================================
        -- INSERT - Thêm mới bản ghi (không hỗ trợ trong procedure này)
        -- =============================================
        SET @valid = 0;
        SET @messages = N'Không tìm thấy căn hộ';
        SET @action = N'NOT_FOUND';
    END

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = N'';
    
    SET @valid = 0;
    SET @messages = ERROR_MESSAGE();
    SET @action = N'ERROR';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Apartments', N'SET', @SessionID, @AddlInfo;
END CATCH

    -- =============================================
    -- RESULT - Trả về kết quả
    -- =============================================
    SELECT 
        @valid AS valid, 
        @messages AS [messages],
        @ActualOid AS id,
        @action AS action;
END