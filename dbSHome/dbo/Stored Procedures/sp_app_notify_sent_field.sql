

-- =============================================
-- Author: duongpx
-- Create date: 2025-09-25 07:23:39
-- Description: Lấy thông tin fields cho form NotifySent
-- Output: 3 result sets (Info, Groups, Data)
-- =============================================
CREATE   procedure [dbo].[sp_app_notify_sent_field]
    @userId uniqueidentifier = NULL,
    @n_id uniqueidentifier = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'NotifySent';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        --id = @n_id, 
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
    DROP TABLE if exists #tempIn;

    SELECT subject			= isnull(b.subject,a.subject)
		  ,content_notify	= isnull(b.content_notify,a.content_notify)
		  ,PushTimeAgo		= dbo.fn_Get_TimeAgo1(b.createDt, getdate())
		  ,content_type		= a.content_type
		  ,isRead			= ISNULL(b.read_st, 0)
		  ,b.read_dt
		  ,pushDate			= CONVERT(varchar(10), b.createDt, 103) + ' ' + CONVERT(varchar(8), b.createDt, 108)
		  ,a.external_event
          ,b.external_param
          ,notiAvatarUrl	= a.notiAvatarUrl
          ,r.refName
          ,r.refIcon
		  ,a.attachs
    INTO #tempIn
    FROM NotifyInbox a
		left join NotifySent b on a.n_id = b.n_id and b.userId = @UserId
		LEFT JOIN dbo.NotifyRef AS r ON a.source_ref = r.source_ref
    WHERE b.[n_id] = @n_id;


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
        , case [data_type] 
				  when 'nvarchar' then convert(nvarchar(max), case [field_name] 
						when 'subject' then b.subject 
						when 'content_notify' then b.content_notify 
						when 'PushTimeAgo' then b.PushTimeAgo 
						when 'pushDate' then b.pushDate 
						when 'external_event' then b.external_event 
						when 'external_param' then b.external_param 
						when 'refName' then b.refName 
						when 'refIcon' then b.refIcon 
						--when 'external_event' then b.external_event
						--when 'source_key' then b.source_key
						--when 'brand_name' then b.brand_name
						when 'notiAvatarUrl' then b.notiAvatarUrl
						--when 'tempId' then lower(cast(b.tempId as varchar(100)))
						--when 'source_ref' then lower(cast(b.source_ref as varchar(100)))
						--when 'send_name' then b.send_name
					end) 
					when 'uniqueidentifier' then convert(nvarchar(50), case [field_name] 
						when 'attachs' then b.attachs
					end)
				  when 'datetime' then convert(nvarchar(100),case [field_name] 
						when 'read_dt' then format(b.read_dt,'dd/MM/yyyy HH:mm:ss')
						end)
				  else convert(nvarchar(50),case [field_name] 
						when 'content_type' then b.content_type
					end) end as columnValue
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
    SET @ErrorMsg = N'sp_app_notify_sent_fields ' + ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'NotifySent', N'GET', @SessionID, @AddlInfo;
END CATCH