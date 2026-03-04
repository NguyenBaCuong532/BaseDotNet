
CREATE procedure [dbo].[sp_Hom_Get_Payment_Report_ById]
	@userId	nvarchar(450),
	@receiveId int
as
	begin try
	declare @ApartmentId int 
	declare @ProjectCd nvarchar(50) = ''
	declare @DiscountElecAmt decimal(18,0)
	declare @DiscountWaterAmt decimal(18,0)

	set @ApartmentId = (select top 1 ApartmentId from MAS_Service_ReceiveEntry where ReceiveId = @receiveId)
	set @ProjectCd = (select top 1 isnull(projectCd,'01') from MAS_Apartments where ApartmentId = @ApartmentId)
	select @DiscountElecAmt = t.DiscountAmt
	                       from MAS_Service_Living_Tracking t inner join MAS_Service_ReceiveEntry k
	                       on t.ApartmentId = k.ApartmentId and t.LivingTypeId = 1 and t.PeriodMonth = month(k.ToDt)
						   where k.ReceiveId = @receiveId

	select @DiscountWaterAmt = t.DiscountAmt
	                       from MAS_Service_Living_Tracking t inner join MAS_Service_ReceiveEntry k
	                       on t.ApartmentId = k.ApartmentId and t.LivingTypeId = 2 and t.PeriodMonth = month(k.ToDt)
						   where k.ReceiveId = @receiveId

	--set @receiveId = 933
	--0 - Thong tin chung
	SELECT a.ReceiveId
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
			  --,isnull(v.projectName,isnull(v.projectName,(select top 1 projectCd from mas_Projects where projectCd = (isnull(v.projectCd,b.projectCd))))) as ProjectName
			  --,isnull(v.projectCd,b.projectCd) +'-'+ isnull(v.projectName,(select top 1 projectName from mas_Projects where projectCd = (isnull(v.projectCd,b.projectCd)))) as projectFolder
			  --,isnull(v.projectCd,b.projectCd) as ProjectCd
			  --,isnull(v.buildingName,(select top 1 buildingName from dbSCRM.dbo.BLD_Buildings where buildingName = b.buildingCd)) as BuildingNo
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
			  ,a.TotalAmt as TransactionAmt
			  ,b.RoomCode + ' THANH TOAN TIEN PHI THANG ' + cast(month(a.ToDt) as varchar) + ' NAM ' + cast(year(a.ToDt) as varchar) as TransContent
	  FROM  [dbo].MAS_Service_ReceiveEntry a 
			left JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
			left join MAS_Rooms t on b.RoomCode = isnull(t.RoomCodeView,t.RoomCode)
			--left join dbSCRM.dbo.viewRoom v on isnull(t.RoomCodeView,t.RoomCode) = v.Code
			left join MAS_Service_Bank bk on b.projectCd = bk.ProjectCd
			left join PAR_ServicePrice p on b.projectCd = p.ProjectCd and ServiceTypeId = 1
			left join UserInfo u on b.UserLogin = u.loginName 
			left join MAS_Customers c on u.CustId = c.CustId 			
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
	  WHERE  a.ReceiveId = @ReceiveId and ServiceTypeId = 3 and b.LivingTypeId = 1
	  order by b.[ToDt] desc
	

	--3 Chi tiết phí điện năng sử dụng 
	SELECT e.[Id]
		  ,e.[TrackingId]
		  ,e.[StepPos]
		  ,N'Từ ' + cast(e.fromN as nvarchar(50)) + case when e.toN is null then N' trở lên' else ' - '+ (cast(e.toN as nvarchar(9))) end as PriceRangeElectric
		  ,e.[fromN]
		  ,e.[toN]
		  ,e.[Quantity]
		  ,e.[Price]
		  ,e.[Amount]
		  ,a.ReceiveId
		  ,ServiceTypeId
	  FROM [MAS_Service_Receivable] a
		join MAS_Service_Living_Tracking b on a.srcId = b.TrackingId
		join [MAS_Service_Living_CalSheet] e on b.TrackingId = e.TrackingId
		--join (select top 1 t.ReceiveId,k.TrackingId 
		--      from MAS_Service_Receivable t join MAS_Service_Living_Tracking k on t.srcId = k.TrackingId
		--	 where t.ReceiveId = @receiveId
		--	  order by k.ToDt desc) tm on a.ReceiveId = tm.ReceiveId and b.TrackingId = tm.TrackingId
		WHERE  a.ReceiveId = @ReceiveId
		and a.ServiceTypeId = 3 
		and b.LivingTypeId = 1

		--select * from MAS_Service_Living_Tracking where ReceiveId = 8313

		--4 Phí nước sử dụng
	SELECT top 1 [ReceivableId]
		  ,[ReceiveId]
		  ,[ServiceTypeId]
		  ,[ServiceObject]
		  ,a.[Amount]
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
	  FROM [MAS_Service_Receivable] a
		join MAS_Service_Living_Tracking b on a.srcId = b.TrackingId
		join MAS_Apartment_Service_Living c on b.LivingId = c.LivingId
		join MAS_LivingTypes d on c.LivingTypeId = d.LivingTypeId
	  WHERE  a.ReceiveId = @ReceiveId
		and a.ServiceTypeId = 3 and b.LivingTypeId = 2
	  order by b.ToDt desc

		-- Chi tiết phí nước sử dụng
		SELECT e.[Id]
		  ,e.[TrackingId]
		  ,e.[StepPos]
		  ,N'Từ ' + cast(e.fromN as nvarchar(50)) + case when e.toN is null then N' trở lên' else ' - '+ (cast(e.toN as nvarchar(9))) end as PriceRangeWater
		  ,e.[fromN]
		  ,e.[toN]
		  ,e.[Quantity]
		  ,e.[Price]
		  ,e.[Amount]
		  ,a.ReceiveId
	  FROM [MAS_Service_Receivable] a
		join MAS_Service_Living_Tracking b on a.srcId = b.TrackingId
		join [MAS_Service_Living_CalSheet] e on b.TrackingId = e.TrackingId
		--join (select top 1 t.ReceiveId,k.TrackingId 
		--      from MAS_Service_Receivable t join MAS_Service_Living_Tracking k on t.srcId = k.TrackingId
		--	  where t.ReceiveId = @receiveId
		--	  order by k.ToDt desc) tm on a.ReceiveId = tm.ReceiveId and b.TrackingId = tm.TrackingId
		WHERE  a.ReceiveId = @receiveId
		and a.ServiceTypeId = 3 and b.LivingTypeId = 2

		--select * from MAS_Service_Receivable where ReceiveId = 6

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
	FROM
	(SELECT c.VehicleTypeId
		  ,count(c.VehicleTypeId) sumQ
		  ,sum(a.TotalAmt) as sumA
	  FROM [MAS_Service_Receivable] a
		join MAS_CardVehicle b on a.srcId = b.CardVehicleId
		join MAS_VehicleTypes c on b.VehicleTypeId = c.VehicleTypeId
		--left join MAS_Cards d on b.CardId = d.CardId 
	  WHERE  a.ReceiveId = @ReceiveId
		and a.ServiceTypeId = 2
	group by c.VehicleTypeId, c.VehicleTypeName) t

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
		set @ErrorMsg					= 'sp_Hom_Get_Payment_Report_ById ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'PaymentById', 'GET', @SessionID, @AddlInfo
	end catch