








CREATE procedure [dbo].[sp_Pay_Get_Wallet_Transaction_ByManager]
	@UserId	nvarchar(450),
	@filter nvarchar(100) = null,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
	
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(RefNo)
				FROM [dbo].WAL_Transactions t
				--	inner join WAL_Profile a on t.fromWalletCd = a.WalletCd 
				--WHERE a.UserId = @userId
				


		set @TotalFiltered = @Total

	--1
		SELECT 
		   t.RefNo as [TransNo]
		  ,convert(nvarchar(10),t.TxnDt,103) + ' - ' + convert(nvarchar(5),t.TxnDt,108) [TransDate]
		  ,t.OrderInfo as Note
		  ,t.[Amount]
		  ,[dbo].[fn_Get_TimeAgo1] (t.TxnDt,getdate()) as DateAgo
		  ,case t.Status when 0 then N'Chờ chuyển tiền' when 1 then N'Thành công' else N'Không thành công' end as StatusName
		  ,t.DBCR
		  ,N'Tháng ' + cast(month(t.TxnDt)as nvarchar(2)) + '/' + cast(year(t.TxnDt)as nvarchar(4)) TimeGroup
		  ,t.TxnType as TransType
		  ,b.ShortName as SourceShortName
		  ,d.FullName 
		  ,c.Email 
		  ,c.Phone

		FROM [dbo].WAL_Transactions t
			inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
			inner join MAS_Contacts c on a.BaseCif = c.Cif_No
			inner join MAS_Customers d On c.CustId = d.CustId 
			left join WAL_Banks b on t.SourceCd = b.SourceCd 
		--WHERE a.UserId = @userId
		ORDER BY t.TxnDt DESC
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
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_PayHistory_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Transaction', 'GET', @SessionID, @AddlInfo
	end catch