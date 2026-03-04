CREATE procedure [dbo].[sp_res_get_payment_report_byId_new_center]
        @userId NVARCHAR(450) = NULL ,
        @receiveId INT =	191081	--181138
AS
BEGIN TRY
    DECLARE @ApartmentId int
    declare @ProjectCd nvarchar(50) = ''
    DECLARE @DiscountElecAmt DECIMAL(18,0)
    DECLARE @DiscountWaterAmt DECIMAL(18,0)
    DECLARE @Par_vehicle_oid NVARCHAR(100);
    DECLARE @par_electric_oid UNIQUEIDENTIFIER;
    DECLARE @par_water_oid UNIQUEIDENTIFIER;
    DECLARE @TrackingIdE INT;
    DECLARE @TrackingIdW INT;

    SET @ApartmentId = (SELECT TOP 1 ApartmentId FROM MAS_Service_ReceiveEntry WHERE ReceiveId = @receiveId)
    SET @ProjectCd = (SELECT TOP 1 ISNULL(projectCd,'01') FROM MAS_Apartments WHERE ApartmentId = @ApartmentId)
    SELECT @Par_vehicle_oid=oid FROM par_vehicle WHERE project_code=@projectCd
    
    select @DiscountElecAmt = t.DiscountAmt
    from
        MAS_Service_Living_Tracking t
        inner join MAS_Service_ReceiveEntry k on t.ApartmentId = k.ApartmentId
                                              and t.LivingTypeId = 1
                                              and t.PeriodMonth = month(k.ToDt)
                                              AND t.PeriodYear = YEAR(k.ToDt)
    where k.ReceiveId = @receiveId

    select @DiscountWaterAmt = t.DiscountAmt
    from
        MAS_Service_Living_Tracking t
        inner join MAS_Service_ReceiveEntry k on t.ApartmentId = k.ApartmentId
                                              and t.LivingTypeId = 2
                                              and t.PeriodMonth = month(k.ToDt)
                                              AND t.PeriodYear = YEAR(k.ToDt)
    where k.ReceiveId = @receiveId

    -- Lấy oid và TrackingId cho Điện (LivingTypeId = 1)
    SELECT TOP 1
        @par_electric_oid = e.oid,
        @TrackingIdE = b.TrackingId
    FROM MAS_Service_ReceiveEntry r
    JOIN par_electric e ON r.ProjectCd = e.project_code
    JOIN MAS_Service_Receivable sr ON r.ReceiveId = sr.ReceiveId AND sr.ServiceTypeId = 3
    LEFT JOIN MAS_Service_Living_Tracking b ON sr.srcId = b.TrackingId AND b.LivingTypeId = 1
    WHERE r.ReceiveId = @receiveId;

    -- Lấy oid và TrackingId cho Nước (LivingTypeId = 2)
    SELECT TOP 1
        @par_water_oid = w.oid,
        @TrackingIdW = b.TrackingId
    FROM MAS_Service_ReceiveEntry r
    JOIN par_water w ON r.ProjectCd = w.project_code
    JOIN MAS_Service_Receivable sr ON r.ReceiveId = sr.ReceiveId AND sr.ServiceTypeId = 4
    LEFT JOIN MAS_Service_Living_Tracking b ON sr.srcId = b.TrackingId AND b.LivingTypeId = 2
    WHERE r.ReceiveId = @receiveId;

    --0 - Thong tin chung
    SELECT
        a.ReceiveId
        ,a.entryId
        ,cast(month(a.ToDt) as varchar) [PeriodMonth]
        ,cast(year(a.ToDt) as varchar) [PeriodYear]
        ,FORMAT(t1.FromDt, 'dd/MM/yyyy') [ElectricFromDate]
        ,FORMAT(t1.ToDt, 'dd/MM/yyyy') [ElectricToDate]
        ,FORMAT(t2.FromDt, 'dd/MM/yyyy') [WaterFromDate]
        ,FORMAT(t2.ToDt, 'dd/MM/yyyy') [WaterToDate]
        ,convert(nvarchar(10),a.ReceiveDt,103) as ReceivableDate
        ,convert(nvarchar(10),a.[ExpireDate],103) as [ExpireDate]
        ,a.[IsPayed]
        ,convert(nvarchar(10),a.ToDt,103) as toDate
        ,a.ToDt as tDate
        ,case when a.IsPayed = 1 then N'Đã thanh toán' else N'Chờ thanh toán' end as StatusPayed
        ,isnull(a.Remart,N'Hóa đơn T' + cast(month(a.ToDt) as varchar) + N'/' + cast(year(a.ToDt) as varchar)) as Remarks
        ,isnull(a.Remart,N'Hóa đơn tháng ' + cast(month(a.ToDt) as varchar) + N' năm ' + cast(year(a.ToDt) as varchar)) as Remark
        ,b.RoomCode
