CREATE   PROCEDURE [dbo].[sp_res_apartment_changeRoomCode_field] 
	@UserId UNIQUEIDENTIFIER = NULL,
	@acceptLanguage NVARCHAR(50) = N'vi-VN',
	@Oid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID)
	@roomCode NVARCHAR(450) = NULL, -- Backward compatible
	@project_code NVARCHAR(450) = NULL,
	@buildingCd NVARCHAR(450) = NULL -- Backward compatible
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
				Oid = NULL,
				roomCode = NULL,
				buildingCd = NULL,
				tableKey = N'apartment_change_roomCode',
				groupKey = N'common_group';
			RETURN;
		END
	END

	-- Khai báo biến
	DECLARE @tableKey NVARCHAR(100) = N'apartment_change_roomCode';
	DECLARE @groupKey NVARCHAR(200) = N'common_group';
	DECLARE @ActualOid UNIQUEIDENTIFIER = NULL;
	DECLARE @ActualRoomCode NVARCHAR(450) = NULL;
	DECLARE @ActualBuildingCd NVARCHAR(450) = NULL;

	-- Xác định Oid từ roomCode và buildingCd nếu có (có kiểm tra tenant_oid)
	IF @Oid IS NOT NULL
	BEGIN
		SELECT @ActualOid = @Oid, @ActualRoomCode = a.RoomCode, @ActualBuildingCd = b.BuildingCd
		FROM MAS_Apartments a
		LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
		WHERE a.oid = @Oid
		  AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
	END
	ELSE IF @roomCode IS NOT NULL AND @buildingCd IS NOT NULL
	BEGIN
		SELECT @ActualOid = a.oid, @ActualRoomCode = @roomCode, @ActualBuildingCd = @buildingCd
		FROM MAS_Apartments a
		LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
		WHERE a.RoomCode = @roomCode
		  AND b.BuildingCd = @buildingCd
		  AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
	END

	-- =============================================
	-- RESULT SET 1: INFO - Thông tin cơ bản
	-- =============================================
	SELECT 
		Oid = @ActualOid,
		roomCode = @ActualRoomCode,
		buildingCd = @ActualBuildingCd,
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
	-- Lấy ra từng ô trong group
	
		SELECT s.id
			, s.[table_name]
			, s.[field_name]
			, s.[view_type]
			, s.[data_type]
			, s.[ordinal]
			, s.[columnLabel]
			, s.[group_cd]
			, columnValue = ISNULL(CASE s.[field_name]
					WHEN 'Oid' THEN LOWER(CONVERT(NVARCHAR(100), @ActualOid))
					WHEN 'roomCode'
						THEN a.RoomCode
					WHEN 'buildingCd'
						THEN a.BuildingCd
					WHEN 'roomCodeView'
						THEN a.RoomCodeView
				END, s.[columnDefault])
			, s.[columnClass]
			, s.[columnType]
			, s.[columnObject]
			, s.[isSpecial]
			, s.[isRequire]
			, s.[isDisable]
			, s.[IsVisiable]
			, s.[isEmpty]
			, columnTooltip = ISNULL(s.columnTooltip, s.[columnLabel])
			, s.[columnDisplay]
			, s.[isIgnore]
		FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) s
		LEFT JOIN MAS_Apartments a ON a.oid = @ActualOid
		WHERE (s.IsVisiable = 1 OR s.isRequire = 1)
		ORDER BY s.ordinal;
	
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_changeRoomCode_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Apartments'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;