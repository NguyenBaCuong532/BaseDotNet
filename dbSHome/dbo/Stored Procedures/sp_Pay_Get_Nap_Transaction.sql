








CREATE procedure [dbo].[sp_Pay_Get_Nap_Transaction]
		@orderId nvarchar(50)
	
as
	begin try		

			SELECT [NpTranId]
				  ,[vpc_MerchTxnRef] as TxnNo
				  ,[vpc_OrderInfo] as RefNo
				  ,[vpc_TicketNo] as ClientIp
				  ,[vpc_Amount] as Amount
				  ,[vpc_PaymentGateway] as TranferCd
				  ,[vpc_CardType] as SourceCd
				  ,[IsPayed]
				  ,[TranDt]
				  ,a.vpc_Token as LinkedToken
		  FROM [WAL_NpTransaction] a 
			inner join WAL_Transactions d on a.vpc_OrderInfo = d.RefNo
			inner join WAL_Profile c on d.toWalletCd = c.WalletCd
			--left join WAL_TranferLinked b on b.LinkedID = c.LinkedID
		  WHERE [vpc_OrderInfo] = @orderId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Nap_Transaction ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@TransactionId ' + @orderId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'NapTransaction', 'Get', @SessionID, @AddlInfo
	end catch