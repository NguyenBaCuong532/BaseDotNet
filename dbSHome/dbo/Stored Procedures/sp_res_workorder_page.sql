-- =============================================
-- Author:      Agent
-- Create date: 2026-01-30
-- Description: Get Work Order page/list with grid columns
--              Following base repository pattern
-- =============================================
CREATE   PROCEDURE [dbo].[sp_res_workorder_page]
    @userId UNIQUEIDENTIFIER = NULL,
    @filter NVARCHAR(100) = NULL,
    @clientId NVARCHAR(50) = NULL,
    @Status INT = NULL,
    @MaintenanceType NVARCHAR(50) = NULL,
    @Priority INT = NULL,
    @AssigneeOid UNIQUEIDENTIFIER = NULL,
    @BuildingCd NVARCHAR(50) = NULL,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL,
    @gridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @Total   BIGINT = 0;
    DECLARE @GridKey NVARCHAR(100) = 'view_workorder_page';

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = CASE WHEN ISNULL(@PageSize, 0) > 0 THEN @PageSize ELSE 10 END;
    SET @filter = ISNULL(@filter, '');

    IF @PageSize = 0 SET @PageSize = 10;
    IF @Offset  < 0 SET @Offset  = 0;

    ----------------------------------------------------------------
    -- Total
    ----------------------------------------------------------------
    SELECT @Total = COUNT(1)
    FROM maintenance_work_order w WITH (NOLOCK)
    WHERE w.is_delete = 0
      AND (@Status IS NULL OR w.status = @Status)
      AND (@MaintenanceType IS NULL OR w.maintenance_type = @MaintenanceType)
      AND (@Priority IS NULL OR w.priority = @Priority)
      AND (@AssigneeOid IS NULL OR w.assignee_oid = @AssigneeOid)
      AND (@BuildingCd IS NULL OR w.building_cd = @BuildingCd)
      AND (@FromDate IS NULL OR w.start_datetime >= @FromDate)
      AND (@ToDate IS NULL OR w.start_datetime <= @ToDate)
      AND (@filter = '' 
           OR w.wo_code LIKE N'%' + @filter + N'%'
           OR w.title LIKE N'%' + @filter + N'%'
           OR w.location LIKE N'%' + @filter + N'%');

    -- Result 1: root
    SELECT  recordsTotal   = @Total,
            recordsFiltered= @Total,
            gridKey        = @GridKey,
            valid          = 1;

    ----------------------------------------------------------------
    -- Result 2: grid config
    ----------------------------------------------------------------
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
        ORDER BY [ordinal];
    END;

    ----------------------------------------------------------------
    -- Result 3: Data
    ----------------------------------------------------------------
    SELECT  w.oid AS Oid,
            w.wo_code AS WoCode,
            w.title AS Title,
            w.location AS Location,
            w.estimated_hours AS EstimatedHours,
            CONVERT(NVARCHAR(16), w.sla_deadline, 120) AS SlaDeadline,
            w.assignee_oid AS AssigneeOid,
            N'' AS AssigneeName,
            w.status AS Status,
            CASE w.status
                WHEN 0 THEN N'Đã lên lịch'
                WHEN 1 THEN N'Đang thực hiện'
                WHEN 2 THEN N'Hoàn thành'
                WHEN 3 THEN N'Quá hạn'
                WHEN 4 THEN N'Đã hủy'
                ELSE N'Không xác định'
            END AS StatusName,
            CASE w.status
                WHEN 0 THEN 'info'
                WHEN 1 THEN 'warning'
                WHEN 2 THEN 'success'
                WHEN 3 THEN 'danger'
                WHEN 4 THEN 'secondary'
                ELSE 'secondary'
            END AS StatusSeverity,
            w.priority AS Priority,
            CASE w.priority
                WHEN 1 THEN N'Thấp'
                WHEN 2 THEN N'Trung bình'
                WHEN 3 THEN N'Cao'
                WHEN 4 THEN N'Khẩn cấp'
                ELSE N'Trung bình'
            END AS PriorityName,
            w.maintenance_type AS MaintenanceType,
            w.building_cd AS BuildingCd,
            CONVERT(NVARCHAR(16), w.start_datetime, 120) AS StartDatetime,
            CONVERT(NVARCHAR(16), w.end_datetime, 120) AS EndDatetime,
            w.create_by AS CreateBy,
            CONVERT(NVARCHAR(10), w.create_at, 103) AS CreateAt
    FROM maintenance_work_order w WITH (NOLOCK)
    WHERE w.is_delete = 0
      AND (@Status IS NULL OR w.status = @Status)
      AND (@MaintenanceType IS NULL OR w.maintenance_type = @MaintenanceType)
      AND (@Priority IS NULL OR w.priority = @Priority)
      AND (@AssigneeOid IS NULL OR w.assignee_oid = @AssigneeOid)
      AND (@BuildingCd IS NULL OR w.building_cd = @BuildingCd)
      AND (@FromDate IS NULL OR w.start_datetime >= @FromDate)
      AND (@ToDate IS NULL OR w.start_datetime <= @ToDate)
      AND (@filter = '' 
           OR w.wo_code LIKE N'%' + @filter + N'%'
           OR w.title LIKE N'%' + @filter + N'%'
           OR w.location LIKE N'%' + @filter + N'%')
    ORDER BY w.create_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum  INT,
            @ErrorMsg  VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo  VARCHAR(MAX);

    SET @ErrorNum  = ERROR_NUMBER();
    SET @ErrorMsg  = 'sp_res_workorder_page ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo  = '';

    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'WorkOrder', 'GetPage', @SessionID, @AddlInfo;
END CATCH;