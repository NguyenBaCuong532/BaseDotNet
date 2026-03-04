-- =============================================
-- Author:      Agent
-- Create date: 2026-01-28
-- Description: Create/Update Work Order
-- =============================================
CREATE   PROCEDURE [dbo].[sp_res_workorder_set]
    @Oid UNIQUEIDENTIFIER = NULL,
    @SiteId UNIQUEIDENTIFIER,
    @PlanOid UNIQUEIDENTIFIER = NULL,
    @Title NVARCHAR(200),
    @Description NVARCHAR(MAX) = NULL,
    @MaintenanceType NVARCHAR(50) = NULL,
    @Priority INT = 2,
    @Location NVARCHAR(200) = NULL,
    @BuildingCd NVARCHAR(50) = NULL,
    @Floor NVARCHAR(20) = NULL,
    @EquipmentOid UNIQUEIDENTIFIER = NULL,
    @EquipmentCode NVARCHAR(50) = NULL,
    @EquipmentModel NVARCHAR(100) = NULL,
    @AssigneeOid UNIQUEIDENTIFIER,
    @SupervisorOid UNIQUEIDENTIFIER = NULL,
    @EstimatedHours DECIMAL(5,2) = NULL,
    @StartDatetime DATETIME,
    @EndDatetime DATETIME,
    @SlaDeadline DATETIME = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @UserId UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    DECLARE @NewOid UNIQUEIDENTIFIER;
    DECLARE @WoCode NVARCHAR(50);
    DECLARE @IsNew BIT = 0;
    DECLARE @Message NVARCHAR(500) = N'';
    DECLARE @Valid BIT = 1;

    -- Validation
    IF @Title IS NULL OR LEN(TRIM(@Title)) = 0
    BEGIN
        SET @Message = N'Tiêu đề không được để trống';
        SET @Valid = 0;
    END

    IF @AssigneeOid IS NULL
    BEGIN
        SET @Message = N'Người thực hiện không được để trống';
        SET @Valid = 0;
    END

    IF @StartDatetime IS NULL OR @EndDatetime IS NULL
    BEGIN
        SET @Message = N'Thời gian bắt đầu và kết thúc không được để trống';
        SET @Valid = 0;
    END

    IF @StartDatetime > @EndDatetime
    BEGIN
        SET @Message = N'Thời gian bắt đầu phải trước thời gian kết thúc';
        SET @Valid = 0;
    END

    IF @Valid = 0
    BEGIN
        SELECT @Valid AS valid, @Message AS [message];
        RETURN;
    END

    -- Check if creating or updating
    IF @Oid IS NULL OR NOT EXISTS (SELECT 1 FROM maintenance_work_order WHERE oid = @Oid)
    BEGIN
        SET @IsNew = 1;
        SET @NewOid = ISNULL(@Oid, NEWID());
        
        -- Generate WO Code: WO-YYYYMMDD-XXX
        DECLARE @TodayCount INT;
        SELECT @TodayCount = COUNT(1) + 1
        FROM maintenance_work_order
        WHERE CONVERT(DATE, create_at) = CONVERT(DATE, GETDATE());
        
        SET @WoCode = 'WO-' + FORMAT(GETDATE(), 'yyyyMMdd') + '-' + RIGHT('000' + CAST(@TodayCount AS VARCHAR(3)), 3);
        
        -- Insert new work order
        INSERT INTO maintenance_work_order (
            oid, site_id, plan_oid, wo_code, title, [description],
            maintenance_type, priority, location, building_cd, floor,
            equipment_oid, equipment_code, equipment_model,
            assignee_oid, supervisor_oid, estimated_hours,
            start_datetime, end_datetime, sla_deadline,
            status, create_at, create_by
        )
        VALUES (
            @NewOid, @SiteId, @PlanOid, @WoCode, @Title, @Description,
            @MaintenanceType, @Priority, @Location, @BuildingCd, @Floor,
            @EquipmentOid, @EquipmentCode, @EquipmentModel,
            @AssigneeOid, @SupervisorOid, @EstimatedHours,
            @StartDatetime, @EndDatetime, @SlaDeadline,
            0, -- Status: Scheduled
            GETDATE(), @UserId
        );

        -- Log history
        INSERT INTO maintenance_work_order_history (work_order_oid, action_type, old_status, new_status, notes, action_by)
        VALUES (@NewOid, 'created', NULL, 0, N'Tạo mới phiếu bảo trì', @UserId);

        SET @Message = N'Tạo phiếu bảo trì thành công. Mã: ' + @WoCode;
    END
    ELSE
    BEGIN
        -- Update existing work order
        UPDATE maintenance_work_order
        SET title = @Title,
            [description] = @Description,
            maintenance_type = @MaintenanceType,
            priority = @Priority,
            location = @Location,
            building_cd = @BuildingCd,
            floor = @Floor,
            equipment_oid = @EquipmentOid,
            equipment_code = @EquipmentCode,
            equipment_model = @EquipmentModel,
            assignee_oid = @AssigneeOid,
            supervisor_oid = @SupervisorOid,
            estimated_hours = @EstimatedHours,
            start_datetime = @StartDatetime,
            end_datetime = @EndDatetime,
            sla_deadline = @SlaDeadline,
            completion_notes = @Notes,
            updated_at = GETDATE(),
            updated_by = @UserId
        WHERE oid = @Oid;

        -- Log history
        INSERT INTO maintenance_work_order_history (work_order_oid, action_type, notes, action_by)
        VALUES (@Oid, 'updated', N'Cập nhật thông tin phiếu bảo trì', @UserId);

        SET @NewOid = @Oid;
        SET @Message = N'Cập nhật phiếu bảo trì thành công';
    END

    -- Return result
    SELECT 1 AS valid, @Message AS [message], @NewOid AS oid;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_workorder_set ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'WorkOrder',
                          'SetInfo',
                          @SessionID,
                          @AddlInfo;

    SELECT 0 AS valid, N'Có lỗi xảy ra: ' + ERROR_MESSAGE() AS [message];
END CATCH;