







-- exec sp_Hom_Service_Expectable_Page 
CREATE procedure [dbo].[sp_Hom_Service_Expectable_Page]
	@UserID		nvarchar(450) = null,
	@clientId	nvarchar(50) = null,
	@ProjectCd	nvarchar(10) = null,
	@ToDate		nvarchar(10) = null,
	@IsCalculated		bit = 0,
	@filter		nvarchar(100)='',
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int  out ,
	@TotalFiltered		int  out 
as
	begin try	
		declare @ToDt datetime
		declare @ToDtVehicle datetime
		declare @webId nvarchar(50) --= (select id from [dbAppManager].[dbo].[ClientWebs] where clientId = @clientId or clientIdDev = @clientId)
		set @webId = 'E10C3ADE-EC16-4511-B467-4848241D52C7'
		declare @tbCats TABLE 
		(
			categoryCd [nvarchar](50) not null  INDEX IX1_category NONCLUSTERED
		)
		set		@projectCd				= isnull(@projectCd,'')
		INSERT INTO @tbCats
		select distinct u.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 0 
			and not exists(select CategoryCd from @tbCats where categoryCd = u.CategoryCd)
			and (@ProjectCd = '' or u.categoryCd = @ProjectCd)
		INSERT INTO @tbCats
		select distinct n.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u join [dbSHome].[dbo].MAS_Category n on n.base_type = u.base_type 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 1
			and not exists(select CategoryCd from @tbCats where categoryCd = n.CategoryCd)
			and (@ProjectCd = '' or n.categoryCd = @ProjectCd)

	
	set @ToDate = isnull(@ToDate,convert(nvarchar(10),getdate(),103))
	set @ToDt = EOMONTH(convert(datetime,@todate,103))
    set @ToDtVehicle = EOMONTH(DATEADD(month,1,@ToDt))
	
	set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		if @Offset = 0
		begin
			SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Service_Expectable_Page1', @gridWidth) 
			ORDER BY [ordinal]
		end

		select	@Total					= count(b.ApartmentId)
			FROM MAS_Apartments b 
			join @tbCats ca on b.projectCd = ca.categoryCd
			join MAS_Rooms a on a.RoomCode = b.RoomCode 
			--join MAS_Buildings c on a.BuildingCd = c.BuildingCd 
			join UserInfo u on b.UserLogin = u.loginName
			join MAS_Customers d on u.CustId = d.CustId
			left join MAS_Service_ReceiveEntry r on r.ApartmentId = b.ApartmentId 
				and r.IsPayed = 0 and month(r.ToDt) = month(convert(datetime,@ToDate,103)) and year(r.ToDt) = year(convert(datetime,@ToDate,103))
			WHERE b.IsReceived = 1 
				and b.isFeeStart = 1
				and (b.DebitAmt != 0 or b.DebitAmt is not null 
							or exists(select (CardVehicleId) from MAS_CardVehicle v 
							where v.StartTime < @ToDtVehicle and (v.lastReceivable is null or v.lastReceivable < @ToDtVehicle) 							
								and v.ApartmentId = b.ApartmentId)
							or exists(SELECT ([TrackingId])
							FROM [dbSHome].[dbo].[MAS_Service_Living_Tracking] t
								where IsCalculate = 1 and ToDt <= @ToDt
									and t.IsReceivable = 0
									and t.ApartmentId = b.ApartmentId
									and t.Amount !=0)
							or (isnull(b.lastReceived,b.FreeToDt) < @ToDt)
						)
				--and month(r.ToDt) = month(convert(datetime,@ToDate,103))
				--and year(r.ToDt) = year(convert(datetime,@ToDate,103))
				and (@filter = '' or b.RoomCode like '%'+@filter+'%')
				and (@ProjectCd is null or b.projectCd = @ProjectCd)

				--SELECT *
				--			FROM [dbSHome].[dbo].[MAS_Service_Living_Tracking] t
				--				where IsCalculate = 1 and ToDt <= '2020-12-31'
				--					and t.IsReceivable = 0
				--					and t.ApartmentId = 7405
				--					and t.Amount !=0


		set	@TotalFiltered = @Total
		--
		SELECT b.[ApartmentId]
			  ,b.[RoomCode]
			  ,b.[Cif_No]
			  ,convert(nvarchar(10),b.[ReceiveDt],103) as [ReceiveDate]
			  ,r.ReceiveId
			  ,d.FullName
			  ,a.WaterwayArea
			  ,convert(nvarchar(10),r.ToDt,103) as ToDate
			  ,convert(nvarchar(10),r.[ExpireDate],103) as [ExpireDate]
			  ,r.CommonFee
			  ,r.VehicleAmt
			  ,r.LivingAmt
			  ,(select top 1 round(Amount*1.08,0) from MAS_Service_Receivable where ReceiveId = r.ReceiveId and ServiceObject like N'%Điện sinh hoạt%') as livingElectricAmt
			  ,(select top 1 round(Amount*1.15,0) from MAS_Service_Receivable where ReceiveId = r.ReceiveId and ServiceObject like N'%Nước sinh hoạt%') as livingWaterAmt
			  ,r.ExtendAmt
			  ,r.TotalAmt
			  ,r.DebitAmt as DebitAmt
			  ,isnull(r.isExpected,0) as isExpected
			  ,convert(nvarchar(10),isnull(b.lastReceived,b.FeeStart),103) as AccrualLastDt
			  ,case when r.ToDt is null then N'<span class="bg-warning noti-number ml5">Chưa tính</span>' 
					else N'<span class="bg-success noti-number ml5">'+format(r.ToDt,'MM/yyyy')+'</span>' end AccrualStatus
		  FROM MAS_Apartments b 
			join @tbCats ca on b.projectCd = ca.categoryCd
			join MAS_Rooms a on a.RoomCode = b.RoomCode 
			--join MAS_Buildings c on a.BuildingCd = c.BuildingCd 
			join UserInfo u on b.UserLogin = u.loginName
			join MAS_Customers d on u.CustId = d.CustId
			left join MAS_Service_ReceiveEntry r on r.ApartmentId = b.ApartmentId 
				and r.IsPayed = 0 and month(r.ToDt) = month(convert(datetime,@ToDate,103)) and year(r.ToDt) = year(convert(datetime,@ToDate,103))
			WHERE b.IsReceived = 1 
				and b.isFeeStart = 1
				and (b.DebitAmt != 0 or b.DebitAmt is not null 
							or exists(select (CardVehicleId) from MAS_CardVehicle v 
							where v.StartTime < @ToDtVehicle and (v.lastReceivable is null or v.lastReceivable < @ToDtVehicle) 							
								and v.ApartmentId = b.ApartmentId)
							or exists(SELECT ([TrackingId])
							FROM [dbSHome].[dbo].[MAS_Service_Living_Tracking] t
								where IsCalculate = 1 and ToDt <= @ToDt
									and t.IsReceivable = 0
									and t.ApartmentId = b.ApartmentId
									and t.Amount !=0)
							or (isnull(b.lastReceived,b.FreeToDt) < @ToDt)
						)
				and (@filter = '' or b.RoomCode like '%'+@filter+'%')
				and (@ProjectCd is null or b.projectCd = @ProjectCd)
			ORDER BY  r.SysDate
				  offset @Offset rows	
					fetch next @PageSize rows only
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Expectable_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Expectables', 'Get', @SessionID, @AddlInfo
	end catch