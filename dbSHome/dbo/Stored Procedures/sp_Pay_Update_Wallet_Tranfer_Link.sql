







CREATE procedure [dbo].[sp_Pay_Update_Wallet_Tranfer_Link]
		 @UserID	nvarchar(450)
		,@TranferCd nvarchar(20)
		--,@SourceCd nvarchar(20)
		--,@WalletCd nvarchar(20)
	
as

	
	begin try		
	declare @LinkedID bigint
	declare @WalletCd nvarchar(20)
	set @WalletCd = (SELECT WalletCd FROM WAL_Profile a inner join MAS_Contacts b on a.BaseCif = b.Cif_No 
			inner join UserInfo u on b.CustId = u.CustId  where u.UserId = @UserID)

	if exists(SELECT WalletCd FROM WAL_Profile a inner join MAS_Contacts b on a.BaseCif = b.Cif_No 
			inner join UserInfo u on b.CustId = u.CustId  where u.UserId = @UserID)
		begin
			INSERT INTO [dbo].[WAL_TranferLinked]
				   ([WalletCd]
				   ,[TranferCd]
				   --,SourceCd
				   ,[IsLinked]
				   ,[LinkDt])
			 VALUES
				   (@WalletCd
				   ,@TranferCd
				   --,@SourceCd
				   ,0--case when @SourceCd = 'BANKLINK' then 0 else 1 end
				   ,getdate()
				   )
			set @LinkedID = @@IDENTITY

			UPDATE [dbo].[WAL_Profile]
			   SET LinkID = @LinkedID
			 WHERE WalletCd = @WalletCd

		end
	

		select @LinkedID 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Update_Wallet_Tranfer_Link ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'TranferLink', 'Insert', @SessionID, @AddlInfo
	end catch