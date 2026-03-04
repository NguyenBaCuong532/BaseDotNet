





CREATE procedure [dbo].[sp_Pay_Point_List_Page1]
	@userId			nvarchar(450),
	@filter			nvarchar(50),  
	@lastDate		nvarchar(20)	= null,
	@numDay				int			= 7,
	@gridWidth			int				= 0, 
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out

as
	begin try
		declare @startDate datetime
		declare @endDate datetime
		declare @stDate datetime
		declare  @intFlag int
		declare @totPointCur decimal(18,0)

		declare @totaltemp table
			(
				day_order_amt decimal(18,0),
				day_voucher_pnt decimal(18,0), 
				day_credit_pnt decimal(18,0),
				day_debit_pnt decimal(18,0),
				day_bal_pnt decimal(18,0),
				day_trans decimal(18,0),
				valueDate datetime
			)  

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0) 
		set		@filter					= isnull(@filter,'')

		if		@PageSize	<= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		if @lastDate is null
			set @endDate = getdate()
		else
			set @endDate = convert(datetime,@lastDate,103)
		
		if @numDay is null or @numDay = 0
			set @numDay = 7
		else if @numDay > 30
			set @numDay = 30

		select 
			@Total					= count(p.PointCd)
			 from MAS_Points p
				join MAS_Customers c on p.CustId = c.CustId
			where p.sysDate <= @endDate
		--		and @filter = '' or c.Phone like @filter + '%' or c.FullName like @filter + '%'

		set	@TotalFiltered = @Total 

		if @Offset = 0
		begin
			select * from dbo.[fn_config_list_gets] ('view_Crm_Get_Point_Page', @gridWidth - 100) 
			order by [ordinal]
			
			set @totPointCur = (select sum(p.CurrPoint) as sum_bal_pnt
					from MAS_Points p 
						join mas_customers a on p.custId = a.custId
					where p.sysDate <= @endDate)

			set @startDate = DATEADD(day,-@numDay,@endDate)			
			set  @intFlag = 0
			 while (@intFlag < @numDay)
			 begin	
				set @stDate = dateadd(day,@intFlag,@startDate)
				insert into @totaltemp 
					(valueDate
					,day_bal_pnt
					,day_order_amt
					,day_voucher_pnt
					,day_credit_pnt
					,day_debit_pnt
					,day_trans
					) 
				select @stDate as valueDate
					,sum(t1.CurrPoint) as sum_bal_pnt
					,sum(t2.sum_order_amt) as sum_order_amt
					,sum(t2.sum_voucher_pnt) as sum_voucher_pnt
					,sum(t2.sum_credit_pnt) as sum_credit_pnt
					,sum(t2.sum_debit_pnt) as sum_debit_pnt
					,sum(t2.count_trans) as count_trans
				from
				(select p.PointCd 
					,isnull(e.CurrPoint+e.Point-e.CreditPoint,p.CurrPoint) as CurrPoint
				from MAS_Points p 
					left join (select max(TranDt) as maxtransdt, w.PointCd from WAL_PointOrder w where TranDt <= dateadd(day,1,@stDate) group by w.PointCd) d on p.PointCd = d.PointCd 
					left join WAL_PointOrder e on d.PointCd = e.PointCd and e.TranDt = d.maxtransdt
				where p.sysDate < dateadd(day,1,@stDate)
					group by p.PointCd,p.CurrPoint,e.CurrPoint,e.Point,e.CreditPoint) t1
				join (select p.PointCd 
					,sum(isnull(a.OrderAmount,0)) as sum_order_amt
					,sum(isnull(case when a.TranType = 'voucher' then a.Point else 0 end,0)) as sum_voucher_pnt
					,sum(isnull(a.CreditPoint,0)) as sum_credit_pnt
					,sum(isnull(case when a.TranType = 'smember' then a.Point else 0 end,0)) as sum_debit_pnt
					,sum(case when a.PointTranId is not null then 1 else 0 end) as count_trans
					--,@stDate as valueDate
				from MAS_Points p 
					left join WAL_PointOrder a on p.PointCd = a.PointCd
				where p.sysDate < dateadd(day,1,@stDate)
					and (a.TranDt between @stDate and dateadd(day,1,@stDate))
					group by p.PointCd) t2 on t1.PointCd = t2.PointCd


				  set @intFlag = @intFlag + 1
			 end

			 select * from @totaltemp
			
			select @stDate as valueDate
					,sum(t1.CurrPoint) as sum_bal_pnt
					,sum(t2.sum_order_amt) as sum_order_amt
					,sum(t2.sum_voucher_pnt) as sum_voucher_pnt
					,sum(t2.sum_credit_pnt) as sum_credit_pnt
					,sum(t2.sum_debit_pnt) as sum_debit_pnt
					,sum(t2.count_trans) as count_trans
				from
				(select p.PointCd 
					,isnull(e.CurrPoint+e.Point-e.CreditPoint,p.CurrPoint) as CurrPoint
				from MAS_Points p 
					left join (select max(TranDt) as maxtransdt, w.PointCd from WAL_PointOrder w where TranDt <= @EndDate group by w.PointCd) d on p.PointCd = d.PointCd 
					left join WAL_PointOrder e on d.PointCd = e.PointCd and e.TranDt = d.maxtransdt
				where p.sysDate < @EndDate
					group by p.PointCd,p.CurrPoint,e.CurrPoint,e.Point,e.CreditPoint) t1
				join (select p.PointCd 
					,sum(isnull(a.OrderAmount,0)) as sum_order_amt
					,sum(isnull(case when a.TranType = 'voucher' then a.Point else 0 end,0)) as sum_voucher_pnt
					,sum(isnull(a.CreditPoint,0)) as sum_credit_pnt
					,sum(isnull(case when a.TranType = 'smember' then a.Point else 0 end,0)) as sum_debit_pnt
					,sum(case when a.PointTranId is not null then 1 else 0 end) as count_trans
					--,@stDate as valueDate
				from MAS_Points p 
					join WAL_PointOrder a on p.PointCd = a.PointCd
				where p.sysDate <= @EndDate
					and (a.TranDt between @startDate and @EndDate)
					group by p.PointCd) t2 on t1.PointCd = t2.PointCd


			select sum(sum_order_amt) as sum_order_amt
					,sum(sum_voucher_pnt) as sum_voucher_pnt
					,sum(sum_credit_pnt) as sum_credit_pnt
					,sum(sum_debit_pnt) as sum_debit_pnt
					,sum(sum_bal_pnt) as sum_bal_pnt
					,sum(count_trans) as count_trans
					,@stDate as valueDate
				from
			(select sum(isnull(a.OrderAmount,0)) as sum_order_amt
				,sum(isnull(case when a.TranType = 'voucher' then a.Point else 0 end,0)) as sum_voucher_pnt
				,sum(isnull(a.CreditPoint,0)) as sum_credit_pnt
				,sum(isnull(case when a.TranType = 'smember' then a.Point else 0 end,0)) as sum_debit_pnt
				,p.CurrPoint as sum_bal_pnt
				,sum(case when a.PointTranId is not null then 1 else 0 end) as count_trans
				,p.PointCd
			from MAS_Points p 
				left join WAL_PointOrder a on p.PointCd = a.PointCd
				--left join (select max(TranDt) as maxtransdt, w.PointCd from WAL_PointOrder w where TranDt <= @endDate group by w.PointCd) d on p.PointCd = d.PointCd 
				--left join WAL_PointOrder e on d.PointCd = e.PointCd and e.TranDt = d.maxtransdt
			where p.sysDate <= @endDate
			group by p.PointCd,p.CurrPoint--,e.CurrPoint,p.CurrPoint,e.Point,e.CreditPoint
			) t

		end


		--1
		SELECT p.[PointCd]
			  ,[PointType]
			  ,p.[CustId]
			  --,isnull(e.CurrPoint,p.CurrPoint) as CurrentPoint
			  ,(select sum(Point) from WAL_PointOrder where PointCd = p.PointCd and TranDt <= @endDate) - 
			  (select sum(CreditPoint) from WAL_PointOrder where PointCd = p.PointCd and TranDt <= @endDate) as CurrentPoint
			  ,[LastDt] as LastDate
			  ,'Gold' as [Priority] --Platinum
			  ,(select sum(Point) from WAL_PointOrder where PointCd = p.PointCd and TranType = 'voucher' and TranDt <= @endDate) as sumVoucher
			  ,(select sum(OrderAmount) from WAL_PointOrder where PointCd = p.PointCd and TranDt <= @endDate) as sumOrderAmt
			  ,(select sum(CreditPoint) from WAL_PointOrder where PointCd = p.PointCd and TranDt <= @endDate) as sumCreditPoint
			  ,(select sum(Point) from WAL_PointOrder where PointCd = p.PointCd and TranType = 'smember' and TranDt <= @endDate) as sumDebitPoint
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
		  FROM MAS_Points p 
			join MAS_Customers c on p.CustId = c.CustId
			left join (select max(TranDt) as maxtransdt, w.PointCd from WAL_PointOrder w where TranDt <= @endDate group by w.PointCd) d on p.PointCd = d.PointCd 
			left join WAL_PointOrder e on d.PointCd = e.PointCd and e.TranDt = d.maxtransdt
		  WHERE p.sysDate <= @endDate
			--and 
			--(c.Phone like @filter + '%' or c.FullName like @filter + '%')
			--and (exists(select PointTranId from WAL_PointOrder where PointCd = p.PointCd) or p.CurrPoint >0)
		  ORDER BY p.sysDate desc
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
		set @ErrorMsg					= 'sp_Crm_Get_Point_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@custId ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'GET', @SessionID, @AddlInfo
	end catch