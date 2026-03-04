-- =============================================
-- Author:		duongpx
-- Create date: 10/7/2024 12:31:05 PM 
-- Description:	giao dịch điểm
-- =============================================
CREATE procedure [dbo].[sp_Pay_Point_Transaction_Page]
	@UserId	nvarchar(450), 
	@CustId	nvarchar(50) = NULL,  
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
	declare @startDt datetime
	declare @endDt datetime

	begin try 
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0) 
		set		@ServiceKey				= isnull(@ServiceKey,'')
		set		@PosCd					= isnull(@PosCd,'')
		set		@CustId					= isnull(@CustId,'')
		set		@filter					= isnull(@filter,'')
		set		@tranType				= isnull(@tranType,'')
		set		@dateFilter				= isnull(@dateFilter,0)

		if		@PageSize	<= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		if (@CustId = '' or @CustId is null) and @filter <> ''
			set @CustId = (select top 1 c.custId 
				from MAS_Customers c 
				where c.Phone = @filter and Cif_No is not null)
		if (@CustId = '' or @CustId is null) and @filter <> ''
			set @CustId = (select top 1 u.custId 
				from UserInfo u 
					join MAS_Apartments a on u.loginName = a.UserLogin 
					join MAS_Customers c on u.CustId = c.CustId 
					join MAS_Cards d on c.CustId = d.CustId 
				where RoomCode = @filter)
		
		if (@CustId = '' or @CustId is null) and @filter <> ''
			set @CustId = (select top 1 d.custId 
				from MAS_Cards d 
				where d.CardCd like @filter)
				 --exists(select cardid from MAS_Cards where CustId = c.CustId and CardCd = @filter))

		if @startDate is null or @startDate = ''
		begin
			set @startDt = dateadd(MONTH,-1,getdate())
			set @endDt = dateadd(day,1,getdate())
		end
		else
		begin
			set @startDt = convert(datetime,@startDate,103)
			set @endDt = convert(datetime,@endDate,103)
		end

		--if(@TransTypeId = 3 or @TransTypeId = 0 or @TransTypeId = -1) 
		--begin
		--	--set @PosCd  = 'PC8613035583';
		--	set @ServiceKey = 'SK702831';
		--end
		select 
			@Total					= count(wa.PointTranId)
			 from MAS_Points mp
				join MAS_Customers c on c.CustId = mp.CustId
				join [WAL_PointOrder] wa on mp.PointCd = wa.PointCd
			where (@tranType = '' or wa.TranType = @tranType)
				and (@ServiceKey = '' or wa.ServiceKey = @ServiceKey)
				and (@PosCd = '' or wa.PosCd = @PosCd) -- 'PC8613035583'
				and (@CustId = '' or mp.CustId = @CustId)
				and (--@dateFilter = 0 or @dateFilter = 1 and 
					(wa.TranDt between @startDt and @endDt))
		
		set	@TotalFiltered = @Total 
		if @Offset = 0
		begin
			SELECT *
			FROM [dbo].fn_config_list_gets ('view_Crm_Get_Point_Trans_Page', 0) 
			order by [ordinal]
		end
	
		--1
		  select wa.Ref_No as tranNo
				,wa.OrderAmount as orderAmount
				,wa.Point as point
				,wa.CreditPoint as creditPoint
				,wa.OrderInfo as orderInfo
				,format(wa.TranDt,'dd/MM/yyyy HH:mm:ss') as tranDt
				,wa.TransNo as cardCd
				,s.ServiceName as serviceName
				,p.PosName as posName
				--,format(case when wa.TranType = 'voucher' and wa.TranDt < {d '2020-01-01'} then {d '2020-12-31'} else dateadd(year,1,wa.TranDt) end,'dd/MM/yyyy') as expire_Dt
				,format(wa.expireDt,'dd/MM/yyyy') as expire_Dt
				,case when wa.TranType = 'smember' then N'Thẻ thành viên' else N'Tặng điểm' end as tranTypeName
				,c.FullName as fullName
				,c.Phone as phone
				,c.Email as email
				,mp.CustId as custId
				,wa.CurrPoint + wa.Point - wa.CreditPoint as currPoint
				,STUFF((
					  SELECT ',' +  a.RoomCode 
					  FROM MAS_Apartments a 
						join MAS_Apartment_Member b on a.ApartmentId = b.ApartmentId
					  WHERE b.CustId = c.CustId 
					  FOR XML PATH('')), 1, 1, '') as [apartments]
		from MAS_Points mp
			join MAS_Customers c on c.CustId = mp.CustId
			join [WAL_PointOrder] wa on mp.PointCd = wa.PointCd
			left join WAL_Services s on wa.ServiceKey = s.ServiceKey
				left join WAL_ServicePOS p on p.PosCd = wa.PosCd
		where (@tranType = '' or wa.TranType = @tranType)
				and (@ServiceKey = '' or wa.ServiceKey = @ServiceKey)
				and (@PosCd = '' or wa.PosCd = @PosCd) -- 'PC8613035583'
				and (@CustId = '' or mp.CustId = @CustId)
				and (--@dateFilter = 0 or @dateFilter = 1 and 
					(wa.TranDt between @startDt and @endDt))

			ORDER BY wa.TranDt desc
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
		set @ErrorMsg					= 'sp_Crm_Get_Point_Trans_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Transaction', 'GET', @SessionID, @AddlInfo
	end catch