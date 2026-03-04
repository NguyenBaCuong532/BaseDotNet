

-- =============================================
-- Author: duongpx
-- Create date: 2025-09-18 09:05:37
-- Description: Lấy thông tin fields cho form MAS_Requests
-- Output: 3 result sets (Info, Groups, Data)
-- =============================================
CREATE   procedure [dbo].[sp_app_service_field]
    @userId uniqueidentifier = NULL,
    @requestId int = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'MAS_Requests';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';
	declare @requestKey nvarchar(50) = 'RequestSev'
    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        requestId = @requestId, 
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
    FROM MAS_Requests b
    WHERE b.[requestId] = @requestId;

    -- Nếu không có dữ liệu, tạo record mới
    IF NOT EXISTS (SELECT 1 FROM #tempIn)
    BEGIN
        INSERT INTO #tempIn ([requestId],requestKey,requestUserId) 
        VALUES (@requestId,@requestKey,@UserId);
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
            when 'requestKey' then b.[requestKey]
            when 'comment' then b.[comment]
            when 'projectCd' then b.[projectCd]
            when 'requestUserId' then b.[requestUserId]
            when 'thread_id' then b.[thread_id]
        end)
    when 'datetime' then case [field_name]
            when 'requestDt' then format(b.[requestDt], 'dd/MM/yyyy HH:mm:ss')
            when 'atTime' then format(b.[atTime], 'dd/MM/yyyy HH:mm:ss')
            when 'review_dt' then format(b.[review_dt], 'dd/MM/yyyy HH:mm:ss')
        end
    when 'uniqueidentifier' then CONVERT(NVARCHAR(50), case [field_name]
            when 'attachOid' then b.attachOid
        END)
    when 'bit' then CONVERT(NVARCHAR(50), case [field_name]
            when 'isNow' then case b.[isNow] when 1 then 'true' else 'false' end
        END)
    else CONVERT(NVARCHAR(50), case [field_name]
            when 'requestId' then b.[requestId]
            when 'status' then b.[status]
            when 'rating' then b.[rating]
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
    --WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
    ORDER BY a.ordinal;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = N'sp_app_service_fields ' + ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Requests', N'GET', @SessionID, @AddlInfo;
END CATCH