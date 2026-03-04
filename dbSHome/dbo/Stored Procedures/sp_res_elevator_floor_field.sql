-- =============================================
-- Oid = mã chính; Id/buildingCd = phụ (tương thích ngược, bỏ sau migrate).
-- Lấy thông tin fields cho form MAS_Elevator_Floor. Output: 3 result sets (Info, Groups, Data)
-- =============================================
CREATE   PROCEDURE [dbo].[sp_res_elevator_floor_field]
    @UserId UNIQUEIDENTIFIER = NULL,
    @Id int = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN',
    @buildingCd NVARCHAR(50) = NULL,
    @floorOid UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;
    -- Ưu tiên oid (mã chính); khi có Id thì resolve floorOid từ bảng
    IF @Id IS NOT NULL AND @floorOid IS NULL
        SET @floorOid = (SELECT oid FROM MAS_Elevator_Floor WHERE Id = @Id);
    IF @floorOid IS NOT NULL
        SET @Id = (SELECT Id FROM MAS_Elevator_Floor WHERE oid = @floorOid);
	SET @Id = NULLIF(@Id, '');
	SET @Id = ISNULL(@Id, (SELECT MAX(Id) FROM MAS_Elevator_Floor)) + 1;
    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'MAS_Elevator_Floor';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';
	
    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        Id = @Id, 
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
    FROM MAS_Elevator_Floor b
    WHERE (@floorOid IS NOT NULL AND b.oid = @floorOid) OR (@floorOid IS NULL AND b.[Id] = @Id);

    -- Nếu không có dữ liệu, tạo record mới
--     IF NOT EXISTS (SELECT 1 FROM #tempIn)
--     BEGIN
--         INSERT INTO #tempIn ([Id]) 
--         VALUES (@Id);
--     END

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
							when 'ProjectCd' then b.[ProjectCd]
							when 'AreaCd' then b.[AreaCd]
							when 'BuildZone' then b.[BuildZone]
							when 'FloorName' then b.[FloorName]
							when 'FloorType' then b.[FloorType]
							when 'buildingCd' then b.[buildingCd]
						end)
					when 'datetime' then case [field_name]
							when 'created_at' then format(b.created_at, 'dd/MM/yyyy HH:mm:ss')
						end
					when 'uniqueidentifier' then NULL
					when 'bit' then NULL
					else CONVERT(NVARCHAR(50), case [field_name]
							when 'Id' then @Id
							when 'FloorNumber' then b.[FloorNumber]
						END)
				end,a.columnDefault)
        , a.columnClass
        , a.columnType
        , columnObject = case		when a.field_name = 'ProjectCd' then a.columnObject --+ b.ProjectCd
									when a.field_name = 'AreaCd' then a.columnObject + '?buildingCd=' + ISNULL(b.buildingCd, '')
									when a.field_name = 'BuildZone' then a.columnObject + '?AreaCd=' + ISNULL(b.AreaCd, '')
									when a.field_name = 'buildingCd'  then ISNULL(a.columnObject, '') + '?ProjectCd=' + ISNULL(b.ProjectCd, '')

								else columnObject end
        , a.isSpecial
        , a.isRequire
        , a.isDisable
        , a.IsVisiable
        , a.isEmpty
        , columnTooltip = ISNULL(a.columnTooltip, a.columnLabel)
        , a.columnDisplay
        , a.isIgnore
    FROM
        dbo.fn_config_form_gets(@tableKey,@acceptLanguage) a
        OUTER APPLY(SELECT TOP 1 * FROM #tempIn) b
--         CROSS JOIN #tempIn b
    --WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
    ORDER BY a.ordinal;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = N'sp_res_elevator_floor_fields ' + ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Elevator_Floor', N'GET', @SessionID, @AddlInfo;
END CATCH