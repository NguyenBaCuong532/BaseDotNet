








CREATE procedure [dbo].[sp_Pay_Get_Wallet_Helpers]
as
	begin try		
	 
		SELECT N'Thông tin cơ bản' [HelpLable]
				,'http://s-pay.sunshinegroup.vn/template-Spay/thong-tin-co-ban.html' [HelpUrl]
		UNION
		SELECT N'Quản lý tài khoản' [HelpLable]
				,'http://s-pay.sunshinegroup.vn/template-Spay/quan-ly-tai-khoan.html' [HelpUrl]
		UNION
		SELECT N'Thanh toán mua sắm' [HelpLable]
				,'http://s-pay.sunshinegroup.vn/template-Spay/thanh-toan-mua-sam.html' [HelpUrl]
		UNION
		SELECT N'Ưu đãi, khuyễn mãi' [HelpLable]
				,'http://s-pay.sunshinegroup.vn/template-Spay/khuyen-mai.html' [HelpUrl]
				
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_Helpers ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'PayHelper', 'GET', @SessionID, @AddlInfo
	end catch