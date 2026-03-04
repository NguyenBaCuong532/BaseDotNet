


CREATE procedure [dbo].[sp_Pay_Update_Wallet_PayLimit]
	@UserID	nvarchar(450),
	@Password nvarchar(50),
	@LimitAmount decimal
as
	begin try	
						
		UPDATE t
			SET PaymentLimit = @LimitAmount
		FROM WAL_Profile t 
			inner join MAS_Contacts c on t.BaseCif = c.Cif_No 
			inner join UserInfo u on c.CustId = u.CustId 
		WHERE u.UserId = @UserID 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Update_Wallet_PayLimit ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Wallet', 'Update', @SessionID, @AddlInfo
	end catch