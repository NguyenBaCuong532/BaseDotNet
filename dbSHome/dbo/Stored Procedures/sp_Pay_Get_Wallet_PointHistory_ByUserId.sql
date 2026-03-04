

CREATE procedure [dbo].[sp_Pay_Get_Wallet_PointHistory_ByUserId]
	@UserId	nvarchar(450),
	@FilterType nvarchar(50),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
		declare @month int
		declare @year int

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

	if @FilterType is null or len(@FilterType) <> 7
	begin
		select	@Total					= count(trn.Ref_No)
		FROM (
				SELECT t.Ref_No + '+' as Ref_No
				FROM [dbo].WAL_PointOrder t
					join MAS_Points a on t.PointCd = a.PointCd 
					join UserInfo u on a.CustId = u.CustId 
				WHERE u.UserId = @userId
					and t.Point > 0
				UNION ALL
				SELECT t.Ref_No + '-' as Ref_No
				FROM [dbo].WAL_PointOrder t
					join MAS_Points a on t.PointCd = a.PointCd 
					join UserInfo u on a.CustId = u.CustId 
				WHERE u.UserId = @userId
					and t.Point > 0
			) trn

		set @TotalFiltered = @Total

	-- all
		SELECT * FROM (
		SELECT t.Ref_No 
			  ,t.TransNo
			  ,t.[TranDt]
			  --,t.OrderInfo as Remark
			  --,case when t.Point > 0 then N'Tích điểm - ' else '' end + case when t.CreditPoint > 0 then N'Tiêu điểm - ' else '' end + isnull(s.ServiceName,'') as Remark
			  ,case when t.TranType = 'voucher' then 'Tặng điểm ' else N'Tích điểm tại ' end + isnull(s.ServiceName,'') as Remark
			  ,t.Point 
			  ,[dbo].[fn_Get_TimeAgo1] (t.TranDt,getdate()) as DateAgo
			  ,N'Tháng ' + cast(month(t.TranDt)as nvarchar(2)) + '/' + cast(year(t.TranDt)as nvarchar(4)) TimeGroup
			  ,t.TranType 
			  ,N'Thành công' as StatusName
			  ,1 [Status]
			  --,0 TranType
			FROM [dbo].WAL_PointOrder t
					join MAS_Points a on t.PointCd = a.PointCd 
					join UserInfo u on a.CustId = u.CustId 
					join WAL_Services s on t.ServiceKey = s.ServiceKey 
				WHERE u.UserId = @userId
					and t.Point > 0
		UNION ALL
		SELECT t.Ref_No 
			  ,t.TransNo
			  ,t.[TranDt]
			  --,t.OrderInfo as Remark
			  ,N'Thanh toán tại ' + isnull(s.ServiceName,'') as Remark
			  ,- t.CreditPoint as Point 
			  ,[dbo].[fn_Get_TimeAgo1] (t.TranDt,getdate()) as DateAgo
			  ,N'Tháng ' + cast(month(t.TranDt)as nvarchar(2)) + '/' + cast(year(t.TranDt)as nvarchar(4)) TimeGroup
			  ,t.TranType 
			  --,case t.TranType when 1 then N'Nạp tiền vào ví' else N'Chi tiêu thanh toán' end as TransTypeName
			  ,N'Thành công' as StatusName
			  ,1 [Status]
			  --,0 TranType
			FROM [dbo].WAL_PointOrder t
					join MAS_Points a on t.PointCd = a.PointCd 
					join UserInfo u on a.CustId = u.CustId 
					join WAL_Services s on t.ServiceKey = s.ServiceKey 
				WHERE u.UserId = @userId
					and t.CreditPoint > 0
			) trn
			ORDER BY trn.[TranDt] DESC
					  offset @Offset rows	
						fetch next @PageSize rows only

	end
	else
	begin	
		set @month = cast(SUBSTRING(@FilterType,1,2) as int)
		set @year = cast(SUBSTRING(@FilterType,4,4) as int)

		select	@Total					= count(trn.Ref_No)
		FROM (
				SELECT t.Ref_No + '+' as Ref_No
				FROM [dbo].WAL_PointOrder t
					join MAS_Points a on t.PointCd = a.PointCd 
					join UserInfo u on a.CustId = u.CustId 
				WHERE u.UserId = @userId
					and month(t.TranDt) = @month
					and year(t.TranDt) = @year
					and t.Point > 0
				UNION ALL
				SELECT t.Ref_No + '-' as Ref_No
				FROM [dbo].WAL_PointOrder t
					join MAS_Points a on t.PointCd = a.PointCd 
					join UserInfo u on a.CustId = u.CustId 
				WHERE u.UserId = @userId
					and month(t.TranDt) = @month
					and year(t.TranDt) = @year
					and t.Point > 0
			) trn

		set @TotalFiltered = @Total

		--for time filter
		SELECT * FROM (
		SELECT t.Ref_No 
			  ,t.TransNo
			  ,t.[TranDt]
			  --,t.OrderInfo as Remark
			  --,case when t.Point > 0 then N'Tích điểm - ' else '' end + case when t.CreditPoint > 0 then N'Tiêu điểm - ' else '' end + isnull(s.ServiceName,'') as Remark
			  ,case when t.TranType = 'voucher' then 'Tặng điểm ' else N'Tích điểm tại ' end + isnull(s.ServiceName,'') as Remark
			  ,t.Point 
			  ,[dbo].[fn_Get_TimeAgo1] (t.TranDt,getdate()) as DateAgo
			  ,N'Tháng ' + cast(month(t.TranDt)as nvarchar(2)) + '/' + cast(year(t.TranDt)as nvarchar(4)) TimeGroup
			  ,t.TranType 
			  ,N'Thành công' as StatusName
			  ,1 [Status]
			  --,0 TranType
			FROM [dbo].WAL_PointOrder t
					join MAS_Points a on t.PointCd = a.PointCd 
					join UserInfo u on a.CustId = u.CustId 
					join WAL_Services s on t.ServiceKey = s.ServiceKey 
				WHERE u.UserId = @userId
					and month(t.TranDt) = @month
					and year(t.TranDt) = @year
					and t.Point > 0
		UNION ALL
		SELECT t.Ref_No 
			  ,t.TransNo
			  ,t.[TranDt]
			  --,t.OrderInfo as Remark
			  ,N'Tiêu điểm tại ' + isnull(s.ServiceName,'') as Remark
			  ,- t.CreditPoint as Point 
			  ,[dbo].[fn_Get_TimeAgo1] (t.TranDt,getdate()) as DateAgo
			  ,N'Tháng ' + cast(month(t.TranDt)as nvarchar(2)) + '/' + cast(year(t.TranDt)as nvarchar(4)) TimeGroup
			  ,t.TranType 
			  --,case t.TranType when 1 then N'Nạp tiền vào ví' else N'Chi tiêu thanh toán' end as TransTypeName
			  ,N'Thành công' as StatusName
			  ,1 [Status]
			  --,0 TranType
			FROM [dbo].WAL_PointOrder t
					join MAS_Points a on t.PointCd = a.PointCd 
					join UserInfo u on a.CustId = u.CustId 
					join WAL_Services s on t.ServiceKey = s.ServiceKey 
				WHERE u.UserId = @userId
					and month(t.TranDt) = @month
					and year(t.TranDt) = @year
					and t.CreditPoint > 0
			) trn
			ORDER BY trn.[TranDt] DESC
					  offset @Offset rows	
						fetch next @PageSize rows only

	end
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_PayHistory_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Transaction', 'GET', @SessionID, @AddlInfo
	end catch