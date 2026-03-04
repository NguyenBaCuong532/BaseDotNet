



CREATE procedure [dbo].[sp_Pay_Update_Wallet_Pincode]
	@UserID	nvarchar(450),
	@Pincode nvarchar(50)
as
	begin try	
						
		UPDATE t
			SET Pincode = @Pincode
			   ,isRequirePincode = 1
			   ,isRequestPincode = 0
		FROM WAL_Profile t 
			inner join MAS_Contacts c on t.BaseCif = c.Cif_No 
			inner join UserInfo u on c.CustId = u.CustId 
		WHERE u.UserId = @UserID and isRequestPincode = 1

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Update_Wallet_Pincode ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WalletPin', 'Update', @SessionID, @AddlInfo
	end catch