
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	details of receipt
-- Output: form configuration
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_invoice_field] 
	 @userId UNIQUEIDENTIFIER = NULL
    , @receiveId BIGINT = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @tableKey VARCHAR(50) = 'app_invoice'
    DECLARE @groupKey VARCHAR(50) = 'app_invoice_group'
    DECLARE @vehicle_service NVARCHAR(50) = 'Vehicle'
    DECLARE @debit_service_type INT = 99
    --DECLARE @customerId UNIQUEIDENTIFIER = dbo.fn_get_customerid(@userId);
    DECLARE @apartmentId BIGINT
    DECLARE @ProjectName NVARCHAR(250)
    DECLARE @buildingName NVARCHAR(100)
    DECLARE @Apartment NVARCHAR(100)
    DECLARE @floorNo NVARCHAR(100)
    DECLARE @invoicePeriod NVARCHAR(100)
    DECLARE @PeriodDate NVARCHAR(100)
    DECLARE @invoiceStatus INT
    DECLARE @statusName NVARCHAR(100)
    DECLARE @subTotalAmt DECIMAL
    DECLARE @totalAmt DECIMAL
    DECLARE @refundAmt DECIMAL
    DECLARE @debitAmt DECIMAL
    DECLARE @paidAmt DECIMAL
    DECLARE @remainAmt DECIMAL
    DECLARE @paidGroups NVARCHAR(MAX)

    --
    SELECT @apartmentId = apartmentId
        , @invoicePeriod = dbo.fn_invoice_period_name_format(a.ToDt)
        , @periodDate = CONCAT (
            CONVERT(NVARCHAR, DATEFROMPARTS(YEAR(a.ToDt), MONTH(a.ToDt), 1), 103)
            , ' - '
            , CONVERT(NVARCHAR, a.ToDt, 103)
            )
        , @subTotalAmt = a.TotalAmt
        , @totalAmt = a.TotalAmt
        , @debitAmt = a.DebitAmt
        , @refundAmt = a.RefundAmt
        , @paidAmt = a.PaidAmt
        , @remainAmt = a.TotalAmt - ISNULL(a.PaidAmt, 0)
        , @invoiceStatus = s.objCode
        , @statusName = s.objClass
    FROM MAS_Service_ReceiveEntry a
    LEFT JOIN dbo.fn_config_data_gets_lang('invoice_status', @acceptLanguage) s
        ON s.objCode = dbo.fn_get_invoice_status(a.IsPayed, a.TotalAmt, a.PaidAmt, a.ToDt, a.IsDebt)
    WHERE ReceiveId = @receiveId

    SELECT @paidGroups = STRING_AGG(PaymentSection, ',')
    FROM MAS_Service_Receipts
    WHERE ReceiveId = @receiveId

    --
    SET @projectName = CONCAT (
            @projectName
            , dbo.fn_newline()
            , dbo.fn_apartment_format(@Apartment, @floorNo, @buildingName)
            )

    --
    SELECT @ProjectName = CONCAT (
            p.projectName
            , dbo.fn_newline()
            , dbo.fn_apartment_format(a.RoomCode, CONCAT (
                    N'Tầng '
                    , ISNULL(NULLIF(ISNULL(ef.FloorName, a.floorNo), ''), FORMAT(ISNULL(ef.FloorNumber, a.Floor), '00'))
                    ), b.BuildingName)
            )
    FROM MAS_Apartments a
    LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid
    INNER JOIN MAS_Buildings b ON a.buildingOid = b.oid
    INNER JOIN MAS_Projects p ON p.oid = a.tenant_oid
    WHERE a.ApartmentId = @apartmentId

    --1 thong tin chung
    SELECT ReceiveId = @receiveId
        , tableKey = @tableKey
        , groupKey = @groupKey
        , invoicePeriod = @invoicePeriod
        , periodDate = @PeriodDate
        , projectName = @ProjectName
        , [subTotalAmt] = @totalAmt
        , TotalAmt = @totalAmt
        , DebitAmt = @debitAmt
        , paidAmt = @paidAmt
        , remainAmt = IIF(@remainAmt < 0, 0, @remainAmt)
        , RefundAmt = @refundAmt
        , [_paidGroups] = @paidGroups
        , [invoiceStatus] = @invoiceStatus
        , [StatusName] = @statusName

    --2- cac group
    -- SELECT group_key = 'app_invoice_group'
    --     , [ServiceTypeId] = @debit_service_type
    --     , group_name = N'Công nợ cũ'
    --     , group_cd = 'debit'
    --     , intOrder = 0
    -- WHERE @debitAmt > 0
    -- UNION ALL
    SELECT group_key = 'app_invoice_group'
        , [ServiceTypeId]
        , group_name = [ServiceTypeName]
        , group_cd = [ServiceType]
        , intOrder = IIF(ServiceTypeId = 9, 0, serviceTypeId)
    FROM MAS_ServiceTypes
    WHERE ServiceTypeId IN (
            SELECT ServiceTypeId
            FROM MAS_Service_Receivable
            WHERE ReceiveId = @receiveId
            )
    ORDER BY intOrder

    DROP TABLE

    IF EXISTS #temp;
        -- loại khác trừ gửi xe
        WITH cte
        AS (
            SELECT a.[ReceiveId]
                , a.[ServiceTypeId]
                , t.ServiceType
                , t.ServiceTypeName
                , a.[ServiceObject]
                , a.[Amount]
                , a.[VatAmt]
                , [SubTotalAmt] = NULL
                , a.[TotalAmt]
                , a.[srcId] AS TrackingId
                , d.LivingTypeName
                , c.MeterSeri AS MeterSerial
                , b.FromNum
                , b.ToNum
                , b.TotalNum
                , c.LivingTypeId
                , a.Price
                , a.Quantity
                , WaterwayArea = CONVERT(DECIMAL(18, 3), ap.WaterwayArea)
                , VehicleTypeId = NULL
                , VehicleType = NULL
                , rn = NULL
            FROM [MAS_Service_Receivable] a
            INNER JOIN MAS_ServiceTypes t
                ON t.ServiceTypeId = a.ServiceTypeId
            LEFT JOIN MAS_Service_ReceiveEntry e
                ON e.ReceiveId = a.ReceiveId
            LEFT JOIN MAS_Apartments ap
                ON ap.ApartmentId = e.ApartmentId
            LEFT JOIN MAS_Service_Living_Tracking b
                ON a.srcId = b.TrackingId
            LEFT JOIN MAS_Apartment_Service_Living c
                ON b.LivingId = c.LivingId
            LEFT JOIN MAS_LivingTypes d
                ON c.LivingTypeId = d.LivingTypeId
            WHERE a.ReceiveId = @receiveId
                AND a.ServiceTypeId NOT IN (
                    SELECT ServiceTypeId
                    FROM MAS_ServiceTypes
                    WHERE ServiceType = @vehicle_service
                    )
            
            UNION ALL
            
            --Gửi xe
            SELECT a.[ReceiveId]
                , a.[ServiceTypeId]
                , t.ServiceType
                , ServiceTypeName = NULL
                , [ServiceObject] = NULL
                , [Amount] = SUM(a.Amount)
                , [VatAmt] = SUM(a.VatAmt)
                , [SubTotalAmt] = SUM(a.TotalAmt)
                , [TotalAmt] = SUM(SUM(a.TotalAmt)) OVER ()
                , TrackingId = NULL
                , LivingTypeName = NULL
                , MeterSerial = NULL
                , FromNum = NULL
                , ToNum = NULL
                , TotalNum = NULL
                , LivingTypeId = NULL
                , Price = NULL
                , Quantity = SUM(a.Quantity)
                , WaterwayArea = NULL
                , VehicleTypeId = v.VehicleTypeId
                , VehicleType = v.VehicleTypeName
                , rn = ROW_NUMBER() OVER (
                    ORDER BY v.VehicleTypeId DESC
                    )
            FROM [MAS_Service_Receivable] a
            INNER JOIN MAS_ServiceTypes t
                ON t.ServiceTypeId = a.ServiceTypeId
            LEFT JOIN MAS_Service_Living_Tracking b
                ON a.srcId = b.TrackingId
            LEFT JOIN MAS_CardVehicle cv
                ON a.srcId = cv.CardVehicleId
            LEFT JOIN MAS_VehicleTypes v
                ON cv.VehicleTypeId = v.VehicleTypeId
            WHERE a.ReceiveId = @receiveId
                AND a.ServiceTypeId IN (
                    SELECT ServiceTypeId
                    FROM MAS_ServiceTypes
                    WHERE ServiceType = @vehicle_service
                    )
            GROUP BY a.[ReceiveId]
                , a.[ServiceTypeId]
                , t.ServiceType
                , v.VehicleTypeId
                , v.VehicleTypeName
            )
        SELECT ServiceTypeId
            , ServiceType
            , LivingTypeId
            , TrackingId
            , VehicleTypeId
            , rn
            , json_data = (
                SELECT [ReceiveId]
                    , [ServiceTypeId]
                    , [ServiceType]
                    , [ServiceTypeName]
                    , [ServiceObject]
                    , [Amount]
                    , [VatAmt]
                    , [SubTotalAmt]
                    , [TotalAmt]
                    , [TrackingId]
                    , [LivingTypeName]
                    , [MeterSerial]
                    , [FromNum]
                    , [ToNum]
                    , [TotalNum]
                    , [LivingTypeId]
                    , [Price]
                    , [Quantity]
                    , [WaterwayArea]
                    , [VehicleType]
                FOR JSON PATH
                    , WITHOUT_ARRAY_WRAPPER
                )
        INTO #temp
        FROM cte

    --
    -- INSERT INTO #temp (
    --     ServiceTypeId
    --     , ServiceType
    --     , rn
    --     , json_data
    --     )
    -- VALUES (
    --     @debit_service_type
    --     , 'debit'
    --     , 1
    --     , '{"DebitAmt":' + LOWER(@debitAmt) + '}'
    --     )
    --
    SELECT [id]
        , f.[table_name]
        , f.[field_name]
        , f.[view_type]
        , f.[data_type]
        , f.[ordinal]
        , [group_cd] = g.[value]
        , f.[columnLabel]
        , f.[columnTooltip]
        , f.[columnClass]
        , f.[columnType]
        , [columnObject] = IIF(f.columnObject IS NULL, NULL, CONCAT (
                f.columnObject
                , '='
                , d.TrackingId
                ))
        , f.[isVisiable]
        , f.[isSpecial]
        , f.[isRequire]
        , f.[isDisable]
        , columnValue = JSON_VALUE(d.json_data, '$.' + f.field_name)
        , f.[columnDisplay]
        , f.[isIgnore]
    FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) f
    CROSS APPLY STRING_SPLIT(f.group_cd, ',') g
    INNER JOIN #temp d
        ON g.[value] = d.ServiceType
    -- AND (
    --     CASE g.[value]
    --         WHEN 'Electric'
    --             THEN 1
    --         WHEN 'Water'
    --             THEN 2
    --         ELSE d.LivingTypeId
    --         END = d.LivingTypeId
    --     OR d.LivingTypeId IS NULL
    --     )
    WHERE g.[value] NOT IN ('Vehicle')
        OR f.field_name NOT IN ('TotalAmt')
        OR rn = 1
    ORDER BY d.VehicleTypeId
        , rn
        , f.view_type
        , f.ordinal
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , @tableKey
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;