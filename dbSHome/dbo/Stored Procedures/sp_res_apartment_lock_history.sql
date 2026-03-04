
CREATE PROCEDURE dbo.sp_res_apartment_lock_history
      @UserId UNIQUEIDENTIFIER
    , @clientId NVARCHAR(50) = NULL
    , @projectCd NVARCHAR(50) = NULL
    , @filter NVARCHAR(250) = NULL
    , @lock_id UNIQUEIDENTIFIER = NULL
    , @apartment_id BIGINT = NULL
    , @from_dt NVARCHAR(10) = NULL
    , @to_dt NVARCHAR(10) = NULL
    , @keyword NVARCHAR(200) = NULL
    , @gridWidth INT = 0
    , @Offset INT = 0
    , @PageSize INT = 10
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @GridKey NVARCHAR(100) = N'view_apartment_lock_history_page';
    DECLARE @from_date DATETIME = NULL;
    DECLARE @to_date DATETIME = NULL;

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = CASE WHEN ISNULL(@PageSize, 0) > 0 THEN @PageSize ELSE 10 END;
    IF @Offset < 0 SET @Offset = 0;

    SET @filter = NULLIF(LTRIM(RTRIM(ISNULL(@filter, N''))), N'');
    SET @keyword = NULLIF(LTRIM(RTRIM(ISNULL(@keyword, N''))), N'');

    DECLARE @search NVARCHAR(250) = COALESCE(@keyword, @filter);

    IF ISNULL(@from_dt, N'') <> N'' SET @from_date = CONVERT(DATETIME, @from_dt, 103);
    IF ISNULL(@to_dt, N'') <> N'' SET @to_date = DATEADD(DAY, 1, CONVERT(DATETIME, @to_dt, 103));

    DROP TABLE IF EXISTS #kw;
    CREATE TABLE #kw (kw NVARCHAR(4000) NOT NULL);

    IF @search IS NOT NULL
    BEGIN
        INSERT INTO #kw(kw)
        SELECT TRIM(value)
        FROM STRING_SPLIT(@search, ',')
        WHERE TRIM(value) <> '';
    END

    DROP TABLE IF EXISTS #base;
    CREATE TABLE #base
    (
          oid BIGINT NOT NULL
        , project_cd NVARCHAR(50) NULL
        , lock_id UNIQUEIDENTIFIER NULL
        , apartment_id BIGINT NULL
        , action_type NVARCHAR(200) NULL
        , action_by NVARCHAR(450) NULL
        , action_dt DATETIME NULL
        , result_code INT NULL
        , message NVARCHAR(MAX) NULL
        , client_id NVARCHAR(450) NULL
        , request_id NVARCHAR(200) NULL
        , door_code NVARCHAR(100) NULL
        , lock_name NVARCHAR(200) NULL
    );

    INSERT INTO #base
    SELECT
          h.oid
        , h.project_cd
        , h.lock_id
        , h.apartment_id
        , h.action_type
        , h.action_by
        , h.action_dt
        , h.result_code
        , h.message
        , h.client_id
        , h.request_id
        , l.door_code
        , l.lock_name
    FROM dbo.lock_history h
    LEFT JOIN dbo.apartment_lock l ON l.oid = h.lock_id
    WHERE (@projectCd IS NULL OR @projectCd = N'' OR h.project_cd = @projectCd)
      AND (@lock_id IS NULL OR h.lock_id = @lock_id)
      AND (@apartment_id IS NULL OR @apartment_id = 0 OR h.apartment_id = @apartment_id)
      AND (@from_date IS NULL OR h.action_dt >= @from_date)
      AND (@to_date IS NULL OR h.action_dt < @to_date)
      AND (
            @search IS NULL
            OR EXISTS (
                SELECT 1
                FROM #kw k
                WHERE ISNULL(h.action_type, N'') LIKE N'%' + k.kw + N'%'
                   OR ISNULL(h.action_by, N'') LIKE N'%' + k.kw + N'%'
                   OR ISNULL(h.message, N'') LIKE N'%' + k.kw + N'%'
                   OR ISNULL(l.door_code, N'') LIKE N'%' + k.kw + N'%'
                   OR ISNULL(l.lock_name, N'') LIKE N'%' + k.kw + N'%'
            )
      );

    DECLARE @Total BIGINT = (SELECT COUNT(1) FROM #base);

    SELECT recordsTotal = @Total,
           recordsFiltered = @Total,
           gridKey = @GridKey,
           valid = 1;

    IF @Offset = 0
    BEGIN
        SELECT *
        FROM dbo.fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY ordinal;
    END

    SELECT
          oid
        , project_cd
        , lock_id
        , apartment_id
        , action_type
        , action_by
        , action_dt
        , result_code
        , message
        , client_id
        , request_id
        , door_code
        , lock_name
    FROM #base
    ORDER BY action_dt DESC, oid DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END TRY
BEGIN CATCH
    SELECT recordsTotal = 0,
           recordsFiltered = 0,
           gridKey = N'view_apartment_lock_history_page',
           valid = 0;
END CATCH