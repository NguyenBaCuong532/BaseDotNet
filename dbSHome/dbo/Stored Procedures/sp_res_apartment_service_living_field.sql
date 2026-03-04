CREATE PROCEDURE [dbo].[sp_res_apartment_service_living_field]
    @userId UNIQUEIDENTIFIER = NULL,
    @LivingId INT = 7718,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'apartment_service_living';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        LivingId = @LivingId,
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
    
    -- Tạo temp table để lưu dữ liệu
    IF OBJECT_ID(N'tempdb..#tempIn') IS NOT NULL 
        DROP TABLE #tempIn;

    SELECT b.*
    INTO #tempIn
    FROM MAS_Apartment_Service_Living b
    WHERE b.LivingId = @LivingId;

    -- Nếu không có dữ liệu, tạo record mới
    IF NOT EXISTS (SELECT 1 FROM #tempIn)
    BEGIN
        INSERT INTO #tempIn (LivingId) 
        VALUES (@LivingId);
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
            CASE a.data_type
                WHEN 'nvarchar' THEN CONVERT(NVARCHAR(350), CASE a.field_name
                    WHEN 'CustId' THEN b.CustId
                    WHEN 'CustPhone' THEN b.CustPhone
                    WHEN 'ContractNo' THEN b.ContractNo
                    WHEN 'MeterSerial' THEN b.MeterSeri
                    WHEN 'DeliverName' THEN b.DeliverName
                    WHEN 'ProviderCd' THEN b.ProviderCd
                    WHEN 'Note' THEN b.Note
                    WHEN 'EmployeeCd' THEN b.EmployeeCd
                END)
                WHEN 'date' THEN CONVERT(NVARCHAR(50), CASE a.field_name
                    WHEN 'ContractDate' THEN CONVERT(NVARCHAR(10), b.ContractDt, 103)
                    WHEN 'StartDate' THEN CONVERT(NVARCHAR(10), b.MeterDate, 103)
                END)
                WHEN 'int' THEN CONVERT(NVARCHAR(50), CASE a.field_name
                    WHEN 'ApartmentId' THEN CAST(b.ApartmentId AS VARCHAR(50))
                    WHEN 'MeterNumber' THEN CAST(b.MeterNum AS VARCHAR(50))
                    WHEN 'LivingType' THEN CAST(b.LivingTypeId AS VARCHAR(50))
                    WHEN 'LivingId' THEN CAST(b.LivingId AS VARCHAR(50))
                    WHEN 'NumPersonWater' THEN CAST(b.NumPersonWater AS VARCHAR(50))
                END)
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
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_service_living_field ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_service_living',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;
