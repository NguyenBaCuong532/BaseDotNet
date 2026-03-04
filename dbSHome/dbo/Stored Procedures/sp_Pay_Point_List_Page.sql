
create PROCEDURE [dbo].[sp_Pay_Point_List_Page]
    @userId         nvarchar(450),
    @filter         nvarchar(50),
    @lastDate       nvarchar(20) = NULL,
    @numDay         int          = 7,
    @gridWidth      int          = 0,
    @Offset         int          = 0,
    @PageSize       int          = 10,
    @Total          int OUT,
    @TotalFiltered  int OUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        /* ========= Chuẩn hoá tham số & mốc thời gian ========= */
        DECLARE @p_now      datetime = GETDATE();
        DECLARE @endDate    datetime;
        DECLARE @startDate  datetime;

        SET @Offset   = ISNULL(@Offset, 0);
        SET @PageSize = CASE WHEN ISNULL(@PageSize, 10) <= 0 THEN 10 ELSE @PageSize END;
        SET @filter   = ISNULL(@filter, '');

        IF (@lastDate IS NULL OR LTRIM(RTRIM(@lastDate)) = '')
            SET @endDate = @p_now;
        ELSE
        BEGIN
            SET @endDate = TRY_CONVERT(datetime, @lastDate, 103);
            IF (@endDate IS NULL) SET @endDate = TRY_CONVERT(datetime, @lastDate, 120);
            IF (@endDate IS NULL) SET @endDate = @p_now;
        END

        IF (@numDay IS NULL OR @numDay = 0) SET @numDay = 7;
        IF (@numDay > 30) SET @numDay = 30;

        SET @startDate = DATEADD(DAY, -@numDay, @endDate);

        /* ================= Tổng bản ghi ================= */
        SELECT @Total = COUNT_BIG(p.PointCd)
        FROM dbo.MAS_Points AS p
        JOIN dbo.MAS_Customers AS c ON p.CustId = c.CustId
        WHERE p.sysDate <= @endDate
          --AND (
          --      @filter = '' OR
          --      c.Phone    LIKE @filter + '%' OR
          --      c.FullName LIKE @filter + '%'
          --    )
        OPTION (RECOMPILE);

        SET @TotalFiltered = @Total;

        /* =============== Kết quả trang đầu (offset=0) =============== */
        IF (@Offset = 0)
        BEGIN
            /* 1) gridflexs */
            SELECT *
            FROM dbo.[fn_config_list_gets] ('view_Crm_Get_Point_Page', @gridWidth - 100)
            ORDER BY [ordinal];

            /* 2) chart_day */
            DECLARE @intFlag int = 0;
            DECLARE @stDate  datetime;

            DECLARE @totaltemp TABLE
            (
                day_order_amt   decimal(18,0),
                day_voucher_pnt decimal(18,0),
                day_credit_pnt  decimal(18,0),
                day_debit_pnt   decimal(18,0),
                day_bal_pnt     decimal(18,0),
                day_trans       decimal(18,0),
                valueDate       datetime
            );

            WHILE (@intFlag < @numDay)
            BEGIN
                SET @stDate = DATEADD(DAY, @intFlag, @startDate);

                INSERT INTO @totaltemp
                (
                    valueDate, day_bal_pnt, day_order_amt,
                    day_voucher_pnt, day_credit_pnt, day_debit_pnt, day_trans
                )
                SELECT
                    @stDate AS valueDate,
                    /* snapshot balance cuối ngày @stDate */
                    SUM(t1.CurrPoint) AS sum_bal_pnt,
                    /* giao dịch trong ngày */
                    SUM(t2.sum_order_amt)   AS sum_order_amt,
                    SUM(t2.sum_voucher_pnt) AS sum_voucher_pnt,
                    SUM(t2.sum_credit_pnt)  AS sum_credit_pnt,
                    SUM(t2.sum_debit_pnt)   AS sum_debit_pnt,
                    SUM(t2.count_trans)     AS count_trans
                FROM
                (
                    SELECT
                        p.PointCd,
                        ISNULL(e.CurrPoint + e.Point - e.CreditPoint, p.CurrPoint) AS CurrPoint
                    FROM dbo.MAS_Points AS p
                    LEFT JOIN
                    (
                        SELECT w.PointCd, MAX(w.TranDt) AS maxtransdt
                        FROM dbo.WAL_PointOrder AS w
                        WHERE w.TranDt < DATEADD(DAY, 1, @stDate)
                        GROUP BY w.PointCd
                    ) AS d ON p.PointCd = d.PointCd
                    LEFT JOIN dbo.WAL_PointOrder AS e
                           ON e.PointCd = d.PointCd AND e.TranDt = d.maxtransdt
                    WHERE p.sysDate < DATEADD(DAY, 1, @stDate)
                ) AS t1
                JOIN
                (
                    SELECT
                        p.PointCd,
                        SUM(ISNULL(a.OrderAmount, 0)) AS sum_order_amt,
                        SUM(ISNULL(CASE WHEN a.TranType = 'voucher' THEN a.Point ELSE 0 END, 0)) AS sum_voucher_pnt,
                        SUM(ISNULL(a.CreditPoint, 0)) AS sum_credit_pnt,
                        SUM(ISNULL(CASE WHEN a.TranType = 'smember' THEN a.Point ELSE 0 END, 0)) AS sum_debit_pnt,
                        SUM(CASE WHEN a.PointTranId IS NOT NULL THEN 1 ELSE 0 END) AS count_trans
                    FROM dbo.MAS_Points AS p
                    LEFT JOIN dbo.WAL_PointOrder AS a
                           ON a.PointCd = p.PointCd
                          AND a.TranDt >= @stDate
                          AND a.TranDt <  DATEADD(DAY, 1, @stDate)
                    WHERE p.sysDate < DATEADD(DAY, 1, @stDate)
                    GROUP BY p.PointCd
                ) AS t2
                ON t1.PointCd = t2.PointCd
                OPTION (RECOMPILE);

                SET @intFlag += 1;
            END

            SELECT *
            FROM @totaltemp
            ORDER BY valueDate;

            /* 3) total_of_days: tổng trong khoảng @startDate..@endDate */
            ;WITH rangeAgg AS
            (
                SELECT
                    SUM(ISNULL(a.OrderAmount, 0)) AS sum_order_amt,
                    SUM(CASE WHEN a.TranType = 'voucher' THEN ISNULL(a.Point, 0) ELSE 0 END) AS sum_voucher_pnt,
                    SUM(ISNULL(a.CreditPoint, 0)) AS sum_credit_pnt,
                    SUM(CASE WHEN a.TranType = 'smember' THEN ISNULL(a.Point, 0) ELSE 0 END) AS sum_debit_pnt,
                    SUM(CASE WHEN a.PointTranId IS NOT NULL THEN 1 ELSE 0 END) AS count_trans
                FROM dbo.MAS_Points AS p
                LEFT JOIN dbo.WAL_PointOrder AS a
                       ON a.PointCd = p.PointCd
                      AND a.TranDt >= @startDate
                      AND a.TranDt <  DATEADD(DAY, 1, @endDate)
                WHERE p.sysDate <= @endDate
            )
            SELECT
                ra.sum_order_amt,
                ra.sum_voucher_pnt,
                ra.sum_credit_pnt,
                ra.sum_debit_pnt,
                /* balance tại thời điểm @endDate */
                SUM(pts.CurrPoint) AS sum_bal_pnt,
                ra.count_trans,
                @endDate AS valueDate
            FROM rangeAgg AS ra
            CROSS JOIN
            (
                SELECT p.CurrPoint
                FROM dbo.MAS_Points AS p
                WHERE p.sysDate <= @endDate
            ) AS pts
            GROUP BY ra.sum_order_amt, ra.sum_voucher_pnt, ra.sum_credit_pnt, ra.sum_debit_pnt, ra.count_trans;

            /* 4) total_last: tổng toàn kỳ (theo bản gốc – không lọc ngày WAL) */
            SELECT
                SUM(t.sum_order_amt)   AS sum_order_amt,
                SUM(t.sum_voucher_pnt) AS sum_voucher_pnt,
                SUM(t.sum_credit_pnt)  AS sum_credit_pnt,
                SUM(t.sum_debit_pnt)   AS sum_debit_pnt,
                SUM(t.sum_bal_pnt)     AS sum_bal_pnt,
                SUM(t.count_trans)     AS count_trans,
                @endDate               AS valueDate
            FROM
            (
                SELECT
                    p.PointCd,
                    /* tổng WAL không giới hạn ngày – giữ nguyên tinh thần thủ tục gốc */
                    SUM(ISNULL(a.OrderAmount, 0)) AS sum_order_amt,
                    SUM(ISNULL(CASE WHEN a.TranType = 'voucher' THEN a.Point ELSE 0 END, 0)) AS sum_voucher_pnt,
                    SUM(ISNULL(a.CreditPoint, 0)) AS sum_credit_pnt,
                    SUM(ISNULL(CASE WHEN a.TranType = 'smember' THEN a.Point ELSE 0 END, 0)) AS sum_debit_pnt,
                    p.CurrPoint AS sum_bal_pnt,
                    SUM(CASE WHEN a.PointTranId IS NOT NULL THEN 1 ELSE 0 END) AS count_trans
                FROM dbo.MAS_Points p
                LEFT JOIN dbo.WAL_PointOrder a ON a.PointCd = p.PointCd
                WHERE p.sysDate <= @endDate
                GROUP BY p.PointCd, p.CurrPoint
            ) AS t;
        END

        /* ================= Listing phân trang (result set cuối) ================= */
        ;WITH aggEnd AS
        (
            SELECT
                a.PointCd,
                SUM(ISNULL(a.Point, 0)) AS sumPointAll,
                SUM(ISNULL(a.CreditPoint, 0)) AS sumCreditAll,
                SUM(ISNULL(a.OrderAmount, 0)) AS sumOrderAll,
                SUM(CASE WHEN a.TranType = 'voucher' THEN ISNULL(a.Point, 0) ELSE 0 END) AS sumVoucher,
                SUM(CASE WHEN a.TranType = 'smember' THEN ISNULL(a.Point, 0) ELSE 0 END) AS sumDebit
            FROM dbo.WAL_PointOrder AS a
            WHERE a.TranDt <= @endDate
            GROUP BY a.PointCd
        )
        SELECT
            p.PointCd,
            p.PointType,
            p.CustId,
            CurrentPoint   = ISNULL(ag.sumPointAll, 0) - ISNULL(ag.sumCreditAll, 0),
            LastDate       = p.LastDt,
            [Priority]     = 'Gold',
            sumVoucher     = ISNULL(ag.sumVoucher, 0),
            sumOrderAmt    = ISNULL(ag.sumOrderAll, 0),
            sumCreditPoint = ISNULL(ag.sumCreditAll, 0),
            sumDebitPoint  = ISNULL(ag.sumDebit, 0),
            c.FullName,
            Phone          = '*****' + RIGHT(c.Phone, 4),
            c.Email,
            base_types =
                STUFF((
                    SELECT ',' + CAST(bt.base_desc AS nvarchar(255))
                    FROM dbo.MAS_Base_Type bt
                    WHERE EXISTS
                    (
                        SELECT 1
                        FROM dbo.MAS_Category_Customer pcc
                        JOIN dbo.MAS_Category m ON pcc.CategoryCd = m.CategoryCd
                        WHERE m.base_type = bt.base_type
                          AND pcc.CustId = c.CustId
                    )
                    FOR XML PATH(''), TYPE
                ).value('.', 'nvarchar(max)'), 1, 1, ''),
            [Address] =
                STUFF((
                    SELECT ',' + a.RoomCode
                    FROM dbo.MAS_Apartments a
                    JOIN dbo.MAS_Apartment_Member b ON a.ApartmentId = b.ApartmentId
                    JOIN dbo.MAS_Rooms r ON a.RoomCode = r.RoomCode
                    JOIN dbo.MAS_Buildings mb ON r.BuildingCd = mb.BuildingCd
                    WHERE b.CustId = c.CustId
                    FOR XML PATH(''), TYPE
                ).value('.', 'nvarchar(max)'), 1, 1, '')
                + ISNULL(c.[Address], '')
        FROM dbo.MAS_Points AS p
        JOIN dbo.MAS_Customers AS c ON p.CustId = c.CustId
        LEFT JOIN aggEnd AS ag       ON ag.PointCd = p.PointCd
        WHERE p.sysDate <= @endDate
          --AND (
          --      @filter = '' OR
          --      c.Phone    LIKE @filter + '%' OR
          --      c.FullName LIKE @filter + '%'
          --    )
        ORDER BY p.sysDate DESC
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY
        OPTION (RECOMPILE);

    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum  int,
                @ErrorMsg  varchar(200),
                @ErrorProc varchar(50),
                @SessionID int,
                @AddlInfo  varchar(max);

        SET @ErrorNum  = ERROR_NUMBER();
        SET @ErrorMsg  = 'sp_Pay_Point_List_Page ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo  = '@userId ';

        EXEC dbo.utl_Insert_ErrorLog
             @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'GET', @SessionID, @AddlInfo;
    END CATCH
END