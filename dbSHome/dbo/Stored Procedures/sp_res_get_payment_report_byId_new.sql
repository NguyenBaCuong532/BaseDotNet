
CREATE procedure [dbo].[sp_res_get_payment_report_byId_new]
	@userId	nvarchar(450) = null ,
	@receiveId int =   159613
as
	begin try
	declare @ApartmentId int 
	declare @ProjectCd nvarchar(50) = ''
	declare @DiscountElecAmt decimal(18,0)
	declare @DiscountWaterAmt decimal(18,0)
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

	--set @receiveId = 933
	--0 - Thong tin chung
	SELECT a.ReceiveId
		      ,a.entryId
			  ,cast(month(a.ToDt) as varchar) [PeriodMonth]
			  ,cast(year(a.ToDt) as varchar) [PeriodYear]
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceivableDate
			  --,TotalAmt as [TotalAmt]
			  ,convert(nvarchar(10),a.[ExpireDate],103) as [ExpireDate]
			  ,a.[IsPayed]
			  --,convert(nvarchar(10),a.FromDt,103) as fromDate
			  ,convert(nvarchar(10),a.ToDt,103) as toDate
			  ,a.ToDt as tDate
			  ,case when a.IsPayed = 1 then N'Đã thanh toán' else N'Chờ thanh toán' end as StatusPayed
			  ,isnull(a.Remart,N'Hóa đơn T' + cast(month(a.ToDt) as varchar) + N'/' + cast(year(a.ToDt) as varchar)) as Remarks
			  ,isnull(a.Remart,N'Hóa đơn tháng ' + cast(month(a.ToDt) as varchar) + N' năm ' + cast(year(a.ToDt) as varchar)) as Remark 
			  ,b.RoomCode
			  ,c.FullName
			  ,b.WaterwayArea
			  ,p.Price
			  --,isnull(v.projectName,isnull(v.projectName,(select top 1 projectCd from dbSCRM.dbo.BLD_Projects where projectCd = (isnull(v.projectCd,b.projectCd))))) as ProjectName
			  --,isnull(v.projectCd,b.projectCd) +'-'+ isnull(v.projectName,(select top 1 projectName from dbSCRM.dbo.BLD_Projects where projectCd = (isnull(v.projectCd,b.projectCd)))) as projectFolder
			  --,isnull(v.projectCd,b.projectCd) as ProjectCd
			  --,isnull(v.buildingName,(select top 1 buildingName from dbSCRM.dbo.BLD_Buildings where buildingName = b.buildingCd)) as BuildingNo
			  ,ISNULL(pro.projectName,'')  as ProjectName
			  ,ISNULL(b.projectCd,'') + '-' + ISNULL(pro.projectName,'') AS projectFolder
			  ,ISNULL(b.projectCd,'') as ProjectCd
			  ,ISNULL(bui.BuildingName,'') as BuildingNo
			  ,cast(month(a.ToDt) as varchar) as MonthLiving
			  ,cast(month(Dateadd(month,1,a.ToDt)) as varchar) as MonthVehicleFee
			  ,bk.Bank_Acc_Num as Bank_Acc_Num
			  ,bk.Bank_Acc_Name as Bank_Acc_Name
			  ,bk.Bank_Acc_Branch as Bank_Acc_Branch
			  ,b.DebitAmt + a.CreditAmt as CurrBal
			  ,format(isnull(a.TotalAmt,0),'#,###,###,###') as TotalAmt
			  ,dbo.Num2Text(isnull(a.TotalAmt,0)) as TotalAmtText
			  ,format(isnull(@DiscountElecAmt,0),'#,###,###,###') as DiscountElecAmt
			  ,format(isnull(@DiscountWaterAmt,0),'#,###,###,###') as DiscountWaterAmt
			  ,bk.Bank_Code
			  ,bk.bank_cif_no AS prefix
			  ,CAST(
					CONCAT(
						FORMAT(GETDATE(), 'ddMMyy'),  -- 6 chữ số đầu: DDMMYY
						RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR(6)), 6)  -- 6 số ngẫu nhiên
					) AS BIGINT
				) AS virtualPartNum
			  ,ISNULL(a.TotalAmt,0) as TransactionAmt
			  ,b.RoomCode + ' THANH TOAN TIEN PHI THANG ' + cast(month(a.ToDt) as varchar) + ' NAM ' + cast(year(a.ToDt) as varchar) as TransContent
	  FROM  [dbo].MAS_Service_ReceiveEntry a 
			left JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
			LEFT JOIN MAS_Buildings bui On b.buildingOid = bui.oid 
			LEFT JOIN dbo.MAS_Projects pro ON pro.projectCd = b.projectCd AND pro.sub_projectCd = b.sub_projectCd
			--left join dbSCRM.dbo.viewRoom v on isnull(t.RoomCodeView,t.RoomCode) = v.Code
			left join MAS_Service_Bank bk on b.projectCd = bk.ProjectCd
			left join PAR_ServicePrice p on b.projectCd = p.ProjectCd and ServiceTypeId = 1
			left join UserInfo u on b.UserLogin = u.loginName 
			left join MAS_Customers c on u.CustId = c.CustId 
			--inner join dbSCRM.dbo.BLD_Projects pt on b.projectCd = pt.ProjectCd
			--inner join dbSCRM.dbo.BLD_Buildings k on b.buildingCd = k.buildingCd
		WHERE  a.ReceiveId = @ReceiveId



	--1 Olddebt Công nợ tồn cũ
	select isnull(t1.AmtService,0) as AmtService,
	   isnull(t1.ServiceFee,0) as ServiceFee,
		isnull(t1.ElectricFee,0) as ElectricFee,
		isnull(t1.WaterFee,0) as WaterFee,
		--format((isnull(t1.AmtService,0) + isnull(t1.ServiceFee,0) + isnull(t1.ElectricFee,0) + isnull(t1.WaterFee,0) + isnull(t1.DebitAmt,0)),'#,###,###,###') as DebitAmt
		format(isnull(t1.DebitAmt,0),'#,###,###,###') as DebitAmt
	from 
	(select 
	       --sum(isnull(sumAmt,0)) as OldDebt,
	       sum(case when ServiceTypeId = 1 then isnull(sumAmt,0) else 0 end) as AmtService,
	       sum(case when ServiceTypeId = 2 then isnull(sumAmt,0) else 0 end) as ServiceFee,
		   sum(case when ServiceTypeId = 3 and ServiceObject like N'%Điện sinh hoạt%'  then isnull(sumAmt,0) else 0 end) as ElectricFee,
		   sum(case when ServiceTypeId = 3 and ServiceObject like N'%Nước sinh hoạt%'  then isnull(sumAmt,0) else 0 end) as WaterFee,
		   sum(case when ServiceTypeId = 8 then isnull(sumAmt,0) else 0 end) as OldDebt,
		   (select isnull(DebitAmt,0) from MAS_Apartments where ApartmentId = @ApartmentId) as DebitAmt
	from (select a.ServiceTypeId,a.ServiceObject,
	       sum(isnull(a.TotalAmt,0)) sumAmt
	from MAS_Service_Receivable a inner join MAS_Service_ReceiveEntry b on a.ReceiveId = b.ReceiveId
	                              --inner join MAS_Service_Living_Tracking c on b.ApartmentId = c.ApartmentId
	where a.ReceiveId <> @receiveId and b.ApartmentId = @ApartmentId
	group by a.ServiceTypeId,a.ServiceObject,b.IsPayed,a.srcId
	having isnull(b.IsPayed,0) = 0
	) as t) as t1

	--2 living Phí điện năng sử dụng
	SELECT top 1 [ReceivableId]
		  ,[ReceiveId]
		  ,[ServiceTypeId]
		  ,[ServiceObject]
		  ,a.[Amount]
		  ,pe.vat AS [VAT]
		  ,a.[VATAmt]
		  ,[TotalAmt]
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
		  --,a.ReceiveId
	  FROM [MAS_Service_Receivable] a
		join MAS_Service_Living_Tracking b on a.srcId = b.TrackingId
		join MAS_Apartment_Service_Living c on b.LivingId = c.LivingId
		join MAS_LivingTypes d on c.LivingTypeId = d.LivingTypeId
		OUTER APPLY(
			SELECT vat FROM par_electric where project_code = @ProjectCd
		) pe
	  WHERE  a.ReceiveId = @ReceiveId and ServiceTypeId = 3 and b.LivingTypeId = 1
	  order by b.[ToDt] desc
	

	--3 Chi tiết phí điện năng sử dụng 
	IF NOT EXISTS (
	SELECT 1
	FROM MAS_Service_Receivable a
	JOIN MAS_Service_Living_Tracking b ON a.srcId = b.TrackingId
	WHERE a.ReceiveId = @ReceiveId
	  AND a.ServiceTypeId = 3
	  AND b.LivingTypeId = 1
	)
	BEGIN
		SELECT 
			StepPos =ped.sort_order ,
			PriceRangeElectric = 
			CASE 
				WHEN (ped.start_value = 400 AND ped.end_value IS NULL) THEN NULL
				ELSE N'Từ ' + CAST(ped.start_value AS NVARCHAR(50))
					 + CASE 
						 WHEN ped.end_value IS NULL THEN N' trở lên'
						 ELSE N' - ' + CAST(ped.end_value AS NVARCHAR(9))
					   END
			END ,
			fromN = ped.start_value,
			toN = ped.end_value,
			Quantity = 0 ,
			Price = ped.unit_price,
			Amount = 0
		FROM par_electric pe
		JOIN par_electric_detail ped ON pe.oid = ped.par_electric_oid
		WHERE pe.project_code = @ProjectCd
		ORDER BY ped.sort_order asc
	END
	ELSE
	BEGIN
		SELECT 
			e.[Id],
			e.[TrackingId],
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
			a.ReceiveId,
			a.ServiceTypeId
		FROM MAS_Service_Receivable a
		JOIN MAS_Service_Living_Tracking b ON a.srcId = b.TrackingId
		JOIN MAS_Service_Living_CalSheet e ON b.TrackingId = e.TrackingId
		WHERE a.ReceiveId = @ReceiveId
		  AND a.ServiceTypeId = 3
		  AND b.LivingTypeId = 1
		ORDER BY b.[ToDt] DESC
	END;

		--4 Phí nước sử dụng
	SELECT top 1 [ReceivableId]
		  ,[ReceiveId]
		  ,[ServiceTypeId]
		  ,[ServiceObject]
		  ,a.[Amount]
		  ,pe.vat as [VAT]
		  ,pe.environmental_fee AS EnvironmentalFee
		  ,CAST(ROUND(a.[Amount] * (pe.vat / 100), 0) AS DECIMAL(18,0)) AS VATAmt   	
		  ,CAST(ROUND(a.[Amount] * (pe.environmental_fee / 100), 0) AS DECIMAL(18,0)) AS EnvironmentalFeeAmt 		 
		  ,[TotalAmt]
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
	  WHERE  a.ReceiveId = @ReceiveId
		and a.ServiceTypeId = 3 and b.LivingTypeId = 2
	  order by b.ToDt desc

	-- Chi tiết phí Nước sử dụng
	IF NOT EXISTS (
		SELECT 1
		FROM MAS_Service_Receivable a
		JOIN MAS_Service_Living_Tracking b ON a.srcId = b.TrackingId
		WHERE a.ReceiveId = @ReceiveId
		  AND a.ServiceTypeId = 3
		  AND b.LivingTypeId = 2
		)
		BEGIN
			SELECT 
				StepPos =pwd.sort_order ,
				PriceRangeWater = 
				CASE 
					WHEN (pwd.start_value = 400 AND pwd.end_value IS NULL) THEN NULL
					ELSE N'Từ ' + CAST(pwd.start_value AS NVARCHAR(50))
						 + CASE 
							 WHEN pwd.end_value IS NULL THEN N' trở lên'
							 ELSE N' - ' + CAST(pwd.end_value AS NVARCHAR(9))
						   END
				END ,
				fromN = pwd.start_value,
				toN = pwd.end_value,
				Quantity = 0 ,
				Price = pwd.unit_price,
				Amount = 0
			FROM par_water pw
			JOIN par_water_detail pwd ON pw.oid = pwd.par_water_oid
			WHERE pw.project_code = @ProjectCd
			ORDER BY pwd.sort_order asc
		END
		ELSE
		BEGIN
			SELECT 
				e.[Id],
				e.[TrackingId],
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
				a.ReceiveId,
				a.ServiceTypeId
			FROM MAS_Service_Receivable a
			JOIN MAS_Service_Living_Tracking b ON a.srcId = b.TrackingId
			JOIN MAS_Service_Living_CalSheet e ON b.TrackingId = e.TrackingId
			WHERE a.ReceiveId = @ReceiveId
			  AND a.ServiceTypeId = 3
			  AND b.LivingTypeId = 2
			ORDER BY b.[ToDt] DESC
		END;

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
	FROM (
    SELECT 
        c.VehicleTypeId,
        COUNT(c.VehicleTypeId) AS sumQ,
        SUM(ISNULL(pv.unit_price * a.Quantity, 0)) AS sumA
    FROM MAS_Service_Receivable a
    JOIN MAS_CardVehicle b ON a.srcId = b.CardVehicleId
    JOIN MAS_VehicleTypes c ON b.VehicleTypeId = c.VehicleTypeId
    CROSS APPLY (
        SELECT TOP 1 pd.unit_price
        FROM par_vehicle_detail pd
        WHERE pd.par_vehicle_oid = @Par_vehicle_oid
          AND pd.vehicleTypeId = c.VehicleTypeId
          AND (
              (pd.start_value <= ISNULL(b.VehicleNum, 1))
              AND (pd.end_value IS NULL OR pd.end_value >= ISNULL(b.VehicleNum, 1))
          )
        ORDER BY pd.sort_order
    ) AS pv
    WHERE 
        a.ReceiveId = @receiveId
        AND a.ServiceTypeId = 2
        AND b.Status = 1
    GROUP BY c.VehicleTypeId
) t

	--7
	select top 1
	       b.WaterwayArea as WaterArea,
	       format((select isnull(Price,10000) from PAR_ServicePrice where projectCd = b.projectCd and ServiceTypeId = 1),'#,###,###,###') as Price,
		   format(a.CommonFee,'#,###,###,###') as CommonFee
	from MAS_Service_ReceiveEntry a 
		JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
			--join MAS_Rooms t on b.RoomCode = t.RoomCode
	where b.ApartmentId = @ApartmentId  and a.ReceiveId = @receiveId


	--8
	select top 1 format((select case when c.ServiceId = 5 then isnull(c.Price2,1500000) end as CarFee2
	from  PAR_ServicePrice c 
	where c.ProjectCd = @ProjectCd and ServiceTypeId = 2 and ServiceId = 5 and TypeId = 1),'#,###,###,###') as CarFee2,
	format((select top 1 case when c.ServiceId = 6 then isnull(c.Price2,1500000) end as MotoFee3
	from  PAR_ServicePrice c 
	where c.ProjectCd = @ProjectCd and ServiceTypeId = 2 and ServiceId = 6 and TypeId = 1),'#,###,###,###') as MotoFee3
	
	--bat dau tao hoa don
	UPDATE [dbo].[MAS_Service_ReceiveEntry]
		SET bill_st = 1
	WHERE ReceiveId = @ReceiveId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_get_payment_report_byId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'PaymentById', 'GET', @SessionID, @AddlInfo
	end catch