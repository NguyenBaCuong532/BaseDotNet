







CREATE procedure [dbo].[sp_Pay_Get_Wallet_PayHistory_ByUserId]
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
		--set		@FilterType				= isnull(@FilterType,-1)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

	if @FilterType is null or len(@FilterType) <> 7
	begin
		select	@Total					= count(RefNo)
				FROM [dbo].WAL_Transactions t
					inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
				WHERE a.UserId = @userId
					and t.TxnType <> 1 
					and t.TxnType <> 4
		set @TotalFiltered = @Total

	-- all
		SELECT t.RefNo as [TransNo]
			  ,t.TxnDt [TranDt]
			  ,t.OrderInfo as Note
			  ,t.[Amount]
			  ,[dbo].[fn_Get_TimeAgo1] (t.TxnDt,getdate()) as DateAgo
			  ,case t.Status when 1 then N'Thành công' else N'Không thành công' end as StatusName
			  ,t.[Status]
			  ,DBCR
			  ,N'Tháng ' + cast(month(t.TxnDt)as nvarchar(2)) + '/' + cast(year(t.TxnDt)as nvarchar(4)) TimeGroup
			  ,t.TxnType as TransType
			  ,case t.TxnType when 1 then N'Nạp tiền vào ví' else N'Chi tiêu thanh toán' end as TransTypeName
		FROM [dbo].WAL_Transactions t
			inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
			inner join MAS_Contacts b on a.BaseCif = b.Cif_No 
			inner join UserInfo u on b.CustId = u.CustId 
		WHERE u.UserId = @userId
		 and t.TxnType <> 1 
		 and t.TxnType <> 4
		ORDER BY [TranDt] DESC
				  offset @Offset rows	
					fetch next @PageSize rows only
	end
	else
	begin	
		set @month = cast(SUBSTRING(@FilterType,1,2) as int)
		set @year = cast(SUBSTRING(@FilterType,4,4) as int)
		select	@Total					= count(RefNo)
				FROM [dbo].WAL_Transactions t
					inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
				WHERE a.UserId = @userId
					and t.TxnType <> 1 
					and t.TxnType <> 4
					and month(t.TxnDt) = @month
					and year(t.TxnDt) = @year
		set @TotalFiltered = @Total

		--for time filter
		SELECT t.RefNo as [TransNo]
			  ,t.TxnDt [TranDt]
			  ,t.OrderInfo as Note
			  ,t.[Amount]
			  ,[dbo].[fn_Get_TimeAgo1] (t.TxnDt,getdate()) as DateAgo
			  ,case t.Status when 1 then N'Thành công' else N'Không thành công' end as StatusName
			  ,t.[Status]
			  ,DBCR
			  ,N'Tháng ' + cast(month(t.TxnDt)as nvarchar(2)) + '/' + cast(year(t.TxnDt)as nvarchar(4)) TimeGroup
			  ,t.TxnType as TransType
			  ,case t.TxnType when 1 then N'Nạp tiền vào ví' else N'Chi tiêu thanh toán' end as TransTypeName
		FROM [dbo].WAL_Transactions t
			inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
			inner join MAS_Contacts b on a.BaseCif = b.Cif_No 
			inner join UserInfo u on b.CustId = u.CustId 
		WHERE u.UserId = @userId
		 and t.TxnType <> 1 
		 and t.TxnType <> 4
		 and month(t.TxnDt) = @month
					and year(t.TxnDt) = @year
		ORDER BY [TranDt] DESC
				  offset @Offset rows	
					fetch next @PageSize rows only

	end
	--end
	--else if @FilterType = 0
	--begin
	--	select	@Total					= count(RefNo)
	--			FROM [dbo].WAL_Transactions t
	--				inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
	--			WHERE a.UserId = @userId
	--				and t.Status = 1
	--				and t.TxnType <> 1 
	--				and t.TxnType <> 4
	--	set @TotalFiltered = @Total

	----thanh cong
	--	SELECT t.RefNo as [TransNo]
	--		  ,t.TxnDt [TranDt]
	--		  ,t.OrderInfo as Note
	--		  ,t.[Amount]
	--		  ,[dbo].[fn_Get_TimeAgo1] (t.TxnDt,getdate()) as DateAgo
	--		  ,case t.Status when 1 then N'Thành công' else N'Không thành công' end as StatusName
	--		  ,t.[Status]
	--		  ,DBCR
	--		  ,N'Tháng ' + cast(month(t.TxnDt)as nvarchar(2)) + '/' + cast(year(t.TxnDt)as nvarchar(4)) TimeGroup
	--		  ,t.TxnType as TransType
	--		  ,case t.TxnType when 1 then N'Nạp tiền vào ví' else N'Chi tiêu thanh toán' end as TransTypeName
	--	FROM [dbo].WAL_Transactions t
	--		inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
	--		inner join MAS_Contacts b on a.BaseCif = b.Cif_No 
	--		inner join UserInfo u on b.CustId = u.CustId 
	--	WHERE u.UserId = @userId 
	--		and t.Status = 1
	--		and t.TxnType <> 1 
	--		and t.TxnType <> 4
	--	ORDER BY [TranDt] DESC
	--			  offset @Offset rows	
	--				fetch next @PageSize rows only
	--end
	--else if @FilterType = 1
	--begin
	--	select	@Total					= count(RefNo)
	--			FROM [dbo].WAL_Transactions t
	--				inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
	--			WHERE a.UserId = @userId
	--				and not t.Status = 1
	--				and t.TxnType <> 1 
	--				and t.TxnType <> 4
	--	set @TotalFiltered = @Total

	----that bai
	--	SELECT t.RefNo as [TransNo]
	--		  ,t.TxnDt [TranDt]
	--		  ,t.OrderInfo as Note
	--		  ,t.[Amount]
	--		  ,[dbo].[fn_Get_TimeAgo1] (t.TxnDt,getdate()) as DateAgo
	--		  ,case t.Status when 1 then N'Thành công' else N'Không thành công' end as StatusName
	--		  ,t.[Status]
	--		  ,DBCR
	--		  ,N'Tháng ' + cast(month(t.TxnDt)as nvarchar(2)) + '/' + cast(year(t.TxnDt)as nvarchar(4)) TimeGroup
	--		  ,t.TxnType as TransType
	--		  ,case t.TxnType when 1 then N'Nạp tiền vào ví' else N'Chi tiêu thanh toán' end as TransTypeName
	--	FROM [dbo].WAL_Transactions t
	--		inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
	--		inner join MAS_Contacts b on a.BaseCif = b.Cif_No 
	--		inner join UserInfo u on b.CustId = u.CustId 
	--	WHERE u.UserId = @userId 
	--		and not t.Status = 1
	--		and t.TxnType <> 1 
	--		and t.TxnType <> 4
	--	ORDER BY [TranDt] DESC
	--			  offset @Offset rows	
	--				fetch next @PageSize rows only
	--end
	--else if @FilterType = 2
	--begin
	--	select	@Total					= count(RefNo)
	--			FROM [dbo].WAL_Transactions t
	--				inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
	--			WHERE a.UserId = @userId
	--				and t.TxnType = 1 
	--				--and t.TxnType <> 4
	--	set @TotalFiltered = @Total

	----nap tien
	--	SELECT t.RefNo as [TransNo]
	--		  ,t.TxnDt [TranDt]
	--		  ,t.OrderInfo as Note
	--		  ,t.[Amount]
	--		  ,[dbo].[fn_Get_TimeAgo1] (t.TxnDt,getdate()) as DateAgo
	--		  ,case t.Status when 1 then N'Thành công' else N'Không thành công' end as StatusName
	--		  ,t.[Status]
	--		  ,DBCR
	--		  ,N'Tháng ' + cast(month(t.TxnDt)as nvarchar(2)) + '/' + cast(year(t.TxnDt)as nvarchar(4)) TimeGroup
	--		  ,t.TxnType as TransType
	--		  ,case t.TxnType when 1 then N'Nạp tiền vào ví' else N'Chi tiêu thanh toán' end as TransTypeName
	--	FROM [dbo].WAL_Transactions t
	--		inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
	--		inner join MAS_Contacts b on a.BaseCif = b.Cif_No 
	--		inner join UserInfo u on b.CustId = u.CustId 
	--	WHERE u.UserId = @userId 
	--		and t.TxnType = 1
	--		--and t.TxnType <> 1 
	--		--and t.TxnType <> 4
	--	ORDER BY [TranDt] DESC
	--			  offset @Offset rows	
	--				fetch next @PageSize rows only
	--end
	--else --if @FilterType = 0
	--begin
	--	select	@Total					= count(RefNo)
	--			FROM [dbo].WAL_Transactions t
	--				inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
	--			WHERE a.UserId = @userId
	--				and t.TxnType <> 1 
	--				--and t.TxnType <> 4
	--	set @TotalFiltered = @Total

	----thanh toan
	--	SELECT t.RefNo as [TransNo]
	--		  ,t.TxnDt [TranDt]
	--		  ,t.OrderInfo as Note
	--		  ,t.[Amount]
	--		  ,[dbo].[fn_Get_TimeAgo1] (t.TxnDt,getdate()) as DateAgo
	--		  ,case t.Status when 1 then N'Thành công' else N'Không thành công' end as StatusName
	--		  ,t.[Status]
	--		  ,DBCR
	--		  ,N'Tháng ' + cast(month(t.TxnDt)as nvarchar(2)) + '/' + cast(year(t.TxnDt)as nvarchar(4)) TimeGroup
	--		  ,t.TxnType as TransType
	--		  ,case t.TxnType when 1 then N'Nam tiền vào ví' else N'Chi tiêu thanh toán' end as TransTypeName
	--	FROM [dbo].WAL_Transactions t
	--		inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
	--		inner join MAS_Contacts b on a.BaseCif = b.Cif_No 
	--		inner join UserInfo u on b.CustId = u.CustId 
	--	WHERE u.UserId = @userId 
	--		and not t.TxnType = 1
	--	ORDER BY [TranDt] DESC
	--			  offset @Offset rows	
	--				fetch next @PageSize rows only
	--end

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