-- Updated: Hỗ trợ ApartmentId và Oid (backward compatible)
CREATE PROCEDURE [dbo].[sp_res_apartment_add_field]
    @userId UNIQUEIDENTIFIER = NULL,
    @ApartmentId INT = NULL,  -- Backward compatible
    @Oid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID)
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'MAS_Add_Apartments';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- Xác định ApartmentId từ Oid nếu có
    IF @Oid IS NOT NULL AND @ApartmentId IS NULL
    BEGIN
        SELECT @ApartmentId = ApartmentId
        FROM dbo.MAS_Apartments
        WHERE oid = @Oid;
    END

    -- Validation
    IF @ApartmentId IS NOT NULL
       AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.MAS_Apartments
        WHERE ApartmentId = @ApartmentId
    )
        SET @ApartmentId = NULL;

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        ApartmentId = @ApartmentId,
        apartOid = COALESCE(@Oid, (SELECT oid FROM dbo.MAS_Apartments WHERE ApartmentId = @ApartmentId)),
        tableKey = @tableKey,
        groupKey = @groupKey;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
    ORDER BY intOrder;
		   

    --3 tung o trong group
    --exec sp_get_data_fields @ApartmentId,'Apartment'
	IF (@ApartmentId = 0 OR @ApartmentId IS NULL) AND @Oid IS NULL
    BEGIN
        SELECT 
            a.id,
            a.table_name,
            a.field_name,
            a.view_type,
            a.data_type,
            a.ordinal,
            a.columnLabel,
            a.group_cd,
            a.columnDefault AS columnValue,
            a.columnClass,
            a.columnType,
            a.columnObject,
            a.isSpecial,
            a.isRequire,
            a.isDisable,
            a.IsVisiable,
            a.isEmpty,
            columnTooltip = ISNULL(a.columnTooltip, a.columnLabel),
            a.columnDisplay,
            a.isIgnore
        FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
        WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
        ORDER BY a.ordinal;
    END
	ELSE
    BEGIN

    SELECT 
        s.id,
        s.table_name,
        s.field_name,
        s.view_type,
        s.data_type,
        s.ordinal,
        s.columnLabel,
        s.group_cd,
        columnValue = ISNULL(CASE s.field_name
            WHEN 'roomCode' THEN ISNULL(a.RoomCodeView, a.[RoomCode])
            WHEN 'projectCd' THEN b.ProjectCd
            WHEN 'ApartmentId' THEN LOWER(CONVERT(NVARCHAR(500), a.[ApartmentId]))
            WHEN 'BuildingCd' THEN b.BuildingCd
            WHEN 'Floor' THEN CONVERT(NVARCHAR(250), a.Floor)
            WHEN 'WallArea' THEN CONVERT(NVARCHAR(250), a.WallArea)
            WHEN 'WaterwayArea' THEN CONVERT(NVARCHAR(250), a.WaterwayArea)
        END, s.columnDefault),
        s.columnClass,
        s.columnType,
        s.columnObject,
        s.isSpecial,
        s.isRequire,
        s.isDisable,
        s.IsVisiable,
        s.isEmpty,
        columnTooltip = ISNULL(s.columnTooltip, s.columnLabel),
        s.columnDisplay,
        s.isIgnore
    FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) s
        JOIN dbo.MAS_Apartments a ON ((@ApartmentId IS NOT NULL AND a.ApartmentId = @ApartmentId) OR (@Oid IS NOT NULL AND a.oid = @Oid))
        LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
    WHERE (s.IsVisiable = 1 OR s.isRequire = 1)
    ORDER BY s.ordinal;
    END
			
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_add_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'Apartment',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;