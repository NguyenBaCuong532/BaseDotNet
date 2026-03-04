CREATE FUNCTION fn_CalcWaterPrice
(
    @ProjectCode NVARCHAR(10),  -- Mã dự án
    @TotalWater DECIMAL(10,2),  -- Tổng số nước sử dụng
    @FromDate DATE,              -- Ngày bắt đầu kỳ tính
    @ToDate DATE                 -- Ngày kết thúc kỳ tính
)
RETURNS TABLE
AS
RETURN
(
    -------------------------------------------------------------------------
    -- 1. Xác định các khoảng thời gian hiệu lực (Periods)
    --    Dựa vào bảng par_water (chứa thông tin thời gian áp dụng biểu giá)
    -------------------------------------------------------------------------
    WITH Periods AS (
        SELECT
            pw.oid AS par_water_oid,  -- ID bảng par_water
            CASE WHEN pw.effective_date > @FromDate THEN pw.effective_date ELSE @FromDate END AS period_start,
            CASE WHEN pw.expiry_date < @ToDate THEN pw.expiry_date ELSE @ToDate END AS period_end
        FROM par_water pw
        WHERE
            pw.project_code = @ProjectCode
            AND pw.is_active = 1
            AND pw.effective_date <= @ToDate   -- có hiệu lực trước khi kết thúc kỳ
            AND pw.expiry_date >= @FromDate    -- còn hiệu lực tại thời điểm bắt đầu kỳ
    ),

    -------------------------------------------------------------------------
    -- 2. Tính số ngày tương ứng với từng khoảng thời gian hiệu lực
    --    Mục tiêu: chia đều tổng lượng nước theo số ngày trong kỳ
    -------------------------------------------------------------------------
    WaterSplit AS (
        SELECT 
            p.par_water_oid,
            p.period_start,
            p.period_end,
            DATEDIFF(DAY, p.period_start, p.period_end) + 1 AS days_in_period, -- số ngày trong giai đoạn hiệu lực
            DATEDIFF(DAY, @FromDate, @ToDate) + 1 AS total_days,               -- tổng số ngày trong kỳ
            CAST(@TotalWater AS DECIMAL(10,2)) AS total_water
        FROM Periods p
    ),

    -------------------------------------------------------------------------
    -- 3. Tính lượng nước phân bổ cho từng khoảng thời gian (WaterInPeriod)
    --    = tổng nước * (số ngày giai đoạn / tổng số ngày)
    -------------------------------------------------------------------------
    WaterInPeriod AS (
        SELECT 
            par_water_oid,
            period_start,
            period_end,
            CAST(total_water * (days_in_period * 1.0 / total_days) AS DECIMAL(10,2)) AS water_volume
        FROM WaterSplit
    ),

    -------------------------------------------------------------------------
    -- 4. Chuẩn hóa bảng bậc giá (TierNormalized)
    --    Lấy thêm bậc liền kề trước đó để phát hiện khoảng trống giữa các bậc
    -------------------------------------------------------------------------
    TierNormalized AS (
        SELECT 
            d.par_water_oid,
            d.sort_order,
            d.start_value,
            d.end_value,
            d.unit_price,
            LAG(d.end_value) OVER(PARTITION BY d.par_water_oid ORDER BY d.start_value) AS prev_end
        FROM
            par_water_detail d
            INNER JOIN Periods p ON d.par_water_oid = p.par_water_oid
    ),

    -------------------------------------------------------------------------
    -- 5. Tính giá trị bắt đầu thực tế (effective_start)
    --    Nếu có khoảng trống giữa prev_end và start_value thì đánh dấu để bổ sung sau
    -------------------------------------------------------------------------
    TierFixed AS (
        SELECT 
            par_water_oid,
            sort_order,
            start_value,
            end_value,
            unit_price,
            ISNULL(prev_end, 0) AS prev_end,
            CASE 
                WHEN prev_end IS NOT NULL AND start_value > prev_end + 1 THEN prev_end + 1 
                ELSE start_value END AS effective_start
        FROM TierNormalized
    ),

    -------------------------------------------------------------------------
    -- 6. Mở rộng (TierExpanded)
    --    + Giữ nguyên bậc hiện có
    --    + Bổ sung khoảng trống bằng record ảo có giá bằng giá gần nhất
    -------------------------------------------------------------------------
    TierExpanded AS (
        SELECT 
            par_water_oid, sort_order, effective_start AS start_value, end_value, unit_price
        FROM TierFixed

    --     UNION ALL
    -- 
    --     -- Bổ sung khoảng trống: dùng giá gần nhất (unit_price của bậc trước)
    --     SELECT 
    --         t1.par_water_oid,
    --         t1.sort_order,
    --         t1.prev_end + 1 AS start_value,
    --         t2.start_value - 1 AS end_value,
    --         t1.unit_price
    --     FROM
    --         TierFixed t1
    --         INNER JOIN TierFixed t2 ON t1.par_water_oid = t2.par_water_oid AND t1.end_value < t2.start_value
    --     WHERE t2.start_value > t1.end_value + 1
    ),

    -------------------------------------------------------------------------
    -- 7. Chuẩn hóa lại dữ liệu, loại bỏ trùng (TierFull)
    -------------------------------------------------------------------------
    TierFull AS (
        SELECT DISTINCT 
            par_water_oid, sort_order, start_value, end_value, unit_price
        FROM TierExpanded
    ),

    -------------------------------------------------------------------------
    -- 8. Bổ sung bậc cao nhất cho phần vượt (TierExtended)
    --    Nếu người dùng dùng nước vượt mức cao nhất thì dùng giá cuối cùng
    -------------------------------------------------------------------------
    TierExtended AS (
        SELECT 
            t.par_water_oid,
            t.sort_order,
            t.start_value,
            t.end_value,
            t.unit_price
        FROM TierFull t

        UNION ALL

        -- Tạo bậc "phần vượt" đến vô hạn
        SELECT 
            t.par_water_oid,
            MAX(t.sort_order),
            MAX(t.end_value) + 1,
            999999, -- end_value giả định rất lớn
            MAX(t.unit_price) -- dùng giá cao nhất
        FROM TierFull t
        GROUP BY t.par_water_oid
    ),

    -------------------------------------------------------------------------
    -- 9. Tính lượng nước nằm trong từng bậc (FinalCalc)
    --    So sánh water_volume của kỳ với start_value / end_value từng bậc
    -------------------------------------------------------------------------
    FinalCalc AS (
        SELECT 
            t.sort_order,
            w.period_start,
            w.period_end,
            t.start_value,
            t.end_value,
            t.unit_price,
            CASE 
                WHEN w.water_volume > t.end_value THEN (t.end_value - t.start_value + 1)         -- dùng hết bậc
                WHEN w.water_volume > t.start_value - 1 THEN w.water_volume - (t.start_value - 1) -- dùng một phần bậc
                ELSE 0 END AS used_water
        FROM WaterInPeriod w
        INNER JOIN TierExtended t ON w.par_water_oid = t.par_water_oid
    )

    -------------------------------------------------------------------------
    -- 10. Trả kết quả cuối cùng
    --     Gồm: thứ tự bậc, thời gian, giá trị từ-đến, đơn giá, lượng nước, thành tiền
    -------------------------------------------------------------------------
    SELECT DISTINCT
        f.sort_order,
        f.period_start,
        f.period_end,
        f.start_value,
        f.end_value,
        f.unit_price,
        CASE WHEN f.used_water < 0 THEN 0 ELSE f.used_water END AS used_water,
        CAST(CASE WHEN f.used_water < 0 THEN 0 ELSE f.used_water * f.unit_price END AS DECIMAL(18,2)) AS amount
    FROM FinalCalc f
    WHERE f.used_water > 0
);