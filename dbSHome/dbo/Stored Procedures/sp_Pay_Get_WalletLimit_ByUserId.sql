





CREATE procedure [dbo].[sp_Pay_Get_WalletLimit_ByUserId]
	@userId nvarchar(450)
as
	begin try		

		SELECT w.[WalletCd]
		  ,w.[CurrAmount]
		  ,isnull(w.[PaymentLimit],0) as PayLimitAmount
		FROM [dbo].WAL_Profile w
			inner join MAS_Contacts d on w.BaseCif = d.Cif_No 
			inner join UserInfo u on u.CustId = d.CustId 
		WHERE u.UserId = @userId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Wallet_PayLimit_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Wallet', 'GET', @SessionID, @AddlInfo
	end catch