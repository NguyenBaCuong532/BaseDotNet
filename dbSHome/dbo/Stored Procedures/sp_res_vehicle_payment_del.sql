
-- =============================================
-- Author: duongpx
-- Create date: 2025-09-12 17:49:55
-- Description: Xóa bản ghi từ bảng MAS_CardVehicle_Pay
-- =============================================
CREATE   PROCEDURE [sp_res_vehicle_payment_del]
    @userId NVARCHAR(50),
    @id int,
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
    IF NOT EXISTS(SELECT 1 FROM MAS_CardVehicle_Pay WHERE [PayId] = @id)
    BEGIN
        SET @messages = N'Bản ghi không tìm thấy';
        SELECT 
            @valid AS valid, 
            @messages AS [messages],
            @id AS id,
            N'NOT_FOUND' AS action;
        RETURN;
    END

    -- =============================================
    -- DELETE - Thực hiện xóa
    -- =============================================
    
    -- Thực hiện xóa
    DELETE FROM MAS_CardVehicle_Pay 
    WHERE [PayId] = @id;

    SET @valid = 1;
    SET @messages = N'Xóa thành công';

    -- =============================================
    -- RESULT - Trả về kết quả
    -- =============================================
    SELECT 
        @valid AS valid, 
        @messages AS [messages],
        @id AS id,
        N'DELETE' AS action;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'@Userid: ' + ISNULL(CAST(@userId AS NVARCHAR(50)),N'NULL') + N', @id: ' + ISNULL(CAST(@id AS NVARCHAR(50)), N'NULL');
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_CardVehicle_Pay', N'DEL', @SessionID, @AddlInfo;
    
    -- Trả về lỗi
    SELECT 
        0 AS valid, 
        N'Lỗi: ' + ERROR_MESSAGE() AS [messages],
        @id AS id,
        N'ERROR' AS action;
END CATCH