









CREATE procedure [dbo].[sp_Pay_Get_Wallet_PointHistory_ByNo]
	@UserId	nvarchar(450),
	@transNo nvarchar(100)
as
	begin try
	
	--1
		SELECT t.Ref_No 
			  ,t.TransNo
			  ,t.[TranDt]
			  --,t.OrderInfo as Remark
			  ,case when t.Point > 0 then N'Tích điểm - ' else '' end + case when t.CreditPoint > 0 then N'Tiêu điểm - ' else '' end + isnull(s.ServiceName,'') as Remark
			  ,t.Point 
			  ,[dbo].[fn_Get_TimeAgo1] (t.TranDt,getdate()) as DateAgo
			  ,N'Tháng ' + cast(month(t.TranDt)as nvarchar(2)) + '/' + cast(year(t.TranDt)as nvarchar(4)) TimeGroup
			  ,t.TranType 
			  --,case t.TranType when 1 then N'Nạp tiền vào ví' else N'Chi tiêu thanh toán' end as TransTypeName
			  ,N'Thành công' as StatusName
			  ,1 [Status]
		FROM [dbo].WAL_PointOrder t
					join MAS_Points a on t.PointCd = a.PointCd 
					join UserInfo u on a.CustId = u.CustId 
					join WAL_Services s on t.ServiceKey = s.ServiceKey 
		WHERE t.TransNo = @transNo

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
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_PointHistory_ByNo ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Transaction', 'GET', @SessionID, @AddlInfo
	end catch