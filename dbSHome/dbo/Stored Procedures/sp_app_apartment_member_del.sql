

-- =============================================
-- Author: duongpx
-- Create date: 2025-09-18 09:14:34
-- Description: Xóa bản ghi từ bảng MAS_Apartment_Member
-- Updated: Hỗ trợ ApartmentId và Oid (backward compatible)
-- =============================================
CREATE   procedure [dbo].[sp_app_apartment_member_del]
    @userId uniqueidentifier,
    @id int = NULL,  -- Backward compatible (ApartmentId)
    @Oid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (apartOid)
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);

    -- Cần ít nhất một trong hai: @id hoặc @Oid
    IF @id IS NULL AND @Oid IS NULL
    BEGIN
        SET @messages = N'Cần truyền ApartmentId hoặc Oid';
        SELECT @valid AS valid, @messages AS [messages], @id AS id, N'INVALID' AS action;
        RETURN;
    END

    -- Kiểm tra bản ghi tồn tại
    IF NOT EXISTS(SELECT 1 FROM MAS_Apartment_Member WHERE ([ApartmentId] = @id AND @id IS NOT NULL) OR (@Oid IS NOT NULL AND apartOid = @Oid))
    BEGIN
        SET @messages = N'Bản ghi không tìm thấy';
        SELECT 
            @valid AS valid, 
            @messages AS [messages],
            @id AS id,
            N'NOT_FOUND' AS action;
        RETURN;
    END

    -- Thực hiện xóa
    DELETE FROM MAS_Apartment_Member 
    WHERE ([ApartmentId] = @id AND @id IS NOT NULL) OR (@Oid IS NOT NULL AND apartOid = @Oid);

    SET @valid = 1;
    SET @messages = N'Xóa thành công';

    SELECT 
        @valid AS valid, 
        @messages AS [messages],
        @id AS id,
        @Oid AS apartOid,
        N'DELETE' AS action;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N', @id: ' + ISNULL(CAST(@id AS NVARCHAR(50)), N'NULL');
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Apartment_Member', N'DEL', @SessionID, @AddlInfo;
    
    -- Trả về lỗi
    SELECT 
        0 AS valid, 
        N'Lỗi: ' + ERROR_MESSAGE() AS [messages],
        @id AS id,
        N'ERROR' AS action;
END CATCH