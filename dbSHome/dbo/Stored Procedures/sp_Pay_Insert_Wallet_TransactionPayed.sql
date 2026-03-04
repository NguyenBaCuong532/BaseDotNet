








CREATE procedure [dbo].[sp_Pay_Insert_Wallet_TransactionPayed]
	@RefNo nvarchar(50),
	@SourceCd nvarchar(50),
	@ResponseCode int
as
	begin try		
		declare @ordTnxRef nvarchar(50)
		DECLARE @Txn_No nvarchar(50)
		declare @errmessage nvarchar(100)
		
		IF exists(select WalTxnId from WAL_Transactions where RefNo = @RefNo)
		BEGIN
			set @ordTnxRef = (select a.RefNo FROM [dbo].WAL_Transactions t JOIN WAL_Transactions a On t.OrdTxnId = a.WalTxnId
					WHERE t.RefNo = @RefNo)

			if @ResponseCode = 0
			 begin
				
				UPDATE p
				   SET CurrAmount = CurrAmount - t.Amount --case when t.DBCR = 1 then t.Amount else -t.Amount end
					  ,[LastDt] = getdate()
					FROM WAL_Profile p 
						inner join WAL_Transactions t on p.WalletCd = t.fromWalletCd 
				 WHERE t.RefNo = @RefNo 

				 UPDATE p
				   SET CurrAmount = CurrAmount + t.Amount --case when t.DBCR = 1 then t.Amount else -t.Amount end
					  ,[LastDt] = getdate()
					FROM WAL_Profile p 
						inner join WAL_Transactions t on p.WalletCd = t.toWalletCd 
				 WHERE t.RefNo = @RefNo 

				 UPDATE t
				   SET [Status] = 1
				      ,SourceCd = isnull(@SourceCd,SourceCd)
				 FROM [dbo].WAL_Transactions t 
				 WHERE t.RefNo = @RefNo

				 if @ordTnxRef is not null
					EXECUTE [dbo].[sp_Pay_Insert_Wallet_TransactionPayed] 
					   @ordTnxRef
					  ,NULL
					  ,@ResponseCode
			 end
			 else
			 begin
				UPDATE t
				   SET [Status] = 2
				 FROM [dbo].WAL_Transactions t 
				 WHERE t.RefNo = @RefNo

				 if @ordTnxRef is not null
					UPDATE t
					   SET [Status] = 2
					 FROM [dbo].WAL_Transactions t 
					 WHERE t.RefNo = @ordTnxRef
			 end
		END
		ELSE
		begin
			set @errmessage = 'This transaction: ' + @RefNo + ' is not exists, can not do it!'

			RAISERROR (@errmessage, -- Message text.
				   16, -- Severity.
				   1 -- State.
				   );
		
		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Wallet_TransactionPayed ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Trans ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Trans', 'Insert', @SessionID, @AddlInfo
	end catch