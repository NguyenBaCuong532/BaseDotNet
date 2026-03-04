







CREATE procedure [dbo].[sp_Hom_Service_Receivable_Bill_Page]
	@UserId			nvarchar(450),
	@apartmentId	bigint,
	@ToDate			nvarchar(20),
	@filter			nvarchar(50),
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 5,
	@Total				bigint out,
	@TotalFiltered		bigint out
as
	begin try
		
		if @ApartmentId is null or @ApartmentId = 0
			set @ApartmentId = (SELECT top 1 ApartmentId FROM MAS_Apartment_Member a 
			inner join UserInfo b on a.CustId=b.CustId WHERE b.UserId = @UserID
				)
		if @ApartmentId is null
			set @ApartmentId = (SELECT top 1 ApartmentId FROM MAS_Apartment_Member a 
			inner join UserInfo b on a.CustId=b.CustId WHERE 
				exists(select userid from UserInfo where CustId = b.CustId and UserId = @UserId)
				)

		--set @ApartmentId = 4443
		SELECT @Total			= count(a.ReceiveId)
	  FROM [dbo].MAS_Service_ReceiveEntry a 
			INNER JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
			left join MAS_Service_Receipts c on a.ReceiveId = c.ReceiveId 
			  WHERE a.isExpected = 1 
				and (a.IsPayed = 0 or a.TotalAmt - a.PaidAmt > 0)
				and b.ApartmentId = @ApartmentId 

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 5)
		set		@Total					= isnull(@Total, 0)
		

		if		@PageSize	<= 0		set @PageSize	= 5
		if		@Offset		< 0			set @Offset		=  0

		if @Offset = 0
		begin
			SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Service_Receivable_Bill_Page', @gridWidth) 
			ORDER BY [ordinal]
		end

		--1
		SELECT a.ReceiveId
			  --,cast(month(a.ToDt) as varchar) [PeriodMonth]
			  --,cast(year(a.ToDt) as varchar) [PeriodYear]
			  ,format(a.ToDt,'MM/yyyy') as PeriodMonth
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceivableDate
			  ,format(a.PaidAmt,'###,###,###') as PaidAmt
			  ,format(TotalAmt,'###,###,###') as [TotalAmt]
			  ,convert(nvarchar(10),a.[ExpireDate],103) as [ExpireDate]
			  ,a.[IsPayed]
			  ,convert(nvarchar(10),a.ToDt,103) as toDate
			  , case when a.TotalAmt - a.PaidAmt = 0 then N'Đã thanh toán đủ' else ( case when a.IsPayed = 1 then N'Dư nợ :' + convert(nvarchar(10),format(a.TotalAmt - a.PaidAmt,'###,###,###')) + N'(Chuyển nợ)' end) end StatusPayed
			  --,case when a.IsPayed = 0 then N'Chờ thanh toán' else case when (a.TotalAmt - a.PaidAmt) > 0 then N'Còn nợ: '+ cast(format((a.TotalAmt - a.PaidAmt),'###,###,###') as nvarchar(15)) else N'Đã thanh toán đủ' end end as StatusPayed
			  ,N'Hóa đơn tháng ' + cast(month(a.ToDt) as varchar) + N'/' + cast(year(a.ToDt) as varchar) as Remark 
			  ,b.RoomCode
			  ,b.projectCd as ProjectCd
			  ,'' as FullName
	  FROM [dbo].MAS_Service_ReceiveEntry a 
			JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
			--left join MAS_Service_Receipts c on a.ReceiveId = c.ReceiveId 
			  WHERE a.isExpected = 1 
				and (a.IsPayed = 0 or a.TotalAmt - a.PaidAmt > 0)
				and b.ApartmentId = @apartmentId 
				  ORDER BY  a.ReceiveDt DESC
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
		set @ErrorMsg					= 'sp_Hom_Service_Receivable_Bill_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'PagePayment', 'GET', @SessionID, @AddlInfo
	end catch