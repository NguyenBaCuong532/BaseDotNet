








CREATE procedure [dbo].[sp_Pay_Insert_Buy_TelephoneCard]
	@UserID	nvarchar(450),
	@ProviderCd nvarchar(50),
	@cardValue int,
	@Quantity int,
	@ClientId nvarchar(50) = null,
	@ClientIp nvarchar(50) = null,
	@ServiceKey nvarchar(50) = null,
	@PosCd nvarchar(50) = null
as
	begin try	
	declare @TxnId bigint
	declare @RefNo nvarchar(20) 
	declare @OrderInfo nvarchar(100)
	declare @FeeAmt decimal
	declare @DBCR bit 
	declare @TranferCd nvarchar(20)
	declare @SourceCd nvarchar(20) 
	
	declare @fromWalletCd nvarchar(30) = null
	declare @toWalletCd nvarchar(30) = null
	declare @i int
	declare @CrdTransId int
	declare @ProviderId int
	declare @promotion float

	set @DBCR = 0
	set @FeeAmt = 0
	set @TranferCd = 'SPAY'
	set @promotion = 0.03

	--exec utl_Insert_ErrorLog 0, @PosCd, 0, 'WALPayment', 'Insert', 0, @ServiceKey
	set @RefNo = 'C'+ right('000'+ cast( DATEPART(ms,getdate()) as varchar),3) + CAST( DATEDIFF(ss, '2018-01-01', GETUTCDATE()) as varchar) 
	select @OrderInfo = N'Mua ' + cast(@Quantity as varchar) + N' thẻ di động ' + ProviderShort, @ProviderId = ProviderId
	FROM WAL_Providers 
		where ProviderCd = @ProviderCd

	SELECT @SourceCd =[WalServiceCd], @ServiceKey = a.ServiceKey, @PosCd = c.PosCd
		FROM [WAL_Services] a 
			inner join WAL_Service_Provider b on a.ServiceKey = b.ServiceKey 
			inner join WAL_ServicePOS c on b.ServiceKey = c.ServiceKey Where b.ProviderId = @ProviderId

	set @fromWalletCd = isnull(@fromWalletCd,(select WalletCd from WAL_Profile a inner join MAS_Contacts b on a.BaseCif = b.Cif_No 
		inner join UserInfo u on b.CustId = u.CustId 
	  WHERE u.[UserId] = @UserID))

	set @toWalletCd = isnull(@toWalletCd,(select WalletCd from WAL_Profile a inner join WAL_Providers b on a.BaseCif = b.ProviderCd
		 where b.ProviderId = @ProviderId))
		 	
	if @Quantity <= 5 and exists(select walletCd from WAL_Profile where WalletCd = @toWalletCd)
	begin
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
				   )
			 VALUES
				   (@fromWalletCd
				   ,@toWalletCd
				   ,getdate()
				   ,@RefNo
				   ,@OrderInfo
				   ,@cardValue*@Quantity
				   ,@FeeAmt
				   ,@DBCR
				   ,@PosCd
				   ,@ServiceKey
				   ,@TranferCd
				   ,@SourceCd
				   ,@ClientId
				   ,@ClientIp
				   ,0--@Status
				   ,3
				   )

			set @TxnId = @@IDENTITY


		EXECUTE [dbo].sp_Pay_Insert_Wallet_TransactionPayed 
			 @RefNo
			,'Success'
			,0
			

		--
		INSERT INTO [dbo].[WAL_CrdTransaction]
				   ([UserID]
				   ,[TxnId]
				   ,[ProviderId]
				   ,[cardValue]
				   ,[Quantity]
				   ,[TnxDt]
				   ,[IsTrans]
				   ,[ClientId]
				   ,promotion
				   ,promotionAmt
				   )
			 VALUES
				   (@UserID
				   ,@TxnId
				   ,@ProviderId
				   ,@cardValue
				   ,@Quantity
				   ,getdate()
				   ,1
				   ,@ClientId
				   ,@promotion
				   ,@promotion*@cardValue*@Quantity
				   )

		set @CrdTransId = @@IDENTITY
		set @i = 1

		WHILE @i <= @Quantity
		BEGIN
			INSERT INTO [dbo].[WAL_CrdTransactionRecharge]
				   ([CrdTransId]
				   ,[RechargeCode]
				   ,[CardSerial])
			 VALUES
				   (@CrdTransId
				   ,right('0000000000000' + cast(CAST(RAND(CHECKSUM(NEWID())) * 1000000000000 as bigint) as nvarchar(13)),13)
				   ,CAST(RAND(CHECKSUM(NEWID())) * 10000000000 as bigint)
				   
				   )

			SET @i = @i + 1
			/* do some work */
		END
		
		--1
		SELECT [WalTxnId]
			  ,[TxnDt] as BuyDate
			  ,[RefNo]
			  --,[OrderInfo]
			  ,[Amount]
			  ,[FeeAmt] as Fee
			  ,[DBCR]
			  ,[TranferCd] as SourceName 
		  FROM [WAL_Transactions]
		  WHERE WalTxnId = @TxnId

		  --2
		  SELECT [CrdTransId]
				,[cardValue]
				,[Quantity]
				,b.ProviderShort as providerName
				,a.promotion
				,a.promotionAmt
			FROM [dbSHome].[dbo].[WAL_CrdTransaction] a 
				join WAL_Providers b on a.ProviderId = b.ProviderId 
			WHERE [CrdTransId] = @CrdTransId
		--3
		SELECT [Id]
			  ,[CrdTransId]
			  ,[RechargeCode]
			  ,[CardSerial]
		  FROM [WAL_CrdTransactionRecharge]
		  WHERE [CrdTransId] = @CrdTransId
	end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Buy_TelephoneCard ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@SCard ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'STelephoneCard', 'Insert', @SessionID, @AddlInfo
	end catch