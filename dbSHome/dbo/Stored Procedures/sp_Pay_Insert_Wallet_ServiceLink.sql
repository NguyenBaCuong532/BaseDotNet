








CREATE procedure [dbo].[sp_Pay_Insert_Wallet_ServiceLink]
		 @UserID	nvarchar(450)
		,@ServiceKey nvarchar(20)
		,@ProviderCd nvarchar(20)
		
	
as
	declare @WalletCd nvarchar(200)

	begin try		
	--declare @LinkedID nvarchar(100)
	if not exists(SELECT WalletCd FROM WAL_Profile where UserId = @ServiceKey and AccountType = 1)
		begin
			set @WalletCd = '11'+right('00000000'+ replace(cast(CAST(RAND(CHECKSUM(NEWID())) * 10000000 as decimal) as nvarchar(8)),'4',''),6)
			WHILE exists(select WalletCd from WAL_Profile where WalletCd = @WalletCd)
			BEGIN
				set @WalletCd = '11'+right('00000000'+ replace(cast(CAST(RAND(CHECKSUM(NEWID())) * 10000000 as decimal) as nvarchar(8)),'4',''),6)
			END

			INSERT INTO [dbo].WAL_Profile
				([WalletCd]
				,[BaseCif]
				,UserId
				,[AccountType]
				,[Legacy_AC]
				,[CurrAmount]
				,[PaymentLimit]
				,[CreateDt])
			VALUES
				(@WalletCd
				,@ProviderCd
				,@ServiceKey
				,1
				,'131'
				,0
				,0
				,getdate()
				)

			UPDATE [dbo].[WAL_Services]
			   SET [IsWallet] = 1
			 WHERE ServiceKey = @ServiceKey
		end
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Wallet_ServiceLink ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServiceLink', 'Insert', @SessionID, @AddlInfo
	end catch