CREATE PROCEDURE [dbo].[sp_res_service_expected_living_page]
    @UserId UNIQUEIDENTIFIER = NULL,
    @project_code NVARCHAR(50) = NULL,
    @receiveId INT = 193285,
    @filter NVARCHAR(30) = NULL,
    @gridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @Total INT = 0 OUT,
    @TotalFiltered INT = 0 OUT,
    @GridKey nvarchar(200) = null out,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');
    SET @GridKey = 'view_service_expected_living_page'

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].[fn_config_list_gets_lang]('view_service_expected_living_page',@gridWidth, @AcceptLanguage)
        ORDER BY ordinal;

        SELECT *
        FROM [dbo].[fn_config_list_gets_lang]('view_service_expected_living_detail_page',@gridWidth, @AcceptLanguage)
        ORDER BY ordinal;
    END;
    
    SELECT @Total = COUNT(a.[ReceivableId])
    FROM [MAS_Service_Receivable] a
        JOIN MAS_Service_Living_Tracking b ON a.srcId = b.TrackingId
        JOIN MAS_Apartment_Service_Living c ON b.LivingId = c.LivingId
        JOIN MAS_LivingTypes d ON c.LivingTypeId = d.LivingTypeId
    WHERE a.ReceiveId = @receiveId
          AND a.ServiceTypeId = 3;

    SET @TotalFiltered = @Total;

    SELECT [ReceivableId],
           [ReceiveId],
           [ServiceTypeId],
           [ServiceObject],
           b.[Amount],
           b.[VatAmt],
           [TotalAmt],
           CONVERT(NVARCHAR(10), b.FromDt, 103) AS fromDt,
           CONVERT(NVARCHAR(10), b.[ToDt], 103) AS ToDate,
           [srcId] AS TrackingId,
           d.LivingTypeName,
           c.MeterSeri AS MeterSerial,
           b.FromNum,
           b.ToNum,
           b.TotalNum,
           c.LivingTypeId,
           a.Price,
           a.Quantity
    FROM [MAS_Service_Receivable] a
        JOIN MAS_Service_Living_Tracking b ON a.srcId = b.TrackingId
        JOIN MAS_Apartment_Service_Living c ON b.LivingId = c.LivingId
        JOIN MAS_LivingTypes d ON c.LivingTypeId = d.LivingTypeId
    WHERE a.ReceiveId = @receiveId
          AND a.ServiceTypeId IN(3, 4);

    -- living detail: Bảng thang giá điện/nước sử dụng theo tháng
    DECLARE @par_electric_oid uniqueidentifier
    DECLARE @par_water_oid uniqueidentifier
    DECLARE @TrackingIdE INT
    DECLARE @TrackingIdW INT

    -- Lấy TrackingId cho Điện (LivingTypeId = 1)
    SELECT TOP 1
        @par_electric_oid = e.oid,
        @TrackingIdE = b.TrackingId
    FROM MAS_Service_ReceiveEntry r
    JOIN par_electric e ON r.ProjectCd = e.project_code
    JOIN MAS_Service_Receivable sr ON r.ReceiveId = sr.ReceiveId AND sr.ServiceTypeId = 3
    JOIN MAS_Service_Living_Tracking b ON sr.srcId = b.TrackingId AND b.LivingTypeId = 1
    WHERE r.ReceiveId = @receiveId;

    -- Lấy TrackingId cho Nước (LivingTypeId = 2)
    SELECT TOP 1
        @par_water_oid = w.oid,
        @TrackingIdW = b.TrackingId
    FROM MAS_Service_ReceiveEntry r
    JOIN par_water w ON r.ProjectCd = w.project_code
    JOIN MAS_Service_Receivable sr ON r.ReceiveId = sr.ReceiveId AND sr.ServiceTypeId = 4
    JOIN MAS_Service_Living_Tracking b ON sr.srcId = b.TrackingId AND b.LivingTypeId = 2
    WHERE r.ReceiveId = @receiveId;

    -- Trả về bảng thang giá điện/nước
    SELECT
        ISNULL(e.Id, 0) AS Id,
        ISNULL(e.TrackingId, @TrackingIdE) AS TrackingId,
        ped.sort_order AS StepPos,
        ped.start_value AS fromN,
        ped.end_value AS toN,
        ISNULL(e.Quantity, 0) AS Quantity,
        ISNULL(e.Price, 0) AS Price,
        ISNULL(e.Amount, 0) AS Amount,
        ISNULL(e.VatAmt, 0) AS VatAmt,
        Period = CASE
                    WHEN e.from_dt IS NULL THEN NULL
                    ELSE FORMAT(e.from_dt,'dd/MM/yyyy') + '-' + FORMAT(e.to_dt,'dd/MM/yyyy')
                 END,
        1 AS SourceType  -- 1 cho electric
    FROM par_electric_detail ped
    LEFT JOIN MAS_Service_Living_CalSheet e
        ON e.StepPos = ped.sort_order
        AND e.TrackingId = @TrackingIdE  -- Sử dụng biến đã tính sẵn
    WHERE ped.par_electric_oid = @par_electric_oid

    UNION ALL

    SELECT
        ISNULL(e.Id, 0) AS Id,
        ISNULL(e.TrackingId, @TrackingIdW) AS TrackingId,
        pwd.sort_order AS StepPos,
        pwd.start_value AS fromN,
        pwd.end_value AS toN,
        ISNULL(e.Quantity, 0) AS Quantity,
        ISNULL(e.Price, 0) AS Price,
        ISNULL(e.Amount, 0) AS Amount,
        ISNULL(e.VatAmt, 0) AS VatAmt,
        Period = CASE
                    WHEN e.from_dt IS NULL THEN NULL
                    ELSE FORMAT(e.from_dt,'dd/MM/yyyy') + '-' + FORMAT(e.to_dt,'dd/MM/yyyy')
                 END,
        2 AS SourceType  -- 2 cho water
    FROM par_water_detail pwd
    LEFT JOIN MAS_Service_Living_CalSheet e
        ON e.StepPos = pwd.sort_order
        AND e.TrackingId = @TrackingIdW  -- Sử dụng biến đã tính sẵn
    WHERE pwd.par_water_oid = @par_water_oid

    ORDER BY SourceType, StepPos;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_expected_living_get ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'ServiceExpecteLiving',
                             'GET',
                             @SessionID,
                             @AddlInfo;
END CATCH;