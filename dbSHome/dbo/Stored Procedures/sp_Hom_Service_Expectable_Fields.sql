

-- exec sp_Hom_Service_Expectable_Fields null,19779

CREATE procedure [dbo].[sp_Hom_Service_Expectable_Fields]
	@userId	nvarchar(450),
	@receiveId int
as
	begin try
	--0
		SELECT a.ReceiveId
			  ,cast(month(a.ToDt) as varchar) [PeriodMonth]
			  ,cast(year(a.ToDt) as varchar) [PeriodYear]
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceivableDate
			  ,TotalAmt as [TotalAmt]
			  ,convert(nvarchar(10),a.[ExpireDate],103) as [ExpireDate]
			  ,a.[IsPayed]
			  --,convert(nvarchar(10),a.FromDt,103) as fromDate
			  ,convert(nvarchar(10),a.ToDt,103) as toDate
			  ,case when a.IsPayed = 1 then N'Đã thanh toán' else N'Chờ thanh toán' end as StatusPayed
			  ,isnull(a.Remart,N'Hóa đơn tháng ' + cast(month(a.ToDt) as varchar) + N' năm ' + cast(year(a.ToDt) as varchar)) as Remark 
			  ,b.RoomCode
			  ,c.FullName
	  FROM [dbo].MAS_Service_ReceiveEntry a 
			INNER JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
			left join UserInfo u on b.UserLogin = u.loginName 
			left join MAS_Customers c on u.CustId = c.CustId 
		WHERE  a.ReceiveId = @ReceiveId

		SELECT *
			FROM dbo.[fn_get_field_group] ('service_expectable_field_group') 
		   order by intOrder
			
		SELECT distinct a.id
				,table_name
				,field_name
				,view_type
				,data_type
				,ordinal
				,columnLabel
				,group_cd
				,case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
					when 'roomCode' then d.RoomCode
					when 'fullName' then e.FullName
					when 'projectName' then p.projectName
					--when 'onTime' then convert(nvarchar(10),r.[AtTime],103) + ' ' + convert(nvarchar(5),r.[AtTime],108)
					when 'userLogin' then u.loginName
					when 'phone' then e.Phone
					end
					) 
				when 'decimal' then cast(case field_name 
					 when 'totalAmt' then b.TotalAmt
					 when 'CommonFee' then b.CommonFee
					 when 'VehicleAmt' then b.VehicleAmt
					 when 'LivingAmt' then b.LivingAmt
					 when 'ExtendAmt' then b.ExtendAmt
					 when 'PaidAmt' then b.PaidAmt
					 when 'Price' then f.Price 
					 when 'freeAmt' then f.TotalAmt
					 when 'feeVatAmt' then f.TotalAmt/11
					 when 'feeNoVatAmt' then f.TotalAmt - f.TotalAmt/11
					 end as nvarchar(100)) 
				when 'datetime' then convert(nvarchar(50), case field_name 
					when 'receiveDt' then convert(nvarchar(10),b.ReceiveDt,103)
					when 'toDt' then convert(nvarchar(10),b.ToDt,103)
					when 'expireDate' then convert(nvarchar(10),b.ExpireDate,103)
					end)
					 
				else convert(nvarchar(50),case field_name 
					when 'isPayed' then b.[IsPayed]
					when 'WaterwayArea' then d.WaterwayArea
					when 'monthFee' then DATEDIFF(m,f.fromDt,f.ToDt)
					--when 'requestTypeId' then b.requestTypeId
					end) 
				end as columnValue
				,columnClass
				,columnType
				,columnObject
				,isSpecial
				,isRequire
				,isDisable
				,isVisiable
				,[IsEmpty]
				,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
			FROM sys_config_form a
			,[dbo].MAS_Service_ReceiveEntry b
				JOIN MAS_Apartments d ON b.ApartmentId = d.ApartmentId
				left join UserInfo u on d.UserLogin = u.loginName 
				left join MAS_Customers e on u.CustId = e.CustId 
				left join MAS_Service_Receivable f on f.srcId = b.ApartmentId and f.ReceiveId = b.ReceiveId and f.ServiceTypeId = 1
				join MAS_Rooms h on d.RoomCode = h.RoomCode 
				--join COR_Contracts k on h.RoomCode = k.roomCode
				join MAS_Projects p on d.projectCd = p.projectCd
			WHERE  b.ReceiveId = @ReceiveId
				and a.table_name = 'MAS_Service_ReceiveEntry' and (a.isVisiable = 1 or a.isRequire =1)
			order by ordinal
			--select * from .dbo.viewRoom where Code ='PH-2601'

	 --	and ServiceTypeId = 1
	SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Service_Expectable_Fee_Detail', 0) 
			ORDER BY [ordinal]
	
	SELECT [ReceivableId]
		  ,[ReceiveId]
		  ,[ServiceObject]
		  ,a.Quantity
		  ,a.Price
		  ,[Amount]
		  ,[VATAmt]
		  ,[TotalAmt]
		  ,b.ApartmentId
		  ,b.WaterwayArea
		  ,convert(nvarchar(10),a.fromDt,103) as fromDt
		  ,convert(nvarchar(10),a.ToDt,103) as toDt
		  ,b.RoomCode
	  FROM [MAS_Service_Receivable] a
		join MAS_Apartments b on a.srcId = b.ApartmentId
		--join MAS_VehicleTypes c on b.VehicleTypeId = c.VehicleTypeId
		--left join MAS_Cards d on b.CardId = d.CardId 
	  WHERE  a.ReceiveId = @ReceiveId
		and ServiceTypeId = 1

	--	and ServiceTypeId = 2
	SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Service_Expectable_Vehicle_Detail', 0) 
			ORDER BY [ordinal]
		

	--2 vehicle
	SELECT [ReceivableId]
		  --,[ReceiveId]
		  ,[ServiceObject] 
		  ,a.Quantity
		  ,a.Price
		  ,[Amount]
		  ,[VATAmt]
		  ,[TotalAmt]
		  ,[srcId] as CardVehicleId
		  ,c.VehicleTypeName
		  ,b.VehicleName
		  ,b.VehicleNo
		  ,b.VehicleNum
		  ,d.CardCd
		  ,convert(nvarchar(10),a.fromDt,103) as fromDt
		  ,convert(nvarchar(10),a.ToDt,103) as toDt
	  FROM [MAS_Service_Receivable] a
		join MAS_CardVehicle b on a.srcId = b.CardVehicleId
		join MAS_VehicleTypes c on b.VehicleTypeId = c.VehicleTypeId
		left join MAS_Cards d on b.CardId = d.CardId 
	  WHERE  a.ReceiveId = @ReceiveId
		and ServiceTypeId = 2

	SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Service_Expectable_Living_Detail', 0) 
			ORDER BY [ordinal]
	--3 living
	SELECT [ReceivableId]
		  ,[ReceiveId]
		  ,[ServiceTypeId]
		  ,[ServiceObject]
		  ,a.[Amount]
		  ,a.[VATAmt]
		  ,[TotalAmt]
		  ,convert(nvarchar(10),b.FromDt,103) as fromDt
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
		and a.ServiceTypeId = 3
	

	SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Service_Expectable_LivingSheet_Detail', 0) 
			ORDER BY [ordinal]

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

	----4 extend
	SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Service_Expectable_Extend', 0) 
			ORDER BY [ordinal]

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
		and ServiceTypeId = 8

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Expectable_Fields ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Service_Expectable', 'GET', @SessionID, @AddlInfo
	end catch