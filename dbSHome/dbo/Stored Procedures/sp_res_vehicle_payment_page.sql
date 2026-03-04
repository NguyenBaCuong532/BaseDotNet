
CREATE PROCEDURE [dbo].[sp_res_vehicle_payment_page]
      @userId         UNIQUEIDENTIFIER   = NULL
    , @filter         NVARCHAR(100)   = NULL
    , @Offset         INT             = 0
    , @PageSize       INT             = 10
    , @gridWidth      INT             = 0
    , @acceptLanguage NVARCHAR(50)    = N'vi-VN'
    , @CardVehicleId  INT             = NULL
    , @PaymentStatus  NVARCHAR(50)    = NULL
    , @ProjectCd      NVARCHAR(40)    = NULL
    , @ApartmentId    NVARCHAR(50)    = NULL
    , @FromDate       DATETIME        = NULL
    , @ToDate         DATETIME        = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GridKey NVARCHAR(100) = N'view_res_vehicle_payment_page';

    BEGIN TRY
        /* ===== Normalize input ===== */
        SET @Offset   = ISNULL(@Offset, 0);
        SET @PageSize = ISNULL(@PageSize, 10);
        IF @PageSize <= 0 SET @PageSize = 10;
        IF @Offset  <  0 SET @Offset  = 0;

        SET @filter        = ISNULL(@filter, N'');
        SET @PaymentStatus = NULLIF(LTRIM(RTRIM(@PaymentStatus)), N'');
        SET @ProjectCd     = NULLIF(LTRIM(RTRIM(@ProjectCd)), N'');
        SET @ApartmentId   = NULLIF(LTRIM(RTRIM(@ApartmentId)), N'');

        DECLARE @PaymentStatusInt INT = TRY_CONVERT(INT, @PaymentStatus);

        /* ✅ BẮT BUỘC: Xe nào thì load xe đó */
        IF ISNULL(@CardVehicleId, 0) = 0
        BEGIN
            /* RESULT SET 1: META */
            SELECT
                recordsTotal    = 0,
                recordsFiltered = 0,
                gridKey         = @GridKey,
                valid           = 1;

            /* RESULT SET 2: HEADER */
            SELECT *
            FROM dbo.fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
            ORDER BY ordinal;

            /* RESULT SET 3: DATA (rỗng) */
            SELECT
                  CAST(NULL AS INT)              AS PayId
                , CAST(NULL AS INT)              AS CardVehicleId
                , CAST(NULL AS DATETIME)         AS PayDt
                , CAST(NULL AS NVARCHAR(450))    AS UserId
                , CAST(NULL AS DECIMAL(18,2))    AS Amount
                , CAST(NULL AS DATETIME)         AS StartDt
                , CAST(NULL AS DATETIME)         AS EndDt
                , CAST(NULL AS NVARCHAR(1000))   AS Remart
                , CAST(NULL AS UNIQUEIDENTIFIER) AS paymentId
                , CAST(NULL AS UNIQUEIDENTIFIER) AS price_oid
                , CAST(NULL AS DECIMAL(18,2))    AS month_price
                , CAST(NULL AS FLOAT)            AS month_num
                , CAST(NULL AS INT)              AS payment_st
                , CAST(NULL AS DATETIME)         AS created_dt
                , CAST(NULL AS NVARCHAR(450))    AS created_by
                , CAST(NULL AS DATETIME)         AS updated_dt
                , CAST(NULL AS NVARCHAR(450))    AS updated_by
                , CAST(NULL AS UNIQUEIDENTIFIER) AS oid
            WHERE 1 = 0;

            RETURN;
        END

        /* ===== TotalAll: tổng theo xe + filter form (không tính @filter search) ===== */
        DECLARE @TotalAll BIGINT =
        (
            SELECT COUNT(1)
            FROM dbo.MAS_CardVehicle_Pay p
            LEFT JOIN dbo.MAS_CardVehicle  cv ON cv.CardVehicleId = p.CardVehicleId
            LEFT JOIN dbo.MAS_Apartments   ap ON ap.ApartmentId   = cv.ApartmentId
            WHERE
                  p.CardVehicleId = @CardVehicleId
              AND (@PaymentStatusInt IS NULL OR p.payment_st = @PaymentStatusInt)
              AND (@ProjectCd IS NULL OR ap.projectCd COLLATE DATABASE_DEFAULT = @ProjectCd COLLATE DATABASE_DEFAULT)
              AND (@ApartmentId IS NULL OR CONVERT(NVARCHAR(50), cv.ApartmentId) COLLATE DATABASE_DEFAULT
                                     = @ApartmentId COLLATE DATABASE_DEFAULT)
              AND (@FromDate IS NULL OR p.PayDt >= @FromDate)
              AND (
                    @ToDate IS NULL
                    OR p.PayDt <= @ToDate
                    OR (CONVERT(time(0), @ToDate) = '00:00:00'
                        AND p.PayDt < DATEADD(DAY, 1, CONVERT(date, @ToDate)))
                  )
        );

        /* ===== Build filtered dataset (có tính @filter search) ===== */
        IF OBJECT_ID('tempdb..#base') IS NOT NULL DROP TABLE #base;

        SELECT
              p.PayId
            , p.CardVehicleId
            , p.PayDt
            , UserId      = p.empUserId
            , p.Amount
            , p.StartDt
            , p.EndDt
            , p.Remart
            , p.paymentId
            , p.price_oid
            , p.month_price
            , p.month_num
            , p.payment_st
            , p.created_dt
            , p.created_by
            , p.updated_dt
            , p.updated_by
            , p.oid
        INTO #base
        FROM dbo.MAS_CardVehicle_Pay p
        LEFT JOIN dbo.MAS_CardVehicle  cv ON cv.CardVehicleId = p.CardVehicleId
        LEFT JOIN dbo.MAS_Apartments   ap ON ap.ApartmentId   = cv.ApartmentId
        WHERE
              p.CardVehicleId = @CardVehicleId
          AND (@PaymentStatusInt IS NULL OR p.payment_st = @PaymentStatusInt)
          AND (@ProjectCd IS NULL OR ap.projectCd COLLATE DATABASE_DEFAULT = @ProjectCd COLLATE DATABASE_DEFAULT)
          AND (@ApartmentId IS NULL OR CONVERT(NVARCHAR(50), cv.ApartmentId) COLLATE DATABASE_DEFAULT
                                 = @ApartmentId COLLATE DATABASE_DEFAULT)
          AND (@FromDate IS NULL OR p.PayDt >= @FromDate)
          AND (
                @ToDate IS NULL
                OR p.PayDt <= @ToDate
                OR (CONVERT(time(0), @ToDate) = '00:00:00'
                    AND p.PayDt < DATEADD(DAY, 1, CONVERT(date, @ToDate)))
              )
          AND (
                @filter = N''
                OR CONVERT(NVARCHAR(50), p.PayId) LIKE N'%' + @filter + N'%'
                OR CONVERT(NVARCHAR(50), p.CardVehicleId) LIKE N'%' + @filter + N'%'
                OR CONVERT(NVARCHAR(50), p.Amount) LIKE N'%' + @filter + N'%'
                OR ISNULL(p.Remart, N'') COLLATE DATABASE_DEFAULT LIKE N'%' + @filter + N'%'
              );

        DECLARE @TotalFiltered BIGINT = (SELECT COUNT(1) FROM #base);

        /* ===== RESULT SET 1: META ===== */
        SELECT
            recordsTotal    = @TotalAll,
            recordsFiltered = @TotalFiltered,
            gridKey         = @GridKey,
            valid           = 1;

        /* ===== RESULT SET 2: HEADER ===== */
        SELECT *
        FROM dbo.fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY ordinal;

        /* ===== RESULT SET 3: DATA ===== */
        SELECT *
        FROM #base
        ORDER BY ISNULL(created_dt, PayDt) DESC, PayId DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

    END TRY
    BEGIN CATCH
        DECLARE
            @ErrorNum  INT = ERROR_NUMBER(),
            @ErrorMsg  NVARCHAR(4000) = ERROR_MESSAGE(),
            @ErrorProc NVARCHAR(200) = ERROR_PROCEDURE(),
            @SessionID INT = NULL,
            @AddlInfo  NVARCHAR(MAX) = N'@userId=' + ISNULL(cast(@userId as varchar(50)), N'NULL') +
                                       N'; @CardVehicleId=' + ISNULL(CONVERT(NVARCHAR(20), @CardVehicleId), N'NULL');

        BEGIN TRY
            EXEC dbo.utl_errorlog_set
                @ErrorNum, @ErrorMsg, @ErrorProc,
                N'MAS_CardVehicle_Pay', N'Page',
                @SessionID, @AddlInfo
            WITH RESULT SETS NONE;
        END TRY
        BEGIN CATCH
        END CATCH;

        /* Trả đúng 3 result sets để FE không crash */
        SELECT
            recordsTotal    = 0,
            recordsFiltered = 0,
            gridKey         = @GridKey,
            valid           = 0,
            [messages]      = @ErrorMsg;

        SELECT *
        FROM dbo.fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY ordinal;

        SELECT
              CAST(NULL AS INT)              AS PayId
            , CAST(NULL AS INT)              AS CardVehicleId
            , CAST(NULL AS DATETIME)         AS PayDt
            , CAST(NULL AS NVARCHAR(450))    AS UserId
            , CAST(NULL AS DECIMAL(18,2))    AS Amount
            , CAST(NULL AS DATETIME)         AS StartDt
            , CAST(NULL AS DATETIME)         AS EndDt
            , CAST(NULL AS NVARCHAR(1000))   AS Remart
            , CAST(NULL AS UNIQUEIDENTIFIER) AS paymentId
            , CAST(NULL AS UNIQUEIDENTIFIER) AS price_oid
            , CAST(NULL AS DECIMAL(18,2))    AS month_price
            , CAST(NULL AS FLOAT)            AS month_num
            , CAST(NULL AS INT)              AS payment_st
            , CAST(NULL AS DATETIME)         AS created_dt
            , CAST(NULL AS NVARCHAR(450))    AS created_by
            , CAST(NULL AS DATETIME)         AS updated_dt
            , CAST(NULL AS NVARCHAR(450))    AS updated_by
            , CAST(NULL AS UNIQUEIDENTIFIER) AS oid
        WHERE 1 = 0;
    END CATCH
END