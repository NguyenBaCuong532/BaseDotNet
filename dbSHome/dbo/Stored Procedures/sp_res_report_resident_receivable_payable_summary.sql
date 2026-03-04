
-- =============================================
-- Author:		VuTc
-- Create date: 10/15/2025
-- Description:	bc Tổng hợp công nợ của khu dân cư / Resident
-- =============================================
CREATE   PROCEDURE [dbo].[sp_res_report_resident_receivable_payable_summary]
	@UserId				UNIQUEIDENTIFIER = NULL
	--,@FromDate			NVARCHAR(50) 	= '01/01/2025'		--NULL,
	--,@ToDate		    NVARCHAR(50)	= '30/11/2025'	--NULL,
	,@FromDate			DATETIME 	= '2025/01/01'		--NULL,
	,@ToDate		    DATETIME	= '2025/11/30'	--NULL,
	,@AcceptLanguage	VARCHAR(20)	= 'vi-VN'
	,@ProjectCd			NVARCHAR(30)	= '04'
	,@BuildingCd		NVARCHAR(MAX)	= NULL --N''				-- 'Sunshine Center',
	,@RoomCode			NVARCHAR(MAX)	= NULL				-- 'CH-0123'
	,@Total			INT = 1000 OUT
	,@TotalFiltered	INT = 0 OUT
	,@GridKey		NVARCHAR(100) = '' OUT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	--SELECT Oid, EmployeeID, FullName FROM dbo.EmployeeMaintenance WHERE EmployeeID = 'S 01119'
	SET NOCOUNT ON;

	DECLARE @messages NVARCHAR(MAX)
	DECLARE @FromDate2			DATETIME 	= @FromDate 
			,@ToDate2		    DATETIME  	= @ToDate

	IF(@BuildingCd	= '' OR @BuildingCd	IS NULL)	SET @BuildingCd	= NULL
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
			SELECT Id, BuildingCd, BuildingCd, ProjectName 
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
    WHERE 
    --re.ReceiveId = @receiveId AND
	re.IsDebt     = 1
	--AND re.ToDt BETWEEN '20251031' AND '20251031';
	ORDER BY re.ReceiveId, re.ToDt ASC

	--SELECT * FROM #CongNo

	/* Biên nhận hóa đơn */
	---------------------------------------------------------------------------------
			SELECT 'BienNhan' Bien_Nhan,
				[ReceiptId]
				,[ReceiptNo]
				,CONVERT(NVARCHAR(10), [ReceiptDt], 103) AS [ReceiptDate]
				,a.ReceiveId
				,a.TranferCd
				,[TranferName] = pm.name
				,ISNULL([Object], c.fullName) AS [Object]
				,ISNULL(a.[Pass_No], c.Pass_No) AS PassNo
				,A.[Address]
				,[Contents]
				,[Attach]
				,[IsDBCR]
				,a.Amount
				,u2.loginName AS [CreatorCd]
				,[CreateDate]
				,b.RoomCode
				,NoPhi		= CASE WHEN a.PaymentSection LIKE N'%Debt%' THEN a.Amount ELSE 0 END
				,PhiDichVu	= CASE WHEN a.PaymentSection LIKE N'%Common%' THEN a.Amount ELSE 0 END
				,PhiDien	= CASE WHEN a.PaymentSection LIKE N'%Electric%' THEN a.Amount ELSE 0 END
				,PhiNuoc	= CASE WHEN a.PaymentSection LIKE N'%Water%' THEN a.Amount ELSE 0 END
				,PhiGuiXe	= CASE WHEN a.PaymentSection LIKE N'%Vehicle%' THEN a.Amount ELSE 0 END
				,a.PaymentSection CacLoaiPhi
				,PaymentSection = (
					SELECT STRING_AGG(
						CASE TRIM(s.value)
							WHEN 'Common'   THEN N'Dịch vụ chung'
							WHEN 'Debt'     THEN N'Nợ phí'
							WHEN 'Electric' THEN N'Điện sinh hoạt'
	 						WHEN 'Water'    THEN N'Nước sạch'
							WHEN 'Vehicle'  THEN N'Phí gửi phương tiện'
							ELSE TRIM(s.value)
						END, ', ')
					FROM STRING_SPLIT(a.PaymentSection, ',') AS s
				)
			INTO #BienNhan
			FROM MAS_Service_ReceiveEntry d
			JOIN [dbo].MAS_Service_Receipts a ON d.ReceiveId = a.ReceiveId
			LEFT JOIN (SELECT code = value1, [name] = par_desc FROM sys_config_data WHERE key_1 = 'payment_method') pm ON pm.code = a.TranferCd
			LEFT JOIN MAS_Apartments b ON d.ApartmentId = b.ApartmentId
			LEFT JOIN MAS_Customers c ON a.CustId = c.CustId
			LEFT JOIN dbo.Users u2 ON a.CreatorCd = u2.UserId
			WHERE (@ProjectCd = '-1' OR b.projectCd = @ProjectCd)
			  --AND EXISTS(SELECT 1 FROM UserProject up WHERE up.userId = @UserId AND up.projectCd = @ProjectCd)
			  AND a.ReceiptDt BETWEEN CONVERT(DATETIME, @fromDate, 103) AND DATEADD(DAY, 1, CONVERT(DATETIME, @toDate, 103))
			ORDER BY a.[ReceiptDt] DESC

			--SELECT * FROM #BienNhan
	---------------------------------------------------------------------------------

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
			  ,b.RoomCode 
			  ,d.ReceiveId 
			  ,[Fast]	= ''		-- Để trống  isnull(a.[Pass_No],c.Pass_No)
			  ,FullName = ISNULL(a.[Object],c.fullName) 
			  ,DkPt		= ISNULL(cn.DebitFee,0)
			  ,DkDt		= 0
			  ,Pdv		= ISNULL(d.CommonFee,0)
			  ,Ddv		= ISNULL(bn.PhiDichVu,0)
			  ,Pvs		= 0								-- Để trống
			  ,Dvs		= 0								-- Để trống
			  ,Pxe		= ISNULL(d.VehicleAmt,0)
			  ,Dxe		= ISNULL(bn.PhiGuiXe,0)
			  ,Pdien	= CASE WHEN sl.LivingTypeId = 1 THEN lt.Amount ELSE 0 END
			  ,Ddien	= CASE WHEN sl.LivingTypeId = 1 AND lt.IsReceivable = 1 THEN lt.Amount ELSE 0 END
			  ,Dien2	= ISNULL(bn.PhiDien,0)
			  ,Pnuoc	= CASE WHEN sl.LivingTypeId = 2 THEN lt.Amount ELSE 0 END
			  ,Dnuoc	= CASE WHEN sl.LivingTypeId = 2 AND lt.IsReceivable = 1 THEN lt.Amount ELSE 0 END
			  ,Nuoc2	= ISNULL(bn.PhiNuoc,0)
			  ,Ptc		= 0
			  ,Dtc		= 0
			  ,[ReceiptDate] = CONVERT(nvarchar(10),[ReceiptDt],103) 
		INTO #temp
		FROM MAS_Service_ReceiveEntry d
		JOIN [dbo].MAS_Service_Receipts a on d.ReceiveId = a.ReceiveId
        LEFT JOIN (select code = value1, [name] = par_desc from sys_config_data where key_1 = 'payment_method') pm ON pm.code = a.TranferCd
		LEFT JOIN MAS_Apartments b on d.ApartmentId = b.ApartmentId
		LEFT JOIN MAS_Apartment_Service_Living sl on sl.ApartmentId = d.ApartmentId
		LEFT JOIN (SELECT * FROM MAS_Service_Living_Tracking WHERE PeriodMonth = MONTH(@ToDate2) AND PeriodYear = YEAR(@ToDate2)) lt ON lt.LivingId = sl.LivingId  
		LEFT JOIN MAS_Customers c on a.CustId= c.CustId
		LEFT JOIN dbo.Users u2 on a.CreatorCd = u2.UserId 
		LEFT JOIN MAS_Rooms m ON m.RoomCode = b.RoomCode
		LEFT JOIN #BienNhan bn ON bn.ReceiveId = d.ReceiveId
		LEFT JOIN #CongNo   cn ON cn.ReceiveId = d.ReceiveId
		INNER JOIN #Buildings bd ON bd.BuildingCd	= m.BuildingCd
		INNER JOIN #MAS_Rooms mr ON mr.RoomCode		= b.RoomCode
		OUTER APPLY (
						SELECT SUM(ISNULL(pd.unit_price, 0)) AS TotalVehicleFee
						FROM VehicleRank vr
						OUTER APPLY (
										SELECT TOP 1 pd.unit_price
										FROM par_vehicle_detail pd
										WHERE pd.vehicleTypeId = vr.VehicleTypeId
										AND vr.vehicle_order BETWEEN pd.start_value AND pd.end_value
										ORDER BY pd.start_value
									) pd
						WHERE vr.ApartmentId = b.ApartmentId
					) v
		WHERE (a.ReceiptDt between convert(datetime,@fromDate,103) and dateadd(day,1,convert(datetime,@toDate,103)))  
		/*	AND (@ProjectCd IS NULL or b.projectCd = @ProjectCd)
		AND (@BuildingCd IS NULL or @BuildingCd IS NOT NULL)
		AND (@RoomCode IS NULL OR b.RoomCode = @RoomCode)
		ORDER BY a.[ReceiptDt] DESC */

		CREATE INDEX temp ON #temp(Fast)

		--SELECT * FROM #temp

		SELECT BuildingCd, RoomCode, Fast, FullName, ReceiptDate
		, DkPt	 = SUM(DkPt)
		, DkDt	 = SUM(DkDt)
		, Pdv	 = SUM(Pdv)
		, Ddv	 = SUM(Ddv)
		, Pvs	 = SUM(Pvs)
		, Dvs	 = SUM(Dvs)
		, Pxe	 = SUM(Pxe)
		, Dxe	 = SUM(Dxe)
		, Pdien	 = SUM(Pdien)
		, Ddien	 = SUM(Ddien)
		, Pnuoc	 = SUM(Pnuoc)
		, Dnuoc	 = SUM(Dnuoc)
		, Ptc	 = SUM(Ptc)
		, Dtc	 = SUM(Dtc)
		FROM #temp 
		GROUP BY BuildingCd, RoomCode, Fast, FullName, ReceiptDate
		--ORDER BY ReceiptDate DESC
	END TRY


	BEGIN CATCH
	DECLARE	@ErrorNum				INT,
			@ErrorMsg				VARCHAR(200),
			@ErrorProc				VARCHAR(50),

			@SessionID				INT,
			@AddlInfo				VARCHAR(max)

	SET		@ErrorNum				= error_number()
	SET		@ErrorMsg				= 'sp_bzz_report_resident_receivable_payable_summary' + error_message()
	SET		@ErrorProc				= error_procedure()

	SET		@AddlInfo				= ' '

	EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_bzz_report_resident_receivable_payable_summary', 'GET', @SessionID, @AddlInfo
	END CATCH
END;