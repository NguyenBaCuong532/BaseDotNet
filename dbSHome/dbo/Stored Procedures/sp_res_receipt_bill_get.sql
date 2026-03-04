CREATE PROCEDURE [dbo].[sp_res_receipt_bill_get]
	@userId NVARCHAR(50) = NULL
  , @receiptId BIGINT
AS
BEGIN TRY
    SELECT [ReceiptId]
        , [ReceiptNo]
        , convert(NVARCHAR(10), [ReceiptDt], 103) AS [ReceiptDate]
        --,a.[ApartmentId]
        , a.ReceiveId
        , a.TranferCd
        , isnull([Object], c.fullName) AS FullName
        -- ,A.[Address]
        , b.RoomCode + '-' + v.ProjectName AS Address
        , [Contents]
        , [Attach]
        , [IsDBCR]
        , [Amount] = ISNULL(a.[Amount],0)
        , u2.loginName AS [CreatorCd]
        , [CreateDate]
        , b.RoomCode
        , CONCAT (
            v.projectCd
            , '-'
            , v.ProjectName
            ) AS projectFolder
    FROM MAS_Service_ReceiveEntry d
    JOIN [dbo].MAS_Service_Receipts a
        ON d.ReceiveId = a.ReceiveId
    JOIN MAS_Apartments b
        ON d.ApartmentId = b.ApartmentId
    LEFT JOIN MAS_Projects v
        ON b.projectCd = v.projectCd
    LEFT JOIN MAS_Customers c
        ON a.CustId = c.CustId
    LEFT JOIN Users u2
        ON a.CreatorCd = u2.UserId
    WHERE a.ReceiptId = @receiptId
	--WHERE d.ReceiveId = @receiptId
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_receipt_bill_get ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = '@UserID ' + @UserID

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Service_Receipts'
        , 'Get'
        , @SessionID
        , @AddlInfo
END CATCH