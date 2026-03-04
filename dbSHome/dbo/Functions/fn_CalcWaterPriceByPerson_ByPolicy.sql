CREATE FUNCTION [dbo].[fn_CalcWaterPriceByPerson_ByPolicy]
(
    @ProjectCode     NVARCHAR(10),   -- Mã dự án
    @TotalWater      DECIMAL(10,2),  -- Tổng số nước sử dụng (m³)
    @NumPersonWater  INT,            -- Số người đăng ký định mức
    @FromDate        DATE,           -- Ngày bắt đầu kỳ tính
    @ToDate          DATE            -- Ngày kết thúc kỳ tính
)
RETURNS TABLE
AS
RETURN
(
    /* 1) Sinh lịch ngày trong kỳ (@FromDate -> @ToDate)
       NOTE: replaced master..spt_values with local catalog views to avoid cross-db unresolved reference.
    */
    --WITH Num AS (
    --    SELECT TOP (DATEDIFF(DAY, @FromDate, @ToDate) + 1)
    --           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    --    FROM sys.all_objects
    --),
    --Days AS (
    --    SELECT DATEADD(DAY, n, @FromDate) AS work_day
    --    FROM Num
    --),
	WITH Days AS (
		SELECT work_day = CAST(@FromDate AS date)
		WHERE @FromDate IS NOT NULL AND @ToDate IS NOT NULL AND @FromDate <= @ToDate

		UNION ALL

		SELECT work_day = DATEADD(DAY, 1, d.work_day)
		FROM Days d
		WHERE d.work_day < @ToDate
	),
    /* 2) Tìm policy nước hợp lệ theo từng ngày */
    Eligible AS (
        SELECT 
            d.work_day,
            pw.oid AS par_water_oid,
            pw.effective_date,
            b.is_step_price
        FROM Days d
        JOIN par_water pw
             ON pw.project_code   = @ProjectCode
            AND pw.is_active      = 1
            AND pw.effective_date <= d.work_day
            AND (pw.expiry_date IS NULL OR pw.expiry_date >= d.work_day)
        LEFT JOIN par_service_price_type b
             ON pw.par_service_price_type_oid = b.oid
    ),

    /* 3) Mỗi ngày chọn 1 policy: effective_date mới nhất, tie-break theo OID */
    PickOne AS (
        SELECT 
            work_day,
            par_water_oid,
            is_step_price,
            ROW_NUMBER() OVER (
                PARTITION BY work_day
                ORDER BY effective_date DESC, par_water_oid DESC
            ) AS rn
        FROM Eligible
    ),
    Daily AS (
        SELECT work_day, par_water_oid, is_step_price
        FROM PickOne
        WHERE rn = 1
    ),

    /* 4) Gom các ngày liên tiếp có cùng policy thành period */
    Islands AS (
        SELECT
            work_day,
            par_water_oid,
            is_step_price,
            grp = DATEADD(
                    DAY,
                    -ROW_NUMBER() OVER (PARTITION BY par_water_oid ORDER BY work_day),
                    work_day
                  )
        FROM Daily
    ),
    Periods AS (
        SELECT
            par_water_oid,
            is_step_price,                      -- không dùng MAX(bit) nữa
            period_start   = MIN(work_day),
            period_end     = MAX(work_day),
            days_in_period = COUNT(*)
        FROM Islands
        GROUP BY par_water_oid, is_step_price, grp
    ),

    /* 5) Tổng số ngày có policy trong kỳ (mẫu số phân bổ) */
    Totals AS (
        SELECT total_days = SUM(days_in_period)
        FROM Periods
    ),

    /* 6) Phân bổ tổng m³ vào từng policy/period theo tỷ lệ ngày */
    WaterInPeriod AS (
        SELECT
            p.par_water_oid,
            p.period_start,
            p.period_end,
            p.is_step_price,
            p.days_in_period,
            t.total_days,
            water_volume = CAST(
                ROUND(
                    CAST(@TotalWater * (p.days_in_period * 1.0 / NULLIF(t.total_days,0)) AS DECIMAL(18,6)),
                    0
                ) AS DECIMAL(18,4)
            ),
            num_person = ISNULL(@NumPersonWater, 0)
        FROM Periods p
        CROSS JOIN Totals t
    ),

    /* 7) Danh sách bậc giá nước cho các policy được dùng */
    TierBase AS (
        SELECT 
            d.par_water_oid,
            d.sort_order,
            d.start_value,
            d.end_value,
            d.unit_price
        FROM par_water_detail d
        WHERE EXISTS (
            SELECT 1
            FROM Periods p
            WHERE p.par_water_oid = d.par_water_oid
        )
    ),

    /* ============ NHÁNH 1: TÍNH THEO HỘ (is_step_price = 1) ============ */
    Hh_Tiers AS (
        SELECT
            w.par_water_oid,
            w.period_start,
            w.period_end,
            w.water_volume,
            t.sort_order,
            t.start_value,  -- m³/hộ
            t.end_value,    -- m³/hộ
            t.unit_price,
            tier_max = CAST(COALESCE(t.end_value, 999999999.0) AS DECIMAL(18,6)),
            prev_max = CAST(
                          COALESCE(
                              LAG(t.end_value) OVER (
                                  PARTITION BY w.par_water_oid, w.period_start, w.period_end
                                  ORDER BY t.sort_order
                              ),
                              0.0
                          ) AS DECIMAL(18,6)
                       )
        FROM WaterInPeriod w
        JOIN TierBase t ON t.par_water_oid = w.par_water_oid
        WHERE w.is_step_price = 1
    ),
    Hh_Alloc AS (
        SELECT
            par_water_oid,
            period_start,
            period_end,
            sort_order,
            start_value,
            end_value,
            unit_price,
            water_volume,
            tier_max,
            prev_max,
            ChiSoTinh = CASE WHEN tier_max > prev_max THEN tier_max - prev_max ELSE 0 END,
            TieuThu = CASE
                        WHEN water_volume <= prev_max THEN CAST(0 AS DECIMAL(18,4))
                        WHEN water_volume >= tier_max THEN CAST(tier_max - prev_max AS DECIMAL(18,4))
                        ELSE CAST(water_volume - prev_max AS DECIMAL(18,4))
                      END
        FROM Hh_Tiers
    ),
    Hh_Result AS (
        SELECT
            par_water_oid,
            period_start,
            period_end,
            sort_order,
            start_value,
            end_value,
            unit_price,
            used_water = TieuThu,
            amount     = CAST(TieuThu * unit_price AS DECIMAL(18,2))
        FROM Hh_Alloc
        WHERE TieuThu > 0
    ),

    /* ============ NHÁNH 2: TÍNH THEO NGƯỜI (is_step_price = 0) ============ */

    -- Trường hợp không có số người -> dùng đơn giá cao nhất
    Pp_MaxUnit AS (
        SELECT 
            w.par_water_oid,
            w.period_start,
            w.period_end,
            sort_order = MAX(t.sort_order),
            max_unit_price = MAX(t.unit_price)
        FROM WaterInPeriod w
        JOIN TierBase t ON t.par_water_oid = w.par_water_oid
        WHERE w.is_step_price = 0 AND w.num_person = 0
        GROUP BY w.par_water_oid, w.period_start, w.period_end
    ),
    Pp_MaxPrice AS (
        SELECT
            w.par_water_oid,
            sort_order  = m.sort_order,
            w.period_start,
            w.period_end,
            start_value = CAST(0 AS DECIMAL(18,4)),
            end_value   = CAST(w.water_volume AS DECIMAL(18,4)),
            unit_price  = m.max_unit_price,
            used_water  = w.water_volume,
            amount      = CAST(w.water_volume * m.max_unit_price AS DECIMAL(18,2))
        FROM WaterInPeriod w
        JOIN Pp_MaxUnit m
             ON m.par_water_oid = w.par_water_oid
            AND m.period_start  = w.period_start
            AND m.period_end    = w.period_end
        WHERE w.is_step_price = 0 AND w.num_person = 0
    ),

    -- Trường hợp tính theo người: bậc = (end_value per-person) * num_person
    Pp_Tiers AS (
        SELECT
            w.par_water_oid,
            w.period_start,
            w.period_end,
            w.num_person,
            w.water_volume,
            t.sort_order,
            t.start_value,   -- m³/người
            t.end_value,     -- m³/người
            t.unit_price,
            tier_max = CAST(
                         COALESCE(t.end_value, 999999999.0) * NULLIF(w.num_person,0)
                         AS DECIMAL(18,6)
                     ),
            prev_max = CAST(
                         COALESCE(
                             LAG(t.end_value) OVER (
                                 PARTITION BY w.par_water_oid, w.period_start, w.period_end
                                 ORDER BY t.sort_order
                             ),
                             0.0
                         ) * NULLIF(w.num_person,0)
                         AS DECIMAL(18,6)
                     )
        FROM WaterInPeriod w
        JOIN TierBase t ON t.par_water_oid = w.par_water_oid
        WHERE w.is_step_price = 0 AND w.num_person > 0
    ),
    Pp_Alloc AS (
        SELECT
            par_water_oid,
            period_start,
            period_end,
            sort_order,
            start_value,
            end_value,
            unit_price,
            water_volume,
            tier_max,
            prev_max,
            ChiSoTinh = CASE WHEN tier_max > prev_max THEN tier_max - prev_max ELSE 0 END,
            TieuThu = CASE
                        WHEN water_volume <= prev_max THEN CAST(0 AS DECIMAL(18,4))
                        WHEN water_volume >= tier_max THEN CAST(tier_max - prev_max AS DECIMAL(18,4))
                        ELSE CAST(water_volume - prev_max AS DECIMAL(18,4))
                      END
        FROM Pp_Tiers
    ),
    Pp_Result AS (
        SELECT
            par_water_oid,
            period_start,
            period_end,
            sort_order,
            start_value,
            end_value,
            unit_price,
            used_water = TieuThu,
            amount     = CAST(TieuThu * unit_price AS DECIMAL(18,2))
        FROM Pp_Alloc
        WHERE TieuThu > 0
    ),

    /* 8) Gộp kết quả */
    Combined AS (
        SELECT 
            par_water_oid,
            period_start,
            period_end,
            sort_order,
            start_value,
            end_value,
            unit_price,
            used_water,
            amount
        FROM Hh_Result

        UNION ALL

        SELECT 
            par_water_oid,
            period_start,
            period_end,
            sort_order,
            start_value,
            end_value,
            unit_price,
            used_water,
            amount
        FROM Pp_MaxPrice

        UNION ALL

        SELECT 
            par_water_oid,
            period_start,
            period_end,
            sort_order,
            start_value,
            end_value,
            unit_price,
            used_water,
            amount
        FROM Pp_Result
    )

    SELECT 
        par_water_oid,
        period_start,
        period_end,
        sort_order,
        start_value,   -- nếu theo người: m³/người
        end_value,     -- nếu theo người: m³/người
        unit_price,
        used_water,    -- m³ vào bậc này trong period này
        amount         -- thành tiền
    FROM Combined
    WHERE used_water > 0
);