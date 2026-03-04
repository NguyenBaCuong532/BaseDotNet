








CREATE procedure [dbo].[sp_Pay_Get_Wallet_PayHistory_ByNo]
	@UserId	nvarchar(450),
	@transNo nvarchar(100)
as
	begin try
	
	--1
		SELECT 
		   t.RefNo as [TransNo]
		  ,convert(nvarchar(10),t.TxnDt,103) + ' - ' + convert(nvarchar(5),t.TxnDt,108) [TransDate]
		  ,t.OrderInfo as Note
		  ,t.[Amount]
		  ,[dbo].[fn_Get_TimeAgo1] (t.TxnDt,getdate()) as DateAgo
		  ,case t.Status when 1 then N'Thành công' else N'Không thành công' end as StatusName
		  ,t.[Status]
		  ,t.DBCR
		  ,N'Tháng ' + cast(month(t.TxnDt)as nvarchar(2)) + '/' + cast(year(t.TxnDt)as nvarchar(4)) TimeGroup
		  ,t.TxnType as TransType
		  ,case t.TxnType when 1 then N'Nạp tiền vào ví' else N'Chi tiêu thanh toán' end as TransTypeName
		  ,isnull(b.ShortName,N'SPay') as SourceShortName
		  ,t.FeeAmt as FeeAmout
		  ,c.TransTypeName
		FROM [dbo].WAL_Transactions t
			--inner join WAL_Profile a on t.fromWalletCd = a.WalletCd or t.toWalletCd = a.WalletCd
			left join WAL_Banks b on t.SourceCd = b.SourceCd 
			left join WAL_TransactionType c on c.TransTypeId = t.TxnType
		WHERE t.RefNo = @transNo

		SELECT [CrdTransId]
				,[cardValue]
				,[Quantity]
				,b.ProviderShort as providerName
				,a.promotion
				,a.promotionAmt
			FROM [WAL_CrdTransaction] a 
				join WAL_Providers b on a.ProviderId = b.ProviderId 
				join WAL_Transactions c on c.WalTxnId = a.TxnId
			WHERE c.RefNo = @transNo
		--3
		SELECT [Id]
			  ,a.[CrdTransId]
			  ,[RechargeCode]
			  ,[CardSerial]
		  FROM [WAL_CrdTransactionRecharge] a
				join [WAL_CrdTransaction] b on a.CrdTransId = b.CrdTransId
				join WAL_Transactions c on c.WalTxnId = b.TxnId
		  WHERE c.RefNo = @transNo

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_PayHistory_ByNo ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Transaction', 'GET', @SessionID, @AddlInfo
	end catch