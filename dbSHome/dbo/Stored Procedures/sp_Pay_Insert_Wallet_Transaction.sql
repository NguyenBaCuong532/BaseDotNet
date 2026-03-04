








CREATE procedure [dbo].[sp_Pay_Insert_Wallet_Transaction]
	 @fromWalletCd	nvarchar(20)
	,@toWalletCd nvarchar(20)
	,@OrderInfo nvarchar(100)
	,@RefNo nvarchar(100)
	,@DBCR bit
	,@Amount decimal
	,@FeeAmt int
	,@PosCd nvarchar(30)
	,@BranchCd nvarchar(50)
	,@TranferCd nvarchar(50)
	,@SourceCd nvarchar(20)
	,@ClientId nvarchar(50)
	,@ClientIp nvarchar(50)
	,@TxnType int 
	,@ordTnxId bigint
as
	begin try		
		declare @errmessage nvarchar(100)
		--DECLARE @Txn_No nvarchar(50)
		
		IF not exists(select WalTxnId from WAL_Transactions where RefNo = @RefNo)
		BEGIN
			--set @Txn_No = 'T'+ right('000'+ cast( DATEPART(ms,getdate()) as varchar),3) + CAST( DATEDIFF(ss, '2008-01-01', GETUTCDATE()) as varchar) 

			INSERT INTO [dbo].[WAL_Transactions]
				   (fromWalletCd
				   ,toWalletCd
				   ,TxnDt
				   ,[RefNo]
				   ,[OrderInfo]
				   ,[Amount]
				   ,[FeeAmt]
				   ,[DBCR]
				   ,[PosCd]
				   ,[BranchCd]
				   ,[TranferCd]
				   ,[SourceCd]
				   ,[ClientId]
				   ,[ClientIp]
				   ,[Status]
				   ,TxnType 
				   ,OrdTxnId
				   )
			 VALUES
				   (@fromWalletCd
				   ,@toWalletCd
				   ,getdate()
				   ,@RefNo
				   ,@OrderInfo
				   ,@Amount
				   ,@FeeAmt
				   ,@DBCR
				   ,@PosCd
				   ,@BranchCd
				   ,@TranferCd
				   ,@SourceCd
				   ,@ClientId
				   ,@ClientIp
				   ,0--@Status
				   ,@TxnType --case when @DBCR = 1 then 1 else 2 end
				   ,@ordTnxId
				   )
		END 
		ELSE
		begin
			set @errmessage = 'This transaction: ' + @RefNo + ' is payed, can not do it!'

			RAISERROR (@errmessage, -- Message text.
				   16, -- Severity.
				   1 -- State.
				   );
		
		end

		SELECT   a.[WalTxnId]
				,a.fromWalletCd
				,a.toWalletCd
				,a.[TxnDt]
				,a.[RefNo]
				,a.[OrderInfo]
				,a.[Amount]
				,a.[FeeAmt]
				,a.[DBCR]
				,a.[PosCd]
				,a.[BranchCd]
				,a.[TranferCd]
				,a.[SourceCd]
				,a.[ClientId]
				,a.[ClientIp]
				,a.[Status]
				--,b.LinkedToken as LinkedToken
			FROM [WAL_Transactions] a
				--left join WAL_TranferLinked b on a.fromWalletCd = b.WalletCd and a.TranferCd = b.TranferCd
			WHERE RefNo = @RefNo

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Wallet_Transaction ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@toWalletCd ' + @toWalletCd + ' @fromWalletCd' + @fromWalletCd

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WAL_Transactions', 'Insert', @SessionID, @AddlInfo
	end catch