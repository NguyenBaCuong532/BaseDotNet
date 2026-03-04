-- exec sp_Hom_App_Payment_Get null,81966

CREATE procedure [dbo].[sp_Hom_App_Payment_Get]
	@userId	nvarchar(450),
	@receiveId int
as
	begin try
	--0
	SELECT a.ReceiveId
		  ,cast((case when month(a.ToDt)< 12 then month(a.ToDt) + 1 else case when month(a.ToDt) = 12 then 1 end end) as varchar) [PeriodMonth]
		  ,cast(year(a.ToDt) as varchar) [PeriodYear]
		  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceivableDate
		  ,a.TotalAmt as [TotalAmt]
		  ,convert(nvarchar(10),a.[ExpireDate],103) as [ExpireDate]
		  ,a.[IsPayed]
		  --,a.DebitAmt as DebitAmtAnother
		  --,a.creditAmt as DebitAmt
		  --,convert(nvarchar(10),a.FromDt,103) as fromDate
		  ,convert(nvarchar(10),a.ToDt,103) as toDate
		  ,case when a.IsPayed = 1 then N'Đã thanh toán' else N'Chờ thanh toán' end as StatusPayed
		  ,N'Hóa đơn tháng ' + cast(month(a.ToDt) as varchar) + N'/' + cast(year(a.ToDt) as varchar) as Remark 
		  ,b.RoomCode
		  ,c.FullName
		  ,(select ExtendAmt from MAS_Service_Receivable where ReceiveId = @receiveId and ServiceTypeId = 8) as ExtendAmt
		  ,isnull(a.RefundAmt,0) as RefundAmt
		  ,a.DebitAmt as debitAmt
		  ,a.RefundAmt as refundAmt
		  ,'' as refundAmtText
		  ,N'Chuyển nợ tháng ' + cast(case when month(a.ToDt) > 1 then month(a.ToDt) - 1  else 12 end as nvarchar(20)) as debitAmtText
	  FROM [dbo].MAS_Service_ReceiveEntry a 
			JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
			left join UserInfo u on b.UserLogin = u.loginName 
			left join MAS_Customers c on u.CustId = c.CustId 
		WHERE  a.ReceiveId = @ReceiveId
	
	--1 fee
	SELECT a.[ReceivableId]
		  ,a.[ServiceObject]
		  ,a.[Amount]
		  ,a.[VATAmt]
		  ,a.[TotalAmt]
		  ,b.WaterwayArea
		  ,a.Quantity
		  ,a.Price
	  FROM [MAS_Service_Receivable] a
		join MAS_Apartments b on a.srcId = b.ApartmentId
		join MAS_Rooms c on b.RoomCode = c.RoomCode 
	  WHERE  a.ReceiveId = @ReceiveId
		and ServiceTypeId = 1

	--2 vehicle
	SELECT [ReceivableId]
		  --,[ReceiveId]
		  ,[ServiceObject]
		  ,a.Quantity
		  ,a.Price
		  ,a.[Amount]
		  ,a.[VATAmt]
		  ,a.[TotalAmt]
		  ,[srcId] as CardVehicleId
		  ,c.VehicleTypeName
		  ,b.VehicleName
		  ,b.VehicleNo
		  ,b.VehicleNum
		  ,d.CardCd
		  ,b.isCharginFee as isCharginFee
	  FROM [MAS_Service_Receivable] a
		join MAS_CardVehicle b on a.srcId = b.CardVehicleId
		join MAS_VehicleTypes c on b.VehicleTypeId = c.VehicleTypeId
		left join MAS_Cards d on b.CardId = d.CardId 
	  WHERE  a.ReceiveId = @ReceiveId
		and ServiceTypeId = 2

	--3 living
	SELECT [ReceivableId]
		  ,[ReceiveId]
		  ,[ServiceTypeId]
		  ,[ServiceObject]
		  ,a.[Amount] + b.DiscountAmt as Amount
		  ,a.[VATAmt]
		  ,a.[TotalAmt]
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
		  ,isnull(b.DiscountAmt,0) as DiscountAmt
		  ,a.Amount as TotalAfterDiscountAmt
	  FROM [MAS_Service_Receivable] a
		join MAS_Service_Living_Tracking b on a.srcId = b.TrackingId
		join MAS_Apartment_Service_Living c on b.LivingId = c.LivingId
		join MAS_LivingTypes d on c.LivingTypeId = d.LivingTypeId
	  WHERE  a.ReceiveId = @ReceiveId
		and ServiceTypeId = 3

	--4 extend
	SELECT [ReceivableId]
		  ,[ReceiveId]
		  ,[ServiceTypeId]
		  ,[ServiceObject]
		  ,[Amount]
		  ,[VATAmt]
		  ,[TotalAmt]
		  ,[fromDt]
		  ,[ToDt]
		  ,[srcId]
	  FROM [MAS_Service_Receivable] a
	  WHERE  a.ReceiveId = @ReceiveId
		and ServiceTypeId = 4

	--5 LivingCalSheet
	SELECT e.[Id]
		  ,e.[TrackingId]
		  ,e.[StepPos]
		  ,e.[fromN]
		  ,e.[toN]
		  ,e.[Quantity]
		  ,e.[Price]
		  ,e.[Amount]
	  FROM [MAS_Service_Receivable] a
		join MAS_Service_Living_Tracking b on a.srcId = b.TrackingId
		join [MAS_Service_Living_CalSheet] e on b.TrackingId = e.TrackingId
		WHERE  a.ReceiveId = @ReceiveId
		and ServiceTypeId = 3

   SELECT [ReceivableId]
		  ,[ServiceObject]
		  ,a.[Amount]
		  ,a.[VATAmt]
		  ,a.[TotalAmt]
		  ,c.WaterwayArea
		  ,a.Quantity
		  ,a.Price
	  FROM [MAS_Service_Receivable] a
		join MAS_Apartments b on a.srcId = b.ApartmentId
		join MAS_Rooms c on b.RoomCode = c.RoomCode 
	  WHERE  a.ReceiveId = @ReceiveId
		and ServiceTypeId = 8

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Payment_ById ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'PaymentById', 'GET', @SessionID, @AddlInfo
	end catch