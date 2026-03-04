
-- exec sp_res_service_expectable_receivable_extend_set null,'02','70262','2021-12-30'
CREATE   procedure [dbo].[sp_res_service_expectable_receivable_extend_set]
    @UserID NVARCHAR(450),
    @ReceiveId BIGINT,
    @ExtendAmt DECIMAL,
    @Note NVARCHAR(250)
AS
BEGIN TRY
    DECLARE @valid BIT = 0;
    DECLARE @message NVARCHAR(100) = N'';
    IF EXISTS
    (
        SELECT *
        FROM MAS_Service_ReceiveEntry
        WHERE ReceiveId = @ReceiveId
              AND IsPayed = 0
    )
    BEGIN
        DELETE MAS_Service_Receivable
        WHERE ServiceTypeId = 8
              AND ReceiveId = @ReceiveId;
        INSERT INTO MAS_Service_Receivable
        (
            [ReceiveId],
            [ServiceTypeId],
            [ServiceObject],
            [Amount],
            VatAmt,
            TotalAmt,
            fromDt,
            [ToDt],
            [Quantity],
            Price,
            srcId,
            updateId
        )
        SELECT @ReceiveId,
               8,
               a.RoomCode + ':' + @Note,
               @ExtendAmt,
               @ExtendAmt / 10,
               @ExtendAmt,
               NULL,
               ToDt,
               1,
               NULL,
               a.ApartmentId,
               @UserID
        FROM MAS_Apartments a
            JOIN [MAS_Service_ReceiveEntry] d
                ON a.ApartmentId = d.ApartmentId
        WHERE d.ReceiveId = @ReceiveId;

        UPDATE MAS_Service_ReceiveEntry
        SET ExtendAmt =
            (
                SELECT SUM(TotalAmt)
                FROM [MAS_Service_Receivable]
                WHERE [ReceiveId] = @ReceiveId
                      AND ServiceTypeId = 8
            ),
            TotalAmt =
            (
                SELECT SUM(TotalAmt)
                FROM [MAS_Service_Receivable]
                WHERE [ReceiveId] = @ReceiveId
            ),
            updateId = @UserID
        WHERE IsPayed = 0
              AND ReceiveId = @ReceiveId;
        SET @valid = 1;
        SET @message = N'Cập nhật công nợ tồn khác thành công!';

    END;
    SELECT @valid AS valid,
           @message AS message;


END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_expectable_receivable_extend_set' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '@UserID ' + @UserID;

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'Receivable',
                             'Ins',
                             @SessionID,
                             @AddlInfo;
END CATCH;