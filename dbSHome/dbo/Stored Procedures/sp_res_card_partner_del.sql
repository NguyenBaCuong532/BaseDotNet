
CREATE PROCEDURE [dbo].[sp_res_card_partner_del] @userId NVARCHAR(450)
    , @partner_id INT
AS
BEGIN TRY
    DECLARE @valid BIT = 1
    DECLARE @messages NVARCHAR(100) = ''

    IF NOT EXISTS (
            SELECT partner_id
            FROM MAS_CardPartner
            WHERE partner_id = @partner_id
            )
    BEGIN
        SET @Valid = 0
        SET @Messages = N'Không tìm thấy thông [' + @partner_id + N']!'
    END
    ELSE IF EXISTS (
            SELECT CardId
            FROM MAS_Cards
            WHERE partner_id = @partner_id
            )
    BEGIN
        SET @Valid = 0
        SET @Messages = N'Đang được sử dụng, không thẻ xóa!'
    END
    ELSE
    BEGIN
        DELETE
        FROM MAS_CardPartner
        WHERE partner_id = @partner_id

        SET @valid = 1
        SET @messages = N'Xóa loại thẻ thành công'
    END

    SELECT @valid AS valid
        , @messages AS [messages]
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_card_partner_del' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ''

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'CardPartner'
        , 'DEL'
        , @SessionID
        , @AddlInfo
END CATCH