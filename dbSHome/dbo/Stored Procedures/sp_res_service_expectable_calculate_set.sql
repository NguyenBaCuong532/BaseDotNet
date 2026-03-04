CREATE   procedure [dbo].[sp_res_service_expectable_calculate_set]
    @UserID NVARCHAR(450),
    @RevenuePeriodId  NVARCHAR(50) = NULL,
    @project_code NVARCHAR(10) = NULL,
    @FromDate NVARCHAR(10) = NULL,
    
    @ProjectCd NVARCHAR(10),
    @ProjectName NVARCHAR(10) = NULL,
    @FloorNo NVARCHAR(10),
    @Apartments NVARCHAR(MAX),
    @ToDate NVARCHAR(10),
    @BuildingCd NVARCHAR(50),
    @ApartmentCd NVARCHAR(50)
AS
BEGIN TRY
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @BuildingCd = ISNULL(@BuildingCd, '');
    SET @FloorNo = ISNULL(@FloorNo, '');
    SET @Apartments = ISNULL(@Apartments, '');

	if((@Apartments is null OR TRIM(@Apartments) = '') and @ApartmentCd is not null)
      set @Apartments = @ApartmentCd;

    IF OBJECT_ID('tempdb..#ArrApartments') IS NOT NULL
        DROP TABLE #ScopeReceive;
    
    SELECT part
    INTO #ArrApartments
    FROM dbo.SplitString(@Apartments, ',')
    
    IF NOT EXISTS(SELECT TOP 1 1 FROM #ArrApartments)
    BEGIN
        INSERT INTO #ArrApartments(part)
        SELECT part = a.ApartmentId
        FROM
            [MAS_Apartments] a
            LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
            LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid
        WHERE
            b.ProjectCd = @ProjectCd
            AND(TRIM(@BuildingCd) = '' OR b.BuildingCd = @BuildingCd)
            AND(TRIM(@FloorNo) = '' OR a.floorNo = @FloorNo)
            AND(TRIM(@Apartments) = '' OR a.ApartmentId = @Apartments)
        ORDER BY a.RoomCode
    END

    DECLARE @valid      BIT           = 0,
            @messages   NVARCHAR(250) = N'',
            @ToDt        DATETIME,
            @ToDtVehicle DATETIME,
            @ToDtFee     DATETIME,
            @feePrice    DECIMAL(18,0);

    DECLARE @tbAparts TABLE
    (
        [ApartmentId] BIGINT NOT NULL
        INDEX IX1_Apartment NONCLUSTERED (ApartmentId)
    );

    -- Kỳ hóa đơn (n) & kỳ xe (n+1)
    SET @ToDt        = EOMONTH(CONVERT(DATETIME, @ToDate, 103));
    SET @ToDtVehicle = EOMONTH(DATEADD(MONTH, 1, @ToDt));
    SET @ToDtFee     = EOMONTH(DATEADD(MONTH, 1, @ToDt));

    SET @feePrice = ISNULL(
        (SELECT TOP 1 Price
         FROM dbo.PAR_ServicePrice
         WHERE ServiceTypeId = 1 AND TypeId = 1 AND ProjectCd = @ProjectCd), 10000);

    BEGIN TRAN;

    /* ============================================================
       0) XÁC ĐỊNH DANH SÁCH CĂN HỘ CẦN TÍNH (@tbAparts)
       ============================================================ */
       INSERT INTO @tbAparts (ApartmentId)
       SELECT part FROM #ArrApartments 
       --WHERE part = '6480'
       
       --loc nhung thang da xuat hoa don
       DELETE a
       FROM @tbAparts a
       JOIN MAS_Service_ReceiveEntry r ON r.ApartmentId = a.ApartmentId
       WHERE r.ToDt = @ToDt AND r.IsBill = 1

       --select*from @tbAparts

    --IF @Apartments IS NULL OR @Apartments = ''
    --BEGIN
    --    INSERT INTO @tbAparts (ApartmentId)
    --    SELECT b.ApartmentId
    --    FROM dbo.MAS_Apartments b
    --    WHERE b.ProjectCd  = @ProjectCd
    --      AND b.IsReceived = 1
    --      AND b.isFeeStart = 1
    --      AND (
    --            b.DebitAmt <> 0
    --            OR (b.IsFree = 0 OR (b.IsFree = 1 AND ISNULL(b.lastReceived, b.FreeToDt) < @ToDtFee))
    --            OR EXISTS (SELECT 1 FROM dbo.MAS_CardVehicle v
    --                       WHERE v.ApartmentId = b.ApartmentId
    --                         AND v.StartTime < @ToDtVehicle
    --                         AND (v.lastReceivable IS NULL OR v.lastReceivable < @ToDtVehicle))
    --            OR EXISTS (SELECT 1
    --                       FROM dbo.MAS_Service_Living_Tracking t
    --                       WHERE t.ApartmentId = b.ApartmentId
    --                         AND t.IsCalculate = 1 AND t.IsReceivable = 0
    --                         AND t.ToDt <= @ToDt
    --                         AND t.Amount <> 0)
    --          );
    --END
    --ELSE
    --BEGIN
    --    INSERT INTO @tbAparts (ApartmentId)
    --    SELECT b.ApartmentId
    --    FROM dbo.SplitString(@Apartments, ',') a
    --    JOIN dbo.MAS_Apartments b ON a.part = b.ApartmentId
    --    WHERE b.IsReceived = 1
    --      AND b.isFeeStart = 1
    --      AND (
    --            b.DebitAmt <> 0
    --            OR (b.IsFree = 0 OR (b.IsFree = 1 AND ISNULL(b.lastReceived, b.FreeToDt) < @ToDtFee))
    --            OR EXISTS (SELECT 1 FROM dbo.MAS_CardVehicle v
    --                       WHERE v.ApartmentId = b.ApartmentId
    --                         AND v.StartTime < @ToDtVehicle
    --                         AND (v.lastReceivable IS NULL OR v.lastReceivable < @ToDtVehicle))
    --            OR EXISTS (SELECT 1
    --                       FROM dbo.MAS_Service_Living_Tracking t
    --                       WHERE t.ApartmentId = b.ApartmentId
    --                         AND t.IsCalculate = 1 AND t.IsReceivable = 0
    --                         AND t.ToDt <= @ToDt
    --                         AND t.Amount <> 0)
    --          );
    --END

    /* ============================================================
       1) RECEIVE ENTRY (KỲ HÓA ĐƠN @ToDt)
       ============================================================ */
    -- Cập nhật dòng dự kiến đã có
    UPDATE t
       SET t.ProjectCd = ma.ProjectCd,
           t.ToDt      = @ToDt,
           t.isExpected= 1
    FROM dbo.MAS_Service_ReceiveEntry t
    JOIN @tbAparts a    ON t.ApartmentId = a.ApartmentId
    JOIN dbo.MAS_Apartments ma ON ma.ApartmentId = a.ApartmentId
    WHERE t.IsPayed = 0 AND t.PaidAmt = 0 AND t.ToDt = @ToDt;

    -- Chèn nếu chưa có dòng mở kỳ này
    INSERT INTO dbo.MAS_Service_ReceiveEntry
    (
        ApartmentId, ReceiveDt, ToDt, SysDate,
        ProjectCd, IsPayed, isExpected,
        CommonFee, CreditAmt, DebitAmt, ExtendAmt, LivingAmt, VehicleAmt, TotalAmt, PaidAmt,
        createId
    )
    SELECT
        a.ApartmentId, GETDATE(), @ToDt, GETDATE(),
        ma.ProjectCd, 0, 1,
        0,0,0,0,0,0,0,0,
        @UserID
    FROM @tbAparts a
    JOIN dbo.MAS_Apartments ma ON ma.ApartmentId = a.ApartmentId
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.MAS_Service_ReceiveEntry x
        WHERE x.ApartmentId = a.ApartmentId
          AND x.ToDt        = @ToDt
          AND x.IsPayed     = 0
          AND x.isExpected  = 1
    );

    /* ============================================================
       2) PHÍ QUẢN LÝ (ServiceTypeId = 1)
       ============================================================ */
    -- UPDATE
    UPDATE t
       SET t.Amount    = ROUND(h.Amount * 10.0 / 11.0, 0),
           t.VATAmt    = ROUND(h.Amount / 11.0, 0),
           t.TotalAmt  = h.Amount,
           t.fromDt    = ISNULL(a.lastReceived, a.FreeToDt),
           t.ToDt      = @ToDt,
           t.Quantity  = h.Quantity,
           t.Price     = h.Price
    FROM dbo.MAS_Service_Receivable t
    JOIN dbo.MAS_Apartments a ON t.srcId = a.ApartmentId AND t.ServiceTypeId = 1
    JOIN @tbAparts c          ON c.ApartmentId = a.ApartmentId
    JOIN dbo.fn_Hom_ServiceFee_Payday_project(@ProjectCd, @ToDtFee) h
         ON h.ApartmentId = a.ApartmentId
    JOIN dbo.MAS_Service_ReceiveEntry d
         ON d.ApartmentId = c.ApartmentId AND d.ReceiveId = t.ReceiveId
    WHERE (a.IsFree = 0 OR (a.IsFree = 1 AND ISNULL(a.FreeToDt, a.lastReceived) < @ToDtFee))
      AND d.ToDt = @ToDt AND d.IsPayed = 0 AND d.PaidAmt = 0;

    -- INSERT
    INSERT INTO dbo.MAS_Service_Receivable
    (
        ReceiveId, ServiceTypeId, ServiceObject,
        Amount, VATAmt, TotalAmt,
        fromDt, ToDt, Quantity, Price, srcId
    )
    SELECT
        d.ReceiveId, 1, a.RoomCode,
        ROUND(h.Amount * 10.0 / 11.0, 0),
        ROUND(h.Amount / 11.0, 0),
        h.Amount,
        ISNULL(a.lastReceived, a.FreeToDt),
        @ToDt,
        h.Quantity,
        h.Price,
        a.ApartmentId
    FROM dbo.MAS_Apartments a
    JOIN @tbAparts c     ON c.ApartmentId = a.ApartmentId
    JOIN dbo.fn_Hom_ServiceFee_Payday_project(@ProjectCd, @ToDtFee) h
         ON h.ApartmentId = a.ApartmentId
    JOIN dbo.MAS_Service_ReceiveEntry d
         ON d.ApartmentId = c.ApartmentId
    WHERE (a.IsFree = 0 OR (a.IsFree = 1 AND ISNULL(a.lastReceived, a.FreeToDt) < @ToDtFee))
      AND d.ToDt = @ToDt AND d.IsPayed = 0 AND d.PaidAmt = 0
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.MAS_Service_Receivable t1
          WHERE t1.ServiceTypeId = 1
            AND t1.srcId         = a.ApartmentId
            AND t1.ReceiveId     = d.ReceiveId
      );

    -- AccrualLastDt
    UPDATE a
       SET a.AccrualLastDt = @ToDtFee
    FROM dbo.MAS_Apartments a
    JOIN @tbAparts c ON c.ApartmentId = a.ApartmentId
    JOIN dbo.MAS_Service_Receivable r ON r.srcId = a.ApartmentId AND r.ServiceTypeId = 1
    JOIN dbo.MAS_Service_ReceiveEntry d ON d.ReceiveId = r.ReceiveId
    WHERE a.ReceiveDt < @ToDtFee
      AND ISNULL(a.lastReceived, a.FreeToDt) < @ToDtFee
      AND d.ToDt = @ToDt AND d.IsPayed = 0 AND d.PaidAmt = 0;

    /* ============================================================
       3) CLEANUP PHÍ XE (ServiceTypeId = 2) - SAFE DELETE
       (giữ nguyên như trước)
       ============================================================ */
    IF OBJECT_ID('tempdb..#ScopeReceive') IS NOT NULL DROP TABLE #ScopeReceive;
    CREATE TABLE #ScopeReceive (ReceiveId BIGINT PRIMARY KEY, IsPayed bit);

    INSERT #ScopeReceive(ReceiveId,IsPayed)
    SELECT d.ReceiveId, d.IsPayed
    FROM dbo.MAS_Service_ReceiveEntry d
    JOIN @tbAparts a ON a.ApartmentId = d.ApartmentId
    WHERE d.ToDt = @ToDt AND d.IsPayed = 0 AND d.PaidAmt = 0;

    DELETE r
    FROM dbo.MAS_Service_Receivable r
    JOIN #ScopeReceive s ON s.ReceiveId = r.ReceiveId
    WHERE r.ServiceTypeId = 2
      AND ISNULL(s.IsPayed,0) = 0
      AND r.ToDt <> @ToDtVehicle;

    ;WITH dups AS
    (
        SELECT r.ReceivableId,
               ROW_NUMBER() OVER (
                   PARTITION BY r.ReceiveId, r.ServiceTypeId, r.srcId, r.ToDt
                   ORDER BY r.ReceivableId DESC
               ) rn
        FROM dbo.MAS_Service_Receivable r
        JOIN #ScopeReceive s ON s.ReceiveId = r.ReceiveId
        WHERE r.ServiceTypeId = 2
          AND ISNULL(s.IsPayed,0) = 0
          AND r.ToDt = @ToDtVehicle
    )
    DELETE r
    FROM dbo.MAS_Service_Receivable r
    JOIN dups d ON d.ReceivableId = r.ReceivableId
    WHERE d.rn > 1;

    ;WITH valid AS
    (
        SELECT d.ReceiveId, v.CardVehicleId AS srcId
        FROM dbo.MAS_CardVehicle v
        JOIN @tbAparts a ON a.ApartmentId = v.ApartmentId
        JOIN dbo.MAS_Service_ReceiveEntry d
             ON d.ApartmentId = a.ApartmentId
            AND d.ToDt = @ToDt AND d.IsPayed = 0 AND d.PaidAmt = 0
        JOIN dbo.fn_Hom_Vehicle_Payday_project(@ProjectCd, @ToDtVehicle) b
             ON b.CardVehicleId = v.CardVehicleId
        WHERE ISNULL(v.EndTime, v.StartTime) <= @ToDtVehicle
          AND (v.lastReceivable IS NULL OR v.lastReceivable < @ToDtVehicle)
    ),
    orphans AS
    (
        SELECT r.ReceivableId
        FROM dbo.MAS_Service_Receivable r
        JOIN #ScopeReceive s ON s.ReceiveId = r.ReceiveId
        LEFT JOIN valid vv
               ON vv.ReceiveId = r.ReceiveId
              AND vv.srcId     = r.srcId
        WHERE r.ServiceTypeId = 2
          AND ISNULL(s.IsPayed,0) = 0
          AND r.ToDt = @ToDtVehicle
          AND vv.ReceiveId IS NULL
    )
    DELETE r
    FROM dbo.MAS_Service_Receivable r
    JOIN orphans o ON o.ReceivableId = r.ReceivableId;

    ;WITH need_reset AS
    (
        SELECT DISTINCT v.CardVehicleId
        FROM dbo.MAS_CardVehicle v
        JOIN @tbAparts a ON a.ApartmentId = v.ApartmentId
        JOIN dbo.MAS_Service_ReceiveEntry d
          ON d.ApartmentId = a.ApartmentId
         AND d.ToDt = @ToDt AND d.IsPayed = 0 AND d.PaidAmt = 0
        WHERE ISNULL(v.EndTime, v.StartTime) <= @ToDtVehicle
          AND ISNULL(v.lastReceivable,'19000101') >= @ToDtVehicle
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.MAS_Service_Receivable r
              WHERE r.ServiceTypeId = 2
                AND r.ToDt = @ToDtVehicle
                AND r.srcId = v.CardVehicleId
                AND r.ReceiveId = d.ReceiveId
          )
    )
    UPDATE v
       SET v.lastReceivable = DATEADD(DAY, -1, @ToDtVehicle),
           v.endTime_Tmp    = v.EndTime
    FROM dbo.MAS_CardVehicle v
    JOIN need_reset x ON x.CardVehicleId = v.CardVehicleId;

    /* ============================================================
       4) PHÍ XE (ServiceTypeId = 2) - UPSERT (MERGE)
       ============================================================ */
    ;WITH Veh AS
    (
        SELECT
            d.ReceiveId,
            v.CardVehicleId                      AS srcId,
            v.VehicleNo                          AS ServiceObject,
            ISNULL(v.endTime_Tmp, v.StartTime)   AS fromDt,
            @ToDtVehicle                         AS ToDt,
            b.[Quantity],
            b.Price,
            ROUND(b.Amount * 10.0 / 11.0, 0)     AS Amount,
            ROUND(b.Amount / 11.0, 0)            AS VATAmt,
            b.Amount                             AS TotalAmt,
			b.VehNum							 AS VehicleNum
        FROM dbo.MAS_CardVehicle v
        JOIN @tbAparts a ON a.ApartmentId = v.ApartmentId
        JOIN dbo.MAS_Service_ReceiveEntry d
             ON d.ApartmentId = a.ApartmentId
            AND d.ToDt        = @ToDt
            AND d.IsPayed     = 0
            AND d.PaidAmt     = 0
        JOIN dbo.fn_Hom_Vehicle_Payday_project(@ProjectCd, @ToDtVehicle) b
             ON b.CardVehicleId = v.CardVehicleId
        WHERE ISNULL(v.EndTime, v.StartTime) <= @ToDtVehicle
          AND (v.lastReceivable IS NULL OR v.lastReceivable < @ToDtVehicle)
    )
    MERGE dbo.MAS_Service_Receivable WITH (HOLDLOCK) AS T
    USING Veh AS S
       ON  T.ReceiveId     = S.ReceiveId
       AND T.ServiceTypeId = 2
       AND T.srcId         = S.srcId
       AND T.ToDt          = S.ToDt
    WHEN MATCHED THEN
        UPDATE SET
            T.Amount        = S.Amount,
            T.VATAmt        = S.VATAmt,
            T.TotalAmt      = S.TotalAmt,
            T.fromDt        = S.fromDt,
            T.Quantity      = S.Quantity,
            T.Price         = S.Price,
            T.ServiceObject = S.ServiceObject,
			T.VehicleNum    = 2
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ReceiveId, ServiceTypeId, ServiceObject, Amount, VATAmt, TotalAmt, fromDt, ToDt, Quantity, Price, srcId,VehicleNum)
        VALUES (S.ReceiveId, 2, S.ServiceObject, S.Amount, S.VATAmt, S.TotalAmt, S.fromDt, S.ToDt, S.Quantity, S.Price, S.srcId,3)
    ;

    UPDATE v
       SET v.lastReceivable = @ToDtVehicle,
           v.endTime_Tmp    = v.EndTime
    FROM dbo.MAS_CardVehicle v
    JOIN (
        SELECT DISTINCT r.srcId
        FROM dbo.MAS_Service_Receivable r
        JOIN #ScopeReceive s ON s.ReceiveId = r.ReceiveId
        WHERE r.ServiceTypeId = 2
          AND r.ToDt          = @ToDtVehicle
    ) x ON x.srcId = v.CardVehicleId;

    /* ============================================================
   5) PHÍ SINH HOẠT (ServiceTypeId = 3)
      SỬA: CLEAR TẤT CẢ DÒNG S3 THEO RECEIVEID CỦA KỲ @ToDt,
           SAU ĐÓ TÍNH LẠI & CHÈN MỚI CHỈ CHO THÁNG @ToDt
   ============================================================ */
	-- 5.A) XÁC ĐỊNH PHẠM VI HÓA ĐƠN MỞ KỲ @ToDt
	IF OBJECT_ID('tempdb..#ScopeReceiveLiving') IS NOT NULL DROP TABLE #ScopeReceiveLiving;
	CREATE TABLE #ScopeReceiveLiving (ReceiveId BIGINT PRIMARY KEY);

	INSERT #ScopeReceiveLiving(ReceiveId)
	SELECT d.ReceiveId
	FROM dbo.MAS_Service_ReceiveEntry d
	JOIN @tbAparts a ON a.ApartmentId = d.ApartmentId
	WHERE d.ToDt = @ToDt AND d.IsPayed = 0 AND d.PaidAmt = 0;

	-- 5.B) CLEAR: XÓA TẤT CẢ DÒNG S3 THEO RECEIVEID (KHÔNG LỌC THEO r.ToDt)
	DELETE r
	FROM dbo.MAS_Service_Receivable r
	JOIN #ScopeReceiveLiving s ON s.ReceiveId = r.ReceiveId
	WHERE r.ServiceTypeId = 3;

	-- 5.C) RE-CALC + INSERT: tính lại như cũ, CHỈ NHẬN DỮ LIỆU THUỘC THÁNG @ToDt
	INSERT INTO dbo.MAS_Service_Receivable
	(
		ReceiveId, ServiceTypeId, ServiceObject,
		Amount, VATAmt, TotalAmt, NtshAmt,
		fromDt, ToDt, Quantity, Price, srcId
	)
	SELECT
		d.ReceiveId, 3, c.LivingTypeName,
		v.Amount,
		CASE v.LivingTypeId WHEN 1 THEN ROUND(v.Amount * 0.08, 0)
							WHEN 2 THEN ROUND(v.Amount * 0.15, 0) END AS VATAmt,
		CASE v.LivingTypeId WHEN 1 THEN ROUND(v.Amount * 1.08, 0)
							WHEN 2 THEN 
								CASE
									WHEN @ProjectCd IN ('09', '18') THEN ROUND(v.Amount * 1.374, 0) --CT = VAT + env fee + VAT of env fee
									ELSE ROUND(v.Amount * 1.15, 0)									--	 = 0.05 + 0.3 + 0.3 x 0.08 
								END
							END AS TotalAmt,
		CASE v.LivingTypeId WHEN 1 THEN 0
							WHEN 2 THEN ROUND(v.Amount / 10.0, 0) END AS NtshAmt,
		v.FromDt, v.ToDt, v.TotalNum, v.Amount, v.TrackingId
	FROM dbo.MAS_Service_Living_Tracking v
	JOIN dbo.MAS_LivingTypes c ON c.LivingTypeId = v.LivingTypeId
	JOIN @tbAparts a           ON a.ApartmentId = v.ApartmentId
	JOIN dbo.MAS_Service_ReceiveEntry d
		 ON d.ApartmentId = a.ApartmentId
		AND d.ToDt        = @ToDt
		AND d.IsPayed     = 0
		AND d.PaidAmt     = 0
	WHERE v.IsCalculate = 1
	  AND MONTH(v.ToDt) = MONTH(@ToDt)
	  AND YEAR(v.ToDt)  = YEAR(@ToDt)
	  AND v.ToDt > DATEFROMPARTS(2020, 11, 30);


	  --INSERT debt fee
	IF OBJECT_ID('tempdb..#ScopeReceiveDebt') IS NOT NULL DROP TABLE #ScopeReceiveDebt;
	CREATE TABLE #ScopeReceiveDebt (ReceiveId BIGINT PRIMARY KEY);


	INSERT #ScopeReceiveDebt(ReceiveId)
	SELECT d.ReceiveId
	FROM
            dbo.MAS_Service_ReceiveEntry d
            JOIN #ArrApartments a ON a.part = d.ApartmentId
	--JOIN dbo.SplitString(@Apartments, ',')  a ON a.part = d.ApartmentId
	WHERE d.IsPayed = 0 AND d.PaidAmt = 0;

	DELETE r
	FROM dbo.MAS_Service_Receivable r
	JOIN #ScopeReceiveDebt s ON s.ReceiveId = r.ReceiveId
	WHERE r.ServiceTypeId = 9;

		INSERT INTO dbo.MAS_Service_Receivable
	(
		ReceiveId, ServiceTypeId, ServiceObject,TotalAmt
	)
	SELECT 
		t.ReceiveId,
		9,
		N'Nợ phí',
		c.DebitAmt
	FROM dbo.MAS_Service_ReceiveEntry t
    JOIN @tbAparts a ON a.ApartmentId = t.ApartmentId
    JOIN dbo.MAS_Apartments c ON c.ApartmentId = a.ApartmentId
	WHERE c.DebitAmt != 0 or c.DebitAmt is not null

    /* ============================================================
       6) CỘNG TỔNG VÀO RECEIVE ENTRY
       ============================================================ */
    UPDATE t
       SET t.CommonFee  = (SELECT SUM(TotalAmt) FROM dbo.MAS_Service_Receivable WHERE ReceiveId = t.ReceiveId AND ServiceTypeId = 1),
           t.VehicleAmt = (SELECT SUM(TotalAmt) FROM dbo.MAS_Service_Receivable WHERE ReceiveId = t.ReceiveId AND ServiceTypeId = 2),
           t.LivingAmt  = (SELECT SUM(TotalAmt) FROM dbo.MAS_Service_Receivable WHERE ReceiveId = t.ReceiveId AND ServiceTypeId = 3),
           t.ExtendAmt  = (SELECT SUM(TotalAmt) FROM dbo.MAS_Service_Receivable WHERE ReceiveId = t.ReceiveId AND ServiceTypeId = 8),
           t.TotalAmt   = (SELECT SUM(TotalAmt) FROM dbo.MAS_Service_Receivable WHERE ReceiveId = t.ReceiveId), -- + ISNULL(c.DebitAmt,0),
           t.DebitAmt   = c.DebitAmt,
           t.ExpireDate = DATEADD(DAY, 10, t.ToDt)
    FROM dbo.MAS_Service_ReceiveEntry t
    JOIN @tbAparts a ON a.ApartmentId = t.ApartmentId
    JOIN dbo.MAS_Apartments c ON c.ApartmentId = a.ApartmentId
    WHERE t.IsPayed = 0 AND t.PaidAmt = 0 AND t.ToDt = @ToDt;

    /* ============================================================
       7) KẾT QUẢ
       ============================================================ */
    SET @valid    = 1;
    SET @messages = N'Cập nhật thành công';

    COMMIT TRAN;
-- 	select a.part from dbo.SplitString(@Apartments, ',') a

    SELECT @valid AS valid, @messages AS [messages];
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN;

    DECLARE @ErrorNum  INT          = ERROR_NUMBER(),
            @ErrorMsg  VARCHAR(200) = 'sp_res_service_expectable_calculate_set ' + ERROR_MESSAGE(),
            @ErrorProc VARCHAR(50)  = ERROR_PROCEDURE(),
            @SessionID INT          = NULL,
            @AddlInfo  VARCHAR(MAX) = '@UserID ' + ISNULL(@UserID,'');

    EXEC dbo.utl_Insert_ErrorLog
         @ErrorNum, @ErrorMsg, @ErrorProc,
         'Receivable', 'Ins', @SessionID, @AddlInfo;
	
    SELECT 0 AS valid, @ErrorMsg AS [messages];
END CATCH;