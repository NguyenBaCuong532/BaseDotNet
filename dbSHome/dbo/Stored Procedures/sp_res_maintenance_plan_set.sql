CREATE   PROCEDURE [dbo].[sp_res_maintenance_plan_set]
    @Oid UNIQUEIDENTIFIER = NULL,
    @plan_code NVARCHAR(50) = NULL,
    @plan_name NVARCHAR(200) = NULL,
    @description NVARCHAR(MAX) = NULL,
    @maintenance_type NVARCHAR(50) = NULL,
    @priority INT = NULL,
    @frequency NVARCHAR(50) = NULL,
    @start_date DATE = NULL,
    @end_date DATE = NULL,
    @execution_start_time TIME(7) = NULL,
    @execution_end_time TIME(7) = NULL,
    @auto_notification BIT = NULL,
    @area_cd NVARCHAR(50) = NULL,
    @building_cds NVARCHAR(MAX) = NULL,
    @asset_oids NVARCHAR(MAX) = NULL,
    @assignment_type NVARCHAR(50) = NULL,
    @assignee_oid UNIQUEIDENTIFIER = NULL,
    @team_oid UNIQUEIDENTIFIER = NULL,
    @external_unit NVARCHAR(200) = NULL,
    @supervisor_oid UNIQUEIDENTIFIER = NULL,
    @estimated_hours DECIMAL(18,2) = NULL,
    @status INT = 0,
    @userId NVARCHAR(450) = NULL,
    @siteId UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;

    IF @siteId IS NULL
    BEGIN
         SELECT valid = 0, message = 'SiteId is required'; 
         RETURN;
    END

    DECLARE @IsNew BIT = 0;
    DECLARE @RetOid UNIQUEIDENTIFIER = @Oid;

    IF @Oid IS NULL OR NOT EXISTS (SELECT 1 FROM maintenance_plan WHERE oid = @Oid)
    BEGIN
        SET @IsNew = 1;
        SET @RetOid = NEWID();
        
        -- Generate Plan Code
        IF @plan_code IS NULL OR @plan_code = ''
        BEGIN
             SET @plan_code = 'MP-' + CONVERT(NVARCHAR(8), GETDATE(), 112) + '-' + LEFT(NEWID(), 4);
        END

        INSERT INTO maintenance_plan (
          oid, site_id, plan_code, plan_name, [description], maintenance_type, priority,
          frequency, start_date, end_date, execution_start_time, execution_end_time,
          auto_notification, area_cd, building_cds, asset_oids, assignment_type,
          assignee_oid, team_oid, external_unit, supervisor_oid, estimated_hours, status,
          create_by, create_at, is_delete
        )
        VALUES (
          @RetOid, @siteId, @plan_code, @plan_name, @description, @maintenance_type, @priority,
          @frequency, @start_date, @end_date, @execution_start_time, @execution_end_time,
          ISNULL(@auto_notification, 0), @area_cd, @building_cds, @asset_oids, @assignment_type,
          @assignee_oid, @team_oid, @external_unit, @supervisor_oid, @estimated_hours, ISNULL(@status, 0),
          @userId, GETDATE(), 0
        );

        INSERT INTO maintenance_plan_history (plan_oid, action_type, new_status, action_by, notes)
        VALUES (@RetOid, 'CREATE', @status, @userId, N'Created plan');
    END
    ELSE
    BEGIN
        DECLARE @OldStatus INT;
        SELECT @OldStatus = status FROM maintenance_plan WHERE oid = @Oid;

        UPDATE maintenance_plan
        SET plan_name = @plan_name,
            [description] = @description,
            maintenance_type = @maintenance_type,
            priority = @priority,
            frequency = @frequency,
            start_date = @start_date,
            end_date = @end_date,
            execution_start_time = @execution_start_time,
            execution_end_time = @execution_end_time,
            auto_notification = @auto_notification,
            area_cd = @area_cd,
            building_cds = @building_cds,
            asset_oids = @asset_oids,
            assignment_type = @assignment_type,
            assignee_oid = @assignee_oid,
            team_oid = @team_oid,
            external_unit = @external_unit,
            supervisor_oid = @supervisor_oid,
            estimated_hours = @estimated_hours,
            status = @status,
            modify_by = @userId,
            modify_at = GETDATE()
        WHERE oid = @Oid;

        INSERT INTO maintenance_plan_history (plan_oid, action_type, old_status, new_status, action_by, notes)
        VALUES (@Oid, 'UPDATE', @OldStatus, @status, @userId, N'Updated details');
    END

    SELECT valid = 1, message = 'Success', oid = @RetOid;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum  INT, @ErrorMsg  VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum  = ERROR_NUMBER();
    SET @ErrorMsg  = 'sp_res_maintenance_plan_set ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'MaintenancePlan', 'SetInfo', @SessionID, @AddlInfo;
    SELECT valid = 0, message = @ErrorMsg;
END CATCH;