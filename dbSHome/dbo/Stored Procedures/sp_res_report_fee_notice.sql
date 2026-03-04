
-- =============================================
-- Author:		VuTc
-- Create date: 10/15/2025
-- Description:	THÔNG BÁO THU PHÍ / Hóa đơn Sài Gòn Sky
-- =============================================
CREATE   procedure [dbo].[sp_res_report_fee_notice]
	@UserId				UNIQUEIDENTIFIER = NULL
	,@FromDate			NVARCHAR(50) 	= '01/10/2025'		--NULL,
	,@ToDate		    NVARCHAR(50)	= '30/10/2025'	--NULL,
	,@AcceptLanguage	VARCHAR(20)	= 'vi-VN'
	,@ProjectCd			NVARCHAR(30)	= NULL
	,@BuildingName		NVARCHAR(MAX)	= NULL				-- 'Sunshine Center',
	/* ,@ApartmentId			NVARCHAR(MAX)	= NULL				 @ApartmentId = @RoomCode	*/
	,@receiveId int =153654
AS 
	SET NOCOUNT ON;
	BEGIN TRY
	DECLARE @ApartmentId INT 
	--DECLARE @ProjectCd NVARCHAR(50) = ''
	DECLARE @DiscountElecAmt DECIMAL(18,0)
	DECLARE @DiscountWaterAmt DECIMAL(18,0)
    DECLARE @Par_vehicle_oid NVARCHAR(100);

	set @ApartmentId = (select top 1 ApartmentId from MAS_Service_ReceiveEntry where ReceiveId = @receiveId)
	set @ProjectCd = (select top 1 isnull(projectCd,'01') from MAS_Apartments where ApartmentId = @ApartmentId)
	 select @Par_vehicle_oid=oid from par_vehicle where project_code=@projectCd
	select @DiscountElecAmt = t.DiscountAmt
	                       from MAS_Service_Living_Tracking t inner join MAS_Service_ReceiveEntry k
	                       on t.ApartmentId = k.ApartmentId and t.LivingTypeId = 1 and t.PeriodMonth = month(k.ToDt) AND t.PeriodYear = YEAR(k.ToDt)
						   where k.ReceiveId = @receiveId

	select @DiscountWaterAmt = t.DiscountAmt
	                       from MAS_Service_Living_Tracking t inner join MAS_Service_ReceiveEntry k
	                       on t.ApartmentId = k.ApartmentId and t.LivingTypeId = 2 and t.PeriodMonth = month(k.ToDt) AND t.PeriodYear = YEAR(k.ToDt)
						   where k.ReceiveId = @receiveId
	--0 - Thong tin chung
	SELECT a.ReceiveId
		      ,a.entryId
			  ,cast(month(a.ToDt) as varchar) [PeriodMonth]
			  ,cast(year(a.ToDt) as varchar) [PeriodYear]
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceivableDate
			  ,convert(nvarchar(10),a.[ExpireDate],103) as [ExpireDate]
			  ,a.[IsPayed]
			  ,convert(nvarchar(10),a.ToDt,103) as toDate
			  ,a.ToDt as tDate
			  ,case when a.IsPayed = 1 then N'Đã thanh toán' else N'Chờ thanh toán' end as StatusPayed
			  ,isnull(a.Remart,N'Hóa đơn T' + cast(month(a.ToDt) as varchar) + N'/' + cast(year(a.ToDt) as varchar)) as Remarks
			  ,isnull(a.Remart,N'Hóa đơn tháng ' + cast(month(a.ToDt) as varchar) + N' năm ' + cast(year(a.ToDt) as varchar)) as Remark 
			  ,b.RoomCode
			  ,c.FullName
			  ,b.WaterwayArea
			  ,p.Price			 
			  ,ISNULL(pro.projectName,'')  as ProjectName
			  ,ISNULL(b.projectCd,'') + '-' + ISNULL(pro.projectName,'') AS projectFolder
			  ,ISNULL(b.projectCd,'') as ProjectCd
			  ,ISNULL(bui.BuildingName,'') as BuildingNo
			  ,cast(month(a.ToDt) as varchar) as MonthLiving
			  ,cast(month(Dateadd(month,1,a.ToDt)) as varchar) as MonthVehicleFee

			  ,pro.bank_acc_no as Bank_Acc_Num
			  ,pro.bank_acc_name AS Bank_Acc_Name
			  ,pro.bank_branch AS Bank_Acc_Branch
			  ,b.DebitAmt + a.CreditAmt AS CurrBal
			  ,FORMAT(ISNULL(a.TotalAmt,0),'#,###,###,###') AS TotalAmt
			  /*	,dbo.Num2Text(isnull(a.TotalAmt,0)) as TotalAmtText		*/
			  ,FORMAT(ISNULL(mr.PaidAmount,0),'#,###,###,###') AS PaidAmount
			  ,FORMAT(ISNULL(a.TotalAmt,0) - ISNULL(mr.PaidAmount,0), '#,###,###,###') AS AmountDue
			  ,dbo.Num2Text(ISNULL(a.TotalAmt,0) - ISNULL(mr.PaidAmount,0)) AS AmountDueText

			  ,FORMAT(ISNULL(@DiscountElecAmt,0),'#,###,###,###') AS DiscountElecAmt
			  ,FORMAT(ISNULL(@DiscountWaterAmt,0),'#,###,###,###') AS DiscountWaterAmt
			  ,bk.Bank_Code
			  ,bk.bank_cif_no AS prefix
			  ,CAST(
					CONCAT(
						FORMAT(GETDATE(), 'ddMMyy'),  -- 6 chữ số đầu: DDMMYY
						RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR(6)), 6)  -- 6 số ngẫu nhiên
					) AS BIGINT
				) AS virtualPartNum
			  ,ISNULL(a.TotalAmt,0) AS TransactionAmt
			  ,b.RoomCode + ' THANH TOAN TIEN PHI THANG ' + CAST(MONTH(a.ToDt) AS VARCHAR) + ' NAM ' + CAST(YEAR(a.ToDt) AS VARCHAR) AS TransContent
			  ,pro.representative_name
	  FROM  [dbo].MAS_Service_ReceiveEntry a 
			LEFT JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
			LEFT JOIN MAS_Buildings bui ON b.buildingOid = bui.oid 
			LEFT JOIN dbo.MAS_Projects pro ON pro.projectCd = b.projectCd AND pro.sub_projectCd = b.sub_projectCd
			LEFT JOIN MAS_Service_Bank bk ON b.projectCd = bk.ProjectCd
			LEFT JOIN PAR_ServicePrice p ON b.projectCd = p.ProjectCd AND ServiceTypeId = 1
			LEFT JOIN UserInfo u ON b.UserLogin = u.loginName 
			LEFT JOIN MAS_Customers c ON u.CustId = c.CustId 
			OUTER APPLY (
				SELECT TOP 1 SUM(mar.Amount) AS PaidAmount
				FROM MAS_Service_Receipts mar 
				WHERE mar.ReceiveId = a.ReceiveId
			) mr
		WHERE  a.ReceiveId = @ReceiveId

	--1 Olddebt Công nợ tồn cũ
	
	SELECT 
		 CommonFee   = ISNULL(re.CommonFee, 0),  --SUM(CASE WHEN r.ServiceTypeId = 1 THEN ISNULL(r.TotalAmt,0) ELSE 0 END),
		 VehicleFee  = ISNULL(re.VehicleAmt, 0),--SUM(CASE WHEN r.ServiceTypeId = 2 THEN ISNULL(r.TotalAmt,0) ELSE 0 END),
		 ElectricFee = ISNULL(re.LivingElectricAmt, 0),--SUM(CASE WHEN r.ServiceTypeId = 3 THEN ISNULL(r.TotalAmt,0) ELSE 0 END),
		 WaterFee    = ISNULL(re.LivingWaterAmt, 0),--SUM(CASE WHEN r.ServiceTypeId = 4 THEN ISNULL(r.TotalAmt,0) ELSE 0 END),
		 DebitFee    = ISNULL(re.TotalAmt, 0)
	FROM MAS_Service_ReceiveEntry re
	--LEFT JOIN MAS_Service_Receivable r 
	--	   ON b.ReceiveId = r.ReceiveId
	WHERE re.ApartmentId = @ApartmentId 
	  AND re.IsDebt = 1
	--GROUP BY 
	--	b.CommonFee,
	--	b.VehicleAmt,
	--	b.TotalAmt
	--6 Phí giữ xe tháng
	SELECT SUM(CASE WHEN VehicleTypeId = 1 THEN ISNULL(sumQ,0) ELSE 0 END) AS CarNumber
		  ,SUM(CASE WHEN VehicleTypeId = 2 THEN ISNULL(sumQ,0) ELSE 0 END) AS MotoNumber
		  ,SUM(CASE WHEN VehicleTypeId = 3 THEN ISNULL(sumQ,0) ELSE 0 END) AS MotoELNumber
		  ,SUM(CASE WHEN VehicleTypeId = 4 THEN ISNULL(sumQ,0) ELSE 0 END) AS BikeELNumber
		  ,SUM(CASE WHEN VehicleTypeId = 5 THEN ISNULL(sumQ,0) ELSE 0 END) AS BikeNumber
		  ,FORMAT(SUM(CASE WHEN VehicleTypeId = 1 THEN ISNULL(sumA,0) ELSE 0 END),'#,###,###,###') AS CarFee
		  ,FORMAT(SUM(CASE WHEN VehicleTypeId = 2 THEN ISNULL(sumA,0) ELSE 0 END),'#,###,###,###') AS MotoFee
		  ,FORMAT(SUM(CASE WHEN VehicleTypeId = 3 THEN ISNULL(sumA,0) ELSE 0 END),'#,###,###,###') AS MotoELFee
		  ,FORMAT(SUM(CASE WHEN VehicleTypeId = 4 THEN ISNULL(sumA,0) ELSE 0 END),'#,###,###,###') AS BikeELFee
		  ,FORMAT(SUM(CASE WHEN VehicleTypeId = 5 THEN ISNULL(sumA,0) ELSE 0 END),'#,###,###,###') AS BikeFee
		  ,FORMAT(SUM(ISNULL(sumA,0)),'#,###,###,###') AS TotalFee
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
			SUM(ISNULL(a.Quantity,0)) AS sumQ,
			SUM(ISNULL(a.TotalAmt,0)) AS sumA			
		FROM
			MAS_Service_Receivable a
			JOIN MAS_CardVehicle b ON a.srcId = b.CardVehicleId
			JOIN MAS_VehicleTypes c ON b.VehicleTypeId = c.VehicleTypeId
			CROSS APPLY (
				SELECT TOP 1 pd.unit_price
				FROM par_vehicle_detail pd
				WHERE
					pd.par_vehicle_oid = @Par_vehicle_oid
					--AND pd.vehicleTypeId = c.VehicleTypeId
					AND ((pd.start_value <= ISNULL(b.VehicleNum, 1)) AND (pd.end_value IS NULL OR pd.end_value >= ISNULL(b.VehicleNum, 1)))
				ORDER BY pd.sort_order
			) AS pv
		WHERE 
			a.ReceiveId = @receiveId
			AND a.ServiceTypeId = 2
			AND b.Status = 1
		GROUP BY c.VehicleTypeId) t
	--7 Tiền nước
	SELECT TOP 1
	       b.WaterwayArea AS WaterArea,
	       FORMAT(pc.value,'#,###,###,###') AS Price,
		   FORMAT(a.CommonFee,'#,###,###,###') AS CommonFee,
		   ISNULL(mr.TotalAmt,0) AS PaidCommonFee
	FROM MAS_Service_ReceiveEntry a 
		JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
		LEFT JOIN MAS_Service_Receipts mar ON mar.ReceiveId = a.ReceiveId 
		JOIN par_common pc ON pc.project_code = @ProjectCd
		--select * from MAS_Apartments where RoomCode = 'G3-2510'
		OUTER APPLY (
			SELECT TOP 1 r.TotalAmt
			FROM MAS_Service_Receivable r
			WHERE 
				r.ReceiveId = a.ReceiveId
				AND r.ServiceTypeId = 1
				AND mar.PaymentSection LIKE '%Common%'
		) mr
	WHERE b.ApartmentId = @ApartmentId  AND a.ReceiveId = @receiveId		
	--2 living Phí điện năng sử dụng
	SELECT TOP 1 [ReceivableId]
		  ,a.ReceiveId
		  ,[ServiceTypeId]
		  ,[ServiceObject]
		  ,a.[Amount]
		  ,pe.vat AS [VAT]
		  ,a.[VATAmt]
		  ,a.TotalAmt
		  , ISNULL(mr.TotalAmt,0) AS PaidElectricFee
		  --,[fromDt]
		  ,CONVERT(NVARCHAR(10),b.[ToDt],103) AS ToDate
		  ,[srcId] AS TrackingId
		  ,d.LivingTypeName
		  ,c.MeterSeri AS MeterSerial
		  ,b.FromNum
		  ,b.ToNum
		  ,b.TotalNum
		  ,c.LivingTypeId
		  ,a.Price
		  ,a.Quantity 
		  --,a.ReceiveId
	  FROM [MAS_Service_Receivable] a
		JOIN MAS_Service_Living_Tracking b ON a.srcId = b.TrackingId
		JOIN MAS_Apartment_Service_Living c ON b.LivingId = c.LivingId
		JOIN MAS_LivingTypes d ON c.LivingTypeId = d.LivingTypeId
		OUTER APPLY(
			SELECT vat FROM par_electric WHERE project_code = @ProjectCd
		) pe
		LEFT JOIN MAS_Service_Receipts mar ON mar.ReceiveId = a.ReceiveId 
		OUTER APPLY (
			SELECT TOP 1 r.TotalAmt
			FROM MAS_Service_Receivable r
			WHERE 
				r.ReceiveId = a.ReceiveId
				AND r.ServiceTypeId = 3    
			    AND mar.PaymentSection LIKE '%Electric%'
		) mr
	  WHERE  a.ReceiveId = @ReceiveId AND ServiceTypeId = 3 AND b.LivingTypeId = 1
	  ORDER BY b.[ToDt] DESC
      
	--3 Chi tiết phí điện năng sử dụng 
    -- Lưu dữ liệu chi tiết vào bảng tạm
    IF OBJECT_ID('tempdb..#CalElectric') IS NOT NULL 
        DROP TABLE #CalElectric;
 
    SELECT 
            e.[Id],
            e.[TrackingId],
            a.ReceiveId,
            a.ServiceTypeId,
            e.[StepPos],
            CASE 
                WHEN (e.fromN = 400 AND e.toN IS NULL) THEN NULL
                ELSE N'Từ ' + CAST(e.fromN AS NVARCHAR(50))
                     + CASE 
                         WHEN e.toN IS NULL THEN N' trở lên'
                         ELSE N' - ' + CAST(e.toN AS NVARCHAR(9))
                       END
            END AS PriceRangeElectric,
            e.[fromN],
            e.[toN],
            e.[Quantity],
            CASE WHEN e.[Price] = 2927 THEN NULL ELSE e.[Price] END AS Price,
            e.[Amount],
            e.from_dt,
            e.to_dt
    INTO #CalElectric
    FROM MAS_Service_Receivable a
    JOIN MAS_Service_Living_Tracking  b ON a.srcId      = b.TrackingId
    JOIN MAS_Service_Living_CalSheet  e ON b.TrackingId = e.TrackingId
    WHERE a.ReceiveId     = @receiveId
      AND a.ServiceTypeId = 3
      AND b.LivingTypeId  = 1;

    ----------------------------------------------------------------
    -- Xác định tháng đang tính (dựa trên from_dt của chi tiết điện)
    ----------------------------------------------------------------
    DECLARE @MonthStart DATE, @MonthEnd DATE;

    SELECT  @MonthStart = DATEFROMPARTS(YEAR(MIN(from_dt)), MONTH(MIN(from_dt)), 1),
            @MonthEnd   = EOMONTH(MIN(from_dt))
    FROM #CalElectric;

    ----------------------------------------------------------------
    -- Tìm ngày hết hiệu lực trong tháng nếu par_electric có >= 2 bản ghi
    ----------------------------------------------------------------
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

    ----------------------------------------------------------------
    -- Xuất kết quả:
    --   - Không có @SplitDate  : 1 bảng (giống cũ)
    --   - Có @SplitDate        : 2 bảng (2 result set)
    ----------------------------------------------------------------
    IF @SplitDate IS NULL
    BEGIN
        -- Không tách, trả 1 bảng duy nhất
        SELECT *
        FROM #CalElectric
        ORDER BY to_dt ASC;

		SELECT*
		FROM #CalElectric
		WHERE 1= 2
    END
    ELSE
    BEGIN
        -- Bảng 1: từ đầu tháng đến ngày hết hiệu lực đó
        SELECT *
        FROM #CalElectric
        WHERE to_dt <= @SplitDate
        ORDER BY to_dt ASC;

        -- Bảng 2: từ sau ngày hết hiệu lực đến cuối tháng
        SELECT *
        FROM #CalElectric
        WHERE from_dt > @SplitDate
        ORDER BY to_dt ASC;
    END

	--4 Phí nước sử dụng
	SELECT top 1 [ReceivableId]
			,'Bang7' [Table]
		  ,a.[ReceiveId]
		  ,[ServiceTypeId]
		  ,[ServiceObject]
		  ,a.[Amount]
		  ,pe.vat as [VAT]
		  ,pe.environmental_fee AS EnvironmentalFee			-- Phi moi truong
		  ,pe.env_protection_tax ProtectionEnvironmentalFee	-- thue bao ve moi truong
		  ,CAST(ROUND(a.[Amount] * (pe.vat / 100), 0) AS DECIMAL(18,0)) AS VATAmt   	
		  ,CAST(ROUND(a.[Amount] * (pe.environmental_fee / 100), 0) AS DECIMAL(18,0)) AS EnvironmentalFeeAmt 		 
		  ,a.[TotalAmt]
		  , ISNULL(mr.TotalAmt,0) as PaidWaterFee
		  --,[fromDt]
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
		  --,pe.vat as VatE
		  --,pw.vat as VatW
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
	  WHERE  a.ReceiveId = @ReceiveId
		and a.ServiceTypeId = 4 and b.LivingTypeId = 2		
	  order by b.ToDt desc
	  	
	-- Chi tiết phí Nước sử dụng
	  IF OBJECT_ID('tempdb..#CalWater') IS NOT NULL 
        DROP TABLE #CalWater;
 
    SELECT 
            e.[Id],
            e.[TrackingId],
            a.ReceiveId,
            a.ServiceTypeId,
            e.[StepPos],
            CASE 
                WHEN (e.fromN = 400 AND e.toN IS NULL) THEN NULL
                ELSE N'Từ ' + CAST(e.fromN AS NVARCHAR(50))
                     + CASE 
                         WHEN e.toN IS NULL THEN N' trở lên'
                         ELSE N' - ' + CAST(e.toN AS NVARCHAR(9))
                       END
            END AS PriceRangeWater,
            e.[fromN],
            e.[toN],
            e.[Quantity],
            CASE WHEN e.[Price] = 2927 THEN NULL ELSE e.[Price] END AS Price,
            e.[Amount],
            e.from_dt,
            e.to_dt
    INTO #CalWater
    FROM MAS_Service_Receivable a
    JOIN MAS_Service_Living_Tracking  b ON a.srcId      = b.TrackingId
    JOIN MAS_Service_Living_CalSheet  e ON b.TrackingId = e.TrackingId
    WHERE a.ReceiveId     = @ReceiveId
      AND a.ServiceTypeId = 4
      AND b.LivingTypeId  = 2;

    ----------------------------------------------------------------
    -- Xác định tháng đang tính (dựa trên from_dt của chi tiết điện)
    ----------------------------------------------------------------

    SELECT  @MonthStart = DATEFROMPARTS(YEAR(MIN(from_dt)), MONTH(MIN(from_dt)), 1),
            @MonthEnd   = EOMONTH(MIN(from_dt))
    FROM #CalWater;

    ----------------------------------------------------------------
    -- Tìm ngày hết hiệu lực trong tháng nếu par_electric có >= 2 bản ghi
    ----------------------------------------------------------------
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

    ----------------------------------------------------------------
    -- Xuất kết quả:
    --   - Không có @SplitDate  : 1 bảng (giống cũ)
    --   - Có @SplitDate        : 2 bảng (2 result set)
    ----------------------------------------------------------------
    IF @SplitDate IS NULL
    BEGIN
        -- Không tách, trả 1 bảng duy nhất
        SELECT *
        FROM #CalWater
        ORDER BY to_dt ASC;

		SELECT*
		FROM #CalWater
		WHERE 1= 2
    END
    ELSE
    BEGIN
        -- Bảng 1: từ đầu tháng đến ngày hết hiệu lực đó
        SELECT *
        FROM #CalWater
        WHERE to_dt <= @SplitDate
        ORDER BY to_dt ASC;

        -- Bảng 2: từ sau ngày hết hiệu lực đến cuối tháng
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
		DECLARE	@ErrorNum				INT,
				@ErrorMsg				VARCHAR(200),
				@ErrorProc				VARCHAR(50),

				@SessionID				INT,
				@AddlInfo				VARCHAR(max)

		SET @ErrorNum					= error_number()
		SET @ErrorMsg					= 'sp_res_report_fee_notice ' + error_message()
		SET @ErrorProc					= error_procedure()
		   
		SET @AddlInfo					= ' '

		EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_res_report_fee_notice', 'GET', @SessionID, @AddlInfo
	END CATCH;