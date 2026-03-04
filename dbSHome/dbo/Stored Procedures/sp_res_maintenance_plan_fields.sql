CREATE   PROCEDURE [dbo].[sp_res_maintenance_plan_fields]
    @Oid UNIQUEIDENTIFIER = NULL,
    @userId UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @group_key VARCHAR(50) = 'maintenance_plan_form_group';
    DECLARE @table_key VARCHAR(50) = 'maintenance_plan';

    -- Result 1: Root info
    SELECT @Oid AS [Oid],
           tableKey = @table_key,
           groupKey = @group_key;

    -- Result 2: Field groups
    -- Assuming fn_get_field_group is standard wrapper. If not, replace with SELECT.
    -- Logic: usually SELECT * FROM sys_config_data_view WHERE group_key = ...
    -- I'll use explicit select to be safe if function is missing/renamed, based on sys_config_data.
    SELECT [key_2] AS [group_cd],
           [par_desc] AS [group_name],
           [intOrder]
    FROM [dbo].[sys_config_data]
    WHERE [key_1] = @group_key AND [isUsed] = 1
    ORDER BY [intOrder];

    -- Result 3: Field values
    IF EXISTS (SELECT 1 FROM maintenance_plan WHERE oid = @Oid)
    BEGIN
        SELECT s.[id],
               s.[table_name],
               s.[field_name],
               s.[view_type],
               s.[data_type],
               s.[ordinal],
               s.[columnLabel],
               s.[group_cd],
               ISNULL(CASE s.[field_name]
                   WHEN 'oid' THEN LOWER(CONVERT(NVARCHAR(100), p.oid))
                   WHEN 'plan_code' THEN p.plan_code
                   WHEN 'plan_name' THEN p.plan_name
                   WHEN 'description' THEN p.[description]
                   WHEN 'maintenance_type' THEN p.maintenance_type
                   WHEN 'priority' THEN CONVERT(NVARCHAR(10), p.priority)
                   WHEN 'frequency' THEN p.frequency
                   WHEN 'start_date' THEN CONVERT(NVARCHAR(20), p.start_date, 120)
                   WHEN 'end_date' THEN CONVERT(NVARCHAR(20), p.end_date, 120)
                   WHEN 'execution_start_time' THEN CONVERT(NVARCHAR(8), p.execution_start_time)
                   WHEN 'execution_end_time' THEN CONVERT(NVARCHAR(8), p.execution_end_time)
                   WHEN 'auto_notification' THEN CASE WHEN p.auto_notification = 1 THEN 'true' ELSE 'false' END
                   WHEN 'area_cd' THEN p.area_cd
                   WHEN 'building_cds' THEN p.building_cds
                   WHEN 'asset_oids' THEN p.asset_oids
                   WHEN 'assignment_type' THEN p.assignment_type
                   WHEN 'assignee_oid' THEN LOWER(CONVERT(NVARCHAR(100), p.assignee_oid))
                   WHEN 'team_oid' THEN LOWER(CONVERT(NVARCHAR(100), p.team_oid))
                   WHEN 'external_unit' THEN p.external_unit
                   WHEN 'supervisor_oid' THEN LOWER(CONVERT(NVARCHAR(100), p.supervisor_oid))
                   WHEN 'estimated_hours' THEN CONVERT(NVARCHAR(20), p.estimated_hours)
                   WHEN 'status' THEN CONVERT(NVARCHAR(10), p.status)
               END, s.[columnDefault]) AS columnValue,
               s.[columnClass],
               s.[columnType],
               s.[columnObject],
               s.[isSpecial],
               s.[isRequire],
               CASE
                   WHEN s.field_name IN ('oid', 'plan_code', 'status')
                   THEN 1
                   ELSE s.[isDisable]
               END AS [isDisable],
               s.[isVisiable],
               NULL AS [IsEmpty],
               ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
               , s.[columnDisplay]
               , s.[isIgnore]
        FROM fn_config_form_gets(@table_key, @acceptLanguage) s
        CROSS JOIN maintenance_plan p
        WHERE p.oid = @Oid
        ORDER BY s.ordinal;
    END
    ELSE
    BEGIN
        -- New
        SELECT s.[id],
               s.[table_name],
               s.[field_name],
               s.[view_type],
               s.[data_type],
               s.[ordinal],
               s.[columnLabel],
               s.[group_cd],
               CASE
                   WHEN s.field_name = 'status' THEN '0'
                   WHEN s.field_name = 'priority' THEN '2'
                   WHEN s.field_name = 'start_date' THEN CONVERT(NVARCHAR(20), GETDATE(), 120)
                   ELSE s.columnDefault
               END AS columnValue,
               s.[columnClass],
               s.[columnType],
               s.[columnObject],
               s.[isSpecial],
               s.[isRequire],
               s.[isDisable],
               s.[isVisiable],
               NULL AS [IsEmpty],
               ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
               , s.[columnDisplay]
               , s.[isIgnore]
        FROM fn_config_form_gets(@table_key, @acceptLanguage) s
        ORDER BY s.ordinal;
    END

END TRY
BEGIN CATCH
    DECLARE @ErrorNum  INT, @ErrorMsg  VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum  = ERROR_NUMBER();
    SET @ErrorMsg  = 'sp_res_maintenance_plan_fields ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo  = '';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'MaintenancePlan', 'GetInfo', @SessionID, @AddlInfo;
END CATCH;