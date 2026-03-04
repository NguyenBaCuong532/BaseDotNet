
CREATE PROCEDURE [dbo].[sp_res_receipt_del] @UserId UNIQUEIDENTIFIER = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
    , @ReceiptId BIGINT
AS
BEGIN TRY
    DECLARE @valid BIT = 1
    DECLARE @messages NVARCHAR(200)

    --declare @errmessage nvarchar(100)
    --set @errmessage = 'This Receivable: ' + cast(@receiveId as varchar) + ' is Receipted!'
    IF NOT EXISTS (
            SELECT receiveid
            FROM MAS_Service_Receipts
            WHERE ReceiveId = @ReceiptId
            )
    BEGIN
        BEGIN TRANSACTION
        UPDATE t
        SET AccrualLastDt = b.fromDt
            --,DebitAmt = t.DebitAmt - (- a.PaidAmt)
            , lastReceived = b.fromDt
        FROM MAS_Apartments t
        JOIN MAS_Service_ReceiveEntry a
            ON a.ApartmentId = t.ApartmentId
        LEFT JOIN MAS_Service_Receivable b
            ON a.ReceiveId = b.ReceiveId
        WHERE a.ReceiveId = @ReceiptId
            AND b.ServiceTypeId = 1
            AND a.isExpected = 1

        UPDATE t
        SET t.lastReceivable = b.fromDt,
            t.EndTime = t.endTime_Tmp
        FROM MAS_CardVehicle t
        JOIN MAS_Service_Receivable b
            ON t.CardVehicleId = b.srcId
        WHERE ReceiveId = @ReceiptId
            AND b.ServiceTypeId = 2

        UPDATE t
        SET lastReceivable = b.fromDt
            , IsReceivable = 0
        --,IsCalculate = 0
        FROM MAS_Service_Living_Tracking t
        JOIN MAS_Service_Receivable b
            ON t.TrackingId = b.srcId
        WHERE b.ReceiveId = @ReceiptId
            AND b.ServiceTypeId in (3,4)

        DELETE t
        FROM MAS_Service_Receivable t
        WHERE ReceiveId = @ReceiptId

        DELETE trg
        FROM MAS_Service_ReceiveEntry trg
        WHERE ReceiveId = @ReceiptId
        COMMIT
        SET @messages = N'Xóa thành công!'
    END
    ELSE
    BEGIN
        SET @valid = 0
        SET @messages = N'Hóa đơn đã được thanh toán, không cho phép xóa!'
            --RAISERROR (@errmessage, -- Message text.
            --	   16, -- Severity.
            --	   1 -- State.
            --	   );
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
    SET @ErrorMsg = 'sp_res_receipt_del' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ''

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'Receivable'
        , 'DEL'
        , @SessionID
        , @AddlInfo
END CATCH
    --select * from MAS_Service_Receivable where  ServiceObject like '%2601%'