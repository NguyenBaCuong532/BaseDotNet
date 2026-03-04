-- =============================================
-- Author:		System
-- Create date: 2025-01-29
-- Description:	Lấy thông tin field cho form MAS_Projects
-- Updated: Hỗ trợ cả projectCd và Oid (backward compatible)
-- =============================================
CREATE   PROCEDURE [dbo].[sp_res_project_field]
	@UserId				UNIQUEIDENTIFIER = NULL,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN',
	@projectCd			NVARCHAR(10) = NULL, -- Backward compatible
	@Oid				UNIQUEIDENTIFIER = NULL -- Ưu tiên sử dụng (GUID)
AS
BEGIN TRY
	SET NOCOUNT ON;
	
	DECLARE @group_key NVARCHAR(50) = N'common_group'
	DECLARE @table_key NVARCHAR(50) = N'MAS_Projects'
	DECLARE @ActualProjectCd NVARCHAR(10) = NULL
	DECLARE @ActualOid UNIQUEIDENTIFIER = NULL

	-- Xác định projectCd từ Oid nếu có
	IF @Oid IS NOT NULL AND @projectCd IS NULL
	BEGIN
		SELECT @ActualOid = @Oid, @ActualProjectCd = projectCd
		FROM MAS_Projects
		WHERE oid = @Oid;
	END
	ELSE IF @projectCd IS NOT NULL
	BEGIN
		SELECT @ActualOid = oid, @ActualProjectCd = @projectCd
		FROM MAS_Projects
		WHERE projectCd = @projectCd;
	END

	-- =============================================
	-- RESULT SET 1: INFO - Thông tin cơ bản
	-- =============================================
	SELECT 
		ProjectCd = ISNULL(@ActualProjectCd, @projectCd),
		projectOid = @ActualOid,
		tableKey = @table_key,
		groupKey = @group_key;

	-- =============================================
	-- RESULT SET 2: GROUPS - Nhóm field
	-- =============================================
	SELECT *
	FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
	ORDER BY intOrder;

	-- =============================================
	-- RESULT SET 3: DATA - Dữ liệu field
	-- =============================================
	DROP TABLE IF EXISTS #tempIn
	
	SELECT b.*
	INTO #tempIn
	FROM MAS_Projects b
	WHERE (@ActualOid IS NOT NULL AND b.oid = @ActualOid)
	   OR (@ActualProjectCd IS NOT NULL AND b.projectCd = @ActualProjectCd)
	
	IF NOT EXISTS(SELECT 1 FROM #tempIn)
	BEGIN
		INSERT INTO #tempIn (sub_projectCd, projectCd, projectName, investorName, address, oid)
		SELECT '', '', '', '', '', NEWID()
	END

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
						WHEN 'projectOid' THEN b.oid
					END))
				WHEN 'nvarchar' THEN CONVERT(NVARCHAR(350), 
					CASE a.[field_name] 
						WHEN 'projectCd' THEN b.projectCd
						WHEN 'projectName' THEN b.projectName
						WHEN 'address' THEN b.address
						WHEN 'bank_code' THEN b.bank_code
						WHEN 'timeWorking' THEN b.timeWorking
						WHEN 'bank_acc_no' THEN b.bank_acc_no
						WHEN 'bank_acc_name' THEN b.bank_acc_name
						WHEN 'bank_branch' THEN b.bank_branch
						WHEN 'bank_name' THEN b.bank_name
						WHEN 'mailSender' THEN b.mailSender
						WHEN 'investorName' THEN b.investorName
						WHEN 'representative_name' THEN b.representative_name
					END)
				WHEN 'datetime' THEN CONVERT(NVARCHAR(50), 
					CASE a.[field_name] 
						WHEN 'dayOfNotice1' THEN FORMAT(b.dayOfNotice1, 'dd/MM/yyyy HH:mm:ss')
						WHEN 'dayOfNotice2' THEN FORMAT(b.dayOfNotice2, 'dd/MM/yyyy HH:mm:ss')
						WHEN 'dayOfNotice3' THEN FORMAT(b.dayOfNotice3, 'dd/MM/yyyy HH:mm:ss')
						WHEN 'dayStopService' THEN FORMAT(b.dayStopService, 'dd/MM/yyyy HH:mm:ss')
					END)
				ELSE CONVERT(NVARCHAR(50),
					CASE a.[field_name] 
						WHEN 'dayOfIndexElectric' THEN b.dayOfIndexElectric
						WHEN 'dayOfIndexWater' THEN b.dayOfIndexWater
						WHEN 'caculateVehicleType' THEN b.caculateVehicleType
						WHEN 'type_discount_elec' THEN b.type_discount_elec
						WHEN 'type_discount_water' THEN b.type_discount_water
						WHEN 'is_proxy_payment' THEN b.is_proxy_payment
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
	SET @ErrorMsg = N'sp_res_project_field ' + ERROR_MESSAGE();
	SET @ErrorProc = ERROR_PROCEDURE();
	SET @AddlInfo = N'';
	EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Projects', N'GET', @SessionID, @AddlInfo;
END CATCH