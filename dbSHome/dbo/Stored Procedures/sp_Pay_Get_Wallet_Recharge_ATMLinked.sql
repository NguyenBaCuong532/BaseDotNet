








CREATE procedure [dbo].[sp_Pay_Get_Wallet_Recharge_ATMLinked]
@UserId	nvarchar(450)

as
	begin try
		--1
		SELECT c.[TranferCd]
			  ,c.[TranferName]
			  ,c.RateFee
			  ,a.SourceCd
			  ,a.ShortName
			  ,a.SourceName
			  ,a.LogoUrl
		FROM WAL_Banks a
			join [WAL_BankLinked] b on a.SourceCd = b.SourceCd
			join WAL_Tranfers c on b.TranferCd = c.TranferCd
		WHERE b.IsLinked = 1
		ORDER BY intOrder

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_Recharge_ATMLinked ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RechargeATMLinked', 'GET', @SessionID, @AddlInfo
	end catch