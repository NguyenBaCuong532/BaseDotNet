CREATE   FUNCTION dbo.fn_common_service_calculation
(
    @project_code NVARCHAR(50),
    @fromDate DATE,
    @toDate DATE,
    @par_residence_type_oid NVARCHAR(50),
    @area DECIMAL(10,2),
    @freeFromDate DATE = NULL,
    @freeToDate DATE = NULL
)
RETURNS @Result TABLE
(
    oid UNIQUEIDENTIFIER,
    project_code NVARCHAR(50),
    par_residence_type_oid NVARCHAR(50),
    effective_date DATE,
    expiry_date DATE,
    totalDays INT,
    value DECIMAL(18,2),
    tax_percent DECIMAL(10,2),
    is_active BIT,
    total_day INT,
    total_amount DECIMAL(18,2),
    amount_tax DECIMAL(18,2),
    total_amount_tax DECIMAL(18,2)
)
AS
BEGIN
--     IF(@freeFromDate IS NOT NULL AND @freeToDate IS NOT NULL)
--     BEGIN
--         IF(@freeFromDate < @fromDate AND @freeToDate < @toDate)
--             RETURN;
--             
--     END
    
    
    DECLARE @totalDays INT = DATEDIFF(DAY, @fromDate, @toDate) + 1;
    
    -- Bảng tạm trong bộ nhớ (không dùng # vì trong hàm không được phép)
    DECLARE @filled_periods TABLE (
        oid UNIQUEIDENTIFIER,
        project_code NVARCHAR(50),
        par_residence_type_oid NVARCHAR(50),
        value DECIMAL(18,2),
        effective_date DATE,
        expiry_date DATE,
        tax_percent DECIMAL(10,2),
        is_active BIT,
        total_day INT
    );

    -- 1. Lấy dữ liệu gốc
    INSERT INTO @filled_periods
    SELECT 
        a.[oid],
        a.[project_code],
        a.[par_residence_type_oid],
        a.[value],
        [effective_date] = ISNULL(a.[effective_date], '1900-01-01'),
        [expiry_date] = ISNULL(a.[expiry_date], '9999-12-31'),
        a.[tax_percent],
        a.[is_active],
        total_day = 0
    FROM par_common a
    WHERE a.project_code = @project_code
      AND a.is_active = 1
      AND a.par_residence_type_oid = @par_residence_type_oid
      AND ((ISNULL(a.expiry_date, '9999-12-31') >= @fromDate)
           AND (ISNULL(a.effective_date, '1900-01-01') <= @toDate));

    -- 2. Lấp khoảng trống đầu kỳ
    UPDATE @filled_periods
    SET effective_date = @fromDate
    WHERE effective_date > @fromDate
      AND oid = (SELECT TOP 1 oid FROM @filled_periods ORDER BY effective_date ASC);
          
    UPDATE a
    SET a.effective_date = @fromDate
    FROM @filled_periods a
    WHERE a.effective_date < @fromDate

    -- 3. Lấp các khoảng trống giữa các bản ghi
    ;WITH Ordered AS (
        SELECT *,
               LEAD(effective_date) OVER (ORDER BY effective_date) AS next_start
        FROM @filled_periods
    )
    UPDATE f
    SET expiry_date = DATEADD(DAY, -1, o.next_start)
    FROM @filled_periods f
    INNER JOIN Ordered o ON f.oid = o.oid
    WHERE o.next_start IS NOT NULL
      AND DATEDIFF(DAY, f.expiry_date, o.next_start) > 1;

    -- 4. Lấp khoảng trống cuối kỳ
    UPDATE @filled_periods
    SET expiry_date = @toDate
    WHERE expiry_date < @toDate
      AND oid = (SELECT TOP 1 oid FROM @filled_periods ORDER BY effective_date DESC);
      
    UPDATE a
    SET a.expiry_date = @toDate
    FROM @filled_periods a
    WHERE a.expiry_date > @toDate

    -- 5. Cập nhật tổng số ngày
    UPDATE @filled_periods
    SET total_day = (DATEDIFF(DAY, effective_date, expiry_date) + 1);

    -- 6. Tính kết quả cuối cùng
    INSERT INTO @Result
    SELECT
        f.oid,
        f.project_code,
        f.par_residence_type_oid,
        f.effective_date,
        f.expiry_date,
        @totalDays AS totalDays,
        f.value,
        f.tax_percent,
        f.is_active,
        f.total_day,
        ROUND((((@area / @totalDays) * f.total_day) * f.value), 2) AS total_amount,
        ROUND(((f.tax_percent / 100) * (((@area / @totalDays) * f.total_day) * f.value)), 2) AS amount_tax,
        ROUND((((f.tax_percent / 100) * (((@area / @totalDays) * f.total_day) * f.value)) + (((@area / @totalDays) * f.total_day) * f.value)), 2) AS total_amount_tax
    FROM @filled_periods f
    ORDER BY f.effective_date;
    
    IF(@freeFromDate IS NOT NULL AND @freeToDate IS NOT NULL)
    BEGIN
        DECLARE @totalDayFree INT = 0;
        IF(@freeFromDate <= @fromDate AND @toDate <= @freeToDate)
            SET @totalDayFree = @totalDays;
        ELSE IF(@freeFromDate <= @fromDate AND @freeFromDate <= @fromDate AND @freeToDate <= @toDate)
            SET @totalDayFree = DATEDIFF(DAY, @fromDate, @freeToDate) + 1;
        ELSE IF(@fromDate <= @freeFromDate AND @freeToDate <= @toDate AND @toDate <= @freeToDate)
            SET @totalDayFree = DATEDIFF(DAY, @freeFromDate, @toDate) + 1;
        ELSE IF(@fromDate <= @freeFromDate AND @freeToDate <= @toDate)
            SET @totalDayFree = (DATEDIFF(DAY, @fromDate, @freeFromDate) + 1) + (DATEDIFF(DAY, @freeToDate, @toDate) + 1);

        DECLARE @totalDayCalculation INT = (@totalDays - @totalDayFree);
        IF(@totalDayFree IS NOT NULL AND @totalDayFree > 0)
        BEGIN
            SET @totalDayCalculation = (@totalDayCalculation + 1);
            
            UPDATE a
            SET
                a.total_amount = (a.total_amount / @totalDays) * @totalDayCalculation,
                a.total_amount_tax = (a.total_amount_tax / @totalDays) * @totalDayCalculation
            FROM @Result a
        END
    END

    RETURN;
END;