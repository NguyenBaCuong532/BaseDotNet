-- =============================================
-- Author:      AnhTT
-- Create date: 2026-01-28
-- Description: Get Work Order form fields (for GetInfo)
-- =============================================
CREATE   PROCEDURE [dbo].[sp_res_workorder_fields]
    @Oid UNIQUEIDENTIFIER = NULL,
    @userId UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @group_key VARCHAR(50) = 'workorder_form_group';
    DECLARE @table_key VARCHAR(50) = 'work_order';

    -- Result 1: Root info
    SELECT @Oid AS [Oid],
           tableKey = @table_key,
           groupKey = @group_key;

    -- Result 2: Field groups
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
    ORDER BY intOrder;

    -- Result 3: Field values
    IF EXISTS (SELECT 1 FROM maintenance_work_order WHERE oid = @Oid)
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
                   WHEN 'oid' THEN LOWER(CONVERT(NVARCHAR(100), w.oid))
                   WHEN 'wo_code' THEN w.wo_code
                   WHEN 'title' THEN w.title
                   WHEN 'maintenance_type' THEN w.maintenance_type
                   WHEN 'priority' THEN CONVERT(NVARCHAR(10), w.priority)
                   WHEN 'location' THEN w.location
                   WHEN 'building_cd' THEN w.building_cd
                   WHEN 'floor' THEN w.floor
                   WHEN 'description' THEN w.[description]
                   WHEN 'equipment_oid' THEN LOWER(CONVERT(NVARCHAR(100), w.equipment_oid))
                   WHEN 'assignee_oid' THEN LOWER(CONVERT(NVARCHAR(100), w.assignee_oid))
                   WHEN 'supervisor_oid' THEN LOWER(CONVERT(NVARCHAR(100), w.supervisor_oid))
                   WHEN 'estimated_hours' THEN CONVERT(NVARCHAR(20), w.estimated_hours)
                   WHEN 'start_datetime' THEN CONVERT(NVARCHAR(20), w.start_datetime, 120)
                   WHEN 'end_datetime' THEN CONVERT(NVARCHAR(20), w.end_datetime, 120)
                   WHEN 'sla_deadline' THEN CONVERT(NVARCHAR(20), w.sla_deadline, 120)
                   WHEN 'notes' THEN w.completion_notes
                   WHEN 'status' THEN CONVERT(NVARCHAR(10), w.status)
               END, s.[columnDefault]) AS columnValue,
               s.[columnClass],
               s.[columnType],
               s.[columnObject],
               s.[isSpecial],
               s.[isRequire],
               CASE 
                   WHEN s.field_name IN ('oid', 'wo_code', 'status') 
                   THEN 1 
                   ELSE s.[isDisable] 
               END AS [isDisable],
               s.[isVisiable],
               NULL AS [IsEmpty],
               ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
               , s.[columnDisplay]
               , s.[isIgnore]
        FROM fn_config_form_gets(@table_key, @acceptLanguage) s
        CROSS JOIN maintenance_work_order w
        WHERE s.view_type = 2
          AND w.oid = @Oid
        ORDER BY s.ordinal;
    END
    ELSE
    BEGIN
        -- New record - return default values
        SELECT s.[table_name],
               s.[field_name],
               s.[view_type],
               s.[data_type],
               s.[ordinal],
               s.[columnLabel],
               s.[group_cd],
               CASE 
                   WHEN s.field_name = 'status' THEN '0'
                   WHEN s.field_name = 'priority' THEN '2'
                   WHEN s.field_name = 'start_datetime' THEN CONVERT(NVARCHAR(20), GETDATE(), 120)
                   WHEN s.field_name = 'end_datetime' THEN CONVERT(NVARCHAR(20), DATEADD(HOUR, 2, GETDATE()), 120)
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
        WHERE s.view_type = 2
        ORDER BY s.ordinal;
    END

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_workorder_fields ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'WorkOrder',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;