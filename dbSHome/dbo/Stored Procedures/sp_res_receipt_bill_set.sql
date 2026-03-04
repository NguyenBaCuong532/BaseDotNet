
CREATE PROCEDURE [dbo].[sp_res_receipt_bill_set] @UserID NVARCHAR(50)
    , @ReceiptId BIGINT
    , @ReceiptBillUrl NVARCHAR(350)
    , @ReceiptBillViewUrl NVARCHAR(350)
AS
BEGIN TRY
    SET @ReceiptBillUrl = isnull(@ReceiptBillUrl, '')

    IF @ReceiptId > 0
        UPDATE [dbo].MAS_Service_Receipts
        SET ReceiptBillUrl = @ReceiptBillUrl
            , ReceiptBillViewUrl = @ReceiptBillViewUrl
        WHERE ReceiptId = @ReceiptId
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_receipt_bill_set ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = '@User ' + @UserID

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Service_Receipts'
        , 'Set'
        , @SessionID
        , @AddlInfo
END CATCH