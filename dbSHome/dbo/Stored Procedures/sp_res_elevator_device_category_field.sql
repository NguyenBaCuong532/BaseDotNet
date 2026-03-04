CREATE   PROCEDURE [dbo].[sp_res_elevator_device_category_field]
	@UserId			UNIQUEIDENTIFIER = NULL,
	@id			int,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
	BEGIN TRY
		DECLARE @group_key VARCHAR(50) = 'common_group'
		DECLARE @table_key VARCHAR(50) = 'MAS_Elevator_Device_Category'

		SELECT id = @id, tableKey = @table_key, groupKey = @group_key;

		SELECT * FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage) ORDER BY intOrder;

		DROP TABLE IF EXISTS #tempIn
		SELECT b.* INTO #tempIn FROM MAS_Elevator_Device_Category b WHERE b.id = @id
	
		IF NOT EXISTS(SELECT 1 FROM #tempIn)
		BEGIN
			SET IDENTITY_INSERT #tempIn ON
			INSERT INTO #tempIn (oid, Id, HardwareId, ProjectCd, buildingCd,  IsActived, created_at)
			SELECT newid(), ISNULL((SELECT MAX(Id) FROM MAS_Elevator_Device_Category), 0) + 1, '', '', '', 1, GETDATE()
			SET IDENTITY_INSERT #tempIn OFF
		END

		SELECT a.id, table_name, field_name, view_type, data_type, ordinal, columnLabel, group_cd,
			CASE data_type 
			WHEN 'nvarchar' THEN CONVERT(NVARCHAR(350), CASE field_name 
				WHEN 'HardwareId' THEN b.HardwareId
				WHEN 'ProjectCd' THEN b.ProjectCd
				WHEN 'ElevatorShaftName' THEN b.ElevatorShaftName
				WHEN 'buildingCd' THEN b.buildingCd
				END) 
			WHEN 'datetime' THEN CONVERT(NVARCHAR(50), CASE field_name 
				WHEN 'created_at' THEN FORMAT(b.created_at,'dd/MM/yyyy HH:mm:ss')
				END)
			WHEN 'bit' THEN CASE WHEN b.IsActived = 0 THEN 'false' ELSE 'true' END
			ELSE CONVERT(NVARCHAR(50), CASE field_name 
				WHEN 'Id' THEN b.Id
				WHEN 'ElevatorBank' then b.ElevatorBank
				WHEN 'ElevatorShaftNumber' then b.ElevatorShaftNumber
				END) 
			END AS columnValue,
			columnClass, columnType,
			columnObject = CASE WHEN a.field_name = 'buildingCd' THEN columnObject + b.ProjectCd 
				ELSE columnObject END
			,isSpecial, isRequire, isDisable, isVisiable, ISNULL(a.columnTooltip,[columnLabel]) AS columnTooltip
		FROM dbo.fn_config_form_gets(@table_key, @acceptLanguage) a
		CROSS JOIN #tempIn b
		WHERE a.table_name = @table_key AND (a.isVisiable = 1 OR a.isRequire = 1)
		ORDER BY ordinal

	END TRY
	BEGIN CATCH
		DECLARE @ErrorNum int, @ErrorMsg varchar(200), @ErrorProc varchar(50), @SessionID int, @AddlInfo varchar(max)
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = 'sp_res_elevator_device_category_field ' + ERROR_MESSAGE()
		SET @ErrorProc = ERROR_PROCEDURE()
		EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Elevator_Device_Category', 'GET', @SessionID, ''
	END CATCH
END