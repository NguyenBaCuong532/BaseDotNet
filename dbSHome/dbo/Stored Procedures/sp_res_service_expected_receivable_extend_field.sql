CREATE PROCEDURE [dbo].[sp_res_service_expected_receivable_extend_field]
    @userId UNIQUEIDENTIFIER = NULL,
    @ReceivedId INT = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'service_expected_receivable_extend';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        receiveId = @ReceivedId,
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
    
    -- Tạo temp table để lưu dữ liệu (nếu cần)
    -- Vì đây là form config, không có bảng thực tế, chỉ trả về config
    IF OBJECT_ID(N'tempdb..#tempIn') IS NOT NULL 
        DROP TABLE #tempIn;

    -- Tạo temp table rỗng để đảm bảo cấu trúc
    CREATE TABLE #tempIn (
        receiveId INT
    );

    -- Nếu có @ReceivedId, insert vào temp table
    IF @ReceivedId IS NOT NULL
    BEGIN
        INSERT INTO #tempIn (receiveId) 
        VALUES (@ReceivedId);
    END
    ELSE
    BEGIN
        INSERT INTO #tempIn (receiveId) 
        VALUES (NULL);
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
                WHEN 'receiveId' THEN CONVERT(NVARCHAR(50), b.receiveId)
                -- Có thể thêm các field mapping khác nếu cần
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
    SET @ErrorMsg = 'sp_res_service_expected_receivable_extend_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'service_expected_receivable_extend',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;