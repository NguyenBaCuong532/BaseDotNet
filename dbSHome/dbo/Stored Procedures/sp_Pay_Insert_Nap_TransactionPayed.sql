


CREATE procedure [dbo].[sp_Pay_Insert_Nap_TransactionPayed]
		 --@UserID	nvarchar(450)
		 @vpc_MerchTxnRef nvarchar(50)
		,@vpc_Amount bigint
		,@vpc_OrderInfo nvarchar(50)
		,@vpc_TransactionNo nvarchar(100)
		,@vpc_BatchNo nvarchar(150)
		,@vpc_AcqResponseCode nvarchar(50)
		,@vpc_AdditionalData nvarchar(100)
		,@vpc_ResponseCode int
		,@vpc_Message nvarchar(200)

as
	begin try	
	declare @errmessage nvarchar(100)
		set @errmessage = 'This transaction: ' + @vpc_MerchTxnRef + ' is payed, can not do it!'
			
	IF not exists(SELECT NpTranId FROM WAL_NpTransaction WHERE [vpc_OrderInfo] = @vpc_OrderInfo AND IsPayed = 1)
	BEGIN
			INSERT INTO [dbo].[WAL_NpTransactionPay]
				   ([NpTranId]
				   ,[vpc_MerchTxnRef]
				   ,[vpc_Amount]
				   ,[vpc_OrderInfo]
				   ,[vpc_TransactionNo]
				   ,[vpc_BatchNo]
				   ,[vpc_AcqResponseCode]
				   ,[vpc_AdditionalData]
				   ,[vpc_ResponseCode]
				   ,[vpc_Message]
				   ,[TranPayDt])
			 SELECT
				    NpTranId
				   ,@vpc_MerchTxnRef
				   ,@vpc_Amount
				   ,@vpc_OrderInfo
				   ,@vpc_TransactionNo
				   ,@vpc_BatchNo
				   ,@vpc_AcqResponseCode
				   ,@vpc_AdditionalData
				   ,@vpc_ResponseCode
				   ,@vpc_Message
				   ,getdate()
			FROM WAL_NpTransaction 
			WHERE vpc_OrderInfo = @vpc_OrderInfo
				--AND IsPayed <> 1

			if @vpc_ResponseCode = 0
			begin
				UPDATE [dbo].WAL_NpTransaction
				   SET IsPayed = 1
				WHERE vpc_OrderInfo = @vpc_OrderInfo
					--AND IsPayed <> 1

				EXECUTE [dbo].[sp_Pay_Insert_Wallet_TransactionPayed] 
				   @vpc_OrderInfo
				  ,'Success'
				  ,@vpc_ResponseCode
				  
			end
			else
			begin
				UPDATE [dbo].WAL_NpTransaction
				   SET IsPayed = 2
				WHERE vpc_OrderInfo = @vpc_OrderInfo
			end
	END
	ELSE
			RAISERROR (@errmessage, -- Message text.
				   16, -- Severity.
				   1 -- State.
				   );
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Insert_Bank_Transaction ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@TxnRef ' + @vpc_MerchTxnRef 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'NapTransactionPayed', 'Insert', @SessionID, @AddlInfo
	end catch