-- Main calculation procedure
CREATE PROCEDURE [dbo].[sp_res_service_living_meter_calculate]
    @UserID NVARCHAR(450),
    @TrackingId INT,
    @ProjectCd NVARCHAR(30),
    @LivingType INT,
    @PeriodMonth INT,
    @PeriodYear INT
AS
BEGIN TRY
    SET NOCOUNT ON;

    IF @TrackingId > 0
    BEGIN
        -- Update existing calculation lines
        UPDATE t
        SET t.Quantity = dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, a.Pos, b.LivingTypeId, mp.caculateWaterType, a.NumFrom, a.NumTo),
            t.Price = a.Price,
            t.Amount = dbo.fn_CalculateAmount(a.Price, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, a.Pos, b.LivingTypeId, mp.caculateWaterType, a.NumFrom, a.NumTo)),
            t.FreeAmt = dbo.fn_CalculateFreeAmt(a.free_rt, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, a.Pos, b.LivingTypeId, mp.caculateWaterType, a.NumFrom, a.NumTo), a.Price)
        FROM MAS_Service_Living_CalSheet t
        JOIN PAR_ServiceLivingPrice a ON t.StepPos = a.Pos
        JOIN MAS_Service_Living_Tracking b ON t.TrackingId = b.TrackingId AND a.ProjectCd = b.ProjectCd AND a.LivingTypeId = b.LivingTypeId
        JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId
        JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd
        WHERE b.TrackingId = @TrackingId AND IsReceivable = 0;

        -- Insert missing steps
        INSERT INTO MAS_Service_Living_CalSheet (TrackingId, StepPos, fromN, toN, Quantity, Price, Amount, FreeAmt)
        SELECT DISTINCT
            @TrackingId,
            a.Pos,
            a.NumFrom,
            a.NumTo,
            dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, a.Pos, b.LivingTypeId, mp.caculateWaterType, a.NumFrom, a.NumTo),
            a.Price,
            dbo.fn_CalculateAmount(a.Price, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, a.Pos, b.LivingTypeId, mp.caculateWaterType, a.NumFrom, a.NumTo)),
            dbo.fn_CalculateFreeAmt(a.free_rt, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, a.Pos, b.LivingTypeId, mp.caculateWaterType, a.NumFrom, a.NumTo), a.Price)
        FROM MAS_Service_Living_Tracking b
        JOIN MAS_Apartments c ON b.ApartmentId = c.ApartmentId
        JOIN PAR_ServiceLivingPrice a ON a.LivingTypeId = b.LivingTypeId AND a.ProjectCd = c.projectCd
        JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId
        JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd
        WHERE b.TrackingId = @TrackingId AND IsReceivable = 0
          AND NOT EXISTS (SELECT 1 FROM MAS_Service_Living_CalSheet WHERE TrackingId = b.TrackingId AND StepPos = a.Pos)
        ORDER BY a.Pos;

        -- Update tracking summary
        EXEC dbo.sp_Update_Living_Tracking_Total @TrackingId, @LivingType;
    END
    ELSE
    BEGIN
        -- Bulk update existing calculation lines
        UPDATE t
        SET t.Quantity = dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, a.Pos, b.LivingTypeId, mp.caculateWaterType, a.NumFrom, a.NumTo),
            t.Price = a.Price,
            t.Amount = dbo.fn_CalculateAmount(a.Price, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, a.Pos, b.LivingTypeId, mp.caculateWaterType, a.NumFrom, a.NumTo)),
            t.FreeAmt = dbo.fn_CalculateFreeAmt(a.free_rt, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, a.Pos, b.LivingTypeId, mp.caculateWaterType, a.NumFrom, a.NumTo), a.Price)
        FROM MAS_Service_Living_CalSheet t
        JOIN PAR_ServiceLivingPrice a ON t.StepPos = a.Pos
        JOIN MAS_Service_Living_Tracking b ON t.TrackingId = b.TrackingId AND a.ProjectCd = b.ProjectCd AND a.LivingTypeId = b.LivingTypeId
        JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId
        JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd
        WHERE b.LivingTypeId = @LivingType AND MONTH(b.ToDt) = @PeriodMonth AND YEAR(b.ToDt) = @PeriodYear
          AND b.ProjectCd = @ProjectCd AND IsReceivable = 0;

        -- Insert missing calculation lines
        INSERT INTO MAS_Service_Living_CalSheet (TrackingId, StepPos, fromN, toN, Quantity, Price, Amount, FreeAmt)
        SELECT DISTINCT
            b.TrackingId,
            a.Pos,
            a.NumFrom,
            a.NumTo,
            dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, a.Pos, b.LivingTypeId, mp.caculateWaterType, a.NumFrom, a.NumTo),
            a.Price,
            dbo.fn_CalculateAmount(a.Price, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, a.Pos, b.LivingTypeId, mp.caculateWaterType, a.NumFrom, a.NumTo)),
            dbo.fn_CalculateFreeAmt(a.free_rt, dbo.fn_CalculateQuantity(b.TotalNum, ma.NumPersonWater, a.Pos, b.LivingTypeId, mp.caculateWaterType, a.NumFrom, a.NumTo), a.Price)
        FROM MAS_Service_Living_Tracking b
        JOIN MAS_Apartments c ON b.ApartmentId = c.ApartmentId
        JOIN PAR_ServiceLivingPrice a ON a.LivingTypeId = b.LivingTypeId AND a.ProjectCd = c.projectCd
        JOIN MAS_Apartment_Service_Living ma ON b.ApartmentId = ma.ApartmentId AND ma.LivingTypeId = b.LivingTypeId
        JOIN MAS_Projects mp ON b.ProjectCd = mp.projectCd
        WHERE b.LivingTypeId = @LivingType AND MONTH(b.ToDt) = @PeriodMonth AND YEAR(b.ToDt) = @PeriodYear
          AND c.ProjectCd = @ProjectCd AND IsReceivable = 0
          AND NOT EXISTS (SELECT 1 FROM MAS_Service_Living_CalSheet WHERE TrackingId = b.TrackingId AND StepPos = a.Pos)
        ORDER BY b.TrackingId, a.Pos;

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