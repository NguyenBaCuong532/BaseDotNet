
-- fn_CalcElectricPrice: tính tiền điện theo bậc, hỗ trợ nhiều bảng giá trong 1 kỳ
-- BỔ SUNG: vat_amount (gộp đúng theo VAT từng bảng giá) & total_with_vat
CREATE FUNCTION [dbo].[fn_CalcElectricPrice]
(
    @ProjectCode    NVARCHAR(10),   -- Mã dự án
    @TotalElectric  DECIMAL(18,4),  -- Tổng kWh kỳ tính
    @FromDate       DATE,           -- Từ ngày
    @ToDate         DATE            -- Đến ngày
)
RETURNS TABLE
AS
RETURN
(
    /* 1) Sinh lịch ngày */
    WITH Days AS (
        SELECT @FromDate AS work_day
        UNION ALL
        SELECT DATEADD(DAY, 1, work_day)
        FROM Days
        WHERE work_day < @ToDate
    ),

    /* 2) Các bảng giá hiệu lực theo từng ngày */
    Eligible AS (
        SELECT d.work_day, pe.oid AS par_electric_oid, pe.effective_date
        FROM Days d
        JOIN par_electric pe
          ON pe.project_code = @ProjectCode
         AND pe.is_active = 1
         AND pe.effective_date <= d.work_day
         AND (pe.expiry_date IS NULL OR pe.expiry_date >= d.work_day)
    ),

    /* 3) Chọn 1 bảng giá duy nhất cho mỗi ngày:
          - Ưu tiên effective_date mới nhất, tie-break theo oid lớn hơn */
    PickOne AS (
        SELECT work_day, par_electric_oid,
               ROW_NUMBER() OVER (
                   PARTITION BY work_day
                   ORDER BY effective_date DESC, par_electric_oid DESC
               ) AS rn
        FROM Eligible
    ),
    Daily AS (
        SELECT work_day, par_electric_oid
        FROM PickOne
        WHERE rn = 1
    ),

    /* 4) Gom ngày liên tiếp cùng bảng giá → periods */
    Islands AS (
        SELECT work_day, par_electric_oid,
               grp = DATEADD(DAY,
                    -ROW_NUMBER() OVER (PARTITION BY par_electric_oid ORDER BY work_day),
                    work_day)
        FROM Daily
    ),
    Periods AS (
        SELECT par_electric_oid,
               period_start = MIN(work_day),
               period_end   = MAX(work_day),
               days_in_period = COUNT(*)
        FROM Islands
        GROUP BY par_electric_oid, grp
    ),
    Totals AS (SELECT total_days = SUM(days_in_period) FROM Periods),

    /* 5) Phân bổ kWh theo ngày (tỉ lệ days/total_days) */
    ElectricSplit AS (
        SELECT
            p.par_electric_oid,
            p.period_start,
            p.period_end,
            p.days_in_period,
            t.total_days,
            period_volume = ROUND(CAST(@TotalElectric * (p.days_in_period * 1.0 / NULLIF(t.total_days,0)) AS DECIMAL(18,6)),0)
        FROM Periods p
        CROSS JOIN Totals t
    ),

    /* 6) Chuẩn hoá bậc cho từng bảng giá (lấp gap bằng giá bậc trước) */
    TierBase AS (
        SELECT
            d.par_electric_oid,
            d.sort_order,
            d.start_value,
            d.end_value,
            d.unit_price,
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
        SELECT
            par_electric_oid,
            sort_order  = sort_order - 0.5,     -- tạm, sẽ chuẩn hoá lại
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
    TierExt AS (  -- bậc vượt
        SELECT par_electric_oid, sort_order, start_value, end_value, unit_price
        FROM TierNorm
        UNION ALL
        SELECT par_electric_oid, sort_order + 1, end_value + 1, 999999, unit_price
        FROM LastTier
    ),

    /* 7) Tính tiêu thụ theo bậc cho TỪNG period (công thức liên tục, không +1) */
    PeriodTier AS (
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
        FROM ElectricSplit e
        JOIN TierExt t ON t.par_electric_oid = e.par_electric_oid
    ),
    PeriodAmt AS (  -- tính tiền & gắn VAT theo bảng giá
        SELECT
            pt.par_electric_oid,
            pt.sort_order,
            pt.start_value, pt.end_value, pt.unit_price,
            used_electric = CASE WHEN pt.used_electric < 0 THEN 0 ELSE pt.used_electric END,
            amount        = CASE WHEN pt.used_electric < 0 THEN 0 ELSE pt.used_electric * pt.unit_price END,
            vat_rate      = pe.vat / 100.0
        FROM PeriodTier pt
        JOIN par_electric pe ON pe.oid = pt.par_electric_oid
        WHERE pt.used_electric > 0
    ),

    /* 8) Cộng gộp toàn kỳ THEO BẬC (đúng logic cũ),
          NHƯNG vat_amount được cộng sau khi áp đúng vat_rate từng bảng giá */
    FinalAgg AS (
        SELECT
            sort_order,
            start_value = MIN(start_value),
            end_value   = MAX(end_value),
            used_electric = SUM(used_electric),
            amount        = SUM(amount),
            vat_amount    = SUM(ROUND(amount * vat_rate, 0)),              -- theo ảnh: ROUND 0đ
            unit_price_eff = CAST(
                CASE WHEN SUM(used_electric) > 0
                     THEN SUM(amount) / SUM(used_electric)
                     ELSE NULL
                END AS DECIMAL(18,4))
        FROM PeriodAmt
        GROUP BY sort_order
    )

    /* 9) Kết quả: 1 dòng / bậc (giữ schema cũ + thêm vat_amount, total_with_vat) */
    SELECT
        sort_order,
        period_start = @FromDate,
        period_end   = @ToDate,
        start_value,
        end_value,
        unit_price   = unit_price_eff,
        used_electric = CAST(ROUND(used_electric, 2) AS DECIMAL(18,2)),
        amount        = CAST(ROUND(amount,        2) AS DECIMAL(18,2)),
        vat_amount    = CAST(vat_amount           AS DECIMAL(18,0)),       -- làm tròn 0đ
        total_with_vat= CAST(ROUND(amount, 2) + vat_amount AS DECIMAL(18,0))
    FROM FinalAgg
    WHERE used_electric > 0
);