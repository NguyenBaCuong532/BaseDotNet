








CREATE procedure [dbo].[sp_Pay_Get_Wallet_About]
as
	begin try		


	SELECT 'http://s-pay.sunshinegroup.vn/template-Spay/intro.html' as AboutUrl
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_About ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CabHelper', 'GET', @SessionID, @AddlInfo
	end catch