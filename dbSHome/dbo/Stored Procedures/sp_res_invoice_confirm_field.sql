--select * from MAS_Service_ReceiveEntry where receiveId = 162129
--select * from MAS_Service_ReceiveEntry where receiveId = 161452
CREATE PROCEDURE [dbo].[sp_res_invoice_confirm_field] 
     @userId uniqueidentifier = NULL
    , @receiveId INT = 161452
    , @remainamt DECIMAL = 1173660
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @form VARCHAR(50) = 'form_invoice_confirm'
    DECLARE @group VARCHAR(50) = 'invoice_confirm_group'
    DECLARE @apartmentId BIGINT
    DECLARE @ProjectCd NVARCHAR(50)
    DECLARE @customerId NVARCHAR(50)
    DECLARE @PaidSections NVARCHAR(MAX);

    SELECT @apartmentId = ApartmentId
        , @ProjectCd = ProjectCd
    FROM MAS_Service_ReceiveEntry
    WHERE ReceiveId = @receiveId

    SELECT 
        @PaidSections = STUFF((
            SELECT ', ' + [PaymentSection]
            FROM [dbo].[MAS_Service_Receipts]
            WHERE ReceiveId = @receiveId
            FOR XML PATH('')
        ), 1, 2, '')

    SET @PaidSections = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@PaidSections,
                        'Common', N'Phí dịch vụ chung'),
                        'Vehicle', N'Khoản tiền xe'),
                        'Debt', N'Khoản tiền nợ'),
                        'Water', N'Phí nước'),
                        'Electric', N'Phí điện');

    SELECT TOP 1 @customerId = a.CustId
    FROM MAS_Apartment_Member a
    WHERE a.ApartmentId = @apartmentId
        AND EXISTS (
            SELECT TOP 1 ApartmentId
                    FROM MAS_Apartments ma
                    JOIN UserInfo mu
                        ON ma.UserLogin = mu.loginName
                    WHERE mu.CustId = a.CustId
                        AND ma.ApartmentId = a.ApartmentId
            )
    SELECT id = NULL
        , tableKey = 'form_invoice_confirm'
        , groupKey = @group;

    SELECT *
    FROM [dbo].[fn_get_field_group](@group)
    ORDER BY intOrder;

    -- Tạo bảng tạm để lưu kết quả từ sp_res_payment_option_list
    DECLARE @PaymentOptions TABLE (
        name NVARCHAR(100),
        value NVARCHAR(50)
    );

    -- Gọi stored procedure sp_res_payment_option_list và lưu kết quả vào bảng tạm
    INSERT INTO @PaymentOptions (name, value)
    EXEC [dbo].[sp_res_payment_option_list] 
        @UserId = @userId,
        @receiveId = @receiveId;

    --2 tung o 
    SELECT config.[id]
        , [table_name]
        , [field_name]
        , [view_type]
        , [data_type]
        , [ordinal]
        , [columnLabel]
        , [group_cd]
        , columnValue = CASE field_name
            WHEN 'amount' THEN FORMAT(@remainamt, '')
            WHEN 'total_amount' THEN FORMAT(@remainamt, '')
            WHEN 'receiveId' THEN FORMAT(@receiveId, '')
            WHEN 'custId' THEN @customerId
            WHEN 'ProjectCd' THEN @ProjectCd
            WHEN 'Electric' THEN 
                CASE 
                    WHEN EXISTS(SELECT 1 FROM @PaymentOptions WHERE value = 'Electric')
                    THEN FORMAT(ISNULL(a.[LivingElectricAmt], 0), 'N2')
                    ELSE '0.00'
                END
            WHEN 'Water' THEN 
                CASE 
                    WHEN EXISTS(SELECT 1 FROM @PaymentOptions WHERE value = 'Water')
                    THEN FORMAT(ISNULL(a.[LivingWaterAmt], 0), 'N2')
                    ELSE '0.00'
                END
            WHEN 'Vehicle' THEN 
                CASE 
                    WHEN EXISTS(SELECT 1 FROM @PaymentOptions WHERE value = 'Vehicle')
                    THEN FORMAT(ISNULL(a.VehicleAmt, 0), 'N2')
                    ELSE '0.00'
                END
            WHEN 'Common' THEN 
                CASE 
                    WHEN EXISTS(SELECT 1 FROM @PaymentOptions WHERE value = 'Common')
                    THEN FORMAT(ISNULL(a.CommonFee, 0), 'N2')
                    ELSE '0.00'
                END
            WHEN 'Debt' THEN 
                CASE 
                    WHEN EXISTS(SELECT 1 FROM @PaymentOptions WHERE value = 'Debt')
                    THEN FORMAT(ISNULL(a.DebitAmt, 0), 'N2')
                    ELSE '0.00'
                END
            WHEN 'PaidSections' THEN ISNULL(@PaidSections, '')
            WHEN 'PaymentOption' THEN 
                STUFF((
                    SELECT ',' + value
                    FROM @PaymentOptions
                    FOR XML PATH('')
                ), 1, 1, '')
            WHEN 'all' THEN '0'
            ELSE columnDefault
          END
        , [columnClass]
        , [columnType] 
        , [columnObject] 
        = CASE field_name
            WHEN 'PaymentOption'
                THEN config.columnObject + CAST(@receiveId AS nvarchar(50))
            ELSE config.columnObject
            END
        , [isSpecial]
        , [isRequire]
        , [isDisable]
        , [isVisiable]
        , [columnDisplay]
        , [IsEmpty]
        , ISNULL(config.columnTooltip, config.[columnLabel]) AS columnTooltip
        , [isIgnore]
    FROM dbo.fn_config_form_gets(@form, @acceptLanguage) config
    CROSS JOIN [MAS_Service_ReceiveEntry] a
    WHERE a.ReceiveId = @receiveId
    ORDER BY ordinal;
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_invoice_confirm_field' + ERROR_MESSAGE();
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