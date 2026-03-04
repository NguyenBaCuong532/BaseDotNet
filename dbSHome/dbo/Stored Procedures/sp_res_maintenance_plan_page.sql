CREATE   PROCEDURE [dbo].[sp_res_maintenance_plan_page]
    @userId UNIQUEIDENTIFIER = NULL,
    @filter NVARCHAR(100) = NULL,
    @clientId NVARCHAR(50) = NULL,
    @Status INT = NULL,
    @PlanType NVARCHAR(50) = NULL,
    @Priority INT = NULL,
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
    DECLARE @GridKey NVARCHAR(100) = 'view_maintenance_plan_page';

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = CASE WHEN ISNULL(@PageSize, 0) > 0 THEN @PageSize ELSE 10 END;
    SET @filter = ISNULL(@filter, '');

    IF @PageSize = 0 SET @PageSize = 10;
    IF @Offset  < 0 SET @Offset  = 0;

    -- Total
    SELECT @Total = COUNT(1)
    FROM maintenance_plan p WITH (NOLOCK)
    WHERE p.is_delete = 0
      AND (@Status IS NULL OR p.status = @Status)
      AND (@PlanType IS NULL OR p.maintenance_type = @PlanType)
      AND (@Priority IS NULL OR p.priority = @Priority)
      AND (@BuildingCd IS NULL OR p.building_cds LIKE N'%' + @BuildingCd + N'%')
      AND (@FromDate IS NULL OR p.start_date >= @FromDate)
      AND (@ToDate IS NULL OR p.start_date <= @ToDate)
      AND (@filter = '' 
           OR p.plan_code LIKE N'%' + @filter + N'%'
           OR p.plan_name LIKE N'%' + @filter + N'%');

    -- Result 1: root
    SELECT  recordsTotal   = @Total,
            recordsFiltered= @Total,
            gridKey        = @GridKey,
            valid          = 1;

    -- Result 2: grid config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
        ORDER BY [ordinal];
    END;

    -- Result 3: Data
    SELECT  p.oid AS Oid,
            p.plan_code AS PlanCode,
            p.plan_name AS PlanName,
            p.maintenance_type AS MaintenanceType,
            p.frequency AS Frequency,
            CONVERT(NVARCHAR(10), p.start_date, 103) AS StartDate,
            CONVERT(NVARCHAR(10), p.end_date, 103) AS EndDate,
            p.status AS Status,
            CASE p.status
                WHEN 0 THEN N'Nháp'
                WHEN 1 THEN N'Hoạt động'
                WHEN 2 THEN N'Hoàn thành'
                WHEN 3 THEN N'Đã hủy'
                ELSE N'Không xác định'
            END AS StatusName,
            p.priority AS Priority,
            p.create_by AS CreateBy,
            CONVERT(NVARCHAR(10), p.create_at, 103) AS CreateAt
    FROM maintenance_plan p WITH (NOLOCK)
    WHERE p.is_delete = 0
      AND (@Status IS NULL OR p.status = @Status)
      AND (@PlanType IS NULL OR p.maintenance_type = @PlanType)
      AND (@Priority IS NULL OR p.priority = @Priority)
      AND (@BuildingCd IS NULL OR p.building_cds LIKE N'%' + @BuildingCd + N'%')
      AND (@FromDate IS NULL OR p.start_date >= @FromDate)
      AND (@ToDate IS NULL OR p.start_date <= @ToDate)
      AND (@filter = '' 
           OR p.plan_code LIKE N'%' + @filter + N'%'
           OR p.plan_name LIKE N'%' + @filter + N'%')
    ORDER BY p.create_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum  INT, @ErrorMsg  VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum  = ERROR_NUMBER();
    SET @ErrorMsg  = 'sp_res_maintenance_plan_page ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo  = '';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'MaintenancePlan', 'GetPage', @SessionID, @AddlInfo;
END CATCH;