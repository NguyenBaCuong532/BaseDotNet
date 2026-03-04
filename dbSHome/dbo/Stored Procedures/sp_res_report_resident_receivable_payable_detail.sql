
-- =============================================
-- Author:		VuTc
-- Create date: 11/3/2025 9:48:13 AM
-- Description:	bc Chi tiết công nợ của khu dân cư / Resident
-- =============================================
CREATE   PROCEDURE [dbo].[sp_res_report_resident_receivable_payable_detail]
	 @userId				UNIQUEIDENTIFIER	= NULL
	,@acceptLanguage	NVARCHAR(50)	= 'vi-VN'
	,@FromDate			DATETIME 	= '2025/11/01'		-- '01/11/2025',
	,@ToDate		    DATETIME	= '2025/11/30'		-- '30/11/2025',
	,@ProjectCd			NVARCHAR(30)	= NULL
	,@BuildingCd		NVARCHAR(MAX)	= NULL				-- 'Sunshine Center',
	,@RoomCode			NVARCHAR(MAX)	= NULL				-- 'CH-0123'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @messages NVARCHAR(MAX)
	DECLARE @GridKey NVARCHAR(250)
	DECLARE @Total INT
	DECLARE @FromDate2		DATE 	= @FromDate
		,@ToDate2		    DATE  	= @ToDate

	IF(@BuildingCd		= '' OR @BuildingCd	IS NULL)	SET @BuildingCd	= NULL
	IF(@RoomCode		= '' OR @RoomCode		IS NULL)	SET @RoomCode		= NULL
	IF(@ProjectCd		= '' OR @ProjectCd		IS NULL)	SET @ProjectCd		= NULL

	BEGIN TRY	
		CREATE TABLE #Buildings(Id INT, BuildingCd NVARCHAR(50), BuildingName NVARCHAR(50), ProjectName NVARCHAR(150))
		IF(ISNULL(@BuildingCd, '0') <> '0')
		BEGIN
			INSERT INTO #Buildings(BuildingCd)
			SELECT CAST(data AS NVARCHAR(50)) BuildingCd		
			FROM dbo.fn_TKM_ALL_1000_Split(@BuildingCd, ',')
		END
		ELSE
		BEGIN
			INSERT INTO #Buildings(Id, BuildingCd, BuildingName, ProjectName)
			SELECT Id, BuildingCd, BuildingName, ProjectName 
			FROM MAS_Buildings
		END
		CREATE INDEX IX_Buildings ON #Buildings(Id, BuildingCd)
		--SELECT * FROM #Buildings

		CREATE TABLE #MAS_Rooms (RoomCode NVARCHAR(50), BuildingCd NVARCHAR(50))
		IF(ISNULL(@RoomCode, '0') <> '0')
			BEGIN
			INSERT INTO #MAS_Rooms(RoomCode)
			SELECT CAST(data AS NVARCHAR(50)) RoomCode
			FROM dbo.fn_TKM_ALL_1000_Split(@RoomCode, ',')	
			END
		ELSE
			BEGIN
				INSERT INTO #MAS_Rooms(RoomCode, BuildingCd)
				SELECT a.RoomCode, b.BuildingCd	
				FROM MAS_Apartments a
				LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
				ORDER BY a.RoomCode, b.BuildingCd
			END
		CREATE INDEX MAS_Rooms ON #MAS_Rooms(RoomCode, BuildingCd)
	
	--SELECT  * FROM #MAS_Rooms

		/*	Tính công nợ	*/
	SELECT	'CongNo' CongNo, re.ReceiveId, re.ApartmentId, re.ToDt
			   ,CommonFee = ISNULL(re.CommonFee, 0)
               ,VehicleFee = ISNULL(re.VehicleAmt, 0)
               ,ElectricFee = ISNULL(re.LivingElectricAmt, 0)
               ,WaterFee = ISNULL(re.LivingWaterAmt, 0)
               ,DebitFee = CASE WHEN apt.AptDebit > 0 THEN apt.AptDebit ELSE ISNULL(re.TotalAmt, 0)END
               ,Note = CASE WHEN EXISTS (SELECT 1 FROM MAS_Service_Receipts r 
										WHERE r.ReceiveId = re.receiveId AND r.PaymentSection LIKE '%Debt%') 
							THEN N'Đã thanh toán' ELSE N'' END
    INTO #CongNo
	FROM   MAS_Service_ReceiveEntry re  
    OUTER APPLY (
					SELECT ISNULL(DebitAmt, 0) AS AptDebit 
					FROM MAS_Apartments 
					WHERE ApartmentId = re.ApartmentId
				) apt
    WHERE re.IsDebt     = 1
	ORDER BY re.ReceiveId, re.ToDt ASC

	--SELECT * FROM #CongNo

	;WITH VehicleRank AS (
			SELECT 
				a.CardVehicleId,
				a.ApartmentId,
				a.VehicleTypeId,
				ROW_NUMBER() OVER (
					PARTITION BY a.ApartmentId, a.VehicleTypeId 
					ORDER BY a.AssignDate
				) AS vehicle_order
			FROM MAS_CardVehicle a
		)

		--1 profile
		SELECT DISTINCT m.BuildingCd
			  ,a.RoomCode 
			  ,e.ReceiveId
			  ,[Fast]   = ISNULL(sr.[Pass_No],c.Pass_No)
			  ,FullName = ISNULL([Object],c.fullName) 
			  ,Pdv		= ISNULL(e.CommonFee,0)
			  ,Pxe		= ISNULL(TienXe.VehicleAmt,0)		--Phí gửi xe
			  ,Pdien	= ISNULL(TienDien.ElectricAmt,0)	--Tiền điện
			  ,Ddien	= CASE WHEN sl.LivingTypeId = 1 AND lt.IsReceivable = 1 THEN lt.Amount ELSE 0 END
			  ,Pnuoc	= ISNULL(TienNuoc.WaterAmt,0)		--Tiền nước
			  ,Dnuoc	= CASE WHEN sl.LivingTypeId = 2 AND lt.IsReceivable = 1 THEN lt.Amount ELSE 0 END
			  ,Ptc		= 0
			  ,khac		= ISNULL(e.ExtendAmt,0)				-- Phí khác
			  ,DebitAmt = ISNULL(e.DebitAmt,0)				-- Công nợ chung
			  ,convert(nvarchar(10),[ReceiptDt],103) as [ReceiptDate]
		INTO #temp
		FROM MAS_Service_ReceiveEntry e
		JOIN MAS_Apartments a on a.ApartmentId = e.ApartmentId
		LEFT JOIN UserInfo u ON u.loginName = a.UserLogin
		LEFT JOIN MAS_Customers c on c.CustId = u.CustId
		JOIN [dbo].MAS_Service_Receipts sr on sr.ReceiveId = e.ReceiveId
        LEFT JOIN (select code = value1, [name] = par_desc from sys_config_data where key_1 = 'payment_method') pm ON pm.code = sr.TranferCd
		OUTER APPLY(SELECT SUM(TotalAmt) AS VehicleAmt FROM MAS_Service_Receivable sr WHERE sr.ReceiveId = e.ReceiveId AND sr.ServiceTypeId = 2) TienXe
        OUTER APPLY(SELECT SUM(TotalAmt) AS ElectricAmt FROM MAS_Service_Receivable sr WHERE sr.ReceiveId = e.ReceiveId AND sr.ServiceTypeId = 3) TienDien
        OUTER APPLY(SELECT SUM(TotalAmt) AS WaterAmt FROM MAS_Service_Receivable sr WHERE sr.ReceiveId = e.ReceiveId AND sr.ServiceTypeId = 4) TienNuoc
		LEFT JOIN MAS_Apartment_Service_Living sl on sl.ApartmentId = e.ApartmentId
		LEFT JOIN (SELECT * FROM MAS_Service_Living_Tracking WHERE PeriodMonth = MONTH(@ToDate2) AND PeriodYear = YEAR(@ToDate2)) lt ON lt.LivingId = sl.LivingId  
		LEFT JOIN MAS_Rooms m ON m.RoomCode = a.RoomCode
		LEFT JOIN dbo.Users u2 on sr.CreatorCd = u2.UserId 
		LEFT JOIN MAS_Projects p ON a.projectCd = p.projectCd
		INNER JOIN #Buildings bd ON bd.BuildingCd	= m.BuildingCd
		INNER JOIN #MAS_Rooms mr ON mr.RoomCode		= a.RoomCode
		WHERE (sr.ReceiptDt between @fromDate and dateadd(day,1,@toDate))
		/*	AND (@ProjectCd IS NULL or a.projectCd = @ProjectCd)
		AND (@BuildingCd IS NULL OR m.RoomCode = @BuildingCd)
		AND (@RoomCode IS NULL OR a.RoomCode = @RoomCode)	*/
		--AND (sr.ReceiptDt between convert(datetime,@fromDate,103) and dateadd(day,1,convert(datetime,@toDate,103)))
		--ORDER BY a.[ReceiptDt] DESC 

		CREATE INDEX temp ON #temp(Fast)

		--SELECT * FROM #temp

		SELECT ReceiveId, BuildingCd, RoomCode, FullName
		, Pdv	 = SUM(Pdv)
		, xe	 = SUM(Pxe)
		, dien	 = SUM(Pdien)
		, nuoc	 = SUM(Pnuoc)
		, Ptc	 = SUM(Ptc)
		INTO #tonghop
		FROM #temp 
		GROUP BY ReceiveId, BuildingCd, RoomCode, FullName

	-- Data 0: Tổng hợp báo cáo công nợ
			SELECT 'Data0' Data0 , BuildingCd
					,RoomCode
					,FullName
					,Pdv
					,xe
					,dien
					,nuoc
					,Ptc 
					,sddk		= 0				--(4)
					,khac		= 0
					,tong		= 0				--(11)
					,ptlk		= 0 + 0			--(12=4+11)
					,sttt		= 0				--(13)
					,congnoconlai	 = 0		--(14=12-13)
					,Note	 = ''	  
		FROM #tonghop;

			-- Data 1: BC  XE THÁNG	--------------------------------------------------------------------
			WITH RankedVehicles AS (
				SELECT 
					a.ReceiveId,
					c.VehicleTypeId,
					b.VehicleName,
					b.VehicleNo,
					TongTien = FORMAT(a.TotalAmt,'#,###,###,###'),
					ROW_NUMBER() OVER (
						PARTITION BY a.ReceiveId, c.VehicleTypeId 
						ORDER BY b.CardVehicleId
					) AS Seq
				FROM MAS_Service_Receivable a
				JOIN MAS_CardVehicle b ON a.srcId = b.CardVehicleId
				JOIN MAS_VehicleTypes c ON b.VehicleTypeId = c.VehicleTypeId
				WHERE a.ServiceTypeId = 2
				  --AND a.ReceiveId = 195127
			)
			SELECT 
				ReceiveId,
				ISNULL(MAX(CASE WHEN VehicleTypeId = 1 AND Seq = 1 THEN TongTien END), '0') AS [Car1],
				ISNULL(MAX(CASE WHEN VehicleTypeId = 1 AND Seq = 2 THEN TongTien END), '0') AS [Car2],
				ISNULL(MAX(CASE WHEN VehicleTypeId = 2 AND Seq = 1 THEN TongTien END), '0') AS [Motor1],
				ISNULL(MAX(CASE WHEN VehicleTypeId = 2 AND Seq = 2 THEN TongTien END), '0') AS [Motor2],
				ISNULL(MAX(CASE WHEN VehicleTypeId = 2 AND Seq = 3 THEN TongTien END), '0') AS [Motor3],

				ISNULL(MAX(CASE WHEN VehicleTypeId = 3 THEN TongTien END), '0') AS [MotorElec],
				ISNULL(MAX(CASE WHEN VehicleTypeId = 4 THEN TongTien END), '0') AS [BicycleElec],
				ISNULL(MAX(CASE WHEN VehicleTypeId = 5 THEN TongTien END), '0') AS [Bicycle]
			INTO #RankedVehicles1
			FROM RankedVehicles
			GROUP BY ReceiveId;

		SELECT	DISTINCT 'Data1' Data1, m.BuildingCd
				  ,a.RoomCode 
				  ,FullName = isnull(sr.[Object],c.fullName)
				  ,xe1 = Car1
				  ,xe2 = Car2
				  ,xemay1_2 = Motor1 + Motor2
				  ,xemay3 = Motor3
				  ,xemaydien = MotorElec
				  ,xedapdien = BicycleElec
				  ,xedap = Bicycle 
				  ,thanhtien	= Car1+ Car2+ Motor1+ Motor2+ Motor3+ MotorElec+ BicycleElec+ Bicycle
				  ,sddk			= 0
				  ,tongtt		= 0
				  ,sotientt		= 0
				  ,congnoconlai = 0      
		FROM #RankedVehicles1 r
		LEFT JOIN MAS_Service_ReceiveEntry e ON r.ReceiveId = e.ReceiveId
		JOIN MAS_Apartments a on a.ApartmentId = e.ApartmentId
		LEFT JOIN UserInfo u ON u.loginName = a.UserLogin
		LEFT JOIN MAS_Customers c on c.CustId = u.CustId
		JOIN [dbo].MAS_Service_Receipts sr on sr.ReceiveId = e.ReceiveId
		INNER JOIN MAS_Rooms m ON m.RoomCode = a.RoomCode
		--INNER JOIN #Buildings bd ON bd.BuildingCd	= m.BuildingCd
		--INNER JOIN #MAS_Rooms mr ON mr.RoomCode		= a.RoomCode
		ORDER BY m.BuildingCd, a.RoomCode, FullName

	-- Data 2: BC PHÍ DV	--------------------------------------------------------------------
			SELECT 'Data2' Data2, BuildingCd
							,RoomCode
							,FullName
							,dientich	  = 0
							,dongia		  = 0
							,thanhtien	  = 0
							,sddk		  = 0
							,tongtt		  = 0
							,sttt		  = 0
							,cncl		  = 0
							,note		  = ''
			FROM #tonghop

	-- Data 3: BC DT NƯỚC	--------------------------------------------------------------------
	SELECT DISTINCT 'Data3' Data3,[ReceivableId]
			  ,a.[ReceiveId]
			  ,t.RoomCode
			  ,t.FullName
			  ,CAST(ROUND(a.[Amount] * (pe.vat / 100), 0) AS DECIMAL(18,0)) AS VATAmt   	
			  ,CAST(ROUND(a.[Amount] * (pe.environmental_fee / 100), 0) AS DECIMAL(18,0)) AS EnvironmentalFeeAmt 		 
			  ,a.[TotalAmt]
			  , ISNULL(mr.TotalAmt,0) as PaidWaterFee
			  ,convert(nvarchar(10),b.[ToDt],103) as ToDate
			  ,[srcId] as TrackingId
			  ,d.LivingTypeName loaicongto
			  ,c.MeterSeri as macongto
			  ,b.FromNum tuso
			  ,b.ToNum denso
			  ,b.TotalNum tongso
			  ,c.LivingTypeId
			  ,a.Price thanhtien
			  ,a.Quantity
			  ,a.[Amount]
			  ,pe.vat as [VAT]
			  ,pe.environmental_fee AS EnvironmentalFee			-- Phi moi truong
			  ,pe.env_protection_tax ProtectionEnvironmentalFee	-- thue bao ve moi truong
			  ,b.ToDt
			  ,sddk			 = 0
			,tongtt			 = 0
			,sotientt		 = 0
			,sdck			 = 0
			,note            = ''   
		  FROM [MAS_Service_Receivable] a
			join MAS_Service_Living_Tracking b on a.srcId = b.TrackingId
			join MAS_Apartment_Service_Living c on b.LivingId = c.LivingId
			join par_water pw on pw.project_code = c.ProjectCd
			join MAS_LivingTypes d on c.LivingTypeId = d.LivingTypeId
			JOIN #tonghop t ON t.ReceiveId = a.ReceiveId
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
		  WHERE  a.ServiceTypeId = 4 and b.LivingTypeId = 2		
		  order by b.ToDt desc

