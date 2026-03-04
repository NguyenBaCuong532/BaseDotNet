CREATE   PROCEDURE [dbo].[sp_res_apartment_service_cut_history_field]
    @UserId UNIQUEIDENTIFIER = NULL,
    @ApartmentId NVARCHAR(50) = NULL,
    @Id NVARCHAR(50) = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'apartment_service_cut_history';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        Id = @Id,
        ApartmentId = @ApartmentId,
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
    FROM MAS_Service_Cut_History b
    WHERE b.Id = @Id;

    -- Nếu không có dữ liệu, tạo record mới
    IF NOT EXISTS (SELECT 1 FROM #tempIn)
    BEGIN
        INSERT INTO #tempIn (Id, ApartmentId) 
        VALUES (@Id, @ApartmentId);
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
                WHEN 'Id' THEN CONVERT(NVARCHAR(50), b.Id)
                WHEN 'Reason' THEN b.Reason
                WHEN 'CutStartDate' THEN (
                    CONVERT(VARCHAR(10), b.CutStartDate, 103) + ' ' + LEFT(CONVERT(VARCHAR(8), b.CutStartDate, 108), 5)
                )
                WHEN 'CutEndDate' THEN CONVERT(VARCHAR(10), b.CutEndDate, 103) + ' ' + LEFT(CONVERT(VARCHAR(8), b.CutEndDate, 108), 5)
                WHEN 'CutType' THEN CAST(b.CutType AS VARCHAR(50))
                WHEN 'ApartmentId' THEN CAST(b.ApartmentId AS VARCHAR(50))
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
    SET @ErrorMsg = 'sp_res_apartment_service_cut_history_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'Mas_Service_Cut_History',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;