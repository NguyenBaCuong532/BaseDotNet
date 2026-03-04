CREATE PROCEDURE [dbo].[sp_res_service_living_meter_electric_calculate]
    @UserID NVARCHAR(450) = null,
    @project_code NVARCHAR(50) = NULL,
    @periods_oid NVARCHAR(50) = NULL,
    @TrackingId INT = 197299,
    @ProjectCd NVARCHAR(30) = '02',
    @LivingType INT = 1,
    @PeriodMonth INT = 10,
    @PeriodYear INT = 2025
AS

BEGIN TRY
    SET NOCOUNT ON;
    
    IF(@ProjectCd IS NULL AND @project_code IS NOT NULL)
        SET @ProjectCd = @project_code

    EXEC sp_res_service_living_meter_electric_calculate_new
        @UserID=@UserID,
        @TrackingId=@TrackingId,
        @ProjectCd=@ProjectCd,
--         @periods_oid=@periods_oid,
        @LivingType=@LivingType,
        @PeriodMonth=@PeriodMonth,
        @PeriodYear=@PeriodYear;
    RETURN;
	
	-- Kiểm tra có bản ghi active trong par_electric
	IF EXISTS (
		SELECT 1 
		FROM par_electric pw 
		WHERE pw.project_code = @ProjectCd 
		  AND pw.is_active = 1
	)
	BEGIN
		-- Nếu có is_active = 1 thì phải có chi tiết giá
		IF NOT EXISTS (
			SELECT 1
			FROM par_electric_detail pwd
			JOIN par_electric pw ON pwd.par_electric_oid = pw.oid
			WHERE pw.project_code = @ProjectCd
			  AND pw.is_active = 1
		)
		BEGIN
			SELECT 0 AS valid, N'Chưa có giá điện trong cài đặt' AS messages;
			RETURN; 
		END
	END
	ELSE
	BEGIN
		SELECT 1 AS valid, N'Không có bảng giá điện áp dụng, tính giá = 0' AS messages;
	END

    IF @TrackingId > 0
    BEGIN
        -- Update existing calculation lines     
		UPDATE t
        SET
			t.StepPos= s.sort_order,
			t.fromN =s.start_value,
			t.toN = s.end_value,
			t.Quantity = f.Quantity, 
            t.Price = f.Price,
            t.Amount = f.Amount,
            t.FreeAmt = dbo.fn_CalculateFreeAmt(0, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value), s.unit_price)
        FROM   MAS_Service_Living_CalSheet t
		JOIN MAS_Service_Living_Tracking b  ON t.TrackingId = b.TrackingId	
		JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd 
		JOIN par_electric pe ON b.ProjectCd = pe.project_code AND pe.is_active =1
		JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId AND ma.IsActive = 1

		Outer apply (
			select a.sort_order, start_value, end_value, unit_price
			from par_electric_detail  a
			LEFT JOIN par_service_price_type b ON b.oid = a.par_electric_oid
			where a.par_electric_oid = pe.oid
		) s		
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
                pe.expiry_date
            ) f
        WHERE  IsReceivable = 0 AND b.TrackingId = @TrackingId  AND t.StepPos = s.sort_order
		print'a'
        -- Insert missing steps
        INSERT INTO MAS_Service_Living_CalSheet (TrackingId, StepPos, fromN, toN, Quantity, Price, Amount, FreeAmt)
        SELECT DISTINCT
            @TrackingId,
            s.sort_order,
            s.start_value,
            s.end_value,
            f.Quantity,
            f.Price,
            f.Amount, 
            dbo.fn_CalculateFreeAmt(0, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value), s.unit_price)
        FROM MAS_Service_Living_Tracking b
        JOIN MAS_Apartments c ON b.ApartmentId = c.ApartmentId
		JOIN par_electric pe ON b.ProjectCd = pe.project_code AND pe.is_active =1
        JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId AND ma.IsActive = 1
        JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd
       
		Outer apply (
			select a.sort_order, start_value, end_value, unit_price
			from par_electric_detail  a
			LEFT JOIN par_service_price_type b ON b.oid = a.par_electric_oid
			where a.par_electric_oid = pe.oid
		) s		
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
                pe.expiry_date
            ) f
        WHERE b.TrackingId = @TrackingId AND IsReceivable = 0
          AND NOT EXISTS (SELECT 1 FROM MAS_Service_Living_CalSheet WHERE TrackingId = b.TrackingId AND StepPos = s.sort_order)
        ORDER BY s.sort_order;
		print'b'
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
			Quantity = f.Quantity, 
            Price = f.Price, 
            Amount = f.Amount, 
			--FreeAmt    = dbo.fn_CalculateFreeAmt(0,  f.Quantity, f.Price)	
			Id = t.Id
		INTO #updateAll
		FROM  MAS_Service_Living_CalSheet t
		JOIN MAS_Service_Living_Tracking b  ON t.TrackingId = b.TrackingId	
		JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd
		--JOIN par_electric pe ON b.ProjectCd = pe.project_code AND pe.is_active =1
		JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId AND ma.IsActive = 1

		Outer apply (
			select   a.sort_order, start_value, end_value, unit_price, p.effective_date, p.expiry_date, p.vat
			from par_electric_detail  a
			JOIN par_electric p on p.oid = a.par_electric_oid and p.is_active =1
			LEFT JOIN par_service_price_type b1 ON b1.oid = a.par_service_price_type_oid
			where p.project_code = b.ProjectCd
			AND t.steppos = a.sort_order
			AND t.fromN = a.start_value
			AND a.unit_price = t.price
		) s			
		CROSS APPLY dbo.fn_CalculatePeriod(
                b.TotalNum,
                ma.NumPersonWater,
                s.sort_order,
                b.LivingTypeId,
                mp.caculateWaterType,
                s.start_value,
                s.end_value,
                s.unit_price,
                s.effective_date,
                s.expiry_date
            ) f
        WHERE b.LivingTypeId = @LivingType AND MONTH(b.ToDt) = @PeriodMonth AND YEAR(b.ToDt) = @PeriodYear
          AND b.ProjectCd = @ProjectCd AND IsReceivable = 0 
		  AND t.StepPos = s.sort_order;

		UPDATE t
		SET
			t.StepPos= a.StepPos,
			t.fromN =a.fromN,
			t.toN = a.toN,
			t.Quantity = a.Quantity,
            t.Price = a.Price,
            t.Amount = a.Amount
            --t.FreeAmt = dbo.fn_CalculateFreeAmt(0, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value), s.unit_price)
		FROM MAS_Service_Living_CalSheet t 
		 JOIN  #updateAll a ON a.Id = t.Id

        -- Insert missing calculation lines
        INSERT INTO MAS_Service_Living_CalSheet (TrackingId, StepPos, fromN, toN, Quantity, Price, Amount, FreeAmt)
        SELECT DISTINCT
            b.TrackingId,
             s.sort_order,
            s.start_value,
            s.end_value,
            f.Quantity, 
            f.Price, 
            f.Amount, 
            dbo.fn_CalculateFreeAmt(0, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value), s.unit_price)
        FROM MAS_Service_Living_Tracking b
        JOIN MAS_Apartments c ON b.ApartmentId = c.ApartmentId
		JOIN par_electric pe ON b.ProjectCd = pe.project_code AND pe.is_active =1
        JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId AND ma.IsActive = 1
        JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd

		Outer apply (
			select a.sort_order, start_value, end_value, unit_price
			from par_electric_detail  a
			LEFT JOIN par_service_price_type b ON b.oid = a.par_electric_oid
			where a.par_electric_oid = pe.oid
		) s		
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
                pe.expiry_date
            ) f
        WHERE b.LivingTypeId = @LivingType AND MONTH(b.ToDt) = @PeriodMonth AND YEAR(b.ToDt) = @PeriodYear
          AND c.ProjectCd = @ProjectCd AND IsReceivable = 0
          AND NOT EXISTS (SELECT 1 FROM MAS_Service_Living_CalSheet WHERE TrackingId = b.TrackingId AND StepPos = s.sort_order)
        ORDER BY b.TrackingId, s.sort_order;

        -- Update summary for all matching TrackingIds
        EXEC dbo.sp_Update_Living_Tracking_Total_Bulk @LivingType, @PeriodMonth, @PeriodYear, @ProjectCd;
    END

    SELECT 1 AS valid, N'Tính toán thành công' AS messages;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT = ERROR_NUMBER();
    DECLARE @ErrorMsg NVARCHAR(200) = 'sp_res_service_living_meter_calculate ' + ERROR_MESSAGE();
    DECLARE @ErrorProc NVARCHAR(50) = ERROR_PROCEDURE();
    DECLARE @SessionID INT;
    DECLARE @AddlInfo NVARCHAR(MAX) = '@UserID ' + @UserID;

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServiceLivingCalculate', 'Ins', @SessionID, @AddlInfo;
END CATCH;