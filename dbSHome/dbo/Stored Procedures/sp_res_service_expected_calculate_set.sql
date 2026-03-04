CREATE   procedure [dbo].[sp_res_service_expected_calculate_set]
    @UserID               NVARCHAR(450),
    @periods_oid      NVARCHAR(50) = NULL,
    @project_code         NVARCHAR(10) = NULL,
--     @RevenuePeriodFromDate NVARCHAR(50) = NULL,

    @ProjectCd            NVARCHAR(10),  
    @ToDate               NVARCHAR(10),
    @BuildingCd           NVARCHAR(50),
    @ApartmentCd          NVARCHAR(MAX),
    @FloorNo	             NVARCHAR(10),
    @ProjectName          NVARCHAR(100) = NULL,
    @AcceptLanguage       NVARCHAR(50)  = 'vi',
    @Apartments           NVARCHAR(MAX) = NULL,
    @IsSelectTest         BIT = 0     -- giữ cho tương thích, không dùng nữa
AS
DECLARE @valid        BIT           = 0;
DECLARE @messages     NVARCHAR(250) = N'';
BEGIN TRY
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    IF(@periods_oid IS NOT NULL AND EXISTS(SELECT TOP 1 1 FROM mas_billing_periods WHERE oid = @periods_oid AND locked = 1))
    BEGIN
        SET @valid = 0;
        SET @messages = N'Kỳ thanh toán đã khóa. Vui lòng kiểm tra lại.';
        GOTO FINALLY;
    END

    -------------------------------------------------------
    -- 0. CHUẨN HOÁ INPUT + TẬP CĂN HỘ
    -------------------------------------------------------
    SET @BuildingCd  = ISNULL(@BuildingCd,  '');
    SET @FloorNo     = ISNULL(@FloorNo,     '');
    SET @Apartments  = ISNULL(@Apartments,  '');
    SET @ApartmentCd = ISNULL(@ApartmentCd, '');

    IF (TRIM(@Apartments) = '' AND TRIM(@ApartmentCd) <> '')
        SET @Apartments = @ApartmentCd;

    IF OBJECT_ID('tempdb..#ArrApartments') IS NOT NULL DROP TABLE #ArrApartments;
    SELECT part
    INTO #ArrApartments
    FROM dbo.SplitString(@Apartments, ',');

    IF NOT EXISTS(SELECT 1 FROM #ArrApartments)
    BEGIN
        INSERT INTO #ArrApartments(part)
        SELECT a.ApartmentId
        FROM MAS_Apartments a
        LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
        LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid
        WHERE
            b.ProjectCd = @ProjectCd
            AND (TRIM(@BuildingCd) = '' OR b.BuildingCd = @BuildingCd)
            AND (TRIM(@FloorNo)    = '' OR a.floorNo   = @FloorNo)
            AND (TRIM(@ApartmentCd)= '' OR a.ApartmentId = @ApartmentCd)
        ORDER BY a.RoomCode;
    END

    DECLARE
        @ToDt         DATE,
        @ToDtVehicle  DATETIME,
        @ToDtFee      DATETIME,
        @feePrice     DECIMAL(18,0),
        @ToDtEntry    DATE,
        @MonthStart   DATE,
        @DaysInMonth  INT;

    DECLARE @tbAparts TABLE(
        [ApartmentId] BIGINT NOT NULL
        INDEX IX1_Apartment NONCLUSTERED (ApartmentId)
    );

    -- Kỳ hoá đơn (n), kỳ xe (n+1), kỳ phí DV (n+1)
    SET @ToDt        = EOMONTH(CONVERT(DATE, @ToDate, 103));
    SET @ToDtVehicle = EOMONTH(DATEADD(MONTH, 1, @ToDt));
    SET @ToDtFee     = EOMONTH(DATEADD(MONTH, 1, @ToDt));
    SET @ToDtEntry   = TRY_CONVERT(DATE, @ToDate, 105);
    SET @MonthStart  = DATEFROMPARTS(YEAR(CONVERT(DATE, @ToDate, 103)), MONTH(CONVERT(DATE, @ToDate, 103)), 1);
    SET @DaysInMonth = DAY(EOMONTH(CONVERT(DATE, @ToDate, 103)));
    SET @feePrice    = ISNULL(
                        (SELECT TOP 1 Price
                         FROM PAR_ServicePrice
                         WHERE ServiceTypeId = 1 AND TypeId = 1 AND ProjectCd = @ProjectCd),
                        10000
                      );
    DECLARE @fromDate DATE = @MonthStart;

    INSERT INTO @tbAparts (ApartmentId)
    SELECT part FROM #ArrApartments;

    -- Filter IsBill and Count
    DECLARE @TotalInput INT = (SELECT COUNT(1) FROM @tbAparts);
    
    DELETE a
    FROM @tbAparts a
    JOIN MAS_Service_ReceiveEntry r ON r.ApartmentId = a.ApartmentId
    WHERE r.ToDt = @ToDtEntry AND r.IsBill = 1;

    DECLARE @TotalValid INT = (SELECT COUNT(1) FROM @tbAparts);
    
    -------------------------------------------------------
    -- BẮT ĐẦU TRANSACTION CHO CÁC DML CHÍNH
    -------------------------------------------------------
    BEGIN TRAN

    /* ============================================================
       1) RECEIVE ENTRY (KỲ HÓA ĐƠN @ToDtEntry) - CommonFee
       ============================================================ */
    IF OBJECT_ID('tempdb..#FeeCalc') IS NOT NULL DROP TABLE #FeeCalc;

    SELECT 
        a.ApartmentId,
        ma.ProjectCd,
        SUM(
            CASE 
                WHEN ma.IsFree = 1 AND ma.FreeToDt > @ToDtEntry THEN 0
                ELSE ISNULL(ma.WaterwayArea, 0) * ISNULL(pc.value, 0) *
                     (1.0 * (
                         DATEDIFF(DAY,
                             CASE 
                                 WHEN ma.FreeToDt IS NOT NULL
                                      AND ma.FreeToDt BETWEEN pc.effective_date AND ISNULL(pc.expiry_date, @ToDtEntry)
                                      THEN ma.FreeToDt
                                 WHEN pc.effective_date < @MonthStart THEN @MonthStart
                                 ELSE pc.effective_date
                             END,
                             CASE 
                                 WHEN ISNULL(pc.expiry_date, @ToDtEntry) > @ToDtEntry THEN @ToDtEntry
                                 ELSE ISNULL(pc.expiry_date, @ToDtEntry)
                             END
                         ) + 1
                     ) / NULLIF(@DaysInMonth, 0))
            END
        ) AS CommonFee
    INTO #FeeCalc
    FROM
        @tbAparts a
        JOIN MAS_Apartments ma ON a.ApartmentId = ma.ApartmentId
        JOIN par_common pc ON pc.project_code = ma.ProjectCd AND pc.is_active = 1
    WHERE
        pc.value > 0
        AND pc.effective_date <= @ToDtEntry
        AND (pc.expiry_date IS NULL OR pc.expiry_date >= @MonthStart)
    GROUP BY a.ApartmentId, ma.ProjectCd;

    -- UPDATE dòng dự kiến đã có
    UPDATE t
    SET t.ProjectCd = fc.ProjectCd,
        t.ToDt      = @ToDtEntry,
        t.isExpected= 1,
        t.CommonFee = fc.CommonFee,
        t.periods_oid = ISNULL(@periods_oid, t.periods_oid)
    FROM
        MAS_Service_ReceiveEntry t
        JOIN #FeeCalc fc ON t.ApartmentId = fc.ApartmentId
    WHERE t.IsPayed = 0
        AND t.ToDt    = @ToDtEntry
        AND t.PaidAmt = 0;

    -- INSERT nếu chưa có dòng mở kỳ này
    INSERT INTO MAS_Service_ReceiveEntry
    (
        ApartmentId,
        periods_oid,
        ReceiveDt,
        ToDt,
        SysDate,
        ProjectCd,
        IsPayed,
        isExpected,
        CommonFee,
        CreditAmt, DebitAmt, ExtendAmt, LivingAmt, VehicleAmt, TotalAmt, PaidAmt,
        createId
    )
    SELECT
        fc.ApartmentId,
        @periods_oid,
        GETDATE(), @ToDtEntry, GETDATE(),
        fc.ProjectCd,
        0, 1, fc.CommonFee,
        0,0,0,0,0,0,0,
        @UserID
    FROM #FeeCalc fc
    WHERE NOT EXISTS (SELECT 1
                      FROM MAS_Service_ReceiveEntry x
                      WHERE x.ApartmentId = fc.ApartmentId
                          AND x.ToDt        = @ToDtEntry
                          AND x.isExpected  = 1);

    /* ============================================================
       2) PHÍ DỊCH VỤ (ServiceTypeId = 1)
       ============================================================ */
    DELETE t
    FROM
        MAS_Service_Receivable t
        JOIN MAS_Apartments a ON t.srcId = a.ApartmentId AND t.ServiceTypeId = 1
        JOIN @tbAparts c      ON c.ApartmentId = a.ApartmentId
        JOIN dbo.fn_Hom_ServiceFee_Payday_project(@ProjectCd, @ToDtFee) h ON h.ApartmentId = a.ApartmentId
        JOIN MAS_Service_ReceiveEntry d ON d.ApartmentId = c.ApartmentId AND d.ReceiveId = t.ReceiveId
    WHERE
        (a.IsFree = 0 OR (a.IsFree = 1 AND ISNULL(a.lastReceived, a.FreeToDt) < @ToDtFee))
        AND d.ToDt    = @ToDt
        AND d.IsPayed = 0
        AND d.PaidAmt = 0;
      
    DECLARE @FromCalCommon DATE = DATEADD(MONTH, 1, @MonthStart);
    DECLARE @EndCalCommon DATE = EOMONTH(@FromCalCommon, 0);

    INSERT INTO MAS_Service_Receivable
    (
        ReceiveId, ServiceTypeId, ServiceObject,
        Amount, VATAmt, TotalAmt,
        fromDt, ToDt, Quantity, Price, srcId, totalDays
    )
    SELECT
        d.ReceiveId,
        1,
        CONCAT(a.RoomCode, N' - Phí dịch vụ'),
        cal.total_amount,
        cal.amount_tax,
        cal.total_amount_tax,
        cal.effective_date,
        cal.expiry_date,
        h.Quantity,
        cal.value,
        a.ApartmentId,
        cal.totalDays
    FROM
        MAS_Apartments a
        JOIN @tbAparts c ON c.ApartmentId = a.ApartmentId
        JOIN dbo.fn_Hom_ServiceFee_Payday_project(@ProjectCd, @ToDtFee) h ON h.ApartmentId = a.ApartmentId
        JOIN MAS_Service_ReceiveEntry d ON d.ApartmentId = c.ApartmentId
        OUTER APPLY dbo.fn_common_service_calculation(@ProjectCd, @FromCalCommon, @EndCalCommon, a.par_residence_type_oid, a.WaterwayArea, IIF(a.IsFree = 1, ISNULL(a.FeeStart, a.ReceiveDt), NULL), IIF(a.IsFree = 1, FreeToDt, NULL)) cal
    WHERE
        (a.IsFree = 0 OR (a.IsFree = 1 AND ISNULL(a.FreeToDt, a.lastReceived) < @ToDtFee))
        AND d.ToDt    = @ToDt
        AND d.IsPayed = 0
        AND d.PaidAmt = 0
        AND NOT EXISTS (SELECT 1
                        FROM MAS_Service_Receivable t1
                        WHERE
                            t1.ServiceTypeId = 1
                            AND t1.srcId     = a.ApartmentId
                            AND t1.ReceiveId = d.ReceiveId);

    -- AccrualLastDt
    UPDATE a
    SET a.AccrualLastDt = @ToDtFee
    FROM
        MAS_Apartments a
        JOIN @tbAparts c ON c.ApartmentId = a.ApartmentId
        JOIN MAS_Service_Receivable r ON r.srcId = a.ApartmentId AND r.ServiceTypeId = 1
        JOIN MAS_Service_ReceiveEntry d ON d.ReceiveId = r.ReceiveId
    WHERE
        a.ReceiveDt < @ToDtFee
        AND ISNULL(a.lastReceived, a.FreeToDt) < @ToDtFee
        AND d.ToDt    = @ToDt
        AND d.IsPayed = 0
        AND d.PaidAmt = 0;

    /* ============================================================
       3) PHÍ XE (ServiceTypeId = 2) - CLEANUP
       ============================================================ */
    IF OBJECT_ID('tempdb..#ScopeReceive') IS NOT NULL DROP TABLE #ScopeReceive;
    CREATE TABLE #ScopeReceive (ReceiveId BIGINT PRIMARY KEY, IsPayed bit);

    INSERT #ScopeReceive(ReceiveId, IsPayed)
    SELECT d.ReceiveId, d.IsPayed
    FROM
        MAS_Service_ReceiveEntry d
        JOIN @tbAparts a ON a.ApartmentId = d.ApartmentId
    WHERE
        d.ToDt = @ToDt
        AND d.IsPayed = 0
        AND d.PaidAmt = 0;

    IF OBJECT_ID('tempdb..#VehScope') IS NOT NULL DROP TABLE #VehScope;
    SELECT DISTINCT v.CardVehicleId, v.ApartmentId, v.StartTime, v.EndTime, v.lastReceivable, v.Status
    INTO #VehScope
    FROM
        MAS_CardVehicle v
        JOIN @tbAparts a ON a.ApartmentId = v.ApartmentId
    WHERE v.Status in (1,5);

    IF OBJECT_ID('tempdb..#VehEligible') IS NOT NULL DROP TABLE #VehEligible;
    SELECT v.CardVehicleId
    INTO #VehEligible
    FROM #VehScope v
    WHERE ISNULL(v.EndTime, v.StartTime) <= @ToDtVehicle
      AND (v.lastReceivable IS NULL OR v.lastReceivable < @ToDtVehicle);

    DELETE r
    FROM
        MAS_Service_Receivable r
        JOIN #ScopeReceive s ON s.ReceiveId = r.ReceiveId
        LEFT JOIN #VehEligible e ON e.CardVehicleId = r.srcId
    WHERE r.ServiceTypeId = 2
      AND ISNULL(s.IsPayed,0) = 0
      AND (r.ToDt <> @ToDtVehicle OR e.CardVehicleId IS NULL);

    WITH dups AS (
        SELECT r.ReceivableId,
               ROW_NUMBER() OVER(
                 PARTITION BY r.ReceiveId, r.ServiceTypeId, r.srcId, r.ToDt
                 ORDER BY r.ReceivableId DESC
               ) rn
        FROM MAS_Service_Receivable r
        JOIN #ScopeReceive s ON s.ReceiveId = r.ReceiveId
        WHERE r.ServiceTypeId = 2
          AND ISNULL(s.IsPayed,0) = 0
          AND r.ToDt = @ToDtVehicle
    )
    DELETE r
    FROM
        MAS_Service_Receivable r
        JOIN dups d ON d.ReceivableId = r.ReceivableId
    WHERE d.rn > 1;

    WITH need_reset AS (
        SELECT v.CardVehicleId
        FROM #VehScope v
        WHERE ISNULL(v.EndTime, v.StartTime) <= @ToDtVehicle
          AND ISNULL(v.lastReceivable, '19000101') >= @ToDtVehicle
          AND NOT EXISTS (
              SELECT 1
              FROM MAS_Service_Receivable r
              JOIN #ScopeReceive s ON s.ReceiveId = r.ReceiveId
              WHERE r.ServiceTypeId = 2
                AND r.srcId = v.CardVehicleId
                AND r.ToDt = @ToDtVehicle
                AND ISNULL(s.IsPayed,0) = 0
          )
    )
    UPDATE v
    SET v.lastReceivable = DATEADD(DAY, -1, @ToDtVehicle),
        v.endTime_Tmp    = v.EndTime
    FROM MAS_CardVehicle v
    JOIN need_reset x ON x.CardVehicleId = v.CardVehicleId;

    /* ============================================================
       4) PHÍ XE (ServiceTypeId = 2) - MERGE (KỲ @ToDtVehicle)
       ============================================================ */
    WITH Veh AS (
        SELECT
            d.ReceiveId,
            v.CardVehicleId                    AS srcId,
            v.VehicleNo                        AS ServiceObject,
            ISNULL(v.endTime_Tmp, v.StartTime) AS fromDt,
            @ToDtVehicle                       AS ToDt,
            b.[Quantity],
            b.Price,
            ROUND(b.Amount * 10.0 / 11.0, 0)   AS Amount,    -- net
            ROUND(b.Amount / 11.0, 0)          AS VATAmt,    -- VAT
            b.Amount                           AS TotalAmt,  -- gross
            b.VehNum                           AS VehicleNum
        FROM MAS_CardVehicle v
        JOIN @tbAparts a ON a.ApartmentId = v.ApartmentId
        JOIN MAS_Service_ReceiveEntry d ON d.ApartmentId = a.ApartmentId
                                       AND d.ToDt        = @ToDt
                                       AND d.IsPayed     = 0
                                       AND d.PaidAmt     = 0
        JOIN dbo.fn_Hom_Vehicle_Payday_project(@ProjectCd, @ToDtVehicle) b
             ON b.CardVehicleId = v.CardVehicleId
        WHERE ISNULL(v.EndTime, v.StartTime) <= @ToDtVehicle
          AND (v.lastReceivable IS NULL OR v.lastReceivable < @ToDtVehicle)
          AND v.Status in (1,5)
    )
    MERGE MAS_Service_Receivable AS T
    USING Veh AS S
       ON  T.ReceiveId     = S.ReceiveId
       AND T.ServiceTypeId = 2
       AND T.srcId         = S.srcId
       AND T.ToDt          = S.ToDt
       AND T.VehicleNum    = S.VehicleNum
    WHEN MATCHED THEN
        UPDATE SET
            T.Amount        = S.Amount,
            T.VATAmt        = S.VATAmt,
            T.TotalAmt      = S.TotalAmt,
            T.fromDt        = S.fromDt,
            T.Quantity      = S.Quantity,
            T.Price         = S.Price,
            T.ServiceObject = S.ServiceObject
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ReceiveId, ServiceTypeId, ServiceObject, Amount, VATAmt, TotalAmt, fromDt, ToDt, Quantity, Price, srcId, VehicleNum)
        VALUES (S.ReceiveId, 2, S.ServiceObject, S.Amount, S.VATAmt, S.TotalAmt, S.fromDt, S.ToDt, S.Quantity, S.Price, S.srcId, S.VehicleNum)
    ;

    UPDATE v
    SET v.lastReceivable = @ToDtVehicle,
        v.endTime_Tmp    = v.EndTime
    FROM MAS_CardVehicle v
    JOIN (
        SELECT DISTINCT r.srcId
        FROM MAS_Service_Receivable r
        JOIN #ScopeReceive s ON s.ReceiveId = r.ReceiveId
        WHERE r.ServiceTypeId = 2
          AND r.ToDt = @ToDtVehicle
    ) x ON x.srcId = v.CardVehicleId;

    /* ============================================================
   4b) PHÍ XE - ĐIỀU CHỈNH GIẢM DỰ THU KỲ TRƯỚC (ÂM)
   YÊU CẦU MỚI:
   - Chỉ điều chỉnh nếu THÁNG HIỆN TẠI vẫn còn xe (dựa trên fn_Hom_Vehicle_Payday_project(@ProjectCd, @ToDtVehicle))
   - Nếu tháng hiện tại không còn xe -> không điều chỉnh, VehicleAmt = 0
   ============================================================ */
        --DECLARE @PrevVehiclePeriod DATE = EOMONTH(@ToDt);   -- kỳ dịch vụ cần điều chỉnh (tháng n+1 của kỳ trước, chính là tháng @ToDt)

        --;WITH PrevAgg AS (
        --    SELECT
        --        r.srcId        AS CardVehicleId,
        --        dPrev.ApartmentId,
        --        PrevTotalAmt = SUM(r.TotalAmt)
        --    FROM MAS_Service_Receivable r
        --    JOIN MAS_Service_ReceiveEntry dPrev
        --         ON dPrev.ReceiveId = r.ReceiveId
        --    JOIN @tbAparts a ON a.ApartmentId = dPrev.ApartmentId
        --    WHERE r.ServiceTypeId = 2
        --      AND r.ToDt          = @PrevVehiclePeriod   -- dự thu cho tháng cần điều chỉnh
        --      AND dPrev.IsPayed   = 1
        --      AND dPrev.isExpected = 1
        --      --AND dPrev.PaidAmt   = 0
        --    GROUP BY r.srcId, dPrev.ApartmentId
        --),
        --NewCalc AS (
        --    SELECT
        --        f.CardVehicleId,
        --        cv.ApartmentId,
        --        f.RoomCode,
        --        f.VehNum    AS VehicleNum,
        --        f.Price,
        --        f.Amount    AS NewAmount
        --    FROM dbo.fn_Hom_Vehicle_Payday_project(@ProjectCd, @PrevVehiclePeriod) f
        --    JOIN MAS_CardVehicle cv ON cv.CardVehicleId = f.CardVehicleId
        --    JOIN @tbAparts a        ON a.ApartmentId   = cv.ApartmentId
        --),
        --Adj AS (
        --    SELECT
        --        p.CardVehicleId,
        --        p.ApartmentId,
        --        nc.RoomCode,
        --        nc.VehicleNum,
        --        nc.Price,
        --        p.PrevTotalAmt,
        --        NewAmount = ISNULL(nc.NewAmount, 0),
        --        Diff      = ISNULL(nc.NewAmount, 0) - p.PrevTotalAmt
        --    FROM PrevAgg p
        --    LEFT JOIN NewCalc nc
        --           ON nc.CardVehicleId = p.CardVehicleId
        --          AND nc.ApartmentId   = p.ApartmentId
        --),
        --CurrVeh AS (
        --    -- Tháng hiện tại có xe hay không? 
        --    -- Nếu function @ToDtVehicle không trả dòng nào cho căn hộ -> căn đó KHÔNG được điều chỉnh.
        --    SELECT DISTINCT cv.ApartmentId
        --    FROM dbo.fn_Hom_Vehicle_Payday_project(@ProjectCd, @ToDtVehicle) f
        --    JOIN MAS_CardVehicle cv ON cv.CardVehicleId = f.CardVehicleId
        --    JOIN @tbAparts a        ON a.ApartmentId   = cv.ApartmentId
        --)
        --INSERT INTO MAS_Service_Receivable
        --(
        --    ReceiveId, ServiceTypeId, ServiceObject,
        --    Amount, VATAmt, TotalAmt,
        --    fromDt, ToDt, Quantity, Price, srcId, VehicleNum
        --)
        --SELECT
        --    dCurr.ReceiveId,
        --    2,
        --    CONCAT(Adj.RoomCode, N' - Điều chỉnh giảm phí xe tháng ',
        --           RIGHT('0' + CAST(MONTH(@PrevVehiclePeriod) AS NVARCHAR(2)),2),
        --           '/', CAST(YEAR(@PrevVehiclePeriod) AS NVARCHAR(4))),
        --    Amount   = ROUND(Adj.Diff * 10.0 / 11.0, 0),
        --    VATAmt   = Adj.Diff - ROUND(Adj.Diff * 10.0 / 11.0, 0),
        --    TotalAmt = Adj.Diff,
        --    fromDt   = @PrevVehiclePeriod,
        --    ToDt     = @PrevVehiclePeriod,
        --    Quantity = NULL,
        --    Price    = Adj.Price,
        --    srcId    = Adj.CardVehicleId,
        --    VehicleNum = Adj.VehicleNum
        --FROM Adj
        --JOIN MAS_Service_ReceiveEntry dCurr
        --         ON dCurr.ApartmentId = Adj.ApartmentId
        --        AND dCurr.ToDt        = @ToDt          -- ghi nhận điều chỉnh ở kỳ hóa đơn hiện tại
        --        AND dCurr.IsPayed     = 0
        --        AND dCurr.PaidAmt     = 0
        --JOIN CurrVeh cv
        --         ON cv.ApartmentId = dCurr.ApartmentId -- 🔴 chỉ căn còn xe ở tháng hiện tại (function trả dữ liệu)
        --WHERE Adj.Diff < 0;                             -- vẫn chỉ điều chỉnh GIẢM (âm)

    
    /* ============================================================
       5) PHÍ SINH HOẠT - ĐIỆN (ServiceTypeId = 3)
       ============================================================ */
    UPDATE t
    SET
        t.Amount   = v.Amount,
        t.VATAmt   = ROUND(v.VatAmt, 0),
        t.TotalAmt = ROUND(v.Amount + v.VatAmt, 0),
        t.fromDt   = v.FromDt,
        t.ToDt     = v.ToDt,
        t.Quantity = v.TotalNum,
        t.Price    = v.Amount,
        t.NtshAmt  = 0
    FROM MAS_Service_Receivable t
        JOIN MAS_Service_Living_Tracking v ON v.TrackingId   = t.srcId AND t.ServiceTypeId = 3 AND v.LivingTypeId  = 1
        JOIN MAS_LivingTypes c ON c.LivingTypeId = v.LivingTypeId
        JOIN @tbAparts a ON a.ApartmentId = v.ApartmentId
        JOIN MAS_Service_ReceiveEntry d ON d.ApartmentId = a.ApartmentId  AND d.ReceiveId   = t.ReceiveId
    WHERE v.IsCalculate = 1
        AND MONTH(d.ToDt) = MONTH(@ToDt) 
        AND YEAR(d.ToDt)  = YEAR(@ToDt)
        AND d.IsPayed = 0 AND d.PaidAmt = 0
        AND v.ToDt > DATEFROMPARTS(2020,11,30);

    INSERT INTO MAS_Service_Receivable
    (
        ReceiveId, ServiceTypeId, ServiceObject,
        Amount, VATAmt, TotalAmt, NtshAmt,
        fromDt, ToDt, Quantity, Price, srcId
    )
    SELECT
        d.ReceiveId, 3, c.LivingTypeName,
        v.Amount,
        ROUND(v.VatAmt, 0),
        ROUND(v.Amount + v.VatAmt, 0),
        0,
        v.FromDt, v.ToDt, v.TotalNum, v.Amount, v.TrackingId
    FROM
        MAS_Service_Living_Tracking v
        JOIN MAS_LivingTypes c ON c.LivingTypeId = v.LivingTypeId
        JOIN @tbAparts a ON a.ApartmentId = v.ApartmentId
        JOIN MAS_Service_ReceiveEntry d ON d.ApartmentId = a.ApartmentId
    WHERE
        v.IsCalculate   = 1
        AND v.LivingTypeId  = 1
        AND d.IsPayed       = 0
        AND d.PaidAmt       = 0
        AND MONTH(v.ToDt)   = MONTH(@ToDt)
        AND YEAR(v.ToDt)    = YEAR(@ToDt)
        AND v.IsReceivable  = 0
        AND NOT EXISTS (
              SELECT 1
              FROM MAS_Service_Receivable t3
              WHERE t3.ServiceTypeId = 3
                AND t3.srcId     = v.TrackingId
                AND t3.ReceiveId = d.ReceiveId
                AND MONTH(t3.ToDt) = MONTH(@ToDt)
                AND YEAR(t3.ToDt)  = YEAR(@ToDt)
        )
        AND v.ToDt > DATEFROMPARTS(2020,11,30);

    /* ============================================================
       6) PHÍ SINH HOẠT - NƯỚC (ServiceTypeId = 4)
       ============================================================ */
    UPDATE t
    SET
        t.Amount   = v.Amount,
        t.VATAmt   = ROUND(ISNULL(v.VatAmt, 0), 0),
        t.TotalAmt = ROUND(v.Amount + ISNULL(v.VatAmt, 0), 0),
        t.fromDt   = v.FromDt,
        t.ToDt     = v.ToDt,
        t.Quantity = v.TotalNum,
        t.Price    = v.Amount,
        t.NtshAmt  = 0
    FROM
        MAS_Service_Receivable t
        JOIN MAS_Service_Living_Tracking v ON v.TrackingId   = t.srcId AND t.ServiceTypeId = 4 AND v.LivingTypeId  = 2
        JOIN MAS_LivingTypes c  ON c.LivingTypeId  = v.LivingTypeId
        JOIN @tbAparts a        ON a.ApartmentId   = v.ApartmentId
        JOIN MAS_Service_ReceiveEntry d ON d.ApartmentId = a.ApartmentId AND d.ReceiveId   = t.ReceiveId
    WHERE
        v.IsCalculate = 1
        AND MONTH(d.ToDt) = MONTH(@ToDt)
        AND YEAR(d.ToDt)  = YEAR(@ToDt)
        AND d.IsPayed     = 0
        AND d.PaidAmt     = 0
        AND v.ToDt > DATEFROMPARTS(2020,11,30);

    INSERT INTO MAS_Service_Receivable
    (
        ReceiveId, ServiceTypeId, ServiceObject,
        Amount, VATAmt, TotalAmt, NtshAmt,
        fromDt, ToDt, Quantity, Price, srcId
    )
    SELECT
        d.ReceiveId,
        4,
        c.LivingTypeName,
        v.Amount,
        ROUND(ISNULL(v.VatAmt, 0), 0),
        ROUND(v.Amount + ISNULL(v.VatAmt, 0), 0),
        0,
        v.FromDt,
        v.ToDt,
        v.TotalNum,
        v.Amount,
        v.TrackingId
    FROM
        MAS_Service_Living_Tracking v
        JOIN MAS_LivingTypes c ON c.LivingTypeId = v.LivingTypeId
        JOIN @tbAparts a       ON a.ApartmentId  = v.ApartmentId
        JOIN MAS_Service_ReceiveEntry d ON d.ApartmentId = a.ApartmentId
    WHERE
        v.IsCalculate   = 1
        AND v.LivingTypeId  = 2
        AND d.IsPayed       = 0
        AND d.PaidAmt       = 0
        AND MONTH(v.ToDt)   = MONTH(@ToDt)
        AND YEAR(v.ToDt)    = YEAR(@ToDt)
        AND v.IsReceivable  = 0
        AND NOT EXISTS (SELECT 1
                        FROM MAS_Service_Receivable t3
                        WHERE
                            t3.ServiceTypeId = 4
                            AND t3.srcId     = v.TrackingId
                            AND t3.ReceiveId = d.ReceiveId
                            AND MONTH(t3.ToDt) = MONTH(@ToDt)
                            AND YEAR(t3.ToDt)  = YEAR(@ToDt))
        AND v.ToDt > DATEFROMPARTS(2020,11,30);

    /* ============================================================
       7) NỢ PHÍ (ServiceTypeId = 9)
       ============================================================ */
    IF OBJECT_ID('tempdb..#ScopeReceiveDebt') IS NOT NULL DROP TABLE #ScopeReceiveDebt;
    CREATE TABLE #ScopeReceiveDebt (ReceiveId BIGINT PRIMARY KEY);

    INSERT #ScopeReceiveDebt(ReceiveId)
    SELECT d.ReceiveId
    FROM MAS_Service_ReceiveEntry d
    JOIN #ArrApartments a ON a.part = d.ApartmentId
    WHERE d.ToDt = @ToDt AND d.IsPayed = 0 AND d.PaidAmt = 0;

    DELETE r
    FROM MAS_Service_Receivable r
    JOIN #ScopeReceiveDebt s ON s.ReceiveId = r.ReceiveId
    WHERE r.ServiceTypeId = 9;

    INSERT INTO MAS_Service_Receivable(ReceiveId, ServiceTypeId, ServiceObject, TotalAmt)
    SELECT t.ReceiveId, 9, N'Nợ phí', c.DebitAmt
    FROM MAS_Service_ReceiveEntry t
    JOIN #ScopeReceiveDebt a ON a.ReceiveId = t.ReceiveId
    JOIN MAS_Apartments c ON c.ApartmentId = t.ApartmentId
    WHERE c.DebitAmt <> 0 OR c.DebitAmt IS NOT NULL;

    /* ============================================================
       8) CỘNG TỔNG VÀO RECEIVE ENTRY
       ============================================================ */
    UPDATE t
    SET 
        t.CommonFee  = (SELECT SUM(TotalAmt) FROM MAS_Service_Receivable WHERE ReceiveId = t.ReceiveId AND ServiceTypeId = 1),
        t.VehicleAmt = (SELECT SUM(TotalAmt) FROM MAS_Service_Receivable WHERE ReceiveId = t.ReceiveId AND ServiceTypeId = 2),
        t.LivingAmt  = (SELECT SUM(TotalAmt) FROM MAS_Service_Receivable WHERE ReceiveId = t.ReceiveId AND ServiceTypeId IN (3,4)),
        t.ExtendAmt  = (SELECT SUM(TotalAmt) FROM MAS_Service_Receivable WHERE ReceiveId = t.ReceiveId AND ServiceTypeId = 8),
        t.TotalAmt   = (SELECT SUM(TotalAmt) FROM MAS_Service_Receivable WHERE ReceiveId = t.ReceiveId),
        t.DebitAmt   = c.DebitAmt,
        t.ExpireDate = DATEADD(DAY, 10, t.ToDt),
        t.LivingElectricAmt = (SELECT SUM(TotalAmt) FROM MAS_Service_Receivable WHERE ReceiveId = t.ReceiveId AND ServiceTypeId = 3),
        t.LivingWaterAmt    = (SELECT SUM(TotalAmt) FROM MAS_Service_Receivable WHERE ReceiveId = t.ReceiveId AND ServiceTypeId = 4),
        t.periods_oid   = ISNULL(@periods_oid, t.periods_oid)
    FROM MAS_Service_ReceiveEntry t
    JOIN @tbAparts a ON a.ApartmentId = t.ApartmentId
    JOIN MAS_Apartments c ON c.ApartmentId = a.ApartmentId
    WHERE t.IsPayed = 0
      AND t.PaidAmt = 0
      AND t.ToDt    = @ToDt;

    
    /* ============================================================
       Cập nhật trạng thái kỳ thanh toán
       ============================================================ */
    IF(@periods_oid IS NOT NULL)
    BEGIN
        UPDATE mas_billing_periods
        SET status = 1
        WHERE oid = @periods_oid
    END
    /* ============================================================
       9) KẾT QUẢ + COMMIT
       ============================================================ */
    COMMIT TRAN;
    
    DECLARE @Skipped INT = @TotalInput - @TotalValid;

    IF @TotalValid > 0
        SET @valid = 1;
    ELSE
        SET @valid = 0;
    
    SET @messages = N'Đã tính dự thu ' + CAST(@TotalValid AS NVARCHAR(20)) + N'/' + CAST(@TotalInput AS NVARCHAR(20)) + N' căn hộ.';
    
    IF @Skipped > 0
    BEGIN
        SET @messages = @messages + N' (' + CAST(@Skipped AS NVARCHAR(20)) + N' căn đã xuất hóa đơn)';
    END

END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    DECLARE
        @ErrorNum  INT          = ERROR_NUMBER(),
        @ErrorMsg  VARCHAR(200) = 'sp_res_service_expected_calculate_set ' + ERROR_MESSAGE(),
        @ErrorProc VARCHAR(50)  = ERROR_PROCEDURE(),
        @SessionID INT          = NULL,
        @AddlInfo  VARCHAR(MAX) = '@UserID ' + ISNULL(@UserID,'');

    EXEC dbo.utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receivable', 'Ins', @SessionID, @AddlInfo;
    SELECT 0 AS valid, @ErrorMsg AS [messages];
END CATCH

FINALLY:
    SELECT
        @valid AS valid,
        @messages AS [messages];