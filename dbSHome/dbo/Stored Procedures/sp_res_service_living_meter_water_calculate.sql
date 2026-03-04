-- Main calculation procedure
CREATE PROCEDURE [dbo].[sp_res_service_living_meter_water_calculate]
    @UserID UNIQUEIDENTIFIER = null,
    @project_code NVARCHAR(50) = NULL,
    @periods_oid NVARCHAR(50) = NULL,
    @TrackingId INT = null,
    @ProjectCd NVARCHAR(30) =null,
    @LivingType INT = null,
    @PeriodMonth INT = null,
    @PeriodYear INT = null
AS
BEGIN TRY
    IF(@ProjectCd IS NULL AND @project_code IS NOT NULL)
        SET @ProjectCd = @project_code
    
    -- ThanhMT Sửa lại sang phiên bản mới
    exec sp_res_service_living_meter_water_calculate_new
        @UserId=@UserID,
        @project_code=@project_code,
--         @periods_oid=@periods_oid,
        @trackingId=@TrackingId,
        @projectCd=@ProjectCd,
        @LivingType=@LivingType,
        @PeriodMonth=@PeriodMonth,
        @PeriodYear=@PeriodYear;
    RETURN;
    
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM par_water pw WHERE pw.project_code = @ProjectCd AND pw.is_active = 1)
    BEGIN
		-- Nếu có is_active = 1 thì phải có chi tiết giá
        IF NOT EXISTS (SELECT TOP 1 1
                       FROM par_water_detail pwd JOIN par_water pw ON pwd.par_water_oid = pw.oid
                       WHERE pw.project_code = @ProjectCd AND pw.is_active = 1)
        BEGIN
            SELECT 0 AS valid, N'Chưa có giá nước trong cài đặt' AS messages;
            RETURN; -- hoặc GOTO FINALLY tuỳ flow của bạn
        END
    END
    ELSE
    BEGIN
        -- Nếu không có bản ghi is_active=1 (tức chỉ toàn 0) → tính giá = 0
        -- (Tuỳ bạn xử lý update bảng hay chỉ return báo giá = 0)
        SELECT 1 AS valid, N'Không có bảng giá nước áp dụng, tính giá = 0' AS messages;
    END
    
    IF @TrackingId > 0
    BEGIN
        -- Update existing calculation lines     
        UPDATE t
        SET
            t.StepPos= s.sort_order,
            t.fromN =s.start_value,
            t.toN = s.end_value,
            t.Quantity = f.Quantity, --dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value),
            t.Price = f.Price,
            t.Amount = f.Amount,
--             t.Amount = cal.TongTien,
            t.FreeAmt = dbo.fn_CalculateFreeAmt(0, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value), s.unit_price)
        FROM 
            MAS_Service_Living_CalSheet t
            JOIN MAS_Service_Living_Tracking b  ON t.TrackingId = b.TrackingId	
            JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd 
            JOIN par_water pe ON b.ProjectCd = pe.project_code AND pe.is_active =1
            JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId AND ma.IsActive = 1
            Outer apply (select a.sort_order, start_value, end_value, unit_price from par_water_detail a where a.par_water_oid = pe.oid) s
--             OUTER APPLY(SELECT SUM(amount) AS TongTien FROM dbo.fn_CalcWaterPrice(@ProjectCd, b.TotalNum, CONCAT(@PeriodYear, '-', @PeriodMonth, '-01'), ISNULL(pe.expiry_date, EOMONTH(pe.effective_date)) )) cal
            CROSS APPLY dbo.fn_CalculatePeriod(
                        b.TotalNum,
                        ma.NumPersonWater,
                        s.sort_order,
                        b.LivingTypeId,
                        mp.caculateWaterType,
                        s.start_value,
                        s.end_value,
                        s.unit_price,
                        CONCAT(@PeriodYear, '-', @PeriodMonth, '-01'), --pe.effective_date,
                        ISNULL(pe.expiry_date, EOMONTH(pe.effective_date))
                    ) f
        WHERE
            IsReceivable = 0 AND
            b.TrackingId = @TrackingId
            AND t.StepPos = s.sort_order

        -- Insert missing steps
        INSERT INTO MAS_Service_Living_CalSheet (TrackingId, StepPos, fromN, toN, Quantity, Price, Amount, FreeAmt)
        SELECT DISTINCT
            @TrackingId,
            s.sort_order,
            s.start_value,
            s.end_value,
            f.Quantity, --dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, a.sort_order, b.LivingTypeId, mp.caculateWaterType, a.start_value, a.end_value),
            f.Price, --a.unit_price,
            f.Amount,
