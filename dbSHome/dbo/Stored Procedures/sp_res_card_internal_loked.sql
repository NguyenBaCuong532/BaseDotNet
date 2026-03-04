
CREATE PROCEDURE [dbo].[sp_res_card_internal_loked]
    @UserID NVARCHAR(450) = NULL,
    @cardId NVARCHAR(50),
    @Status INT = 1,
    @cardOid UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    IF @cardOid IS NOT NULL
        SET @cardId = (SELECT CardCd FROM MAS_Cards WHERE oid = @cardOid);

    DECLARE @valid BIT = 0, @messages NVARCHAR(250);
    SET @Status = ISNULL(@Status, 1);

    IF @Status = 1
    BEGIN
        UPDATE t1 SET Card_St = 3, CloseDate = GETDATE(), CloseBy = @UserID
        FROM MAS_Cards t1 WHERE t1.CardCd = @cardId;
        UPDATE t1 SET [Status] = 2
        FROM [MAS_Requests] t1 INNER JOIN MAS_Cards t2 ON t1.RequestId = t2.RequestId WHERE t2.CardCd = @cardId;
        UPDATE t1 SET [Status] = 3, locked_dt = GETDATE()
        FROM MAS_CardVehicle t1 INNER JOIN MAS_Cards t2 ON t1.CardId = t2.CardId WHERE t2.CardCd = @cardId;
        SET @valid = 1;
        SET @messages = N'Khóa thẻ thành công';
    END
    ELSE
    BEGIN
        UPDATE t1 SET Card_St = 1 FROM MAS_Cards t1 WHERE t1.CardCd = @cardId;
        UPDATE t1 SET [Status] = 1 FROM [MAS_Requests] t1 INNER JOIN MAS_Cards t2 ON t1.RequestId = t2.RequestId WHERE t2.CardCd = @cardId;
        UPDATE t1 SET [Status] = 1, locked_dt = NULL FROM MAS_CardVehicle t1 INNER JOIN MAS_Cards t2 ON t1.CardId = t2.CardId WHERE t2.CardCd = @cardId;
        SET @valid = 1;
        SET @messages = N'Mở thẻ thành công';
    END;

    SELECT @valid AS valid, @messages AS [messages];
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_internal_loked' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'CardInternal', 'SET', @SessionID, @AddlInfo;
END CATCH;
