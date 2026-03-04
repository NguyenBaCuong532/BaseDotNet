

-- =============================================
-- Author: ANHTT
-- Create date: 2025-10-02
-- Description: Xóa yêu cầu dịch vụ
-- =============================================
CREATE   procedure [dbo].[sp_app_service_request_del] 
	  @userId uniqueidentifier
    , @id UNIQUEIDENTIFIER
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);
    DECLARE @status INT = NULL

    -- =============================================
    -- VALIDATION - Kiểm tra dữ liệu đầu vào
    -- =============================================
    SELECT @status = ISNULL([status], 0)
    FROM service_request
    WHERE id = @id

    -- Kiểm tra bản ghi tồn tại
    IF @status IS NULL
    BEGIN
        SET @messages = N'Bản ghi không tìm thấy';

        SELECT @valid AS valid
            , @messages AS [messages]
            , @id AS id
            , N'NOT_FOUND' AS action;

        RETURN;
    END

    -- =============================================
    -- DELETE - Thực hiện xóa
    -- =============================================
    -- Thực hiện xóa nếu chưa chuyển trạng thái
    IF @status = 0
    BEGIN
        BEGIN TRAN

        DELETE
        FROM service_request_extra
        WHERE service_request_id = @id

        --
        DELETE
        FROM service_request
        WHERE [id] = @id;

        COMMIT
    END
    IF @status = 1
    BEGIN
        UPDATE service_request
        SET delete_dt = GETDATE()
            , delete_by = @userId
        WHERE id = @id
    END
    SET @valid = 1;
    SET @messages = N'Xóa thành công';

    -- =============================================
    -- RESULT - Trả về kết quả
    -- =============================================
    SELECT @valid AS valid
        , @messages AS [messages]
        , @id AS id
        , N'DELETE' AS action;
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = N', @id: ' + ISNULL(CAST(@id AS NVARCHAR(50)), N'NULL');

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , N'service_request'
        , N'DEL'
        , @SessionID
        , @AddlInfo;

    -- Trả về lỗi
    SELECT 0 AS valid
        , N'Lỗi: ' + ERROR_MESSAGE() AS [messages]
        , @id AS id
        , N'ERROR' AS action;
END CATCH