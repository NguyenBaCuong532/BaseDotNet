
-- 8. [UPDATE] SP DEVICE Draft (Enable 'Load from Category')
-- Logic: If matching Category exists, use it to fill empty fields.
CREATE   PROCEDURE [dbo].[sp_res_elevator_device_draft]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@Id int = 0
	,@HardwareId nvarchar(50) = NULL
	,@FloorNumber int = NULL
	,@FloorName nvarchar(50) = NULL
	,@ElevatorBank int = NULL
	,@ElevatorShaftName nvarchar(30) = NULL
	,@ElevatorShaftNumber int = NULL
	,@ProjectCd nvarchar(30) = NULL
	,@buildingCd nvarchar(30) = NULL
	,@areaCd nvarchar(50) = NULL
	,@BuildZone nvarchar(50) = NULL
	,@IsActived bit = 0
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
	DECLARE @group_key VARCHAR(50) = 'common_group'
	DECLARE @table_key VARCHAR(50) = 'MAS_Elevator_Device'

	SELECT id = @id, tableKey = @table_key, groupKey = @group_key;
	SELECT * FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage) ORDER BY intOrder;

	DROP TABLE IF EXISTS #tempIn
	SELECT b.* INTO #tempIn FROM MAS_Elevator_Device b WHERE 0 = 1

    -- Logic: Check for matching Category template
    DECLARE @TemplateId INT = NULL
    SELECT TOP 1 @TemplateId = Id FROM MAS_Elevator_Device_Category
    WHERE ProjectCd = @ProjectCd AND buildingCd = @buildingCd

	IF @TemplateId IS NOT NULL
	BEGIN
		-- Use Template values, prioritize input if provided
		INSERT INTO #tempIn (HardwareId, FloorNumber, FloorName, ElevatorBank, ElevatorShaftName, ElevatorShaftNumber, ProjectCd, AreaCd, BuildZone, IsActived, created_at, buildingCd, oid)
		SELECT 
			ISNULL(NULLIF(@HardwareId, ''), HardwareId),
			@FloorNumber,
			@FloorName,
			CASE WHEN @ElevatorBank <> 0 THEN @ElevatorBank ELSE ElevatorBank END,
			ISNULL(NULLIF(@ElevatorShaftName, ''), ElevatorShaftName),
			CASE WHEN @ElevatorShaftNumber <> 0 THEN @ElevatorShaftNumber ELSE ElevatorShaftNumber END,
			ISNULL(@ProjectCd, ProjectCd), @AreaCd,
			@BuildZone, 1, GETDATE(), ISNULL(@buildingCd, buildingCd),
			ISNULL(oid, newid())
		FROM MAS_Elevator_Device_Category WHERE Id = @TemplateId
	END
	ELSE
	BEGIN
		INSERT INTO #tempIn (HardwareId, FloorNumber, FloorName, ElevatorBank, ElevatorShaftName, ElevatorShaftNumber, ProjectCd, buildingCd, AreaCd, BuildZone, IsActived, created_at, oid)
		SELECT @HardwareId, ISNULL(@FloorNumber, 0), ISNULL((SELECT TOP 1 FloorName FROM MAS_Elevator_Floor f WHERE f.ProjectCd = @projectCd AND f.AreaCd = @areaCd AND FloorNumber = ISNULL(@FloorNumber, 0)), ''), ISNULL(@ElevatorBank, 0), ISNULL(@ElevatorShaftName, ''), ISNULL(@ElevatorShaftNumber, 0), ISNULL(@ProjectCd, ''), ISNULL(@buildingCd, ''), ISNULL(@areaCd, ''), ISNULL(@BuildZone, ''), @IsActived, GETDATE(), newid()
	END

	SELECT a.id, table_name, field_name, view_type, data_type, ordinal, columnLabel, group_cd,
		CASE data_type 
		WHEN 'nvarchar' THEN CONVERT(NVARCHAR(350), CASE field_name 
			WHEN 'HardwareId' THEN b.HardwareId
			WHEN 'ElevatorShaftName' THEN b.ElevatorShaftName
			WHEN 'AreaCd' THEN b.AreaCd
			WHEN 'FloorName' THEN b.FloorName
			WHEN 'buildingCd' THEN b.buildingCd
			WHEN 'BuildZone' then b.BuildZone
			WHEN 'ProjectCd' then b.ProjectCd
			END) 
		WHEN 'datetime' THEN CONVERT(NVARCHAR(50), CASE field_name WHEN 'created_at' THEN FORMAT(b.created_at,'dd/MM/yyyy HH:mm:ss') END)
		WHEN 'bit' THEN CASE WHEN b.IsActived = 0 THEN 'false' ELSE 'true' END
		ELSE CONVERT(NVARCHAR(50), CASE field_name WHEN 'FloorNumber' THEN b.FloorNumber WHEN 'ElevatorBank' THEN b.ElevatorBank WHEN 'ElevatorShaftNumber' THEN b.ElevatorShaftNumber END) 
		END AS columnValue,
		columnClass, columnType,
		columnObject = CASE WHEN a.field_name = 'buildingCd' THEN columnObject + b.ProjectCd 
			WHEN a.field_name = 'AreaCd' THEN columnObject + b.buildingCd + '&projectCd=' + b.ProjectCd
			WHEN a.field_name = 'FloorNumber' THEN ISNULL(columnObject,'') + '?areaCd=' + ISNULL(b.AreaCd,'') + '&ProjectCd=' + b.ProjectCd
			WHEN a.field_name = 'BuildZone' THEN columnObject + '?projectCd=' + b.ProjectCd + '&AreaCd=' + ISNULL(b.AreaCd,'')
			ELSE columnObject END,
		isSpecial, isRequire, isDisable, isVisiable, ISNULL(a.columnTooltip,[columnLabel]) AS columnTooltip, isIgnore
	FROM dbo.fn_config_form_gets(@table_key, @acceptLanguage) a
	CROSS JOIN #tempIn b
	WHERE a.table_name = @table_key AND (a.isVisiable = 1 OR a.isRequire = 1)
	ORDER BY ordinal

END TRY
BEGIN CATCH
	DECLARE @ErrorNum int, @ErrorMsg varchar(200), @ErrorProc varchar(50), @SessionID int, @AddlInfo varchar(max)
	SET @ErrorNum = ERROR_NUMBER(); SET @ErrorMsg = 'sp_res_elevator_device_draft ' + ERROR_MESSAGE(); SET @ErrorProc = ERROR_PROCEDURE();
	EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'elevator', 'SET', @SessionID, ''
END CATCH