--         ,c.FullName
        ,h.FullName
        ,b.WaterwayArea
        ,p.Price
        ,ISNULL(pro.projectName,'')  as ProjectName
        ,ISNULL(b.projectCd,'') + '-' + ISNULL(pro.projectName,'') AS projectFolder
        ,ISNULL(b.projectCd,'') as ProjectCd
        ,ISNULL(bui.BuildingName,'') as BuildingNo
        ,cast(month(a.ToDt) as varchar) as MonthLiving
        ,cast(month(Dateadd(month,1,a.ToDt)) as varchar) as MonthVehicleFee
        ,cast(YEAR(Dateadd(month,1,a.ToDt)) as varchar) as YearVehicleFee
        ,pro.bank_acc_no as Bank_Acc_Num
        ,pro.bank_acc_name as Bank_Acc_Name
        ,pro.bank_branch as Bank_Acc_Branch
        ,b.DebitAmt + a.CreditAmt as CurrBal
        ,format(isnull(a.TotalAmt,0),'#,###,###,###') as TotalAmt
        ,format(isnull(mr.PaidAmount,0),'#,###,###,###') as PaidAmount
        ,FORMAT(ISNULL(a.TotalAmt,0) - ISNULL(mr.PaidAmount,0), '#,###,###,###') AS AmountDue
        ,dbo.Num2Text(ISNULL(a.TotalAmt,0) - ISNULL(mr.PaidAmount,0)) AS AmountDueText
        ,format(isnull(@DiscountElecAmt,0),'#,###,###,###') as DiscountElecAmt
        ,format(isnull(@DiscountWaterAmt,0),'#,###,###,###') as DiscountWaterAmt
        ,bk.Bank_Code
        ,bk.bank_cif_no AS prefix
        ,CAST(
                      CONCAT(
                              FORMAT(GETDATE(), 'ddMMyy'),
                              RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR(6)), 6)
                      ) AS BIGINT
              ) AS virtualPartNum
        ,ISNULL(a.TotalAmt,0) as TransactionAmt
        ,b.RoomCode + ' THANH TOAN TIEN PHI THANG ' + cast(month(GETDATE()) as varchar) + ' NAM ' + cast(year(GETDATE()) as varchar) as TransContent
        ,ISNULL(masl.NumPersonWater, 0) AS NumPersonWater
    FROM
        [dbo].MAS_Service_ReceiveEntry a
        left JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
        LEFT JOIN MAS_Buildings bui On b.buildingOid = bui.oid
        LEFT JOIN dbo.MAS_Projects pro ON pro.projectCd = b.projectCd AND pro.sub_projectCd = b.sub_projectCd
        left join MAS_Service_Bank bk on b.projectCd = bk.ProjectCd
        left join PAR_ServicePrice p on b.projectCd = p.ProjectCd and ServiceTypeId = 1
        left join UserInfo u on b.UserLogin = u.loginName
        left join MAS_Customers c on u.CustId = c.CustId
        outer apply (SELECT TOP 1 * FROM MAS_Service_Living_Tracking WHERE PeriodMonth = month(a.ToDt) AND PeriodYear = year(a.ToDt) AND a.ApartmentId = ApartmentId AND LivingTypeId = 1) t1
        outer apply (SELECT TOP 1 * FROM MAS_Service_Living_Tracking WHERE PeriodMonth = month(a.ToDt) AND PeriodYear = year(a.ToDt) AND a.ApartmentId = ApartmentId AND LivingTypeId = 2) t2
        outer apply (
                select TOP 1 SUM(mar.Amount) as PaidAmount
                FROM MAS_Service_Receipts mar
                where mar.ReceiveId = a.ReceiveId
        ) mr
        OUTER APPLY (
                SELECT TOP 1 NumPersonWater FROM MAS_Apartment_Service_Living
                WHERE ApartmentId = @ApartmentId AND LivingTypeId = 2
        ) masl
        OUTER APPLY (SELECT TOp(1) t1.*
                      FROM
                          MAS_Customers t1
                          join MAS_Apartment_Member b1 on t1.CustId = b1.CustId 
                          left join MAS_Customer_Relation d1 on b1.RelationId = d1.RelationId
                      WHERE b1.ApartmentId = b.ApartmentId and b1.RelationId = 0) h
    WHERE  a.ReceiveId = @ReceiveId

    --1 Olddebt Công nợ tồn cũ
    SELECT TOP 1
        CommonFee   =  ISNULL(re.CommonFee, 0) ,
        VehicleFee  =  ISNULL(re.VehicleAmt, 0) ,
        ElectricFee =  ISNULL(re.LivingElectricAmt, 0) ,
        WaterFee    =  ISNULL(re.LivingWaterAmt, 0) ,
