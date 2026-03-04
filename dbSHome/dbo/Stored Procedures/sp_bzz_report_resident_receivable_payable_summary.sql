
-- =============================================
-- Author:		VuTc
-- Create date: 10/15/2025
-- Description:	bc Tổng hợp công nợ của khu dân cư / Resident
-- =============================================
CREATE PROCEDURE [dbo].[sp_bzz_report_resident_receivable_payable_summary]
	@userId				NVARCHAR(450)	= NULL
	,@FromDate			NVARCHAR(50) 	= '01/01/2021'		--NULL,
	,@ToDate		    NVARCHAR(50)	= '31/01/2022'	--NULL,
	,@acceptLanguage	NVARCHAR(50)	= 'vi-VN'
	,@ProjectCd			NVARCHAR(30)	= NULL
	,@BuildingName		NVARCHAR(MAX)	= NULL				-- 'Sunshine Center',
	,@RoomCode			NVARCHAR(MAX)	= NULL				-- 'CH-0123'

AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	--SELECT Oid, EmployeeID, FullName FROM dbo.EmployeeMaintenance WHERE EmployeeID = 'S 01119'
	SET NOCOUNT ON;

	DECLARE @messages NVARCHAR(MAX)
	DECLARE @GridKey NVARCHAR(250)
	DECLARE @Total INT
	DECLARE @FromDate2			DATETIME 	= CONVERT(DATETIME,@FromDate,103) 
			,@ToDate2		    DATETIME  	= CONVERT(DATETIME,@ToDate,103)

	IF(@BuildingName	= '' OR @BuildingName	IS NULL)	SET @BuildingName	= NULL
	IF(@RoomCode		= '' OR @RoomCode		IS NULL)	SET @RoomCode		= NULL
	IF(@ProjectCd		= '' OR @ProjectCd		IS NULL)	SET @ProjectCd		= NULL

	BEGIN TRY	
		CREATE TABLE #Buildings(Id INT, BuildingCd NVARCHAR(50), BuildingName NVARCHAR(50), ProjectName NVARCHAR(150))
		IF(ISNULL(@BuildingName, '0') <> '0')
		BEGIN
			INSERT INTO #Buildings(BuildingName)
			SELECT CAST(data AS NVARCHAR(50)) BuildingName		
			FROM dbo.fn_TKM_ALL_1000_Split(@BuildingName, ',')
		END
		ELSE
		BEGIN
			INSERT INTO #Buildings(Id, BuildingCd, BuildingName, ProjectName)
			SELECT Id, BuildingCd, BuildingName, ProjectName 
			FROM MAS_Buildings
		END
		CREATE INDEX IX_Buildings ON #Buildings(Id, BuildingName)
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
				SELECT RoomCode, BuildingCd	
				FROM MAS_Rooms 
				ORDER BY RoomCode, BuildingCd
			END
		CREATE INDEX MAS_Rooms ON #MAS_Rooms(RoomCode, BuildingCd)
	
	--SELECT  * FROM #MAS_Rooms

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
			  --,[ReceiptNo] as [Fast]
			  ,[Fast] = isnull(a.[Pass_No],c.Pass_No)
			   ,isnull([Object],c.fullName) as FullName
			  ,Pdv		= ISNULL(d.CommonFee,0)
			  ,Ddv		= 0
			  ,Pvs		= 0
			  ,Dvs		= 0
			  ,Pxe		= ISNULL(d.VehicleAmt,0)
			  ,Dxe		= 0
			  ,Pdien	= CASE WHEN sl.LivingTypeId = 1 THEN lt.Amount ELSE 0 END
			  ,Ddien	= CASE WHEN sl.LivingTypeId = 1 AND lt.IsReceivable = 1 THEN lt.Amount ELSE 0 END
			  ,Pnuoc	= CASE WHEN sl.LivingTypeId = 2 THEN lt.Amount ELSE 0 END
			  ,Dnuoc	= CASE WHEN sl.LivingTypeId = 2 AND lt.IsReceivable = 1 THEN lt.Amount ELSE 0 END
			  ,Ptc		= 0
			  ,Dtc		= 0
			  ,convert(nvarchar(10),[ReceiptDt],103) as [ReceiptDate]
			  
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
		OUTER APPLY (
					SELECT 
						SUM(ISNULL(pd.unit_price, 0)) AS TotalVehicleFee
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
		
		WHERE (@BuildingName IS NULL or @BuildingName IS NOT NULL) 
		AND (@ProjectCd IS NULL or b.projectCd = @ProjectCd)
		AND (a.ReceiptDt between convert(datetime,@fromDate,103) and dateadd(day,1,convert(datetime,@toDate,103)))
		AND (@RoomCode IS NULL OR b.RoomCode = @RoomCode)
		--ORDER BY a.[ReceiptDt] DESC 

		CREATE INDEX temp ON #temp(Fast)

		--SELECT * FROM #temp

		SELECT BuildingCd, RoomCode, Fast, FullName, ReceiptDate
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
END
/*	
			  ,sl.LivingTypeId
			  ,d.[ProjectCd]
			  ,ReceiptDt = FORMAT(a.ReceiptDt,'dd/mm/yyyy')
			  ,a.[ApartmentId]
			  ,a.ReceiveId
			  ,a.TranferCd
              , [TranferName] = pm.name
			  ,isnull(a.[Pass_No],c.Pass_No) as PassNo
			  ,A.[Address]
			  ,[Contents]
			  ,[Attach]
			  ,[IsDBCR]
			  ,a.[Amount]
			  ,u2.loginName AS [CreatorCd]
			  ,a.ReceiptBillViewUrl
			  */