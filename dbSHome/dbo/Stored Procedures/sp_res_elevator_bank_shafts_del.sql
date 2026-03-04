




CREATE   PROCEDURE [dbo].[sp_res_elevator_bank_shafts_del] 
	  @UserId UNIQUEIDENTIFIER = NULL
	, @id nvarchar(50),
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
    BEGIN TRY
        DECLARE @valid BIT = 0;
        DECLARE @messages NVARCHAR(250);
        
		IF EXISTS (
                SELECT TOP 1 1
                FROM MAS_Elevator_Card c
					join ELE_BankShaft b on c.CardRole = b.id
                WHERE b.id = @id
                )
        BEGIN
            SET @messages = N'Quyền đã được sử dụng. Không thể xóa'
            GOTO FINAL
        END

        --
        DELETE ELE_BankShaft
        WHERE id = @id

        SET @valid = 1
        SET @messages = N'Xóa Quyền thành công'

        --
        FINAL:

        SELECT valid = @valid
            , messages = @messages
    END TRY

    BEGIN CATCH
        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_card_base_del' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo = '';
        SET @valid = 0;
        SET @messages = ERROR_MESSAGE();

        EXEC utl_Insert_ErrorLog @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'MAS_C'
            , 'DEL'
            , @SessionID
            , @AddlInfo;
    END CATCH;

    SELECT @valid AS valid
        , @messages AS [messages];
END;