





CREATE procedure [dbo].[sp_Hom_App_Payment_ByUserId]
	@UserId	nvarchar(450),
	@ApartmentId int,
	@payType			int				= 0,
	@Month				int				= 0,
	@Year				int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 3,
	@Total				bigint out,
	@TotalFiltered		bigint out
as
	begin try
		
		if @ApartmentId is null or @ApartmentId = 0
			set @ApartmentId = (select top 1 ApartmentId from [dbo].[fn_Hom_User_Apartment] (@userId))
			
		--set @ApartmentId = 4443

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 5)
		set		@Total					= isnull(@Total, 0)
		set		@Month					= isnull(@Month, 0)
		set		@Year					= isnull(@Year, 0)
		set		@payType				= isnull(@payType,0)

		if		@PageSize	= 0			set @PageSize	= 3
		if		@Offset		< 0			set @Offset		=  0
		if		@Year		= 0			set @Year		= YEAR(dateadd(month,-1,getdate()))


		select	@Total					= count(a.ReceiveId)
			FROM MAS_Service_ReceiveEntry a 
				--INNER JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
				WHERE a.ApartmentId = @ApartmentId 
					and ((@Month = 0 and (year(a.ToDt) >= @Year)) or (year(a.ToDt) = @Year And month(a.ToDt) = @Month))
					and a.IsBill = 1

			set	@TotalFiltered = @Total

		--1
		SELECT a.ReceiveId
			  ,cast(month(a.ToDt) as varchar) [PeriodMonth]
			  ,cast(year(a.ToDt) as varchar) [PeriodYear]
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceivableDate--+ ' ' + convert(nvarchar(10),a.[PayDt],108) as [PayDate]
			  ,TotalAmt as [TotalAmt]
			  ,convert(nvarchar(10),a.[ExpireDate],103) as [ExpireDate]--+ ' ' + convert(nvarchar(10),a.[ExpireDate],108) as [ExpireDate]
			  ,a.[IsPayed]
			  --,convert(nvarchar(10),a.FromDt,103) as fromDate
			  ,convert(nvarchar(10),a.ToDt,103) as toDate
			  ,case when a.IsPayed = 1 then N'Đã thanh toán' else N'Chờ thanh toán' end as StatusPayed
			  ,case when a.isExpected = 1 then N'Hóa đơn tháng ' + cast(month(a.ToDt) as varchar) + N'/' + cast(year(a.ToDt) as varchar) else a.Remart end as Remark 
			  --,c.Contents as Remart
	  FROM [dbo].MAS_Service_ReceiveEntry a 
			--INNER JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
			--left join MAS_Service_Receipts c on a.ReceiveId = c.ReceiveId 
			  WHERE a.ApartmentId = @ApartmentId 
				and ((@Month = 0 and (year(a.ToDt) >= @Year)) or (year(a.ToDt) = @Year And month(a.ToDt) = @Month))
				and a.IsBill = 1
				  ORDER BY a.ReceiveDt DESC
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
		set @ErrorMsg					= 'sp_Hom_Get_Page_Payment_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'PagePayment', 'GET', @SessionID, @AddlInfo
	end catch