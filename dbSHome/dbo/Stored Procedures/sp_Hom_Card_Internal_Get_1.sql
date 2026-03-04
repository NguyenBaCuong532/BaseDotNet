CREATE procedure [dbo].[sp_Hom_Card_Internal_Get]
@CardCd	nvarchar(50)
as
	begin try	
	
		--1
		SELECT a.[CardCd]
			  ,convert(nvarchar(10),a.[IssueDate],103) IssueDate
			  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
			  ,a.[CardTypeId]
			  ,isnull(p.CurrPoint,0) as [CurrentPoint]
			  --,[ImageUrl]
			  ,a.Card_St as [Status]
			  ,s.[StatusName]
			  ,c.FullName
			  --,e.Position
			  --,e.Organization
			  ,c.Phone
			  ,c.Email
			  --,case when a.[CardTypeId] = 3 then 'http://data.sunshinegroup.vn/shome/card/card_cre.jpg' else 
			  -- case when a.[CardTypeId] = 2 then 'http://data.sunshinegroup.vn/shome/card/card_veh_plc.jpg' else 
				 --'http://data.sunshinegroup.vn/shome/card/card_com_plc.jpg' end end as [ImageUrl]
			  ,a.CardName
			  ,a.CustId
		FROM [dbo].[MAS_Cards] a 
			inner join MAS_Customers c on a.CustId = c.CustId
			left join [dbSHRM].[dbo].[Employees] e on a.CustId = e.CustId
			left join MAS_Points p on a.CustId = p.CustId
			inner join MAS_CardStatus s on a.Card_St = s.StatusId
		WHERE CardCd = @CardCd

		--3
		SELECT a.CardVehicleId
			  ,convert(nvarchar(10),a.[AssignDate],103) [AssignDate]
			  ,a.[VehicleNo]
			  ,a.[VehicleTypeID]
			  ,e.VehicleTypeName
			  ,a.[VehicleName]
			  ,convert(nvarchar(10),a.[StartTime],103) [StartTime]
			  ,convert(nvarchar(10),a.[EndTime],103) [EndTime]
			  ,a.ServiceId
			  ,N'Dịch vụ gửi xe - ' + e.VehicleTypeName as ServiceName
			  ,a.[Status]
			  ,mv.StatusName 
			  --,case a.[Status] when 0 then N'Chờ phê duyệt' when 1 then N'Đang hoạt động'  when 2 then N'Quá hạn' when 3 then N'Đã khóa' end [StatusName]
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