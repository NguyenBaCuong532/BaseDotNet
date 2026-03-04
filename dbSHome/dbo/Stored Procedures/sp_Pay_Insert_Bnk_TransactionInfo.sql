






CREATE procedure [dbo].[sp_Pay_Insert_Bnk_TransactionInfo]
				
		 @UserID	nvarchar(450)
		,@TransactionId nvarchar(50)
		,@CustomerID nvarchar(50)
		,@Period nvarchar(100)
		,@Amount decimal(28,0)
		,@PaymentDt datetime
		,@Description nvarchar(150)
		,@PaymentTypeID int
	
as
	begin try		
		if not exists(select BkTransactionId from WAL_BkTransaction WHERE BkTransactionId = @TransactionId)
			INSERT INTO [dbo].WAL_BkTransaction
				   (BkTransactionId
				   ,[CustomerID]
				   ,[Period]
				   ,[Amount]
				   ,[PaymentDt]
				   ,[Description]
				   ,[PaymentTypeID]
				   ,[IsTrans]
				   )
			 VALUES
				   (NEWID()
				   ,@CustomerID
				   ,@Period
				   ,@Amount
				   ,@PaymentDt
				   ,@Description
				   ,@PaymentTypeID
				   ,0)
		else
			UPDATE [dbo].WAL_BkTransaction
			   SET [Period] = @Period
				  ,[Amount] = @Amount
				  ,[PaymentDt] = @PaymentDt
				  ,[Description] = @Description
				  ,[PaymentTypeID] = @PaymentTypeID
			WHERE BkTransactionId = @TransactionId
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

		set @AddlInfo					= '@TransactionId ' + @TransactionId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'SacombankTransaction', 'Insert', @SessionID, @AddlInfo
	end catch