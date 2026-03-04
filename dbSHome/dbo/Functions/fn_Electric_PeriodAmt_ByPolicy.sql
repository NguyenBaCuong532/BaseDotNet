
/* Chi tiết PERIOD × BẬC (KHÔNG GỘP), giữ đủ các bậc kể cả used_electric = 0 */
CREATE FUNCTION [dbo].[fn_Electric_PeriodAmt_ByPolicy]
(
    @ProjectCode    NVARCHAR(10),
    @TotalElectric  DECIMAL(18,4),
    @FromDate       DATE,
    @ToDate         DATE
)
RETURNS TABLE
AS
RETURN
(
    /* 1) Lịch ngày */
    WITH Days AS (
        SELECT @FromDate AS work_day
        UNION ALL
        SELECT DATEADD(DAY, 1, work_day)
        FROM Days
        WHERE work_day < @ToDate
    ),

    /* 2) Policy hợp lệ theo ngày */
    Eligible AS (
        SELECT d.work_day, pe.oid AS par_electric_oid, pe.effective_date
        FROM Days d
        JOIN par_electric pe
          ON pe.project_code = @ProjectCode
         AND pe.is_active = 1
         AND pe.effective_date <= d.work_day
         AND (pe.expiry_date IS NULL OR pe.expiry_date >= d.work_day)
    ),

    /* 3) Chọn 1 policy/ngày (latest effective_date; tie-break theo OID) */
    PickOne AS (
        SELECT work_day, par_electric_oid,
               ROW_NUMBER() OVER(
                 PARTITION BY work_day
                 ORDER BY effective_date DESC, par_electric_oid DESC) rn
        FROM Eligible
    ),
    Daily AS (
        SELECT work_day, par_electric_oid
        FROM PickOne WHERE rn = 1
    ),

    /* 4) Gom ngày liên tiếp thành period theo policy (không tính tiền ở đây) */
    Islands AS (
        SELECT work_day, par_electric_oid,
               grp = DATEADD(DAY,
                     -ROW_NUMBER() OVER (PARTITION BY par_electric_oid ORDER BY work_day),
                     work_day)
        FROM Daily
    ),
    Periods AS (
        SELECT par_electric_oid,
               period_start   = MIN(work_day),
               period_end     = MAX(work_day),
               days_in_period = COUNT(*)
        FROM Islands
        GROUP BY par_electric_oid, grp
    ),
    Totals AS (SELECT total_days = SUM(days_in_period) FROM Periods),

    /* 5) Phân bổ kWh theo tỷ lệ số ngày cho từng period */
    ElectricSplit AS (
        SELECT
            p.par_electric_oid,
            p.period_start, p.period_end,
            p.days_in_period,
            t.total_days,
            period_volume = round(CAST(@TotalElectric * (p.days_in_period * 1.0 / NULLIF(t.total_days,0)) AS DECIMAL(18,6)),0)
        FROM Periods p
        CROSS JOIN Totals t
    ),

    /* 6) Chuẩn hoá bậc + thêm bậc vượt (TierExt) */
    TierBase AS (
        SELECT
            d.par_electric_oid, d.sort_order, d.start_value, d.end_value, d.unit_price,
            LAG(d.end_value)  OVER (PARTITION BY d.par_electric_oid ORDER BY d.sort_order) AS prev_end,
            LAG(d.unit_price) OVER (PARTITION BY d.par_electric_oid ORDER BY d.sort_order) AS prev_price
        FROM par_electric_detail d
        JOIN Periods p ON p.par_electric_oid = d.par_electric_oid
    ),
    TierKeep AS (
        SELECT par_electric_oid, sort_order, start_value, end_value, unit_price
        FROM TierBase
    ),
    TierGap AS (
        SELECT par_electric_oid,
               sort_order  = sort_order - 0.5,
               start_value = prev_end + 1,
               end_value   = start_value - 1,
               unit_price  = prev_price
        FROM TierBase
        WHERE prev_end IS NOT NULL AND start_value > prev_end + 1
    ),
    TierMerged AS (
        SELECT * FROM TierKeep
        UNION ALL
        SELECT * FROM TierGap
    ),
    TierNorm AS (
        SELECT
            par_electric_oid,
            sort_order = ROW_NUMBER() OVER (PARTITION BY par_electric_oid ORDER BY start_value),
            start_value, end_value, unit_price
        FROM TierMerged
        WHERE start_value <= end_value
    ),
    LastTier AS (
        SELECT *
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY par_electric_oid ORDER BY end_value DESC) rn
            FROM TierNorm
        ) x
        WHERE rn = 1
    ),
    TierExt AS (
        SELECT par_electric_oid, sort_order, start_value, end_value, unit_price
        FROM TierNorm
        UNION ALL
        SELECT par_electric_oid, sort_order + 1, end_value + 1, 999999, unit_price
        FROM LastTier
    ),

    /* 7) Chi tiết PERIOD × BẬC (KHÔNG GROUP, KHÔNG HAVING, KHÔNG WHERE loại 0) */
    PeriodTier AS (
        SELECT
            e.par_electric_oid,
            e.period_start, e.period_end,
            t.sort_order, t.start_value, t.end_value, t.unit_price,
            used_electric_raw =
               CASE
                 WHEN e.period_volume <= (t.start_value - 1) THEN CAST(0 AS DECIMAL(18,6))
                 WHEN e.period_volume >=  t.end_value        THEN CAST(t.end_value - (t.start_value - 1) AS DECIMAL(18,6))
                 ELSE CAST(e.period_volume - (t.start_value - 1) AS DECIMAL(18,6))
               END
        FROM ElectricSplit e
        JOIN TierExt      t ON t.par_electric_oid = e.par_electric_oid
    )

    /* 8) OUTPUT: đúng bộ cột yêu cầu, không lọc bậc 0 kWh */
    SELECT
        pt.par_electric_oid,
        pt.period_start,
        pt.period_end,
        pt.sort_order,
        pt.start_value,
        pt.end_value,
        pt.unit_price,
        used_electric = CAST(CASE WHEN pt.used_electric_raw < 0 THEN 0 ELSE isnull(pt.used_electric_raw,0) END AS DECIMAL(18,6)),
        amount        = CAST(CASE WHEN pt.used_electric_raw < 0 THEN 0 ELSE isnull(pt.used_electric_raw,0) * isnull(pt.unit_price,0) END AS DECIMAL(18,6)),
        vat_rate      = CAST(pe.vat / 100.0 AS DECIMAL(9,6)),
        vat_amount    = CAST(ROUND( (CASE WHEN pt.used_electric_raw < 0 THEN 0 ELSE isnull(pt.used_electric_raw,0) * isnull(pt.unit_price,0) END) * (pe.vat/100.0), 0) AS DECIMAL(18,0))
    FROM PeriodTier pt
    JOIN par_electric pe ON pe.oid = pt.par_electric_oid
);