









CREATE procedure [dbo].[sp_Pay_Get_Wallet_Promotion]
as
	begin try		


	SELECT 'http://s-pay.sunshinegroup.vn/template-Spay' as promotionUrl
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_Promotion ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Promotion', 'GET', @SessionID, @AddlInfo
	end catch