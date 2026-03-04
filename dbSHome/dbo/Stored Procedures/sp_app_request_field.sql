

-- =============================================
-- Author: duongpx
-- Create date: 2025-09-18 08:26:36
-- Description: Lấy thông tin fields cho form MAS_Requests
-- Output: 3 result sets (Info, Groups, Data)
-- =============================================
CREATE   procedure [dbo].[sp_app_request_field]
    @userId uniqueidentifier = NULL,
    @requestId uniqueidentifier = NULL,
	@categoryId int = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'App_Request';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';
	declare @requestKey nvarchar(50) = 'RequestFix'
	declare @apartmentId int
    declare @room_info nvarchar(250);
    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu fields với columnValue động
    -- =============================================
    
    -- Tạo temp table để lưu dữ liệu
    IF OBJECT_ID(N'tempdb..#tempIn') IS NOT NULL 
        DROP TABLE #tempIn;

    SELECT b.*, room_info = a.RoomCode + ' - ' + p.projectName
    INTO #tempIn
    FROM MAS_Requests b
		join MAS_Apartments a on a.apartmentId = b.apartmentId
		join MAS_Projects p on a.projectCd = p.projectCd
    WHERE b.Oid = @requestId;

    -- Nếu không có dữ liệu, tạo record mới
    IF NOT EXISTS (SELECT 1 FROM #tempIn)
    BEGIN
		SELECT TOP 1 @apartmentId = a.ApartmentId, @room_info = a.RoomCode + ' - ' + p.projectName
    FROM MAS_Apartment_Member m
		join MAS_Apartments a on a.apartmentId = m.apartmentId
		join MAS_Projects p on a.projectCd = p.projectCd
		join UserInfo u on m.CustId = u.custId
    WHERE u.userId = @UserId
        AND main_st = 1

		set @requestId = newid()
        INSERT INTO #tempIn (requestId,Oid, requestKey,apartmentId, requestTypeId,requestUserId,status,room_info) 
        VALUES (0,@requestId,@requestKey,isnull(@apartmentId,0), @categoryId,@UserId,0,@room_info);
    END

	-- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        requestId = @requestId, 
        tableKey = @tableKey, 
        groupKey = @groupKey
		,statusId = a.status
	from #tempIn a
    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm fields
    -- =============================================
    SELECT *
    FROM dbo.fn_get_field_group_lang(@groupKey, @acceptLanguage)
    ORDER BY intOrder;

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
							when 'thread_id' then b.thread_id
							when 'room_info' then b.room_info
						end)
					when 'datetime' then case [field_name]
							when 'requestDt' then format(b.[requestDt], 'dd/MM/yyyy')
							when 'atTime' then format(b.[atTime], 'HH:mm:ss')
							when 'review_dt' then format(b.[review_dt], 'dd/MM/yyyy HH:mm:ss')
						end
					when 'uniqueidentifier' then CONVERT(NVARCHAR(50), case [field_name]
							when 'attachOid' then b.attachOid
						END)
					when 'bit' then CONVERT(NVARCHAR(50), case [field_name]
							when 'isNow' then case b.[isNow] when 1 then 'true' else 'false' end
						END)
					else CONVERT(NVARCHAR(50), case [field_name]
							when 'requestTypeId' then b.requestTypeId
							when 'status' then b.[status]
							when 'rating' then b.[rating]
						END)
				end,a.columnDefault)
        , a.columnClass
        , a.columnType
        , columnObject = case 
							when field_name = 'attachOid' then [columnObject] + isnull(cast(b.attachOid as nvarchar(50)),'')
						else [columnObject] end
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
    SET @ErrorMsg = N'sp_app_request_fields ' + ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Requests', N'GET', @SessionID, @AddlInfo;
END CATCH