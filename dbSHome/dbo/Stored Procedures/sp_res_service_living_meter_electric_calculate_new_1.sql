CREATE PROCEDURE [dbo].[sp_res_service_living_meter_electric_calculate_new]
    @UserID NVARCHAR(450) = null,
    @TrackingId INT = 0,
    @ProjectCd NVARCHAR(30) = '04',
    @LivingType INT = 1,
    @PeriodMonth INT = 9,
    @PeriodYear INT = 2025
AS

BEGIN TRY
    SET NOCOUNT ON;
    DECLARE @EndDayOfMonth DATE = EOMONTH(CONCAT(@PeriodYear, '-', @PeriodMonth, '-01'), 0);
	
    -- Kiểm tra có bản ghi active trong par_electric
    IF EXISTS (SELECT 1 FROM par_electric pw WHERE pw.project_code = @ProjectCd AND pw.is_active = 1)
    BEGIN
        -- Nếu có is_active = 1 thì phải có chi tiết giá
        IF NOT EXISTS (SELECT 1
                       FROM par_electric_detail pwd JOIN par_electric pw ON pwd.par_electric_oid = pw.oid
                       WHERE pw.project_code = @ProjectCd AND pw.is_active = 1)
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
        -- Check IsBill for Single Mode
        IF EXISTS (
            SELECT 1
            FROM MAS_Service_Living_Tracking t
            JOIN MAS_Service_ReceiveEntry r ON t.ApartmentId = r.ApartmentId
            WHERE t.TrackingId = @TrackingId
            AND MONTH(t.ToDt) = MONTH(r.ToDt) AND YEAR(t.ToDt) = YEAR(r.ToDt)
            AND r.IsBill = 1
        )
        BEGIN
             SELECT 0 AS valid, N'Kỳ hóa đơn đã xuất, không thể cập nhật chỉ số.' AS messages;
             RETURN;
        END

        -- Update existing calculation lines     
        UPDATE t
        SET
            t.StepPos= cal.sort_order,
            t.fromN = cal.start_value,
            t.toN = cal.end_value,
            t.Quantity = cal.used_electric,
            t.Price = cal.unit_price,
            t.Amount = cal.amount,
            t.FreeAmt = dbo.fn_CalculateFreeAmt(0, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, cal.sort_order, b.LivingTypeId, mp.caculateWaterType, cal.start_value, cal.end_value), cal.unit_price)
        FROM
            MAS_Service_Living_CalSheet t
            JOIN MAS_Service_Living_Tracking b  ON t.TrackingId = b.TrackingId	
            JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd 
            JOIN par_electric pe ON b.ProjectCd = pe.project_code AND pe.is_active =1
            JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId
            CROSS APPLY(SELECT * FROM dbo.fn_CalcElectricPrice(@ProjectCd, b.TotalNum, CONCAT(@PeriodYear, '-', @PeriodMonth, '-01'), @EndDayOfMonth )) cal
        WHERE
            IsReceivable = 0
            AND b.TrackingId = @TrackingId
            AND t.StepPos = cal.sort_order

        -- Insert missing steps
        INSERT INTO MAS_Service_Living_CalSheet (TrackingId, StepPos, fromN, toN, Quantity, Price, Amount, FreeAmt)
        SELECT DISTINCT
            @TrackingId,
            cal.sort_order,
            cal.start_value,
            cal.end_value,
            cal.used_electric,
            cal.unit_price,
            cal.amount, 
            dbo.fn_CalculateFreeAmt(0, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, cal.sort_order, b.LivingTypeId, mp.caculateWaterType, cal.start_value, cal.end_value), cal.unit_price)
        FROM
            MAS_Service_Living_Tracking b
            JOIN MAS_Apartments c ON b.ApartmentId = c.ApartmentId
            JOIN par_electric pe ON b.ProjectCd = pe.project_code AND pe.is_active =1
            JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId
            JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd
            CROSS APPLY(SELECT * FROM dbo.fn_CalcElectricPrice(@ProjectCd, b.TotalNum, CONCAT(@PeriodYear, '-', @PeriodMonth, '-01'), @EndDayOfMonth )) cal
        WHERE
            b.TrackingId = @TrackingId
            AND IsReceivable = 0
            AND NOT EXISTS (SELECT 1 FROM MAS_Service_Living_CalSheet WHERE TrackingId = b.TrackingId AND StepPos = cal.sort_order)
        ORDER BY cal.sort_order;

        -- Update tracking summary
        EXEC dbo.sp_Update_Living_Tracking_Total @TrackingId, @LivingType;
    END
    ELSE
    BEGIN
        -- Bulk update existing calculation lines
        SELECT
            StepPos= cal.sort_order,
            fromN = cal.start_value,
            toN = cal.end_value,
            Quantity = cal.used_electric, 
            Price = cal.unit_price, 
            Amount = cal.amount,
            Id = t.Id
        INTO #updateAll
        FROM
            MAS_Service_Living_CalSheet t
            JOIN MAS_Service_Living_Tracking b  ON t.TrackingId = b.TrackingId	
            JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd
            JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId
            CROSS APPLY(SELECT * FROM dbo.fn_CalcElectricPrice(@ProjectCd, b.TotalNum, CONCAT(@PeriodYear, '-', @PeriodMonth, '-01'), @EndDayOfMonth )) cal
        WHERE
            b.LivingTypeId = @LivingType
            AND MONTH(b.ToDt) = @PeriodMonth
            AND YEAR(b.ToDt) = @PeriodYear
            AND b.ProjectCd = @ProjectCd
            AND IsReceivable = 0 
            AND t.StepPos = cal.sort_order
            -- Filter IsBill for Bulk Mode
            AND NOT EXISTS (
                SELECT 1 
                FROM MAS_Service_ReceiveEntry r 
                WHERE r.ApartmentId = b.ApartmentId 
                AND MONTH(r.ToDt) = @PeriodMonth 
                AND YEAR(r.ToDt) = @PeriodYear 
                AND r.IsBill = 1
            );

        UPDATE t
        SET
            t.StepPos= a.StepPos,
            t.fromN =a.fromN,
            t.toN = a.toN,
            t.Quantity = a.Quantity,
            t.Price = a.Price,
            t.Amount = a.Amount
            --t.FreeAmt = dbo.fn_CalculateFreeAmt(0, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, s.sort_order, b.LivingTypeId, mp.caculateWaterType, s.start_value, s.end_value), s.unit_price)
        FROM
            MAS_Service_Living_CalSheet t 
            JOIN #updateAll a ON a.Id = t.Id

        -- Insert missing calculation lines
        INSERT INTO MAS_Service_Living_CalSheet (TrackingId, StepPos, fromN, toN, Quantity, Price, Amount, FreeAmt)
        SELECT DISTINCT
            b.TrackingId,
            cal.sort_order,
            cal.start_value,
            cal.end_value,
            cal.used_electric, 
            cal.unit_price, 
            cal.amount, 
            FreeAmt = dbo.fn_CalculateFreeAmt(0, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, cal.sort_order, b.LivingTypeId, mp.caculateWaterType, cal.start_value, cal.end_value), cal.unit_price)
        FROM
            MAS_Service_Living_Tracking b
            JOIN MAS_Apartments c ON b.ApartmentId = c.ApartmentId
            JOIN par_electric pe ON b.ProjectCd = pe.project_code AND pe.is_active =1
            JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId
            JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd
            CROSS APPLY(SELECT * FROM dbo.fn_CalcElectricPrice(@ProjectCd, b.TotalNum, CONCAT(@PeriodYear, '-', @PeriodMonth, '-01'), @EndDayOfMonth )) cal
        WHERE
            b.LivingTypeId = @LivingType
            AND MONTH(b.ToDt) = @PeriodMonth
            AND YEAR(b.ToDt) = @PeriodYear
            AND c.ProjectCd = @ProjectCd
            AND IsReceivable = 0
            AND NOT EXISTS (SELECT 1 FROM MAS_Service_Living_CalSheet WHERE TrackingId = b.TrackingId AND StepPos = cal.sort_order)
        ORDER BY b.TrackingId, cal.sort_order;

        -- Update summary for all matching TrackingIds
        EXEC dbo.sp_Update_Living_Tracking_Total_Bulk @LivingType, @PeriodMonth, @PeriodYear, @ProjectCd;
    END

    SELECT 1 AS valid, N'Tính toán thành công' AS messages;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT = ERROR_NUMBER();
    DECLARE @ErrorMsg NVARCHAR(200) = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    DECLARE @ErrorProc NVARCHAR(50) = ERROR_PROCEDURE();
    DECLARE @SessionID INT;
    DECLARE @AddlInfo NVARCHAR(MAX) = '@UserID ' + @UserID;
    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServiceLivingCalculate', 'Ins', @SessionID, @AddlInfo;
END CATCH;