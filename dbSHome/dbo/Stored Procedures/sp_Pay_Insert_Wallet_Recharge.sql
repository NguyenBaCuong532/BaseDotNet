









CREATE procedure [dbo].[sp_Pay_Insert_Wallet_Recharge]
	@UserID	nvarchar(450),
	@ClientId nvarchar(50),
	@ClientIp nvarchar(50),
	@TranferCd nvarchar(20),
	@LinkedID int,
	@Amount decimal,
	@ordTnxId bigint
	
as
	begin try	
	
	declare @RefNo nvarchar(50) 
	declare @OrderInfo nvarchar(200)
	declare @ServiceKey nvarchar(20) 
	declare @FeeAmt decimal
	declare @DBCR bit 
	declare @PosCd nvarchar(20) 
	declare @SourceCd nvarchar(20) 
	declare @toWalletCd nvarchar(20)
	declare @fromWalletCd nvarchar(20) 
		
	set @RefNo = 'R'+ right('000'+ cast( DATEPART(ms,getdate()) as varchar),3) + CAST( DATEDIFF(ss, '2018-01-01', GETUTCDATE()) as varchar) 
	set @DBCR = 1
	if @LinkedID > 0
		set @FeeAmt = (select case when a.IsFee = 1 then 0 else a.FixFee + round(0.011*@Amount,0) end as Fee
			from WAL_BankLinked c 
				inner join WAL_Tranfers a on c.TranferCd = a.TranferCd 
				inner join WAL_Banks b on c.SourceCd = b.SourceCd
				inner join WAL_TranferLinked d on c.SourceCd = d.SourceCd and c.TranferCd = d.TranferCd 
			where d.LinkedID = @LinkedID)
	else
		set @FeeAmt = (select top (1) case when a.IsFee = 1 then 0 else a.FixFee + round(0.011*@Amount,0) end as Fee
			from WAL_BankLinked c 
				inner join WAL_Tranfers a on c.TranferCd = a.TranferCd 
				inner join WAL_Banks b on c.SourceCd = b.SourceCd
			where c.TranferCd = @TranferCd)

	SELECT @ServiceKey = ws.[ServiceKey],@fromWalletCd = wp.WalletCd, @PosCd = sp.PosCd
				  FROM [WAL_Services] ws inner join WAL_Profile wp on UserId = ServiceKey
						left join (SELECT * FROM WAL_ServicePOS WHERE IsSPay = 1) sp on ws.ServiceKey = sp.ServiceKey
				  where [WalServiceCd] = 'SPay'

	SELECT @toWalletCd = a.WalletCd
	  FROM [WAL_Profile] a 
		inner join MAS_Contacts b on a.BaseCif = b.Cif_No 
		inner join UserInfo u on b.CustId = u.CustId 
	  WHERE u.[UserId] = @UserID
   
   if isnull(@LinkedID,0)>0
   begin
	   SELECT  @OrderInfo = N'Nạp tiền từ ' + c.ShortName
		  FROM [WAL_Banks] c 
			inner join WAL_TranferLinked d on c.SourceCd = d.SourceCd
			where d.LinkedID = @LinkedID
		SELECT @TranferCd = [TranferCd]
			  ,@SourceCd = SourceCd 
		FROM WAL_TranferLinked WHERE LinkedID = @LinkedID
	end
	else
	begin
		SELECT  @OrderInfo = N'Nạp tiền từ ' + c.TranferName
		  FROM [WAL_Tranfers] c 
		  where c.TranferCd = @TranferCd
	end
	if ((exists(SELECT [TranferCd] FROM WAL_TranferLinked WHERE LinkedID = @LinkedID) and @LinkedID>0) 
		OR (exists(SELECT TranferCd FROM [WAL_Tranfers] WHERE TranferCd = @TranferCd) and @LinkedID = 0)
		)
		and exists(select walletCd from WAL_Profile where WalletCd = @fromWalletCd) 
		and exists(select walletCd from WAL_Profile where WalletCd = @toWalletCd)

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
			  ,1 
			  ,@ordTnxId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Wallet_Recharge ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@SCard ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WALRecharge', 'Insert', @SessionID, @AddlInfo
	end catch