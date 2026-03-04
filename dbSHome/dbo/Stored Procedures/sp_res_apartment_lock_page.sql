
CREATE PROCEDURE [dbo].[sp_res_apartment_lock_page]
    @UserId       UNIQUEIDENTIFIER,
    @clientId     NVARCHAR(50) = NULL,
    @projectCd    NVARCHAR(50),
    @filter       NVARCHAR(200) = NULL,
    @keyword      NVARCHAR(200) = NULL,
    @status       INT = NULL,
    @gridWidth    INT = 0,
    @Offset       INT = 0,
    @PageSize     INT = 10,
    @apartment_id BIGINT = NULL,
    @device_id    BIGINT = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @GridKey NVARCHAR(100) = N'view_apartment_lock_page';

    SET @projectCd = ISNULL(@projectCd, N'');
    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = CASE WHEN ISNULL(@PageSize, 0) > 0 THEN @PageSize ELSE 10 END;
    IF @Offset < 0 SET @Offset = 0;

    SET @filter = NULLIF(LTRIM(RTRIM(ISNULL(@filter, N''))), N'');
    SET @keyword = NULLIF(LTRIM(RTRIM(ISNULL(@keyword, N''))), N'');

    DECLARE @search NVARCHAR(200) = COALESCE(@keyword, @filter);

    DROP TABLE IF EXISTS #base;
    CREATE TABLE #base
    (
          Oid UNIQUEIDENTIFIER NOT NULL
        , ProjectCd NVARCHAR(50) NULL
        , ApartmentId BIGINT NULL
        , DeviceId BIGINT NULL
        , LockName NVARCHAR(200) NULL
        , DoorCode NVARCHAR(100) NULL
        , Status INT NULL
        , LastUnlockDt DATETIME NULL
        , LastUnlockBy NVARCHAR(450) NULL
        , DeviceCode NVARCHAR(100) NULL
        , Vendor NVARCHAR(200) NULL
        , Model NVARCHAR(200) NULL
    );

    INSERT INTO #base
    SELECT
        l.oid,
        l.project_cd,
        l.apartment_id,
        l.device_id,
        l.lock_name,
        l.door_code,
        l.status,
        l.last_unlock_dt,
        l.last_unlock_by,
        d.device_code,
        d.vendor,
        d.model
    FROM dbo.apartment_lock l WITH (NOLOCK)
    JOIN dbo.lock_device d WITH (NOLOCK)
         ON d.oid = l.device_id
        AND d.is_deleted = 0
    WHERE l.is_deleted = 0
      AND (LTRIM(RTRIM(@projectCd)) = N'' OR l.project_cd = @projectCd)
      AND (@status IS NULL OR l.status = @status)
      AND (@apartment_id IS NULL OR l.apartment_id = @apartment_id)
      AND (@device_id IS NULL OR l.device_id = @device_id)
      AND (
            @search IS NULL OR
            ISNULL(l.lock_name, N'') LIKE N'%' + @search + N'%' OR
            ISNULL(l.door_code, N'') LIKE N'%' + @search + N'%' OR
            ISNULL(d.device_code, N'') LIKE N'%' + @search + N'%' OR
            ISNULL(d.vendor, N'') LIKE N'%' + @search + N'%' OR
            ISNULL(d.model, N'') LIKE N'%' + @search + N'%'
          );

    DECLARE @Total BIGINT = (SELECT COUNT_BIG(1) FROM #base);

    SELECT
        recordsTotal = @Total,
        recordsFiltered = @Total,
        gridKey = @GridKey,
        valid = 1;

    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
        ORDER BY [ordinal];
    END

    SELECT
        Oid,
        ProjectCd,
        ApartmentId,
        DeviceId,
        LockName,
        DoorCode,
        Status,
        LastUnlockDt,
        LastUnlockBy,
        DeviceCode,
        Vendor,
        Model
    FROM #base
    ORDER BY Oid DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END TRY
BEGIN CATCH
    SELECT CAST(0 AS BIT) AS valid, ERROR_MESSAGE() AS [messages];
END CATCH