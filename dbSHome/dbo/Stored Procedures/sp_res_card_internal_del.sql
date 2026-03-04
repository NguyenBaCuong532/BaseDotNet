
CREATE PROCEDURE [dbo].[sp_res_card_internal_del]
    @userId NVARCHAR(450) = NULL,
    @cardId NVARCHAR(50) = NULL,
    @cardOid UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    IF @cardOid IS NOT NULL
        SET @cardId = (SELECT CardCd FROM MAS_Cards WHERE oid = @cardOid);

    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(100) = N'';
    IF NOT EXISTS (SELECT CardId FROM MAS_Cards WHERE CardCd = @cardId)
    BEGIN
        SET @valid = 0;
        SET @messages = N'Không tìm thấy thông tin mã thẻ [' + ISNULL(@cardId, N'') + N']!';
    END;
    ELSE IF EXISTS (SELECT CardId FROM MAS_Cards WHERE CardCd = @cardId AND Card_St < 3)
    BEGIN
        SET @valid = 0;
        SET @messages = N'Số thẻ [' + @cardId + N'] đang được sử dụng, cần khóa trước khi xóa!';
    END;
    ELSE
    BEGIN
        DELETE a FROM MAS_CardVehicle a
        WHERE EXISTS (SELECT CardId FROM MAS_Cards WHERE CardCd = @cardId AND CardId = a.CardId AND Card_St >= 3);
        DELETE a FROM MAS_CardCredit a
        WHERE EXISTS (SELECT CardId FROM MAS_Cards WHERE CardCd = @cardId AND CardId = a.CardId AND Card_St >= 3);
        DELETE a FROM MAS_CardService a
        WHERE EXISTS (SELECT CardId FROM MAS_Cards WHERE CardCd = @cardId AND CardId = a.CardId AND Card_St >= 3);
        INSERT INTO [dbo].[MAS_Card_H] ([CardId],[CardCd],[CardTypeId],[ImageUrl],[IssueDate],[ExpireDate],[CustId],[Card_St],[IsVip],[CardName],[IsDaily],[IsClose],[CloseDate],[RequestId],[ApartmentId],[ProjectCd],[VehicleTypeId],[StarLevel],[IsGuest],[SaveDate],[SaveId])
        SELECT [CardId],[CardCd],[CardTypeId],[ImageUrl],[IssueDate],[ExpireDate],[CustId],[Card_St],[IsVip],[CardName],[IsDaily],[IsClose],[CloseDate],[RequestId],[ApartmentId],[ProjectCd],[VehicleTypeId],[StarLevel],[IsGuest],GETDATE(),@userId
        FROM [MAS_Cards] WHERE CardCd = @cardId;
        DELETE trg FROM MAS_Cards trg WHERE CardCd = @cardId AND Card_St >= 3;
        SET @messages = N'Xóa thẻ thành công.';
    END;
    SELECT @valid AS valid, @messages AS [messages];
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_internal_del' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'CardInternal', 'DEL', @SessionID, @AddlInfo;
END CATCH;