--             cal.TongTien,
            dbo.fn_CalculateFreeAmt(0, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value), s.unit_price)
        FROM
            MAS_Service_Living_Tracking b
            JOIN MAS_Apartments c ON b.ApartmentId = c.ApartmentId
            JOIN par_water pe ON b.ProjectCd = pe.project_code AND pe.is_active =1
            JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId AND ma.IsActive = 1
            JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd       
            Outer apply (select a.sort_order, start_value, end_value, unit_price from par_water_detail a where a.par_water_oid = pe.oid) s
--             OUTER APPLY(SELECT SUM(amount) AS TongTien FROM dbo.fn_CalcWaterPrice(@ProjectCd, b.TotalNum, CONCAT(@PeriodYear, '-', @PeriodMonth, '-01'), ISNULL(pe.expiry_date, EOMONTH(pe.effective_date)) )) cal
            CROSS APPLY dbo.fn_CalculatePeriod(
                        b.TotalNum,
                        ma.NumPersonWater,
                        s.sort_order,
                        b.LivingTypeId,
                        mp.caculateWaterType,
                        s.start_value,
                        s.end_value,
                        s.unit_price,
                        pe.effective_date,
                        ISNULL(pe.expiry_date, EOMONTH(pe.effective_date))
                    ) f
            WHERE
                b.TrackingId = @TrackingId
                AND IsReceivable = 0
                AND NOT EXISTS (SELECT 1 FROM MAS_Service_Living_CalSheet WHERE TrackingId = b.TrackingId AND StepPos = s.sort_order)
            ORDER BY s.sort_order;
                
            -- Update tracking summary
            EXEC dbo.sp_Update_Living_Tracking_Total @TrackingId, @LivingType;
      END
      ELSE
      BEGIN
          -- Bulk update existing calculation lines
          SELECT 
              StepPos= s.sort_order,
              fromN =s.start_value,
              toN = s.end_value,
              Quantity = f.Quantity, --dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value),
              Price = f.Price , --s.unit_price
              Amount = f.Amount,
--               Amount = cal.TongTien,
              Id = t.Id
        INTO #updateAll
        FROM
            MAS_Service_Living_CalSheet t
            JOIN MAS_Service_Living_Tracking b  ON t.TrackingId = b.TrackingId	
            JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd
            JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId AND ma.IsActive = 1
            Outer apply (
                select   a.sort_order, start_value, end_value, unit_price, p.effective_date, p.expiry_date, p.vat, p.environmental_fee
                from par_water_detail  a
                JOIN par_water p on p.oid = a.par_water_oid and p.is_active =1
                LEFT JOIN par_service_price_type b1 ON b1.oid = p.par_service_price_type_oid
                where p.project_code = b.ProjectCd
                AND t.steppos = a.sort_order
                AND t.fromN = a.start_value
                --AND a.unit_price = t.price
            ) s
