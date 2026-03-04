
CREATE PROCEDURE [dbo].[sp_res_card_apartment_del]
    @userId NVARCHAR(450),
    @CardCd NVARCHAR(50)
AS
BEGIN TRY
    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(100) = N'';
    IF NOT EXISTS (SELECT CardId FROM MAS_Cards WHERE CardCd = @CardCd)
    BEGIN
        SET @valid = 0;
        SET @messages = N'Không tìm thấy thông mã thẻ [' + @CardCd + N']!';
    --RAISERROR (@messages, -- Message text.
    --	   16, -- Severity.
    --	   1 -- State.
    --	   );
    END;
    ELSE IF EXISTS
    (
        SELECT CardId
        FROM MAS_Cards
        WHERE CardCd = @CardCd
              AND Card_St < 3
    )
    BEGIN
        SET @valid = 0;
        SET @messages = N'Số thẻ [' + @CardCd + N'] đang được sử dụng, Cần phải khóa trước khi xóa!';
    --RAISERROR (@messages, -- Message text.
    --	   16, -- Severity.
    --	   1 -- State.
    --	   );
    END;
    ELSE --if exists(select cardId from MAS_Cards where CardCd = @CardCd and Card_St >= 3)
    BEGIN
        INSERT INTO [dbo].[MAS_CardVehicle_H]
        (
            [CardVehicleId],
            [AssignDate],
            [CardId],
            [CustId],
            [VehicleNo],
            [VehicleTypeId],
            [VehicleName],
            [VehicleColor],
            [StartTime],
            [EndTime],
            [Status],
            [ServiceId],
            [RegCardVehicleId],
            [RequestId],
            [isVehicleNone],
            [monthlyType],
            [lastReceivable],
            [Auth_id],
            [Auth_Dt],
            [ProjectCd],
            [Reason],
            [SaveDate],
            [SaveId]
        )
        SELECT [CardVehicleId],
               [AssignDate],
               [CardId],
               [CustId],
               [VehicleNo],
               [VehicleTypeId],
               [VehicleName],
               [VehicleColor],
               [StartTime],
               [EndTime],
               [Status],
               [ServiceId],
               [RegCardVehicleId],
               [RequestId],
               [isVehicleNone],
               [monthlyType],
               [lastReceivable],
               [Auth_id],
               [Auth_Dt],
               [ProjectCd],
               [Reason],
               GETDATE(),
               @userId
        FROM [dbSHome].[dbo].[MAS_CardVehicle] a
        WHERE EXISTS
        (
            SELECT CardId
            FROM MAS_Cards
            WHERE CardCd = @CardCd
                  AND CardId = a.CardId
                  AND Card_St >= 3
        );

        UPDATE t
        SET [VehicleNum] = t.VehicleNum - 1
        FROM [dbo].[MAS_CardVehicle] t
            JOIN [dbo].[MAS_CardVehicle] a
                ON t.ApartmentId = a.ApartmentId
                   AND t.VehicleTypeId = a.VehicleTypeId
                   AND t.VehicleNum > a.VehicleNum
        WHERE t.[Status] = 1
              AND EXISTS
        (
            SELECT CardId
            FROM MAS_Cards
            WHERE CardCd = @CardCd
                  AND CardId = a.CardId
                  AND Card_St >= 3
        );

        DELETE a
        FROM MAS_CardVehicle a
        WHERE EXISTS
        (
            SELECT CardId
            FROM MAS_Cards
            WHERE CardCd = @CardCd
                  AND CardId = a.CardId
                  AND Card_St >= 3
        );

        DELETE a
        FROM MAS_CardCredit a
        WHERE EXISTS
        (
            SELECT CardId
            FROM MAS_Cards
            WHERE CardCd = @CardCd
                  AND CardId = a.CardId
                  AND Card_St >= 3
        );

        DELETE a
        FROM MAS_CardService a
        WHERE EXISTS
        (
            SELECT CardId
            FROM MAS_Cards
            WHERE CardCd = @CardCd
                  AND CardId = a.CardId
                  AND Card_St >= 3
        );

        DELETE cc
        FROM [MAS_Apartment_Card] cc
            JOIN MAS_Cards ma
                ON cc.CardId = ma.CardId
        WHERE CardCd = @CardCd;

        INSERT INTO [dbo].[MAS_Card_H]
        (
            [CardId],
            [CardCd],
            [CardTypeId],
            [ImageUrl],
            [IssueDate],
            [ExpireDate],
            [CustId],
            [Card_St],
            [IsVip],
            [CardName],
            [IsDaily],
            [IsClose],
            [CloseDate],
            [RequestId],
            [ApartmentId],
            [ProjectCd],
            [VehicleTypeId],
            [StarLevel],
            [IsGuest],
            [SaveDate],
            [SaveId]
        )
        SELECT [CardId],
               [CardCd],
               [CardTypeId],
               [ImageUrl],
               [IssueDate],
               [ExpireDate],
               [CustId],
               [Card_St],
               [IsVip],
               [CardName],
               [IsDaily],
               [IsClose],
               [CloseDate],
               [RequestId],
               [ApartmentId],
               [ProjectCd],
               [VehicleTypeId],
               [StarLevel],
               [IsGuest],
               GETDATE(),
               @userId
        FROM [MAS_Cards]
        WHERE CardCd = @CardCd;

        DELETE trg
        FROM MAS_Cards trg
        WHERE CardCd = @CardCd
              AND Card_St >= 3;

        UPDATE MAS_CardBase
        SET IsUsed = 0
        WHERE Code = @CardCd;

    END;

    SELECT @valid AS valid,
           @messages AS [messages];

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_card_del' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'Card',
                             'DEL',
                             @SessionID,
                             @AddlInfo;
END CATCH;