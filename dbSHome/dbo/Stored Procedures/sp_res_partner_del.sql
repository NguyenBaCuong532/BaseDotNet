CREATE   PROCEDURE [dbo].[sp_res_partner_del]
    @userId NVARCHAR(450),
    @partner_id INT
AS
BEGIN TRY
    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM MAS_CardPartner WHERE partner_id = @partner_id)
    BEGIN
        SET @valid = 0;
        SET @messages = N'Không tìm thấy thông [' + CAST(@partner_id AS NVARCHAR(20)) + N']!';
    END
    ELSE IF EXISTS (SELECT 1 FROM MAS_Cards WHERE partner_id = @partner_id)
    BEGIN
        SET @valid = 0;
        SET @messages = N'Đang được sử dụng, không thể xóa!';
    END
    ELSE
    BEGIN
        DELETE FROM MAS_CardPartner WHERE partner_id = @partner_id;
        SET @valid = 1;
        SET @messages = N'Xóa đối tác thành công';
    END

    SELECT @valid AS valid, @messages AS [messages];
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_partner_del ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Partner', 'DEL', @SessionID, @AddlInfo;

    SELECT CAST(0 AS BIT) AS valid, N'Lỗi hệ thống' AS [messages];
END CATCH