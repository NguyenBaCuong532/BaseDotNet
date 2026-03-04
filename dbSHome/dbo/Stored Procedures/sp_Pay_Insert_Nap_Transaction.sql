







CREATE procedure [dbo].[sp_Pay_Insert_Nap_Transaction]
				
		 @UserID	nvarchar(450)
		,@ClientIp nvarchar(50)
		,@orderId nvarchar(50)
		,@Amount bigint
		,@cardType nvarchar(20)
		,@transactionType nvarchar(20)
		,@linkedId int
	
as
	begin try		
			declare @linkedToken nvarchar(50)
			declare @vpc_MerchTxnRef nvarchar(50)
			set @vpc_MerchTxnRef = right('000'+ cast( DATEPART(ms,getdate()) as varchar),3) + CAST( DATEDIFF(ss, '2008-01-01', GETUTCDATE()) as varchar) 
			select @linkedToken = LinkedToken from WAL_TranferLinked where LinkedID = @linkedId

			INSERT INTO [dbo].[WAL_NpTransaction]
				   ([vpc_MerchTxnRef]
				   ,[vpc_OrderInfo]
				   ,[vpc_TicketNo]
				   ,[vpc_Amount]
				   ,[vpc_PaymentGateway]
				   ,[vpc_CardType]
				   ,vpc_Token
				   ,[IsPayed]
				   ,[TranDt]
				   )
			 VALUES
				   (@vpc_MerchTxnRef
				   ,@orderId
				   ,@ClientIp
				   ,@Amount
				   ,@transactionType
				   ,@cardType
				   ,@linkedToken
				   ,0
				   ,getdate()
				   )

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
				  --,c.LinkedID
		  FROM [WAL_NpTransaction] a 
			inner join WAL_Transactions d on a.vpc_OrderInfo = d.RefNo
			inner join WAL_Profile c on d.toWalletCd = c.WalletCd
			--left join WAL_TranferLinked b on b.LinkedID = c.LinkedID
		  WHERE [vpc_OrderInfo] = @orderId
			--and c.UserId = @UserID

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Nap_Transaction ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@TransactionId ' + @orderId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'NapTransaction', 'Insert', @SessionID, @AddlInfo
	end catch