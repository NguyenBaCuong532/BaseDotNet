



CREATE procedure [dbo].[sp_Hom_Card_Resident_Get]
@CardCd	nvarchar(50)
as
	begin try	
	
		--1
		SELECT [CardCd]
			  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
			  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
			  ,a.[CardTypeId]
			  ,isnull(p.CurrPoint,0) [CurrentPoint]
			  ,[ImageUrl]
			  ,s.[StatusName]
			  ,b.FullName
			  ,d.RoomCode 
			  ,CardTypeName
			  ,case when a.[CardTypeId] = 3 then 'http://data.sunshinegroup.vn/shome/card/card_cre.jpg' else 
			   case when a.[CardTypeId] = 2 then 'http://data.sunshinegroup.vn/shome/card/card_veh_plc.jpg' else 
				 'http://data.sunshinegroup.vn/shome/card/card_com_plc.jpg' end end as [ImageUrl]
			  ,a.ApartmentId
			  --,p.CurrPoint as CurrentPoint
			  ,a.Card_St as CardStatus
		FROM [dbo].[MAS_Cards] a 
			Inner Join MAS_Customers b On a.CustId = b.CustId 
			inner join MAS_CardTypes c on a.CardTypeId = c.CardTypeId 
			inner join MAS_Apartments d on a.ApartmentId = d.ApartmentId 
			left join MAS_Points p on p.CustId = b.CustId
			inner join MAS_CardStatus s on a.Card_St = s.StatusId
		WHERE CardCd = @CardCd

		--2
		SELECT [Id]
			  ,d.[CardCd]
			  ,a.[ServiceId]
			  ,convert(nvarchar(10),a.[LinkDate],103) [LinkDate]
			  ,ServiceName
			  ,b.ServiceTypeId
			  ,c.ServiceTypeName
			  ,case when a.IsLock = 1 then N'Đã khóa' else N'Đang hoạt động' end as [StatusName]
		FROM [dbo].[MAS_CardService] a 
			inner join MAS_Services b On a.ServiceId = b.ServiceId
			INNER JOIN MAS_ServiceTypes c On b.ServiceTypeId = c.ServiceTypeId
			INNER JOIN [MAS_Cards] d on a.CardId = d.CardId
		WHERE b.ServiceTypeId = 1 AND 
		EXISTS(SELECT CardCd FROM [MAS_Cards] WHERE CardCd = @CardCd and CardId = a.CardID)
		
		--3
		SELECT CardVehicleId
			  ,convert(nvarchar(10),a.[AssignDate],103) [AssignDate]
			  ,[VehicleNo]
			  ,a.[VehicleTypeID]
			  ,e.VehicleTypeName
			  ,a.[VehicleName]
			  ,convert(nvarchar(10),a.[StartTime],103) [StartTime]
			  ,convert(nvarchar(10),a.[EndTime],103) [EndTime]
			  ,a.ServiceId
			  ,N'Vé tháng - ' + e.VehicleTypeName as ServiceName
			  ,a.[Status]
			  ,case a.[Status] when 0 then N'Chờ phê duyệt' when 1 then N'Đang hoạt động'  when 2 then N'Quá hạn' when 3 then N'Đã khóa' end [StatusName]
			  ,mv.StatusName 
			  ,case a.[Status] when 3 then 1 else 0 end IsLock 
			  ,d.[CardCd]
			  ,a.isVehicleNone
	  FROM [dbo].[MAS_CardVehicle] a 
		--INNER JOIN MAS_Services b On a.ServiceId = b.ServiceId
		--Inner join MAS_CardService c on a.CardId = c.CardId and b.ServiceId = c.ServiceId
		INNER JOIN [MAS_Cards] d on a.CardId = d.CardId
		inner join MAS_VehicleTypes e On a.VehicleTypeId = e.VehicleTypeId
		join MAS_VehicleStatus mv on a.Status = mv.StatusId 
	  WHERE EXISTS(SELECT CardCd FROM [MAS_Cards] WHERE CardCd = @CardCd and CardId = a.CardID)

	   --4
	   SELECT a.[Id] as ExtendId
			  ,a.[CardId]
			  ,convert(nvarchar(10),[RegDt],103) as RegDate
			  ,convert(nvarchar(10),[ExpireDt],103) as [ExpireDate]
			  ,[Amount]
			  ,[IsFree]
			  ,a.[ServiceId]
			  --,b.ServiceName
			  ,a.[Status]
			  ,case a.[Status] when 0 then N'Chờ phê duyệt' when 1 then N'Đang hoạt động'  when 2 then N'Quá hạn' when 3 then N'Đã khóa' end [StatusName]
			  ,case a.[Status] when 3 then 1 else 0 end IsLock 
			  ,d.[CardCd]
	  FROM [TRS_RegServiceExtend] a 
		--Inner JOIn MAS_Services b ON a.ServiceId = b.ServiceId
		--Inner join MAS_CardService c on a.CardId = c.CardId and b.ServiceId = c.ServiceId
		INNER JOIN [MAS_Cards] d on a.CardId = d.CardId
	  WHERE EXISTS(SELECT CardCd FROM [MAS_Cards] WHERE CardCd = @CardCd and CardId = a.CardID)

	  --5
	  SELECT a.[Id]
			,a.[CardId]
			,a.[Cif_No2]
			,b.FullName 
			,a.[CreditLimit]
			,a.[SalaryAvg]
			,a.[IsSalaryTranfer]
			,a.[ResidenProvince]
			,a.[AsignDate]
			,a.[Status]
	FROM [MAS_CardCredit] a 
		INNER JOIN [MAS_Cards] d on a.CardId = d.CardId
		LEFT JOIN MAS_Customers b on a.Cif_No2 = b.Cif_No 
	  WHERE EXISTS(SELECT CardCd FROM [MAS_Cards] WHERE CardCd = @CardCd and CardId = a.CardID)


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_SalerMonthly_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'SalerMonthly', 'GET', @SessionID, @AddlInfo
	end catch