-- Data 4: BC DT ĐIỆN	--------------------------------------------------------------------
		SELECT DISTINCT 'Data4' Data4,[ReceivableId]
		  ,a.ReceiveId
		  ,t.RoomCode
		  ,t.FullName
		  ,b.[ToDt]
		  , ISNULL(mr.TotalAmt,0) AS PaidElectricFee
		  ,CONVERT(NVARCHAR(10),b.[ToDt],103) AS ToDate
		  ,[srcId] AS TrackingId
		  ,d.LivingTypeName loaicongto
		  ,c.MeterSeri AS macongto
		  ,b.FromNum tuso
		  ,b.ToNum denso
		  ,b.TotalNum tongso
		  ,c.LivingTypeId
		  ,a.Price thanhtien
		  ,a.[Amount]
		  ,pe.vat AS [VAT]
		  ,a.[VATAmt]
		  ,a.TotalAmt
		,sddk			= 0
		,tongtt			= 0
		,sttt			= 0
		,sdck			= 0
		,Note           = ''  
	  FROM [MAS_Service_Receivable] a
		JOIN MAS_Service_Living_Tracking b ON a.srcId = b.TrackingId
		JOIN MAS_Apartment_Service_Living c ON b.LivingId = c.LivingId
		JOIN MAS_LivingTypes d ON c.LivingTypeId = d.LivingTypeId
		JOIN #tonghop t ON t.ReceiveId = a.ReceiveId
		--LEFT JOIN MAS_Apartments b on d.ApartmentId = b.ApartmentId
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
	  WHERE  ServiceTypeId = 3 AND b.LivingTypeId = 1
	  ORDER BY t.RoomCode ASC ,b.[ToDt] DESC
	
	END TRY


	BEGIN CATCH
	DECLARE	@ErrorNum				INT,
			@ErrorMsg				VARCHAR(200),
			@ErrorProc				VARCHAR(50),

			@SessionID				INT,
			@AddlInfo				VARCHAR(max)

	SET		@ErrorNum				= error_number()
	SET		@ErrorMsg				= 'sp_res_report_resident_receivable_payable_detail' + error_message()
	SET		@ErrorProc				= error_procedure()

	SET		@AddlInfo				= ' '

	EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_res_report_resident_receivable_payable_detail', 'GET', @SessionID, @AddlInfo
	END CATCH
END;