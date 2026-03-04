
-- =============================================
-- Author: ANHTT
-- Create date: 2025-10-17 12:38:38
-- Description:	invoice payment transaction info
-- Output: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_invoice_paymenttransaction_info] @userId NVARCHAR(50) = NULL
    , @receiveId BIGINT = 155172
    , @groups NVARCHAR(250) = 'common,vehicle,debit'
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    --
    DECLARE @entry_id UNIQUEIDENTIFIER
    DECLARE @debit_service_type INT = 99
    --Thông tin ngân hàng
    DECLARE @bank_bin NVARCHAR(50) = '970452'
    DECLARE @bank_account NVARCHAR(20) = '61119999'
    DECLARE @bank_name NVARCHAR(250) = 'NH TMCP Kiên Long (KienLong Bank)'
    DECLARE @bank_logo NVARCHAR(MAX) = 'https://cdn.sunshineapp.vn/smartbank/bankicons/KLB.svg'
    DECLARE @bank_center_logo NVARCHAR(MAX) = 'https://cdn.sunshineapp.vn/smartbank/bankicons/KLB.svg'
    DECLARE @bank_account_holder NVARCHAR(250) = N'Ban Vận hành'
    DECLARE @purpose NVARCHAR(250)
    DECLARE @isVaTransaction BIT
    DECLARE @virtual_account NVARCHAR(12)
    DECLARE @va_bank_bin NVARCHAR(50) = '970452'
    DECLARE @merchant_code NVARCHAR(50) = '1621'
    --
    --Thông tin thanh toán
    DECLARE @projectCd BIGINT
    DECLARE @apartmentId BIGINT
    DECLARE @apartment_name NVARCHAR(250)
    DECLARE @invoice_period_name NVARCHAR(250)
    DECLARE @receivableIds NVARCHAR(250)
    DECLARE @amount DECIMAL
    DECLARE @service_types TABLE (
        ServiceTypeId INT
        , ServiceType NVARCHAR(50)
        )

    INSERT INTO @service_types
    SELECT ServiceTypeId
        , ServiceType
    FROM MAS_ServiceTypes
    WHERE ServiceType IN (
            SELECT [value]
            FROM string_split(@groups, ',')
            )

    --Lấy thông tin thanh toán
    SELECT @apartmentId = ApartmentId
        , @entry_id = entryId
    FROM MAS_Service_ReceiveEntry
    WHERE ReceiveId = @receiveId

    --null -> update guid
    IF @entry_id IS NULL
    BEGIN
        SET @entry_id = NEWID()

        UPDATE MAS_Service_ReceiveEntry
        SET entryId = @entry_id
        WHERE ReceiveId = @receiveId
    END

    SELECT @apartment_name = RoomCode
        , @projectCd = projectCd
    FROM MAS_Apartments
    WHERE ApartmentId = @apartmentId

    --nếu cài đặt thu hộ
    SELECT @isVaTransaction = is_proxy_payment
        , @bank_bin = IIF(is_proxy_payment = 1, sb.Bank_Code, a.bank_code)
        , @bank_account = a.bank_acc_no
        , @bank_name = IIF(is_proxy_payment = 1, sb.Bank_Acc_Branch, b.bank_name)
        , @bank_account_holder = IIF(is_proxy_payment = 1, sb.Bank_Acc_Name, a.bank_acc_name)
        , @bank_logo = b.url
        , @merchant_code = sb.bank_cif_no
    FROM MAS_Projects a
    LEFT JOIN bank_codes b
        ON a.bank_code = b.bank_code
    LEFT JOIN MAS_Service_Bank sb
        ON a.projectCd = sb.ProjectCd
    WHERE a.projectCd = @projectCd

    SELECT @receivableIds = STRING_AGG(a.ReceivableId, ',')
        , @amount = SUM(a.TotalAmt)
        , @invoice_period_name = dbo.fn_invoice_period_name_format(MAX(a.ToDt))
    FROM [MAS_Service_Receivable] a
    INNER JOIN @service_types t
        ON t.ServiceTypeId = a.ServiceTypeId
    WHERE a.ReceiveId = @receiveId
    AND (a.IsPaid IS NULL OR a.IsPaid = 0)

    --tạo tài khoản ảo từ service types
    IF @isVaTransaction = 1
    BEGIN
        SELECT @virtual_account = STRING_AGG(FORMAT(ServiceTypeId, '00'), '')
        FROM @service_types
    END

    IF CHARINDEX('debit', @groups) > 0
    BEGIN
        SELECT @amount = ISNULL(@amount, 0) + ISNULL(debitAmt, 0)
        FROM MAS_Service_ReceiveEntry
        WHERE ReceiveId = @receiveId

        IF @isVaTransaction = 1
            SET @virtual_account = CONCAT (
                    @virtual_account
                    , FORMAT(@debit_service_type, '00')
                    )
    END

    SET @purpose = CONCAT (
            @apartment_name
            , N' - thanh toan hoa don'
            )

    --
    SELECT [bin] = @bank_bin
        , [isVaTransaction] = @isVaTransaction
        , [bankaccount] = IIF(@isVaTransaction = 1, @virtual_account, @bank_account)
        , [bankName] = @bank_name
        , [logo] = @bank_logo
        , [accountHolder] = @bank_account_holder
        , [purpose] = @purpose
        , [amount] = @amount
        , [merchantcode] = @merchant_code
        , [entryId] = @entry_id
        , [receiveId] = @receiveId
        , [receivableIds] = @receivableIds
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    --SET @AddlInfo = NULL;
    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Service_Receivable'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;