--             OUTER APPLY(SELECT SUM(amount) AS TongTien FROM dbo.fn_CalcWaterPrice(@ProjectCd, b.TotalNum, CONCAT(@PeriodYear, '-', @PeriodMonth, '-01'), ISNULL(s.expiry_date, EOMONTH(s.effective_date)) )) cal
            CROSS APPLY dbo.fn_CalculatePeriod(
                        b.TotalNum,
                        ma.NumPersonWater,
                        s.sort_order,
                        b.LivingTypeId,
                        mp.caculateWaterType,
                        s.start_value,
                        s.end_value,
                        s.unit_price,
                        CONCAT(@PeriodYear, '-', @PeriodMonth, '-01'), --s.effective_date,
                        ISNULL(s.expiry_date, EOMONTH(s.effective_date))
                    ) f
        WHERE
            b.LivingTypeId = @LivingType
            AND MONTH(b.ToDt) = @PeriodMonth
            AND YEAR(b.ToDt) = @PeriodYear
            AND b.ProjectCd = @ProjectCd AND IsReceivable = 0 
            --AND t.TrackingId = 197194
            AND t.StepPos = s.sort_order;
            
        UPDATE t
        SET
            t.StepPos= a.StepPos,
            t.fromN =a.fromN,
            t.toN = a.toN,
            t.Quantity = a.Quantity, --dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value),
            t.Price = a.Price,
            t.Amount = a.Amount--dbo.fn_CalculateAmount(s.unit_price, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value))
            --t.FreeAmt = dbo.fn_CalculateFreeAmt(0, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value), s.unit_price)
        FROM
            MAS_Service_Living_CalSheet t 
            JOIN  #updateAll a ON a.Id = t.Id
            
        -- Insert missing calculation lines
        INSERT INTO MAS_Service_Living_CalSheet (TrackingId, StepPos, fromN, toN, Quantity, Price, Amount, FreeAmt)
        SELECT DISTINCT
            b.TrackingId,
            s.sort_order,
            s.start_value,
            s.end_value,
            f.Quantity, --dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value),
            f.Price, --s.unit_price,
            f.Amount,
--             cal.TongTien,
            dbo.fn_CalculateFreeAmt(0, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value), s.unit_price)
        FROM
            MAS_Service_Living_Tracking b
            JOIN MAS_Apartments c ON b.ApartmentId = c.ApartmentId
            JOIN par_water pe ON b.ProjectCd = pe.project_code AND pe.is_active =1
            JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId AND ma.IsActive = 1
            JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd
            Outer apply (select a.sort_order, start_value, end_value, unit_price
                        from
                            par_water_detail a
                            LEFT JOIN par_service_price_type b ON b.oid = a.par_water_oid
                            where a.par_water_oid = pe.oid) s
--             OUTER APPLY(SELECT SUM(amount) AS TongTien FROM dbo.fn_CalcWaterPrice(@ProjectCd, b.TotalNum, CONCAT(@PeriodYear, '-', @PeriodMonth, '-01'), ISNULL(pe.expiry_date, EOMONTH(pe.effective_date)) )) cal
            CROSS APPLY dbo.fn_CalculatePeriod(
                        b.TotalNum,
                        ma.NumPersonWater,
                        s.sort_order,
                        b.LivingTypeId,
                        mp.caculateWaterType,
                        s.start_value,
                        s.end_value,
                        s.unit_price,
                        pe.effective_date,
                        ISNULL(pe.expiry_date, EOMONTH(pe.effective_date))
                    ) f
        WHERE
            b.LivingTypeId = @LivingType
            AND MONTH(b.ToDt) = @PeriodMonth
            AND YEAR(b.ToDt) = @PeriodYear
            AND c.ProjectCd = @ProjectCd
            AND IsReceivable = 0
            AND NOT EXISTS (SELECT 1 FROM MAS_Service_Living_CalSheet WHERE TrackingId = b.TrackingId AND StepPos = s.sort_order)
        ORDER BY b.TrackingId, s.sort_order;

        -- Update summary for all matching TrackingIds
        EXEC dbo.sp_Update_Living_Tracking_Total_Bulk @LivingType, @PeriodMonth, @PeriodYear, @ProjectCd;
    END

    SELECT 1 AS valid, N'Tính toán thành công' AS messages;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT = ERROR_NUMBER();
    DECLARE @ErrorMsg NVARCHAR(200) = ERROR_MESSAGE();
    DECLARE @ErrorProc NVARCHAR(50) = ERROR_PROCEDURE();
    DECLARE @SessionID INT;
    DECLARE @AddlInfo NVARCHAR(MAX) = '@UserID ' + cast(@UserID as varchar(50));

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServiceLivingCalculate', 'Ins', @SessionID, @AddlInfo;
    
    SELECT
        0 AS valid,
        @ErrorMsg AS messages;
END CATCH;