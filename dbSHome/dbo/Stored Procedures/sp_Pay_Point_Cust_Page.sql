CREATE procedure [dbo].[sp_Pay_Point_Cust_Page]
	@userId			nvarchar(450),
	@filter	nvarchar(50) = NULL,  
	@ServiceKey varchar(30) = NULL,
	@PosCd varchar(30) = NULL,
	@tranType nvarchar(50) = NULL, 
	@dateFilter			int				= 0,
	@startDate		nvarchar(20)  = NULL,
	@endDate		nvarchar(20)  = NULL,
	@gridWidth			int				= 0, 
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
	,@gridKey			nvarchar(200) out

as
	begin try
		--declare @startDate datetime
		--declare @endDate datetime
		declare @stDate datetime
		declare  @intFlag int
		declare @totPointCur decimal(18,0)
			

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0) 
		set		@filter					= isnull(@filter,'')
		set		@ServiceKey				= isnull(@ServiceKey,'')
		set		@PosCd					= isnull(@PosCd,'')
		set		@tranType				= isnull(@tranType,'')

		if		@PageSize	<= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		if @startDate = ''
			set @startDate = null
		--else
		--	set @endDate = convert(datetime,@lastDate,103)
		
		if @endDate = ''
			set @endDate =getdate()

		--	set @numDay = 7
		--else if @numDay > 30
		--	set @numDay = 30

		select 
			@Total					= count(p.PointCd)
			 from MAS_Points p
				join MAS_Customers c on p.CustId = c.CustId
			where exists(select 1 from [WAL_PointOrder] wa where wa.PointCd = p.PointCd 
				and(@tranType = '' or wa.TranType = @tranType)
				and (@ServiceKey = '' or wa.ServiceKey = @ServiceKey)
				and (@PosCd = '' or wa.PosCd = @PosCd) -- 'PC8613035583'
				and (@dateFilter = 0 or @dateFilter = 1 and (wa.TranDt between convert(datetime,@startDate,103) and convert(datetime,@endDate,103)))
				)

		set	@TotalFiltered = @Total 

		if @Offset = 0
			select * from dbo.[fn_config_list_gets] ('view_Crm_Get_Point_Page', @gridWidth - 100) 
			order by [ordinal]
			
		--1
		SELECT mp.[PointCd]
			  ,mp.[PointType]
			  ,mp.[CustId]
			  ,mp.CurrPoint as CurrentPoint
			  --,isnull(e.CurrPoint,p.CurrPoint) as CurrentPoint
			  --,(select sum(Point) from WAL_PointOrder where PointCd = p.PointCd and TranDt <= @endDate) - 
			  --(select sum(CreditPoint) from WAL_PointOrder where PointCd = p.PointCd and TranDt <= @endDate) as CurrentPoint
			  ,mp.[LastDt] as LastDate
			  ,'Gold' as [Priority] --Platinum
			  ,sum(case when TranType = 'voucher' then Point else 0 end) as sumVoucher
			  ,sum(OrderAmount) as sumOrderAmt
			  ,sum(CreditPoint) as sumCreditPoint
			  ,sum(case when TranType = 'smember' then Point else 0 end)  as sumDebitPoint
			  ,c.FullName 
			  ,'*****' + right(c.Phone ,4) as Phone
			  ,c.Email
			  ,STUFF((
					  SELECT ',' + CAST(bt.[base_desc] as nvarchar(255))
					  FROM [dbSHome].[dbo].[MAS_Base_Type] bt
					  WHERE exists(select userid from [dbSHome].[dbo].[MAS_Category_Customer] p
								join MAS_Category m on p.CategoryCd = m.CategoryCd 
							where m.base_type = bt.base_type and p.CustId = c.CustId)
					  FOR XML PATH('')), 1, 1, '') as base_types
			 ,STUFF((
					  SELECT ',' +  a.RoomCode 
					  FROM MAS_Apartments a 
						join MAS_Apartment_Member b on a.ApartmentId = b.ApartmentId
						join MAS_Rooms r on a.RoomCode = r.RoomCode 
						join MAS_Buildings mb on r.BuildingCd = mb.BuildingCd 
					  WHERE b.CustId = c.CustId 
					  FOR XML PATH('')), 1, 1, '') + isnull(c.[Address],'') as [Address]
		  FROM MAS_Points mp
			join MAS_Customers c on mp.CustId = c.CustId
			join [WAL_PointOrder] wa on mp.PointCd = wa.PointCd
				left join WAL_Services s on wa.ServiceKey = s.ServiceKey
				left join WAL_ServicePOS p on p.PosCd = wa.PosCd
		where (@tranType = '' or wa.TranType = @tranType)
				and (@ServiceKey = '' or wa.ServiceKey = @ServiceKey)
				and (@PosCd = '' or wa.PosCd = @PosCd) -- 'PC8613035583'
				and (@dateFilter = 0 or @dateFilter = 1 and (wa.TranDt between convert(datetime,@startDate,103) and convert(datetime,@endDate,103)))
		group by mp.[PointCd]
			  ,mp.[PointType]
			  ,mp.[CustId]
			  ,mp.[LastDt]
			  ,mp.sysDate
			  ,mp.CurrPoint
			  ,c.FullName 
			  ,c.Phone 
			  ,c.Email
			  ,c.CustId
			  ,c.[Address]
		  ORDER BY mp.sysDate desc
				  offset @Offset rows	
					fetch next @PageSize rows only
	  --2
	
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Point_Cust_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@custId ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CustomerPoint', 'GET', @SessionID, @AddlInfo
	end catch