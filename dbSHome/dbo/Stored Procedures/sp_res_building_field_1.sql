-- =============================================
-- Author:		System
-- Create date: 2025-01-29
-- Description:	Lấy thông tin field cho form MAS_Buildings
-- Updated: Hỗ trợ cả buildingCd/id và Oid (backward compatible)
-- =============================================
CREATE   PROCEDURE [dbo].[sp_res_building_field]
	@UserId			UNIQUEIDENTIFIER = NULL,
	@acceptLanguage	NVARCHAR(50) = N'vi-VN',
	@projectCd		NVARCHAR(50) = NULL,
	@id				INT = NULL, -- Backward compatible (Id cũ)
	@buildingCd		NVARCHAR(50) = NULL, -- Backward compatible
	@Oid			UNIQUEIDENTIFIER = NULL -- Ưu tiên sử dụng (GUID)
AS
BEGIN TRY
	SET NOCOUNT ON;
	
	-- =============================================
	-- LẤY TENANT_OID TỪ USERS
	-- =============================================
	DECLARE @tenantOid UNIQUEIDENTIFIER = NULL;
	
	IF @UserId IS NOT NULL
	BEGIN
		SELECT @tenantOid = tenant_oid
		FROM Users
		WHERE userId = @UserId;
		
		-- Kiểm tra user có tenant_oid không
		IF @tenantOid IS NULL
		BEGIN
			SELECT 
				id = NULL,
				buildingCd = NULL,
				buildingOid = NULL,
				tableKey = N'MAS_Buildings',
				groupKey = N'common_group';
			RETURN;
		END
	END
	
	DECLARE @group_key NVARCHAR(50) = N'common_group'
	DECLARE @table_key NVARCHAR(50) = N'MAS_Buildings'
	DECLARE @ActualOid UNIQUEIDENTIFIER = NULL
	DECLARE @ActualId INT = NULL
	DECLARE @ActualBuildingCd NVARCHAR(50) = NULL

	-- Xác định Oid từ id hoặc buildingCd nếu có (có kiểm tra tenant_oid)
	IF @Oid IS NOT NULL
	BEGIN
		SELECT @ActualOid = @Oid, @ActualId = Id, @ActualBuildingCd = BuildingCd
		FROM MAS_Buildings
		WHERE oid = @Oid
		  AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
	END
	ELSE IF @id IS NOT NULL
	BEGIN
		SELECT @ActualOid = oid, @ActualId = @id, @ActualBuildingCd = BuildingCd
		FROM MAS_Buildings
		WHERE Id = @id
		  AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
	END
	ELSE IF @buildingCd IS NOT NULL AND @projectCd IS NOT NULL
	BEGIN
		SELECT @ActualOid = oid, @ActualId = Id, @ActualBuildingCd = @buildingCd
		FROM MAS_Buildings
		WHERE BuildingCd = @buildingCd AND ProjectCd = @projectCd
		  AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
	END

	-- =============================================
	-- TẠO DỮ LIỆU #tempIn TRƯỚC
	-- =============================================
	DROP TABLE IF EXISTS #tempIn
	
	SELECT b.*
	INTO #tempIn
	FROM MAS_Buildings b
	WHERE ((@Oid IS NOT NULL AND b.oid = @Oid)
	   OR (@id IS NOT NULL AND b.Id = @id)
	   OR (@buildingCd IS NOT NULL AND @projectCd IS NOT NULL AND b.BuildingCd = @buildingCd AND b.ProjectCd = @projectCd))
	   AND (@tenantOid IS NULL OR b.tenant_oid = @tenantOid)
	
	IF NOT EXISTS(SELECT 1 FROM #tempIn)
	BEGIN
		INSERT INTO #tempIn (Id, buildingCd, BuildingName, ProjectCd, intOrder, rowguid, oid, tenant_oid)
		SELECT 0, '', '', ISNULL(@projectCd, ''), 1, NEWID(), NEWID(), @tenantOid
	END

	-- =============================================
	-- RESULT SET 1: INFO - Thông tin cơ bản (từ #tempIn)
	-- =============================================
	SELECT 
		id = (SELECT TOP 1 Id FROM #tempIn),
		cd = (SELECT TOP 1 BuildingCd FROM #tempIn),
		gd = (SELECT TOP 1 oid FROM #tempIn),
		tableKey = @table_key,
		groupKey = @group_key;

	-- =============================================
	-- RESULT SET 2: GROUPS - Nhóm field
	-- =============================================
	SELECT *
	FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
	ORDER BY intOrder;

	-- =============================================
	-- RESULT SET 3: DATA - Dữ liệu field (từ #tempIn)
	-- =============================================

		
	SELECT 
		a.id,
		a.table_name,
		a.field_name,
		a.view_type,
		a.data_type,
		a.ordinal,
		a.columnLabel,
		a.group_cd,
		columnValue = ISNULL(
			CASE a.[data_type]
				WHEN 'uniqueidentifier' THEN LOWER(CONVERT(NVARCHAR(50), 
					CASE a.[field_name]
						WHEN 'oid' THEN b.oid
						WHEN 'buildingOid' THEN b.oid
					END))
				WHEN 'nvarchar' THEN CONVERT(NVARCHAR(350), 
					CASE a.[field_name] 
						WHEN 'ProjectCd' THEN b.projectCd
						WHEN 'BuildingCd' THEN b.BuildingCd
						WHEN 'BuildingName' THEN b.BuildingName
						WHEN 'ProjectName' THEN b.ProjectName
					END)
				WHEN 'datetime' THEN CONVERT(NVARCHAR(50), 
					CASE a.[field_name] 
						WHEN 'created_at' THEN FORMAT(b.created_at, 'dd/MM/yyyy HH:mm:ss')
					END)
				ELSE CONVERT(NVARCHAR(50),
					CASE a.[field_name] 
						WHEN 'intOrder' THEN b.intOrder
						WHEN 'Id' THEN b.Id
					END)
			END,
			a.columnDefault
		),
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
	FROM dbo.fn_config_form_gets(@table_key, @acceptLanguage) a
	CROSS JOIN #tempIn b
	WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
	ORDER BY a.ordinal
		
END TRY
BEGIN CATCH
	DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
			@SessionID INT, @AddlInfo VARCHAR(MAX);
	SET @ErrorNum = ERROR_NUMBER();
	SET @ErrorMsg = N'sp_res_building_field ' + ERROR_MESSAGE();
	SET @ErrorProc = ERROR_PROCEDURE();
	SET @AddlInfo = N'';
	EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Buildings', N'GET', @SessionID, @AddlInfo;
END CATCH