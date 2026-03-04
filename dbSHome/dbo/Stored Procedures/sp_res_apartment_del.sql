-- =============================================
-- Author:		Namhm
-- Create date: 16/05/2025
-- Description:	Xóa căn hộ
-- Updated: Hỗ trợ cả ApartmentId và Oid (backward compatible)
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_apartment_del]
  @UserId UNIQUEIDENTIFIER = NULL,
  @apartmentId INT = NULL, -- Backward compatible
  @Oid UNIQUEIDENTIFIER = NULL -- Ưu tiên sử dụng (GUID)
AS
BEGIN
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
    
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);
    DECLARE @ActualOid UNIQUEIDENTIFIER = NULL;
    DECLARE @ActualApartmentId INT = NULL;

    -- Xác định Oid từ ApartmentId nếu có (có kiểm tra tenant_oid)
    IF @apartmentId IS NOT NULL AND @Oid IS NULL
    BEGIN
        SELECT @ActualOid = oid, @ActualApartmentId = @apartmentId
        FROM MAS_Apartments
        WHERE ApartmentId = @apartmentId
          AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
    END
    ELSE IF @Oid IS NOT NULL
    BEGIN
        SELECT @ActualOid = @Oid, @ActualApartmentId = ApartmentId
        FROM MAS_Apartments
        WHERE oid = @Oid
          AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
    END

    -- Kiểm tra bản ghi tồn tại
    IF @ActualOid IS NULL OR NOT EXISTS(SELECT 1 FROM MAS_Apartments WHERE oid = @ActualOid)
    BEGIN
        SET @valid = 0;
        SET @messages = N'Không tìm thấy căn hộ';
        SELECT 
            @valid AS valid, 
            @messages AS [messages];
        RETURN;
    END

    -- =============================================
    -- KIỂM TRA CÁC BẢNG QUAN HỆ TRƯỚC KHI XÓA
    -- =============================================
    DECLARE @RelatedTables NVARCHAR(MAX) = N'';
    DECLARE @HasRelatedData BIT = 0;

    -- 1. Kiểm tra MAS_Apartment_Member (Thành viên căn hộ)
    IF EXISTS(SELECT 1 FROM MAS_Apartment_Member WHERE (apartOid = @ActualOid OR ApartmentId = @ActualApartmentId))
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Thành viên căn hộ; ';
    END

    -- 2. Kiểm tra MAS_Apartment_Card (Thẻ căn hộ)
    IF EXISTS(SELECT 1 FROM MAS_Apartment_Card WHERE apartOid = @ActualOid)
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Thẻ căn hộ; ';
    END

    -- 3. Kiểm tra MAS_Customer_Household (Hộ gia đình)
    IF EXISTS(SELECT 1 FROM MAS_Customer_Household WHERE apartOid = @ActualOid)
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Hộ gia đình; ';
    END

    -- 4. Kiểm tra MAS_Requests (Yêu cầu)
    IF EXISTS(SELECT 1 FROM MAS_Requests WHERE (apartOid = @ActualOid OR apartmentId = @ActualApartmentId))
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Yêu cầu; ';
    END

    -- 5. Kiểm tra MAS_Feedbacks (Phản ánh)
    IF EXISTS(SELECT 1 FROM MAS_Feedbacks WHERE (apartOid = @ActualOid OR ApartmentId = @ActualApartmentId))
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Phản ánh; ';
    END

    -- 6. Kiểm tra MAS_Service_ReceiveEntry (Phiếu thu dịch vụ)
    IF EXISTS(SELECT 1 FROM MAS_Service_ReceiveEntry WHERE (apartOid = @ActualOid OR ApartmentId = @ActualApartmentId))
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Phiếu thu dịch vụ; ';
    END

    -- 7. Kiểm tra MAS_Apartment_Profile (Hồ sơ căn hộ)
    IF EXISTS(SELECT 1 FROM MAS_Apartment_Profile WHERE (apartOid = @ActualOid OR ApartmentId = @ActualApartmentId))
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Hồ sơ căn hộ; ';
    END

    -- 8. Kiểm tra MAS_Apartment_Service_Living (Dịch vụ sinh hoạt)
    IF EXISTS(SELECT 1 FROM MAS_Apartment_Service_Living WHERE (apartOid = @ActualOid OR ApartmentId = @ActualApartmentId))
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Dịch vụ sinh hoạt; ';
    END

    -- 9. Kiểm tra MAS_CardVehicle (Thẻ xe)
    IF EXISTS(SELECT 1 FROM MAS_CardVehicle WHERE ApartmentId = @ActualApartmentId)
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Thẻ xe; ';
    END

    -- 10. Kiểm tra MAS_Apartment_Violation (Lịch sử vi phạm)
    IF EXISTS(SELECT 1 FROM MAS_Apartment_Violation WHERE (apartOid = @ActualOid OR ApartmentId = @ActualApartmentId))
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Lịch sử vi phạm; ';
    END

    -- 11. Kiểm tra MAS_Apartment_Service_Extend (Dịch vụ mở rộng)
    IF EXISTS(SELECT 1 FROM MAS_Apartment_Service_Extend WHERE ApartmentId = @ActualApartmentId)
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Dịch vụ mở rộng; ';
    END

    -- 12. Kiểm tra MAS_Service_Cut_History (Lịch sử cắt dịch vụ)
    IF EXISTS(SELECT 1 FROM MAS_Service_Cut_History WHERE (apartOid = @ActualOid OR ApartmentId = @ActualApartmentId))
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Lịch sử cắt dịch vụ; ';
    END

    -- 13. Kiểm tra MAS_Apartment_HostChange_History (Lịch sử đổi chủ hộ)
    IF EXISTS(SELECT 1 FROM MAS_Apartment_HostChange_History WHERE (apartOid = @ActualOid OR ApartmentId = @ActualApartmentId))
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Lịch sử đổi chủ hộ; ';
    END

    -- 14. Kiểm tra MAS_Cards (Thẻ)
    IF EXISTS(SELECT 1 FROM MAS_Cards WHERE (apartOid = @ActualOid OR ApartmentId = @ActualApartmentId))
    BEGIN
        SET @HasRelatedData = 1;
        SET @RelatedTables = @RelatedTables + N'Thẻ; ';
    END

    -- Nếu có dữ liệu liên quan, không cho phép xóa
    IF @HasRelatedData = 1
    BEGIN
        SET @valid = 0;
        SET @messages = N'Không thể xóa căn hộ vì đã tồn tại dữ liệu liên quan: ' + LEFT(@RelatedTables, LEN(@RelatedTables) - 2);
        SELECT 
            @valid AS valid, 
            @messages AS [messages];
        RETURN;
    END

    -- =============================================
    -- THỰC HIỆN XÓA (có kiểm tra tenant_oid)
    -- =============================================
    DELETE FROM [dbo].[MAS_Apartments]
    WHERE oid = @ActualOid
      AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);

    SET @valid = 1;
    SET @messages = N'Xóa thành công';

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_del ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';
    
    SET @valid = 0;
    SET @messages = ERROR_MESSAGE();
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Apartments', N'DEL', @SessionID, @AddlInfo;
END CATCH

    -- =============================================
    -- RESULT - Trả về kết quả
    -- =============================================
    SELECT 
        @valid AS valid, 
        @messages AS [messages];
END