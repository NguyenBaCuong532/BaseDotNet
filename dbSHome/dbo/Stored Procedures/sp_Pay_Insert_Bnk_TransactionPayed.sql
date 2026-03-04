





CREATE procedure [dbo].[sp_Pay_Insert_Bnk_TransactionPayed]
				
		 @UserID	nvarchar(450)
		,@TransactionId nvarchar(50)
		,@BankTransactionID nvarchar(50)
		,@BankAmount decimal(28,0)
		,@BankTransactionDt datetime
		,@BankDescription nvarchar(150)
		,@BankName nvarchar(50)
as
	begin try		
	declare @errmessage nvarchar(100)
	set @errmessage = 'This transaction: ' + @TransactionId + ' is payed, can not do it!'

	IF not exists(SELECT BkTransactionId FROM WAL_BkTransaction WHERE BkTransactionId = @TransactionId AND [IsTrans] = 1)
	BEGIN
			INSERT INTO [dbo].WAL_BkTransactionPay
				   (BkTransactionId
				   ,[BankTransactionID]
				   ,[BankAmount]
				   ,[BankTransactionDt]
				   ,[BankDescription]
				   ,BankName
				   )
			 VALUES
				   (@TransactionId
				   ,@BankTransactionID
				   ,@BankAmount
				   ,@BankTransactionDt
				   ,@BankDescription
				   ,@BankName
				   )

			UPDATE [dbo].WAL_BkTransaction
			   SET [IsTrans] = 1
			WHERE BkTransactionId = @TransactionId
			
			EXECUTE [dbo].[sp_Pay_Insert_Wallet_TransactionPayed] 
				   @TransactionId
				  ,'Success'
				  ,0
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

		set @AddlInfo					= '@BankTransactionID ' + @BankTransactionID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'BankTransaction', 'Insert', @SessionID, @AddlInfo
	end catch