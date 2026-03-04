
CREATE PROCEDURE [dbo].[sp_res_card_base_info_set] @userId NVARCHAR(50)
    , @id VARCHAR(50)
    , @projectCd VARCHAR(50)
    , @type INT
AS
BEGIN
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(200);

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM MAS_CardBase
                WHERE Guid_Cd = @id
                )
        BEGIN
            SET @messages = N'Không tìm thấy thông tin thẻ'

            GOTO FINAL;
        END

        UPDATE MAS_CardBase
        SET [Type] = @type
        WHERE Guid_Cd = @id

        --
        SET @valid = 1
        SET @messages = N'Cập nhật thành công'

        FINAL:

        SELECT @valid valid
            , @messages AS [messages];
    END TRY

    BEGIN CATCH
        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_card_set ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo = '';

        EXEC utl_Insert_ErrorLog @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'Card'
            , 'Insert'
            , @SessionID
            , @AddlInfo;

        SET @valid = 0;
        SET @messages = ERROR_MESSAGE();
    END CATCH;

    SELECT @valid AS valid
        , @messages AS [messages];
END;