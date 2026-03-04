







CREATE procedure [dbo].[sp_Pay_Update_Wallet_Tranferlinked]
		 @UserID	nvarchar(450)
		,@Token nvarchar(100)

		,@Brand nvarchar(50)
		,@NameOnCard nvarchar(50)
		,@IssueDate nvarchar(50)
		,@Number nvarchar(50)
		,@Scheme nvarchar(50)
as
	begin try		
		if exists(select * from WAL_TranferLinked t inner join WAL_Profile w on t.LinkedID <> w.LinkedID and t.WalletCd = w.WalletCd 
					inner join MAS_Contacts c on w.BaseCif = c.Cif_No 
					inner join UserInfo u on c.CustId = u.CustId 
				where u.UserId = @UserID and LinkedToken = @Token)
			delete t from WAL_TranferLinked t 
				inner join WAL_Profile w on t.LinkedID <> w.LinkedID and t.WalletCd = w.WalletCd 
				inner join MAS_Contacts c on w.BaseCif = c.Cif_No 
				inner join UserInfo u on c.CustId = u.CustId 
			where u.UserId = @UserID and LinkedToken = @Token 

			UPDATE t
			   SET [IsLinked] = 1
			    ,SourceCd = @Brand
				,LinkedToken = @Token 
				,card_Brand = @Brand
				,card_NameOnCard = @NameOnCard 
				,card_IssueDate = @IssueDate 
				,card_Number = @Number 
				,card_Scheme = @Scheme 
			FROM [WAL_TranferLinked] t 
				inner join WAL_Profile w on t.LinkedID = w.LinkID
				inner join MAS_Contacts c on w.BaseCif = c.Cif_No 
				inner join UserInfo u on c.CustId = u.CustId 
			 WHERE u.UserId = @UserID


			UPDATE t
				SET LinkedID = LinkID
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
		set @ErrorMsg					= 'sp_Pay_Update_Wallet_Tranferlinked' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Wallet', 'Insert', @SessionID, @AddlInfo
	end catch