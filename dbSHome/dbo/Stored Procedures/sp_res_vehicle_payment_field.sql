
-- =============================================
-- Author: duongpx
-- Create date: 2025-09-12 17:49:55
-- Description: Lấy thông tin fields cho form MAS_CardVehicle_Pay
-- Output: 3 result sets (Info, Groups, Data)
-- =============================================
CREATE   PROCEDURE [sp_res_vehicle_payment_field]
    @UserId UNIQUEIDENTIFIER = NULL,
    @PayId int = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'MAS_CardVehicle_Pay';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        PayId = @PayId, 
        tableKey = @tableKey, 
        groupKey = @groupKey;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm fields
    -- =============================================
    SELECT *
    FROM dbo.fn_get_field_group_lang(@groupKey, @acceptLanguage)
    ORDER BY intOrder;

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu fields với columnValue động
    -- =============================================
    
    -- Tạo temp table để lưu dữ liệu
    IF OBJECT_ID(N'tempdb..#tempIn') IS NOT NULL 
        DROP TABLE #tempIn;

    SELECT b.*
    INTO #tempIn
    FROM MAS_CardVehicle_Pay b
    WHERE b.[PayId] = @PayId;

    -- Nếu không có dữ liệu, tạo record mới
    IF NOT EXISTS (SELECT 1 FROM #tempIn)
    BEGIN
        INSERT INTO #tempIn ([PayId]) 
        VALUES (@PayId);
    END

    -- Trả về dữ liệu fields với columnValue được format
    SELECT
          a.id
        , a.table_name
        , a.field_name
        , a.view_type
        , a.data_type
        , a.ordinal
        , a.columnLabel
        , a.group_cd
        , columnValue = isnull(case [data_type]
    when 'nvarchar' then convert (nvarchar(451),
        case [field_name]
            --when 'UserId' then b.[UserId]
            when 'Remart' then b.[Remart]
        end)
    when 'datetime' then case [field_name]
            when 'PayDt' then format(b.[PayDt], 'dd/MM/yyyy HH:mm:ss')
            when 'StartDt' then format(b.[StartDt], 'dd/MM/yyyy HH:mm:ss')
            when 'EndDt' then format(b.[EndDt], 'dd/MM/yyyy HH:mm:ss')
        end
    when 'uniqueidentifier' then LOWER(CAST(case [field_name]
            when 'paymentId' then b.[paymentId]
            when 'price_oid' then b.[price_oid]
        END AS NVARCHAR(100)))
    when 'bit' then NULL
    else CONVERT(NVARCHAR(50), case [field_name]
            when 'PayId' then b.[PayId]
            when 'CardVehicleId' then b.[CardVehicleId]
            when 'Amount' then b.[Amount]
            when 'month_price' then b.[month_price]
            when 'month_num' then b.[month_num]
            when 'payment_st' then b.[payment_st]
        END)
end,a.columnDefault)
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
    FROM dbo.fn_config_form_gets(@tableKey,@acceptLanguage) a
    CROSS JOIN #tempIn b
    WHERE a.table_name = @tableKey
      AND (a.IsVisiable = 1 OR a.isRequire = 1)
    ORDER BY a.ordinal;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = N'sp_res_vehicle_payment_fields ' + ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_CardVehicle_Pay', N'GET', @SessionID, @AddlInfo;
END CATCH