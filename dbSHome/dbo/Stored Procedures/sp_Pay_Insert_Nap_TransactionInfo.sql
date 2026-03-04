







CREATE procedure [dbo].[sp_Pay_Insert_Nap_TransactionInfo]
				
		 @UserID	nvarchar(450)
		,@ClientId nvarchar(50)
		,@ClientIp nvarchar(50)
		,@RefNo nvarchar(50)
		,@Amount bigint
		,@TranferCd nvarchar(20)
		,@SourceCd nvarchar(20)
		
	
as
	begin try		
			declare @vpc_MerchTxnRef nvarchar(50)
			set @vpc_MerchTxnRef = @RefNo + '/' + cast((SELECT count(*)+1 FROM [WAL_NpTransaction] WHERE [vpc_OrderInfo] = @RefNo) as varchar)
			
			INSERT INTO [dbo].[WAL_NpTransaction]
				   ([vpc_MerchTxnRef]
				   ,[vpc_OrderInfo]
				   ,[vpc_TicketNo]
				   ,[vpc_Amount]
				   ,[vpc_PaymentGateway]
				   ,[vpc_CardType]
				   ,[IsPayed]
				   ,[TranDt])
			 VALUES
				   (@vpc_MerchTxnRef
				   ,@RefNo
				   ,@ClientIp
				   ,@Amount
				   ,@TranferCd
				   ,@SourceCd
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
		  FROM [dbSHome].[dbo].[WAL_NpTransaction]
		  WHERE [vpc_MerchTxnRef] = @vpc_MerchTxnRef

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Nap_TransactionInfo ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@TransactionId ' + @vpc_MerchTxnRef 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'NapTransaction', 'Insert', @SessionID, @AddlInfo
	end catch