





create procedure [dbo].[sp_Pay_Get_Wallet_AmountLimit]
	@userId nvarchar(450)
as
	begin try		

		SELECT 100000 union 
		SELECT 200000 union 
		SELECT 500000 union 
		SELECT 1000000 union 
		SELECT 2000000 union 
		select 5000000

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Wallet_AmountLimit ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Wallet', 'GET', @SessionID, @AddlInfo
	end catch