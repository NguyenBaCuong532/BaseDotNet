-- =============================================
-- Author:		Namhm01
-- Create date: 27/05/2025
-- Description:	Import số TT xe
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_apartment_vehicle_num_import] 
	-- Add the parameters for the stored procedure here
	@UserId NVARCHAR(50)
	,@vehicleNumImport VehicleNumImportType readonly
	,@accept BIT = 0
	,@check BIT = 0 --- check = 0 thì là Import, check = 1 là Kiểm tra
    ,@livingTypeId int = 1
    ,@impId			uniqueidentifier = null
	,@fileName		nvarchar(200) = null
	,@fileType		nvarchar(100) = null
	,@fileSize		bigint	= null
	,@fileUrl		nvarchar(400) = null
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
	BEGIN TRY

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @valid BIT = 1
	DECLARE @messages NVARCHAR(MAX)
	DECLARE @recordsAccepted BIGINT

    IF NOT EXISTS(SELECT 1 FROM @vehicleNumImport)
	BEGIN
	SET @valid = 0
	SET @messages = N'File không có dữ liệu!'
	GOTO FINAL
	END

	DECLARE @checkTieuDe NVARCHAR(MAX)
		SELECT TOP 1 @checkTieuDe = ISNULL(VehicleNo,'') + ISNULL(VehicleNum,'')
		FROM @vehicleNumImport

		IF @checkTieuDe <> N'Biển số xe(*)Số TT(*)' AND @check = 0
		BEGIN
			SET @valid = 0
			SET @messages = N'File mẫu không đúng'
			GOTO FINAL
		END

	CREATE TABLE #vehicleImport(
	VehicleNum varchar(max),
	VehicleNo varchar(max)
	)

	INSERT INTO #vehicleImport
	(
		VehicleNo,
		VehicleNum
	)
	SELECT * FROM @vehicleNumImport

	DELETE TOP(1) FROM #vehicleImport WHERE @check = 0

	SELECT DISTINCT
	#vehicleImport.VehicleNo,
	#vehicleImport.VehicleNum,
	CASE WHEN ISNULL(#vehicleImport.VehicleNo, '') = '' THEN N'Biển số xe không được để trống !' ELSE '' END	+
	CASE WHEN ISNULL(#vehicleImport.VehicleNum, '') = '' THEN N'Số thứ tự xe không được để trống !' ELSE '' END
	AS errors
	INTO #VehicleNumImportType_Import
	FROM #vehicleImport
	LEFT JOIN MAS_CardVehicle ON UPPER(REPLACE(#vehicleImport.VehicleNo, '-', '')) = MAS_CardVehicle.VehicleNo


	    if @impId is null or not exists(select 1 from ImportFiles where impId = @impId) and @fileName is not null
	    begin
		    set @impId = newid()
		    INSERT INTO [dbo].[ImportFiles]
			        ([impId]
			        ,[import_type]
			        ,[upload_file_name]
			        ,[upload_file_type]
			        ,[upload_file_url]
			        ,[upload_file_size]
			        ,[created_by]
			        ,[created_dt]
			        ,[row_count]
			        --,[row_new]
			        --,[row_update]
			        --,[row_fail]
			        ,[updated_st])
		        VALUES
			        (@impId
			        ,'living_import'
			        ,@fileName
			        ,@fileType
			        ,@fileUrl
			        ,@fileSize
			        ,@UserId
			        ,getdate()
			        ,(select count(*) from #VehicleNumImportType_Import)
			        --,0
			        --,0
			        --,0
			        ,0
			        )
            END

		IF(@accept = 1)
			BEGIN
				UPDATE MAS_CardVehicle
				SET MAS_CardVehicle.VehicleNum = #VehicleNumImportType_Import.VehicleNum
				FROM MAS_CardVehicle
				JOIN #VehicleNumImportType_Import ON MAS_CardVehicle.VehicleNo = #VehicleNumImportType_Import.VehicleNo
			END	
		SET @recordsAccepted = (SELECT count(*) FROM #VehicleNumImportType_Import WHERE errors = '')
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK
		DECLARE @ErrorNum INT
			,@ErrorMsg VARCHAR(200)
			,@ErrorProc VARCHAR(50)
			,@SessionID INT
			,@AddlInfo VARCHAR(max)

		SET @ErrorNum = error_number()
		SET @ErrorMsg = 'sp_res_apartment_vehicle_num_import ' + error_message()
		SET @ErrorProc = error_procedure()
		SET @AddlInfo = '@UserId ' + @UserId
		SET @valid = 0
		SET @messages = error_message()

		EXEC utl_ErrorLog_Set @ErrorNum
			,@ErrorMsg
			,@ErrorProc
			,'sp_res_apartment_vehicle_num_import'
			,'Set'
			,@SessionID
			,@AddlInfo   
	END CATCH
	FINAL:
	IF @valid = 0
	BEGIN
		SELECT @valid as valid
			  ,@messages as messages
			  ,'view_vehicle_num_import_page' as GridKey
			  ,recordsTotal = 0
			  ,recordsFail = 0
			  ,recordsAccepted = case when @accept = 1 then @recordsAccepted else 0 end
			  ,accept = case when @recordsAccepted > 0 then 1 else 0 END

		SELECT * FROM dbo.fn_config_list_gets_lang('view_vehicle_num_import_page', 500, @acceptLanguage)
	
		SELECT NULL

		select impId = @impId, fileName = @fileName, fileType = @fileType, fileSize = @fileSize, fileUrl = @fileUrl

		GOTO FINAL2
	END
		SELECT @valid as valid
		  ,@messages as messages
		  ,'view_vehicle_num_import_page' as GridKey
		  ,recordsTotal = (select count(*) from #VehicleNumImportType_Import)
		  ,recordsFail = (select count(*) from #VehicleNumImportType_Import) - @recordsAccepted
		  ,recordsAccepted = case when @accept = 1 then @recordsAccepted else 0 end
		  ,accept = case when @recordsAccepted > 0 then 1 else 0 end

	SELECT * FROM dbo.fn_config_list_gets_lang('view_vehicle_num_import_page', 500, @acceptLanguage)
	
	SELECT
		 VehicleNo
		 ,VehicleNum
        ,apccept = @accept
		,CASE 
			WHEN errors = ''
				THEN
					case when @valid = 1 and @accept = 1 then N'<span class="' + 'bg-success' + ' noti-number ml5">' + 'Done' + '</span>'
						when @valid = 0 and @accept = 1 then N'<span class="' + 'bg-warning' + ' noti-number ml5">' + 'Error' + '</span>'
						else N'<span class="' + 'bg-success' + ' noti-number ml5">' + 'OK' + '</span>' end
				--ELSE N'<span class="' + 'bg-danger' + ' noti-number ml5">' + STUFF(errors, 1, 2, '') + '</span>'
				ELSE N'<span class="' + 'bg-danger' + ' noti-number ml5">' + errors + '</span>'  
				
			END errors
	FROM #VehicleNumImportType_Import
    order by errors

	select impId = @impId, fileName = @fileName, fileType = @fileType, fileSize = @fileSize, fileUrl = @fileUrl 
END
FINAL2: