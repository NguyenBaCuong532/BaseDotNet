


CREATE FUNCTION [dbo].[fn_CalcWaterPriceByPerson]
(
    @ProjectCode NVARCHAR(10),    -- Mã dự án
    @TotalWater DECIMAL(10,2),    -- Tổng số nước sử dụng (m³)
    @NumPersonWater INT,          -- Số người đăng ký định mức
    @FromDate DATE,               -- Ngày bắt đầu kỳ tính
    @ToDate DATE                  -- Ngày kết thúc kỳ tính
)
RETURNS TABLE
AS
RETURN
(
    /* Tổng số ngày kỳ tính */
    WITH Z AS (
        SELECT total_days = DATEDIFF(DAY, @FromDate, @ToDate) + 1
    ),
    /* 1) Xác định các kỳ hiệu lực & cờ is_step_price */
    Periods AS (
        SELECT
            pw.oid AS par_water_oid,
            CASE WHEN pw.effective_date > @FromDate THEN pw.effective_date ELSE @FromDate END AS period_start,
            CASE WHEN pw.expiry_date   < @ToDate   THEN pw.expiry_date   ELSE @ToDate   END AS period_end,
            b.is_step_price
        FROM par_water pw left join par_service_price_type b on pw.par_service_price_type_oid = b.oid
        WHERE
            pw.project_code  = @ProjectCode
            AND pw.is_active = 1
            AND pw.effective_date <= @ToDate
            AND (pw.expiry_date is null or pw.expiry_date >= @FromDate)
    ),
    /* 2) Số ngày trong từng kỳ + phân bổ sản lượng theo ngày */
    WaterSplit AS (
        SELECT 
            p.par_water_oid,
            p.period_start,
            p.period_end,
            p.is_step_price,
            days_in_period = DATEDIFF(DAY, p.period_start, p.period_end) + 1
        FROM Periods p
    ),
    WaterInPeriod AS (
        SELECT 
            w.par_water_oid,
            w.period_start,
            w.period_end,
            w.is_step_price,
            w.days_in_period,
            Z.total_days,
            water_volume = CAST(@TotalWater * (CAST(w.days_in_period AS DECIMAL(18,8)) / NULLIF(Z.total_days,0)) AS DECIMAL(18,4)),
            num_person   = ISNULL(@NumPersonWater, 0)
        FROM WaterSplit w
        CROSS JOIN Z
    ),
    /* 3) Bảng bậc giá trong kỳ */
    TierBase AS (
        SELECT 
            d.par_water_oid,
            d.sort_order,
            d.start_value,    -- m³ (nếu theo hộ) / m³/người (nếu theo người)
            d.end_value,      -- m³ (nếu theo hộ) / m³/người (nếu theo người) - NULL = vô hạn
            d.unit_price
        FROM par_water_detail d
        INNER JOIN Periods p ON p.par_water_oid = d.par_water_oid
    ),

    /* ============================== NHÁNH 1: THEO HỘ (is_step_price = 1) ============================== */
    -- Dùng logic “theo hộ” (giống fn_CalcWaterPrice hiện hữu), tính theo ngưỡng cộng dồn của bậc m³/hộ
    Hh_Tiers AS (
        SELECT
            w.par_water_oid,
            w.period_start,
            w.period_end,
            w.water_volume,
            t.sort_order,
            t.start_value,
            t.end_value,
            t.unit_price,
            tier_max = CAST(COALESCE(t.end_value, 999999999.0) AS DECIMAL(18,6)),
            prev_max = CAST(COALESCE(
                              LAG(t.end_value) OVER(PARTITION BY w.par_water_oid, w.period_start, w.period_end ORDER BY t.sort_order)
                            , 0.0) AS DECIMAL(18,6))
        FROM WaterInPeriod w
        INNER JOIN TierBase t
            ON t.par_water_oid = w.par_water_oid
        WHERE w.is_step_price = 1
    ),
    Hh_Alloc AS (
        SELECT
            sort_order,
            period_start,
            period_end,
            start_value,
            end_value,
            unit_price,
            water_volume,
            tier_max,
            prev_max,
            -- Sức chứa bậc (m³)
            ChiSoTinh = CASE WHEN tier_max > prev_max THEN tier_max - prev_max ELSE 0 END,
            -- Phân bổ vào bậc
            TieuThu = CASE
                        WHEN water_volume <= prev_max THEN CAST(0 AS DECIMAL(18,4))
                        WHEN water_volume >= tier_max THEN CAST(tier_max - prev_max AS DECIMAL(18,4))
                        ELSE CAST(water_volume - prev_max AS DECIMAL(18,4))
                      END
        FROM Hh_Tiers
    ),
    Hh_Result AS (
        SELECT
            sort_order,
            period_start,
            period_end,
            start_value,
            end_value,
            unit_price,
            used_water = TieuThu,
            amount     = CAST(TieuThu * unit_price AS DECIMAL(18,2))
        FROM Hh_Alloc
        WHERE TieuThu > 0
    ),

    /* ============================== NHÁNH 2: THEO NGƯỜI (is_step_price = 0) ============================== */
    -- Nếu số người = 0/NULL → dùng đơn giá cao nhất của kỳ
    Pp_MaxUnit AS (
        SELECT 
            w.par_water_oid,
            w.period_start,
            w.period_end,
            max_unit_price = MAX(t.unit_price)
        FROM WaterInPeriod w
        INNER JOIN TierBase t ON t.par_water_oid = w.par_water_oid
        WHERE w.is_step_price = 0 AND w.num_person = 0
        GROUP BY w.par_water_oid, w.period_start, w.period_end
    ),
    Pp_MaxPrice AS (
        SELECT
            sort_order  = 1,
            w.period_start,
            w.period_end,
            start_value = CAST(0 AS DECIMAL(18,4)),
            end_value   = w.water_volume, -- chỉ tham khảo
            unit_price  = m.max_unit_price,
            used_water  = w.water_volume,
            amount      = CAST(w.water_volume * m.max_unit_price AS DECIMAL(18,2))
        FROM WaterInPeriod w
        INNER JOIN Pp_MaxUnit m
             ON m.par_water_oid = w.par_water_oid
            AND m.period_start  = w.period_start
            AND m.period_end    = w.period_end
        WHERE w.is_step_price = 0 AND w.num_person = 0
    ),
    -- Theo người: ngưỡng cộng dồn = (end_value per-person) * num_person
    Pp_Tiers AS (
        SELECT
            w.par_water_oid,
            w.period_start,
            w.period_end,
            w.num_person,
            w.water_volume,
            t.sort_order,
            t.start_value,            -- m³/người
            t.end_value,              -- m³/người
            t.unit_price,
            tier_max = CAST(COALESCE(t.end_value, 999999999.0) * NULLIF(w.num_person,0) AS DECIMAL(18,6)),
            prev_max = CAST(COALESCE(
                              LAG(t.end_value) OVER(PARTITION BY w.par_water_oid, w.period_start, w.period_end ORDER BY t.sort_order)
                            , 0.0) * NULLIF(w.num_person,0) AS DECIMAL(18,6))
        FROM WaterInPeriod w
        INNER JOIN TierBase t
            ON t.par_water_oid = w.par_water_oid
        WHERE w.is_step_price = 0 AND w.num_person > 0
    ),
    Pp_Alloc AS (
        SELECT
            sort_order,
            period_start,
            period_end,
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
            sort_order,
            period_start,
            period_end,
            start_value,
            end_value,
            unit_price,
            used_water = TieuThu,
            amount     = CAST(TieuThu * unit_price AS DECIMAL(18,2))
        FROM Pp_Alloc
        WHERE TieuThu > 0
    ),

    /* ============================== GỘP KẾT QUẢ ============================== */
    Combined AS (
        SELECT * FROM Hh_Result
        UNION ALL
        SELECT * FROM Pp_MaxPrice
        UNION ALL
        SELECT * FROM Pp_Result
    )

    SELECT 
        sort_order,
        period_start,
        period_end,
        start_value,     -- nếu theo người: đây là m³/người
        end_value,       -- nếu theo người: đây là m³/người
        unit_price,
        used_water,      -- m³ phân bổ vào bậc/kỳ
        amount
    FROM Combined
    WHERE used_water > 0
);