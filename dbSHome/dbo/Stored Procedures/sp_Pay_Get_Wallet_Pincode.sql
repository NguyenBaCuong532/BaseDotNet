






CREATE procedure [dbo].[sp_Pay_Get_Wallet_Pincode]
	@userId nvarchar(450)
as
	begin try		

		SELECT Pincode
		  FROM [dbo].WAL_Profile a 
			inner join MAS_Contacts b on a.BaseCif = b.Cif_No 
			inner join UserInfo u on b.CustId = u.CustId 
		WHERE u.UserId = @userId 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_Pincode ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WalletPin', 'GET', @SessionID, @AddlInfo
	end catch