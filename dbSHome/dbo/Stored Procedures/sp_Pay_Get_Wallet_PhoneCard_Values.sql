






CREATE procedure [dbo].[sp_Pay_Get_Wallet_PhoneCard_Values]
	@userId nvarchar(450)
as
	begin try		

		SELECT 10000 union 
		SELECT 20000 union 
		SELECT 50000 union 
		SELECT 100000 union 
		SELECT 200000 union 
		select 500000

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_PhoneCard_Values ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WalletValue', 'GET', @SessionID, @AddlInfo
	end catch