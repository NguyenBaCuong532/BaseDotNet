CREATE PROCEDURE [dbo].[sp_CalcElectricPrice]
    @ProjectCode    NVARCHAR(10),    -- Mã dự án
    @TotalElectric  DECIMAL(18,4),   -- Tổng kWh kỳ tính
    @FromDate       DATE,            -- Từ ngày
    @ToDate         DATE,            -- Đến ngày
    @Debug          BIT = 0          -- =1 để xem các bảng trung gian
AS
BEGIN TRY
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    /* DỌN DẸP TEMP TABLE */
    IF OBJECT_ID('tempdb..#Days') IS NOT NULL DROP TABLE #Days;
    IF OBJECT_ID('tempdb..#Eligible') IS NOT NULL DROP TABLE #Eligible;
    IF OBJECT_ID('tempdb..#PickOne') IS NOT NULL DROP TABLE #PickOne;
    IF OBJECT_ID('tempdb..#Daily') IS NOT NULL DROP TABLE #Daily;
    IF OBJECT_ID('tempdb..#Islands') IS NOT NULL DROP TABLE #Islands;
    IF OBJECT_ID('tempdb..#Periods') IS NOT NULL DROP TABLE #Periods;
    IF OBJECT_ID('tempdb..#Totals') IS NOT NULL DROP TABLE #Totals;
    IF OBJECT_ID('tempdb..#ElectricSplit') IS NOT NULL DROP TABLE #ElectricSplit;
    IF OBJECT_ID('tempdb..#TierBase') IS NOT NULL DROP TABLE #TierBase;
    IF OBJECT_ID('tempdb..#TierKeep') IS NOT NULL DROP TABLE #TierKeep;
    IF OBJECT_ID('tempdb..#TierGap') IS NOT NULL DROP TABLE #TierGap;
    IF OBJECT_ID('tempdb..#TierMerged') IS NOT NULL DROP TABLE #TierMerged;
    IF OBJECT_ID('tempdb..#TierNorm') IS NOT NULL DROP TABLE #TierNorm;
    IF OBJECT_ID('tempdb..#LastTier') IS NOT NULL DROP TABLE #LastTier;
    IF OBJECT_ID('tempdb..#TierExt') IS NOT NULL DROP TABLE #TierExt;
    IF OBJECT_ID('tempdb..#PeriodTier') IS NOT NULL DROP TABLE #PeriodTier;
    IF OBJECT_ID('tempdb..#PeriodAmt') IS NOT NULL DROP TABLE #PeriodAmt;
    IF OBJECT_ID('tempdb..#FinalAgg') IS NOT NULL DROP TABLE #FinalAgg;

    /* 1) Sinh lịch ngày */
    CREATE TABLE #Days(work_day DATE PRIMARY KEY);
    DECLARE @d DATE = @FromDate;
    WHILE (@d <= @ToDate)
    BEGIN
        INSERT INTO #Days(work_day) VALUES(@d);
        SET @d = DATEADD(DAY, 1, @d);
    END

    /* 2) Các bảng giá hiệu lực theo từng ngày */
    SELECT
        d.work_day,
        pe.oid AS par_electric_oid,
        pe.effective_date
    INTO #Eligible
    FROM #Days d
    JOIN par_electric pe
      ON pe.project_code = @ProjectCode
     AND pe.is_active   = 1
     AND pe.effective_date <= d.work_day
     AND (pe.expiry_date IS NULL OR pe.expiry_date >= d.work_day);

    /* 3) Chọn 1 bảng giá / ngày: ưu tiên effective_date mới nhất, tie-break theo oid lớn hơn */
    SELECT
        e.work_day,
        e.par_electric_oid,
        rn = ROW_NUMBER() OVER (
                PARTITION BY e.work_day
                ORDER BY e.effective_date DESC, e.par_electric_oid DESC)
    INTO #PickOne
    FROM #Eligible e;

    SELECT work_day, par_electric_oid
    INTO #Daily
    FROM #PickOne
    WHERE rn = 1;

    /* 4) Gom ngày liên tiếp cùng bảng giá → periods */
    SELECT
        d.work_day,
        d.par_electric_oid,
        grp = DATEADD(DAY,
              -ROW_NUMBER() OVER (PARTITION BY d.par_electric_oid ORDER BY d.work_day),
              d.work_day)
    INTO #Islands
    FROM #Daily d;

    SELECT
        par_electric_oid,
        period_start = MIN(work_day),
        period_end   = MAX(work_day),
        days_in_period = COUNT(*)
    INTO #Periods
    FROM #Islands
    GROUP BY par_electric_oid, grp;

    SELECT total_days = SUM(days_in_period)
    INTO #Totals
    FROM #Periods;

    /* 5) Phân bổ kWh theo ngày (tỉ lệ days/total_days) */
    SELECT
        p.par_electric_oid,
        p.period_start,
        p.period_end,
        p.days_in_period,
        t.total_days,
        period_volume = ROUND(CAST(@TotalElectric * (p.days_in_period * 1.0 / NULLIF(t.total_days,0)) AS DECIMAL(18,6)),0)
    INTO #ElectricSplit
    FROM #Periods p
    CROSS JOIN #Totals t;

    /* 6) Chuẩn hoá bậc cho từng bảng giá (lấp gap bằng giá bậc trước) */
    SELECT
        d.par_electric_oid,
        d.sort_order,
        d.start_value,
        d.end_value,
        d.unit_price,
        prev_end   = LAG(d.end_value)  OVER (PARTITION BY d.par_electric_oid ORDER BY d.sort_order),
        prev_price = LAG(d.unit_price) OVER (PARTITION BY d.par_electric_oid ORDER BY d.sort_order)
    INTO #TierBase
    FROM par_electric_detail d
    JOIN #Periods p ON p.par_electric_oid = d.par_electric_oid;

    SELECT par_electric_oid, sort_order, start_value, end_value, unit_price
    INTO #TierKeep
    FROM #TierBase;

    SELECT
        par_electric_oid,
        sort_order  = sort_order - 0.5,      -- tạm, sẽ chuẩn hoá lại
        start_value = prev_end + 1,
        end_value   = start_value - 1,       -- tạo dòng gap rỗng để chuẩn hoá
        unit_price  = prev_price
    INTO #TierGap
    FROM #TierBase
    WHERE prev_end IS NOT NULL AND start_value > prev_end + 1;

    SELECT * INTO #TierMerged FROM (
        SELECT * FROM #TierKeep
        UNION ALL
        SELECT * FROM #TierGap
    ) U;

    SELECT
        par_electric_oid,
        sort_order = ROW_NUMBER() OVER (PARTITION BY par_electric_oid ORDER BY start_value),
        start_value, end_value, unit_price
    INTO #TierNorm
    FROM #TierMerged
    WHERE start_value <= end_value;

    SELECT *
    INTO #LastTier
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY par_electric_oid ORDER BY end_value DESC) rn
        FROM #TierNorm
    ) X
    WHERE rn = 1;

    -- Bậc vượt
    SELECT par_electric_oid, sort_order, start_value, end_value, unit_price
    INTO #TierExt
    FROM #TierNorm;

    INSERT INTO #TierExt (par_electric_oid, sort_order, start_value, end_value, unit_price)
    SELECT par_electric_oid, sort_order + 1, end_value + 1, 999999, unit_price
    FROM #LastTier;

    /* 7) Tính tiêu thụ theo bậc cho TỪNG period (liên tục, không +1) */
    SELECT
        e.par_electric_oid,
        e.period_start, e.period_end,
        t.sort_order, t.start_value, t.end_value, t.unit_price,
        used_electric =
           CASE
             WHEN e.period_volume <= (t.start_value - 1) THEN CAST(0 AS DECIMAL(18,6))
             WHEN e.period_volume >=  t.end_value        THEN CAST(t.end_value - (t.start_value - 1) AS DECIMAL(18,6))
             ELSE CAST(e.period_volume - (t.start_value - 1) AS DECIMAL(18,6))
           END
    INTO #PeriodTier
    FROM #ElectricSplit e
    JOIN #TierExt      t ON t.par_electric_oid = e.par_electric_oid;

    /* 8) Tiền & VAT theo bảng giá */
    SELECT
        pt.par_electric_oid,
        pt.sort_order,
        pt.start_value, pt.end_value, pt.unit_price,
        used_electric = CASE WHEN pt.used_electric < 0 THEN 0 ELSE pt.used_electric END,
        amount        = CASE WHEN pt.used_electric < 0 THEN 0 ELSE pt.used_electric * pt.unit_price END,
        vat_rate      = pe.vat / 100.0
    INTO #PeriodAmt
    FROM #PeriodTier pt
    JOIN par_electric pe ON pe.oid = pt.par_electric_oid
    WHERE pt.used_electric > 0;

    /* 9) Cộng gộp THEO BẬC (đúng logic cũ),
          nhưng vat_amount = tổng(ROUND(amount * vat_rate, 0)) theo từng bảng giá */
    SELECT
        sort_order,
        start_value = MIN(start_value),
        end_value   = MAX(end_value),
        used_electric = SUM(used_electric),
        amount        = SUM(amount),
        vat_amount    = SUM(ROUND(amount * vat_rate, 0)),      -- làm tròn 0đ theo yêu cầu
        unit_price_eff = CAST(
            CASE WHEN SUM(used_electric) > 0
                 THEN SUM(amount) / SUM(used_electric)
                 ELSE NULL
            END AS DECIMAL(18,4))
    INTO #FinalAgg
    FROM #PeriodAmt
    GROUP BY sort_order;

    /* 10) KẾT QUẢ CHÍNH */
    SELECT
        sort_order,
        period_start = @FromDate,
        period_end   = @ToDate,
        start_value,
        end_value,
        unit_price     = unit_price_eff,
        used_electric  = CAST(ROUND(used_electric, 2) AS DECIMAL(18,2)),
        amount         = CAST(ROUND(amount,        2) AS DECIMAL(18,2)),
        vat_amount     = CAST(vat_amount           AS DECIMAL(18,0)),
        total_with_vat = CAST(ROUND(amount, 2) + vat_amount AS DECIMAL(18,0))
    FROM #FinalAgg
    WHERE used_electric > 0
    ORDER BY sort_order;

    /* 11) DEBUG: xuất thêm bảng trung gian khi cần */
    IF (@Debug = 1)
    BEGIN
        PRINT '--- DEBUG: #Periods ---';
        SELECT * FROM #Periods ORDER BY period_start;

        PRINT '--- DEBUG: #ElectricSplit ---';
        SELECT * FROM #ElectricSplit ORDER BY period_start;

        PRINT '--- DEBUG: #TierExt ---';
        SELECT * FROM #TierExt ORDER BY par_electric_oid, sort_order;

        PRINT '--- DEBUG: #PeriodAmt ---';
        SELECT * FROM #PeriodAmt ORDER BY sort_order, par_electric_oid;
    END
END TRY
BEGIN CATCH
    DECLARE @err nvarchar(4000) = ERROR_MESSAGE();
    DECLARE @state int = ERROR_STATE();
    DECLARE @severity int = ERROR_SEVERITY();
    RAISERROR(@err, @severity, @state);
END CATCH