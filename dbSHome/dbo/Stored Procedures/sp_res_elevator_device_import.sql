
CREATE   PROCEDURE [dbo].[sp_res_elevator_device_import] 
    @UserId UNIQUEIDENTIFIER = NULL,
    @ele_devices elevator_device_import_type readonly ,
	@accept NVARCHAR(50) = null,
    @accept_int BIT = NULL,
    @project_code NVARCHAR(50) = NULL,
    @impId UNIQUEIDENTIFIER = NULL,
    @fileName NVARCHAR(250) = NULL,
    @fileType NVARCHAR(50) = NULL,
    @fileSize INT = NULL,
    @fileUrl NVARCHAR(4000) = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(MAX);
    DECLARE @recordsAccepted BIGINT;
	SET @accept_int = CASE 
				WHEN LOWER(@accept) = 'true' OR @accept = '1' THEN 1
				WHEN LOWER(@accept) = 'false' OR @accept = '0' THEN 0
				ELSE NULL
			END;

    IF OBJECT_ID('tempdb..#temp') IS NOT NULL
        DROP TABLE #temp;

    -- Load dữ liệu từ TVP vào #temp + kiểm tra lỗi cơ bản
    SELECT *,
        CASE 
            WHEN ISNULL(hardwareId,'') = '' THEN N'; HardwareId không được để trống'
            WHEN ISNULL(projectCd,'') = '' THEN N'; ProjectCd không được để trống'
            ELSE '' 
        END errors
    INTO #temp
    FROM @ele_devices;

    -- Check trùng HardwareId trong DB
    --UPDATE t
    --SET errors = errors + N'; HardwareId đã tồn tại'
    --FROM #temp t
    --WHERE t.hardwareId IS NOT NULL
    --  AND EXISTS (SELECT 1 
    --              FROM dbo.MAS_Elevator_Device d 
    --              WHERE d.HardwareId = t.hardwareId);

    ---- Lưu file import vào ImportFiles (nếu chưa có)
    IF @impId IS NULL 
       OR NOT EXISTS (SELECT 1 FROM ImportFiles WHERE impId = @impId)
       AND @fileName IS NOT NULL
    BEGIN
        SET @impId = NEWID();

        INSERT INTO ImportFiles (
            impId, import_type, upload_file_name, upload_file_type, upload_file_url, 
            upload_file_size, created_by, created_dt, row_count
        )
        VALUES (
            @impId, 'elevatorDevice', @fileName, @fileType, @fileUrl, 
            @fileSize, CAST(@UserId AS NVARCHAR(50)), GETDATE(), (SELECT COUNT(*) FROM #temp)
        );
    END

    -- Nếu xác nhận import
    IF @accept_int = 1
    BEGIN
        BEGIN TRAN

			UPDATE [dbo].[ImportFiles]
			   SET row_new = 0,
				   row_update = (SELECT COUNT(*) FROM #temp WHERE errors = ''),
				   row_fail = (SELECT COUNT(*) FROM #temp WHERE errors != ''),
				   updated_st = 1,
				   updated_by = CAST(@UserId AS NVARCHAR(50)),
				   updated_dt = GETDATE()
			 WHERE impId = @impId;

			-- Cập nhật bản ghi đã có (HardwareId match)
			UPDATE d
			SET d.FloorNumber = t.floorNumber,
				d.FloorName = t.floorName,
				d.ElevatorBank = t.elevatorBank,
				d.ElevatorShaftName = t.elevatorShaftName,
				d.ElevatorShaftNumber = t.elevatorShaftNumber,
				d.ProjectCd = t.projectCd,
				d.AreaCd = t.buildCd,
				d.BuildZone = t.buildZone,
				d.IsActived = CAST(ISNULL(t.isActive,1) AS bit),
				d.created_at = GETDATE(),
				d.created_by = CAST(@UserId AS NVARCHAR(50))
			FROM dbo.MAS_Elevator_Device d
			INNER JOIN #temp t ON d.HardwareId = t.hardwareId
			WHERE t.errors = '';

			-- Thêm mới nếu chưa tồn tại
			INSERT INTO dbo.MAS_Elevator_Device (
				 HardwareId, FloorNumber, FloorName, ElevatorBank, ElevatorShaftName, ElevatorShaftNumber,
				ProjectCd, AreaCd, BuildZone, IsActived, created_at, created_by
			)
			SELECT t.hardwareId, t.floorNumber, t.floorName, t.elevatorBank, 
				   t.elevatorShaftName, t.elevatorShaftNumber, t.projectCd, t.buildCd, t.buildZone, 
				   ISNULL(t.isActive,1), GETDATE(), CAST(@UserId AS NVARCHAR(50))
			FROM #temp t
			WHERE 
			t.errors = '' AND 
			NOT EXISTS (SELECT 1 FROM dbo.MAS_Elevator_Device d WHERE d.HardwareId = t.hardwareId);

        COMMIT
    END

    SET @recordsAccepted = (SELECT COUNT(*) FROM #temp WHERE ISNULL(errors,'') = '');



END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), 
            @SessionID INT, @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_elevator_device_import ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc,
                          'elevatorDevice', 'IMPORT', @SessionID, @AddlInfo;
END CATCH;

    -- Trả về kết quả
    SELECT @valid as valid,
           @messages as messages,
           'view_elevator_device_import_page' as GridKey,
           recordsTotal = (SELECT COUNT(*) FROM #temp),
           recordsFail = (SELECT COUNT(*) FROM #temp) - @recordsAccepted,
           recordsAccepted = CASE WHEN @accept_int = 1 THEN @recordsAccepted ELSE 0 END,
           accept = CASE WHEN @recordsAccepted > 0 THEN 1 ELSE 0 END;

    SELECT * FROM dbo.fn_config_list_gets_lang('view_elevator_device_import_page', 500, @acceptLanguage);

    SELECT seq, hardwareId, floorNumber, floorName, elevatorBank, elevatorShaftName, 
           elevatorShaftNumber, projectCd, buildCd, buildZone,
           CASE 
               WHEN errors = '' THEN
                   CASE 
                       WHEN @valid = 1 AND @accept_int = 1 THEN N'<span class="bg-success noti-number ml5">Done</span>'
                       WHEN @valid = 0 AND @accept_int = 1 THEN N'<span class="bg-warning noti-number ml5">Error</span>'
                       ELSE N'<span class="bg-success noti-number ml5">OK</span>' 
                   END
               ELSE N'<span class="bg-danger noti-number ml5">' + STUFF(errors,1,2,'') + '</span>'
           END errors
    FROM #temp;

    SELECT impId = @impId, fileName = @fileName, fileType = @fileType, 
           fileSize = @fileSize, fileUrl = @fileUrl;