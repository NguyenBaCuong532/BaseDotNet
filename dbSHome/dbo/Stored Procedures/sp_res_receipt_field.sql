
CREATE PROCEDURE [dbo].[sp_res_receipt_field] 
    @UserId UNIQUEIDENTIFIER = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
    , @ReceiptId INT = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'MAS_Service_Receipts';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- Validation
    IF @ReceiptId IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM dbo.MAS_Service_Receipts
            WHERE ReceiptId = @ReceiptId
            )
        SET @ReceiptId = NULL;

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        ReceiptId = @ReceiptId,
        tableKey = @tableKey, 
        groupKey = @groupKey;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
    ORDER BY intOrder;

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu field với columnValue động
    -- =============================================
    
    -- Tạo temp table để lưu dữ liệu với các JOIN cần thiết
    IF OBJECT_ID(N'tempdb..#tempIn') IS NOT NULL 
        DROP TABLE #tempIn;

    SELECT 
        a.ReceiptId,
        a.ReceiptNo,
        a.ReceiptDt,
        a.custId,
        a.ApartmentId,
        a.ReceiveId,
        a.TranferCd,
        ISNULL(a.[Object], c.FullName) AS [Object],
        a.[Pass_No],
        a.[Pass_dt],
        a.[Pass_Plc],
        a.[Address],
        a.[Contents],
        a.[Attach],
        a.[IsDBCR],
        a.[Amount],
        a.[CreatorCd],
        a.[CreateDate],
        a.[AccountLeft],
        a.[AccountRight],
        b.[ProjectCd],
        b.RoomCode,
        c.FullName,
        [dbo].[Num2Text](a.Amount) AS AmountText,
        a.PaymentSection
    INTO #tempIn
    FROM [dbo].MAS_Service_Receipts a
        LEFT JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
        LEFT JOIN MAS_Customers c ON a.custId = c.CustId
    WHERE a.ReceiptId = @ReceiptId;

    -- Nếu không có dữ liệu, tạo record mới
    IF NOT EXISTS (SELECT 1 FROM #tempIn)
    BEGIN
        INSERT INTO #tempIn (ReceiptId) 
        VALUES (@ReceiptId);
    END

    -- Trả về dữ liệu field với columnValue được format
    SELECT
          a.id
        , a.table_name
        , a.field_name
        , a.view_type
        , a.data_type
        , a.ordinal
        , a.columnLabel
        , a.group_cd
        , columnValue = ISNULL(
            CASE a.field_name
                WHEN 'ReceiptId' THEN CONVERT(NVARCHAR(50), b.ReceiptId)
                WHEN 'ReceiptNo' THEN b.ReceiptNo
                WHEN 'ReceiptDate' THEN CONVERT(NVARCHAR(20), b.ReceiptDt, 103)
                WHEN 'CifNo' THEN CONVERT(NVARCHAR(50), b.custId)
                WHEN 'ApartmentId' THEN CONVERT(NVARCHAR(50), b.ApartmentId)
                WHEN 'ReceiveId' THEN CONVERT(NVARCHAR(50), b.ReceiveId)
                WHEN 'TranferCd' THEN b.TranferCd
                WHEN 'Object' THEN b.[Object]
                WHEN 'PassNo' THEN b.[Pass_No]
                WHEN 'PassDate' THEN CONVERT(NVARCHAR(20), b.[Pass_dt], 103)
                WHEN 'PassPlc' THEN b.[Pass_Plc]
                WHEN 'Address' THEN b.[Address]
                WHEN 'Contents' THEN b.[Contents]
                WHEN 'Attach' THEN b.[Attach]
                WHEN 'IsDBCR' THEN CONVERT(NVARCHAR(10), b.[IsDBCR])
                WHEN 'Amount' THEN CONVERT(NVARCHAR(50), b.[Amount])
                WHEN 'CreatorCd' THEN b.[CreatorCd]
                WHEN 'CreateDate' THEN CONVERT(NVARCHAR(20), b.[CreateDate], 120)
                WHEN 'AccountLeft' THEN b.[AccountLeft]
                WHEN 'AccountRight' THEN b.[AccountRight]
                WHEN 'ProjectCd' THEN b.[ProjectCd]
                WHEN 'RoomCode' THEN b.RoomCode
                WHEN 'FullName' THEN b.FullName
                WHEN 'AmountText' THEN b.AmountText
                WHEN 'PaymentSection' THEN (
                    SELECT STRING_AGG(
                        CASE TRIM(s.value)
                            WHEN 'Common'   THEN N'Dịch vụ chung'
                            WHEN 'Debt'     THEN N'Nợ phí'
                            WHEN 'Electric' THEN N'Điện sinh hoạt'
                            WHEN 'Water'    THEN N'Nước sạch'
                            WHEN 'Vehicle'  THEN N'Phí gửi phương tiện'
                            ELSE TRIM(s.value)
                        END, ', ')
                    FROM STRING_SPLIT(b.PaymentSection, ',') AS s
                )
            END,
            a.columnDefault
        )
        , a.columnClass
        , a.columnType
        , a.columnObject
        , a.isSpecial
        , a.isRequire
        , a.isDisable
        , a.IsVisiable
        , a.isEmpty
        , columnTooltip = ISNULL(a.columnTooltip, a.columnLabel)
        , a.columnDisplay
        , a.isIgnore
    FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
    CROSS JOIN #tempIn b
    WHERE a.table_name = @tableKey
      AND (a.IsVisiable = 1 OR a.isRequire = 1)
    ORDER BY a.ordinal;
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_receipt_field' + ERROR_MESSAGE();
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