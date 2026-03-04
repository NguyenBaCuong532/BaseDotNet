








CREATE procedure [dbo].[sp_Pay_Get_Wallet_RechargeView]
		 @UserID	nvarchar(450)
		,@TranferCd nvarchar(50)
		,@LinkedID int
		,@Amount decimal
	
as
	begin try		
	
	if @LinkedID>0
		select c.TranferCd, c.SourceCd, 
			 @Amount as Amount, case when a.IsFee = 1 then 0 else a.FixFee + round(0.011*@Amount,0) end as Fee
			,@Amount + case when a.IsFee = 1 then 0 else a.FixFee + round(0.011*@Amount,0) end as TotalAmount
			,a.TranferName
			,b.ShortName
			,b.SourceName
			,d.LinkedID
		from WAL_BankLinked c 
			inner join WAL_Tranfers a on c.TranferCd = a.TranferCd 
			inner join WAL_Banks b on c.SourceCd = b.SourceCd
			inner join WAL_TranferLinked d on c.SourceCd = d.SourceCd and c.TranferCd = d.TranferCd 
		where d.LinkedID = @LinkedID
	else
		select top (1) c.TranferCd, c.SourceCd, 
			 @Amount as Amount, case when a.IsFee = 1 then 0 else a.FixFee + round(0.011*@Amount,0) end as Fee
			,@Amount + case when a.IsFee = 1 then 0 else a.FixFee + round(0.011*@Amount,0) end as TotalAmount
			,a.TranferName
			,b.ShortName
			,b.SourceName
			,0 as LinkedID
		from WAL_BankLinked c 
			inner join WAL_Tranfers a on c.TranferCd = a.TranferCd 
			inner join WAL_Banks b on c.SourceCd = b.SourceCd
		where c.TranferCd = @TranferCd 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_RechargeView ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Wallet', 'Get', @SessionID, @AddlInfo
	end catch