








CREATE procedure [dbo].[sp_Pay_Insert_Wallet_QrCode]
	@UserID	nvarchar(450),
	@WalletCd nvarchar(50),
	@PosCd nvarchar(50),
	@ExpireDate nvarchar(50)
as
	begin try		
		DECLARE @newQr nvarchar(50)
		--declare @codeCode nvarchar(30)

		set @newQr = replace(NEWID(),'-','')

		IF not exists(select QrId from WAL_QrDuration where QrKey = @newQr)
		BEGIN

			INSERT INTO [dbo].[WAL_QrDuration]
				   ([QrKey]
				   ,[QrStatus]
				   ,[WalletCd]
				   ,PosCd
				   ,[CreateDt]
				   ,[CreateBy]
				   ,[ExpireDt])
			 VALUES(
				    @newQr
				   ,1
				   ,@WalletCd
				   ,@PosCd
				   ,getdate()
				   ,@UserID
				   ,convert(datetime,@ExpireDate,103)
				   )
			 
		END 
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Wallet_QrCode ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@QrCode ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'QrCode', 'Insert', @SessionID, @AddlInfo
	end catch