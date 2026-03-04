create PROCEDURE [dbo].[sp_res_card_classify_set] @userId NVARCHAR(450) = NULL
    , @id VARCHAR(50) = NULL
    ,@projectCode VARCHAR(50)
    ,@type INT
AS
BEGIN TRY
    --
    DECLARE @valid BIT
        ,@messages NVARCHAR(250)

    IF NOT EXISTS(SELECT 1 FROM MAS_CardBase WHERE Guid_Cd = @id)
    BEGIN
        SET @messages = N'Không tìm thấy bản ghi'
        GOTO FINAL
    END
    
    UPDATE MAS_CardBase
    SET ProjectCode = @projectCode
        ,[Type] = @type
    WHERE Guid_Cd = @id

    SET @valid = 1
    SET @messages = N'Phân loại thẻ thành công'

    FINAL:
        SELECT valid = @valid, messages = @messages
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_classify_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'Receipt'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;