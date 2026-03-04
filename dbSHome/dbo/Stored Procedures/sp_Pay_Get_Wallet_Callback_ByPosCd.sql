







CREATE procedure [dbo].[sp_Pay_Get_Wallet_Callback_ByPosCd]
	@PosCd nvarchar(50)
as
	begin try		

		SELECT [PosCd]
			  ,[callbackUrl]
			  ,isnull(callbackChecksumSecret,'') as callbackChecksumSecret
		  FROM [dbo].WAL_ServicePOS a 
			WHERE a.PosCd = @PosCd 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_Callback_ByPosCd ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CallbackPosCd', 'GET', @SessionID, @AddlInfo
	end catch