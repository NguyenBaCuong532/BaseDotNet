




CREATE procedure [dbo].[sp_Pay_Update_Wallet_Pincode_request]
	@UserID	nvarchar(450)
as
	begin try	
						
		UPDATE t
			SET isRequestPincode = 1
		FROM WAL_Profile t 
			inner join MAS_Contacts c on t.BaseCif = c.Cif_No 
			inner join UserInfo u on c.CustId = u.CustId 
		WHERE u.UserId = @UserID 

		SELECT   isnull(u.Phone,c.Phone) as Phone
				,isnull(u.Email,c.Email) as Email
				--,UserLogin
				,UserId
				,cast(0 as int) as isOptType
				,cast(2 as int) as tokenType
		FROM UserInfo u 
			join MAS_Customers c on u.CustId = c.CustId
		WHERE UserId = @UserID 

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