--                 DebitFee    = CASE
--                                                   WHEN apt.AptDebit > 0 THEN apt.AptDebit
--                                                   ELSE ISNULL(re.TotalAmt, 0)
--                                           END
        DebitFee = ISNULL(apt.AptDebit, 0)
        ,Note = CASE
                    WHEN EXISTS(SELECT 1
                                FROM MAS_Service_Receipts r
                                WHERE
                                    r.ReceiveId = @receiveId
                                    AND r.PaymentSection LIKE '%Debt%')
                        THEN N'Đã thanh toán'
                  ELSE N''
          END
    FROM
        (SELECT 1 AS X) base
        CROSS APPLY (SELECT ISNULL(DebitAmt, 0) AS AptDebit FROM MAS_Apartments WHERE ApartmentId = @ApartmentId) apt
        LEFT JOIN MAS_Service_ReceiveEntry re ON re.ApartmentId = @ApartmentId AND re.IsDebt = 1;

        --6 Phí giữ xe tháng
        SELECT Sum(case when VehicleTypeId = 1 then isnull(sumQ,0) else 0 end) as CarNumber
                  ,Sum(case when VehicleTypeId = 2 then isnull(sumQ,0) else 0 end) as MotoNumber
                  ,Sum(case when VehicleTypeId = 3 then isnull(sumQ,0) else 0 end) as MotoELNumber
                  ,Sum(case when VehicleTypeId = 4 then isnull(sumQ,0) else 0 end) as BikeELNumber
                  ,Sum(case when VehicleTypeId = 5 then isnull(sumQ,0) else 0 end) as BikeNumber
                  ,format(Sum(case when VehicleTypeId = 1 then isnull(sumA,0) else 0 end),'#,###,###,###') as CarFee
                  ,format(Sum(case when VehicleTypeId = 2 then isnull(sumA,0) else 0 end),'#,###,###,###') as MotoFee
                  ,format(Sum(case when VehicleTypeId = 3 then isnull(sumA,0) else 0 end),'#,###,###,###') as MotoELFee
                  ,format(Sum(case when VehicleTypeId = 4 then isnull(sumA,0) else 0 end),'#,###,###,###') as BikeELFee
                  ,format(Sum(case when VehicleTypeId = 5 then isnull(sumA,0) else 0 end),'#,###,###,###') as BikeFee
                  ,format(Sum(isnull(sumA,0)),'#,###,###,###') as TotalFee
                  ,CASE
                          WHEN EXISTS (
                                        SELECT 1
                                        FROM MAS_Service_Receipts r
                                        WHERE r.ReceiveId = @receiveId
                                          AND r.PaymentSection LIKE '%Vehicle%'
                          )
                          THEN SUM(ISNULL(sumA,0))
                          ELSE 0
                  END AS PaidVehicleFee
        FROM
                (SELECT
                        c.VehicleTypeId,
                        COUNT(b.CardVehicleId) AS sumQ,
                        sum(isnull(a.TotalAmt,0)) as sumA
                FROM
                        MAS_Service_Receivable a
                        JOIN MAS_CardVehicle b ON a.srcId = b.CardVehicleId
                        JOIN MAS_VehicleTypes c ON b.VehicleTypeId = c.VehicleTypeId
                WHERE
                        a.ReceiveId = @receiveId
                        AND a.ServiceTypeId = 2
                GROUP BY c.VehicleTypeId) t

        --7 Phí quản lý
        select top 1
               b.WaterwayArea as WaterArea,
               format(pc.value,'#,###,###,###') as Price,
                   pc.tax_percent AS [VAT],
                   c.totalDays,
                   CAST(ROUND(c.Amount * (pc.tax_percent / 100), 0) AS DECIMAL(18,0)) AS VATAmt,
                   format(c.Amount,'#,###,###,###') as CommonFee,
                   format(c.TotalAmt,'#,###,###,###') as TotalAmt,
                   ISNULL(mr.TotalAmt,0) as PaidCommonFee
        from MAS_Service_ReceiveEntry a
                JOIN MAS_Service_Receivable c on c.ReceiveId = a.ReceiveId
                JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
                lEFT JOIN MAS_Service_Receipts mar on mar.ReceiveId = a.ReceiveId
        JOIN par_common pc on pc.project_code = @ProjectCd
                outer apply (
                        select top 1 r.TotalAmt
                        from MAS_Service_Receivable r
                        where
                                r.ReceiveId = a.ReceiveId
                                and r.ServiceTypeId = 1
                                AND mar.PaymentSection like '%Common%'
                ) mr
        where b.ApartmentId = @ApartmentId  and a.ReceiveId = @receiveId and c.ServiceTypeId = 1

        --2 living Phí điện năng sử dụng
        SELECT top 1 [ReceivableId]
                  ,a.ReceiveId
                  ,[ServiceTypeId]
                  ,[ServiceObject]
                  ,a.[Amount]
                  ,pe.vat AS [VAT]
                  ,a.[VATAmt]
                  ,a.TotalAmt
                  , ISNULL(mr.TotalAmt,0) As PaidElectricFee
                  ,convert(nvarchar(10),b.[ToDt],103) as ToDate
                  ,[srcId] as TrackingId
                  ,d.LivingTypeName
                  ,c.MeterSeri as MeterSerial
                  ,b.FromNum
                  ,b.ToNum
                  ,b.TotalNum
                  ,c.LivingTypeId
                  ,a.Price
                  ,a.Quantity
          FROM [MAS_Service_Receivable] a
                join MAS_Service_Living_Tracking b on a.srcId = b.TrackingId
                join MAS_Apartment_Service_Living c on b.LivingId = c.LivingId
                join MAS_LivingTypes d on c.LivingTypeId = d.LivingTypeId
                OUTER APPLY(
                        SELECT vat FROM par_electric where project_code = @ProjectCd
                ) pe
                lEFT JOIN MAS_Service_Receipts mar on mar.ReceiveId = a.ReceiveId
                outer apply (
                        select top 1 r.TotalAmt
                        from MAS_Service_Receivable r
                        where
                                r.ReceiveId = a.ReceiveId
                                and r.ServiceTypeId = 3
                            AND mar.PaymentSection like '%Electric%'
                ) mr
          WHERE  a.ReceiveId = @ReceiveId and ServiceTypeId = 3 and b.LivingTypeId = 1
          order by b.[ToDt] desc

        --3 Chi tiết phí điện năng sử dụng - SỬA: Lấy từ par_electric_detail khi không có dữ liệu
    IF OBJECT_ID('tempdb..#CalElectric') IS NOT NULL
        DROP TABLE #CalElectric;

    SELECT DISTINCT
            ISNULL(e.[Id], 0) AS Id,
            ISNULL(e.[TrackingId], @TrackingIdE) AS TrackingId,
            ISNULL(a.ReceiveId, @receiveId) AS ReceiveId,
            3 AS ServiceTypeId,
            ped.sort_order AS [StepPos],
            CASE
                WHEN (ped.start_value = 400 AND ped.end_value IS NULL) THEN NULL
                ELSE N'Từ ' + CAST(ped.start_value AS NVARCHAR(50))
                     + CASE
                         WHEN ped.end_value IS NULL THEN N' trở lên'
                         ELSE N' - ' + CAST(ped.end_value AS NVARCHAR(9))
                       END
            END AS PriceRangeElectric,
            ped.start_value AS [fromN],
            ped.end_value AS [toN],
            ISNULL(e.[Quantity], 0) AS [Quantity],
            CASE WHEN ISNULL(e.[Price], ped.unit_price) = 2927 THEN NULL ELSE ISNULL(e.[Price], ped.unit_price) END AS Price,
            ISNULL(e.[Amount], 0) AS [Amount],
            e.from_dt,
            e.to_dt
    INTO #CalElectric
    FROM par_electric_detail ped
    LEFT JOIN MAS_Service_Living_CalSheet e
        ON e.StepPos = ped.sort_order
        AND e.TrackingId = @TrackingIdE
    LEFT JOIN MAS_Service_Receivable a
        ON a.ReceiveId = @receiveId AND a.ServiceTypeId = 3
    WHERE ped.par_electric_oid = @par_electric_oid;

    DECLARE @MonthStart DATE, @MonthEnd DATE;

    SELECT  @MonthStart = DATEFROMPARTS(YEAR(ISNULL(MIN(from_dt), GETDATE())), MONTH(ISNULL(MIN(from_dt), GETDATE())), 1),
            @MonthEnd   = EOMONTH(ISNULL(MIN(from_dt), GETDATE()))
    FROM #CalElectric;

    DECLARE @SplitDate DATE = NULL;

    ;WITH pe AS
    (
        SELECT
            CAST(expiry_date AS DATE) AS expiry_date,
            COUNT(*) OVER() AS Cnt
        FROM par_electric
        WHERE project_code = @ProjectCd
          AND is_active    = 1
    )
    SELECT @SplitDate = MAX(expiry_date)
    FROM pe
    WHERE Cnt >= 2
      AND expiry_date BETWEEN @MonthStart AND @MonthEnd;

    IF @SplitDate IS NULL
    BEGIN
        SELECT *
        FROM #CalElectric
        ORDER BY StepPos ASC;

        SELECT *
        FROM #CalElectric
        WHERE 1 = 2
    END
    ELSE
    BEGIN
        SELECT *
        FROM #CalElectric
        WHERE to_dt <= @SplitDate
        ORDER BY to_dt ASC;

        SELECT *
        FROM #CalElectric
        WHERE from_dt > @SplitDate
        ORDER BY to_dt ASC;
    END

        --4 Phí nước sử dụng
        SELECT top 1 [ReceivableId]
                  ,a.[ReceiveId]
                  ,[ServiceTypeId]
                  ,[ServiceObject]
                  ,a.[Amount]
                  ,pe.vat as [VAT]
                  ,pe.environmental_fee AS EnvironmentalFee
                  ,pe.env_protection_tax AS ProtectionTaxFee
                  ,CAST(ROUND(a.[Amount] * (pe.vat / 100), 0) AS DECIMAL(18,0)) AS VATAmt
                  ,CAST(ROUND(a.[Amount] * (pe.environmental_fee / 100), 0) AS DECIMAL(18,0)) AS EnvironmentalFeeAmt
                  ,CAST(ROUND(ROUND(a.[Amount] * (pe.environmental_fee / 100.0), 0)* (pe.env_protection_tax / 100.0),0)AS DECIMAL(18,0)) AS ProtectionTaxAmt
                  ,a.[TotalAmt]
                  , ISNULL(mr.TotalAmt,0) as PaidWaterFee
                  ,convert(nvarchar(10),b.[ToDt],103) as ToDate
                  ,[srcId] as TrackingId
                  ,d.LivingTypeName
                  ,c.MeterSeri as MeterSerial
                  ,b.FromNum
                  ,b.ToNum
                  ,b.TotalNum
                  ,c.LivingTypeId
                  ,a.Price
                  ,a.Quantity
                  ,(SELECT COUNT(*) FROM MAS_Apartment_Member mam WHERE mam.ApartmentId = @ApartmentId) AS MemberCount
          FROM [MAS_Service_Receivable] a
                join MAS_Service_Living_Tracking b on a.srcId = b.TrackingId
                join MAS_Apartment_Service_Living c on b.LivingId = c.LivingId
                join par_water pw on pw.project_code = c.ProjectCd
                join MAS_LivingTypes d on c.LivingTypeId = d.LivingTypeId
                OUTER APPLY(
                        SELECT vat,environmental_fee,env_protection_tax FROM par_water where project_code = @ProjectCd
                ) pe
                lEFT JOIN MAS_Service_Receipts mar on mar.ReceiveId = a.ReceiveId
                outer apply (
                        select top 1 r.TotalAmt
                        from MAS_Service_Receivable r
                        where
                                r.ReceiveId = a.ReceiveId
                                and r.ServiceTypeId = 4
                                and mar.PaymentSection like '%Water%'
                ) mr
          WHERE  a.ReceiveId = @receiveId
                and a.ServiceTypeId = 4 and b.LivingTypeId = 2
          order by b.ToDt desc

        -- Chi tiết phí Nước sử dụng - SỬA: Lấy từ par_water_detail khi không có dữ liệu
    IF OBJECT_ID('tempdb..#CalWater') IS NOT NULL
        DROP TABLE #CalWater;

    SELECT DISTINCT
        ISNULL(e.[Id], 0) AS Id,
        ISNULL(e.[TrackingId], @TrackingIdW) AS TrackingId,
        ISNULL(a.ReceiveId, @receiveId) AS ReceiveId,
        4 AS ServiceTypeId,
        pwd.sort_order AS [StepPos],
        PriceRangeWater = CASE
                              WHEN (pwd.start_value = 400 AND pwd.end_value IS NULL) THEN NULL
                              ELSE N'Từ ' + CAST(pwd.start_value AS NVARCHAR(50))
                                   + CASE
                                       WHEN pwd.end_value IS NULL THEN N' trở lên'
                                       ELSE N' - ' + CAST(pwd.end_value AS NVARCHAR(9))
                                     END
                          END,
        pwd.start_value AS [fromN],
        pwd.end_value AS [toN],
        ISNULL(e.[Quantity], 0) AS [Quantity],
        CASE WHEN ISNULL(e.[Price], pwd.unit_price) = 2927 THEN NULL ELSE ISNULL(e.[Price], pwd.unit_price) END AS Price,
        [Amount] = ISNULL(e.[Amount], 0),
        e.from_dt,
        e.to_dt
    INTO #CalWater
    FROM
        par_water_detail pwd
        LEFT JOIN MAS_Service_Living_CalSheet e ON e.StepPos = pwd.sort_order AND e.TrackingId = @TrackingIdW
        LEFT JOIN MAS_Service_Receivable a ON a.ReceiveId = @receiveId AND a.ServiceTypeId = 4
    WHERE pwd.par_water_oid = @par_water_oid;
    SELECT  @MonthStart = DATEFROMPARTS(YEAR(ISNULL(MIN(from_dt), GETDATE())), MONTH(ISNULL(MIN(from_dt), GETDATE())), 1),
            @MonthEnd   = EOMONTH(ISNULL(MIN(from_dt), GETDATE()))
    FROM #CalWater;

    SET @SplitDate = NULL;

    ;WITH pe AS
    (
        SELECT
            CAST(expiry_date AS DATE) AS expiry_date,
            COUNT(*) OVER() AS Cnt
        FROM par_water
        WHERE project_code = @ProjectCd
          AND is_active    = 1
    )
    SELECT @SplitDate = MAX(expiry_date)
    FROM pe
    WHERE Cnt >= 2
      AND expiry_date BETWEEN @MonthStart AND @MonthEnd;

    IF @SplitDate IS NULL
    BEGIN
        SELECT *
        FROM #CalWater
        ORDER BY StepPos ASC;

        SELECT *
        FROM #CalWater
        WHERE 1 = 2
    END
    ELSE
    BEGIN
        SELECT *
        FROM #CalWater
        WHERE to_dt <= @SplitDate
        ORDER BY to_dt ASC;

        SELECT *
        FROM #CalWater
        WHERE from_dt > @SplitDate
        ORDER BY to_dt ASC;
    END

    --Bảng thời gian cấu hình
    --bat dau tao hoa don
    UPDATE [dbo].[MAS_Service_ReceiveEntry]
            SET bill_st = 1
    WHERE ReceiveId = @ReceiveId

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(max)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_get_payment_report_byId ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '
    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'PaymentById', 'GET', @SessionID, @AddlInfo
END CATCH