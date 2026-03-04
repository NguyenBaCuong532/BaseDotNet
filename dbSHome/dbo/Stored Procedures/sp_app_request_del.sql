

-- =============================================
-- Author: duongpx
-- Create date: 2025-09-18 08:26:36
-- Description: Xóa bản ghi từ bảng MAS_Requests
-- =============================================
CREATE   procedure [dbo].[sp_app_request_del]
    @userId uniqueidentifier,
    @Oid UNIQUEIDENTIFIER,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    -- Khai báo biến
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);

    -- =============================================
    -- VALIDATION - Kiểm tra dữ liệu đầu vào
    -- =============================================
    
    -- Kiểm tra bản ghi tồn tại
    IF NOT EXISTS(SELECT 1 FROM MAS_Requests WHERE Oid = @Oid)
    BEGIN
        SET @messages = N'Bản ghi không tìm thấy';
        SELECT 
            @valid AS valid, 
            @messages AS [messages],
            @Oid AS id,
            N'NOT_FOUND' AS action;
        RETURN;
    END

    -- =============================================
    -- DELETE - Thực hiện xóa
    -- =============================================
    
    -- Thực hiện xóa
    DELETE FROM MAS_Requests 
    WHERE Oid = @Oid;

    SET @valid = 1;
    SET @messages = N'Xóa thành công';

    -- =============================================
    -- RESULT - Trả về kết quả
    -- =============================================
    SELECT 
        @valid AS valid, 
        @messages AS [messages],
        @Oid AS id,
        N'DELETE' AS action;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'@Userid: ' 
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Requests', N'DEL', @SessionID, @AddlInfo;
    
    -- Trả về lỗi
    SELECT 
        0 AS valid, 
        N'Lỗi: ' + ERROR_MESSAGE() AS [messages],
        @Oid AS id,
        N'ERROR' AS action;
END CATCH