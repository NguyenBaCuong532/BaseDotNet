CREATE PROCEDURE [dbo].[sp_res_invoice_transfer_field] 
    @userId UNIQUEIDENTIFIER = NULL,
    @receiveId INT = NULL,
    @remainamt DECIMAL = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'form_invoice_transfer';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';
    DECLARE @apartmentId BIGINT;
    DECLARE @ProjectCd NVARCHAR(50);
    DECLARE @customerId NVARCHAR(50);

    SELECT @apartmentId = ApartmentId
        , @ProjectCd = ProjectCd
    FROM MAS_Service_ReceiveEntry
    WHERE ReceiveId = @receiveId;

    SELECT TOP 1 @customerId = a.CustId
    FROM MAS_Apartment_Member a
    WHERE a.ApartmentId = @apartmentId
        AND EXISTS (
            SELECT ApartmentId
            FROM MAS_Apartments ma
            JOIN UserInfo mu
                ON ma.UserLogin = mu.loginName
            WHERE mu.CustId = a.CustId
                AND ma.ApartmentId = a.ApartmentId
            );

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT id = NULL
        , tableKey = @tableKey
        , groupKey = @groupKey;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
    ORDER BY intOrder;

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu field với columnValue động
    -- =============================================
    SELECT a.id
        , a.[table_name]
        , a.[field_name]
        , a.[view_type]
        , a.[data_type]
        , a.[ordinal]
        , a.[columnLabel]
        , a.[group_cd]
        , columnValue = CASE a.field_name
            WHEN 'amount'
                THEN FORMAT(@remainamt, '')
            WHEN 'receiveId'
                THEN FORMAT(@receiveId, '')
            WHEN 'custId'
                THEN @customerId
            WHEN 'ProjectCd'
                THEN @ProjectCd
            ELSE a.columnDefault
            END
        , a.[columnClass]
        , a.[columnType]
        , a.[columnObject]
        , a.[isSpecial]
        , a.[isRequire]
        , a.[isDisable]
        , a.[IsVisiable]
        , a.[columnDisplay]
        , a.[IsEmpty]
        , columnTooltip = ISNULL(a.columnTooltip, a.[columnLabel])
        , a.[isIgnore]
    FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
    WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
    ORDER BY a.ordinal;
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_invoice_transfer_field' + ERROR_MESSAGE();
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