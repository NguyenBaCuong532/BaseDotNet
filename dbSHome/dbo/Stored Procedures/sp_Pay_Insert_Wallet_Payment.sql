









CREATE procedure [dbo].[sp_Pay_Insert_Wallet_Payment]
	@UserID	nvarchar(450),
	@ClientId nvarchar(50),
	@ClientIp nvarchar(50),
	@RefNo nvarchar(50),
	@OrderInfo nvarchar(200),
	
	@Amount decimal,
	@fromWalletCd nvarchar(30),
	@toWalletCd nvarchar(30),
	@ServiceKey nvarchar(30),
	@PosCd nvarchar(20) 

as
	begin try	
	declare @errmessage nvarchar(100)
	declare @BaseCif nvarchar(20) 
	declare @FeeAmt decimal
	declare @DBCR bit 
	declare @TranferCd nvarchar(20)
	declare @SourceCd nvarchar(20) 
	declare @TxnType int

	set @DBCR = 0
	set @FeeAmt = 0
	set @TranferCd = 'SPAY'

	--exec utl_Insert_ErrorLog 0, @PosCd, 0, 'WALPayment', 'Insert', 0, @ServiceKey

	set @SourceCd = (SELECT [WalServiceCd] FROM [WAL_Services] Where ServiceKey = @ServiceKey)

	set @fromWalletCd = isnull(@fromWalletCd,(select WalletCd from WAL_Profile a inner join MAS_Contacts b on a.BaseCif = b.Cif_No 
		inner join UserInfo u on b.CustId = u.CustId 
	  WHERE u.[UserId] = @UserID))

	set @toWalletCd = isnull(@toWalletCd,(select WalletCd from WAL_Profile a inner join WAL_Services b on a.BaseCif = b.ProviderCd
		 where b.ServiceKey = @ServiceKey))

	if @ServiceKey = 'SK293982' --Tranfer
		set @txnType = 4
	else
		set @txnType = 2

	if exists(select walletCd from WAL_Profile where WalletCd = @fromWalletCd) and exists(select walletCd from WAL_Profile where WalletCd = @toWalletCd)
		EXECUTE [dbo].[sp_Pay_Insert_Wallet_Transaction] 
		   @fromWalletCd
		  ,@toWalletCd
		  ,@OrderInfo
		  ,@RefNo
		  ,@DBCR
		  ,@Amount
		  ,@FeeAmt
		  ,@PosCd
		  ,@ServiceKey
		  ,@TranferCd
		  ,@SourceCd
		  ,@ClientId
		  ,@ClientIp
		  ,@TxnType
		  ,0
		else
		begin
			set @errmessage = 'This wallet from: ' + isnull(@fromWalletCd,'') + ' to wallet: ' + isnull(@toWalletCd,'') + ' is not exists, can not do it!'

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
		set @ErrorMsg					= 'sp_Pay_Insert_Wallet_Payment ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@toWalletCd ' + isnull(@toWalletCd,'') + ' @fromWalletCd' + isnull(@fromWalletCd,'') + 'servicekey: ' + isnull(@ServiceKey,'')

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WALPayment', 'Insert', @SessionID, @AddlInfo
	end catch