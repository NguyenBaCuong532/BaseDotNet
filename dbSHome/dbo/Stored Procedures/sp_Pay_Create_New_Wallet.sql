






CREATE procedure [dbo].[sp_Pay_Create_New_Wallet] 
	@Phone nvarchar(20),
	@IsInternal bit,
	@WalletCd		nvarchar(16) out
	
as
	begin try
	declare @custId nvarchar(50)
	declare @baseCif nvarchar(16)
	
	if @IsInternal = 0 
	begin

	if not exists(SELECT custId FROM MAS_Customers WHERE Phone = @Phone)	
		INSERT INTO [dbo].[MAS_Customers]
				   (CustId
				   ,[FullName]
				   ,[Phone]
				   ,[Email]
				   ,sysDate
				   )
			 VALUES
				   (newid()
				   ,null
				   ,@Phone
				   ,null
				   ,getdate()
				   )

	set @custId = (select top (1) CustId from MAS_Customers where Phone = @Phone)

	--exec sp_Cor_Insert_CustCategory @custID, 'S006'

	if not exists(SELECT [WalletCd] FROM WAL_Profile a inner join MAS_Contacts b on a.BaseCif = b.Cif_No WHERE b.Phone = @Phone)
			begin		
			
				if not exists(SELECT custId FROM MAS_Contacts WHERE Phone = @Phone)	
					exec [dbo].[sp_Pay_Create_New_Account] @custId, @baseCif out
		
				set @WalletCd = right('0000000000000' + cast(CAST(RAND(CHECKSUM(NEWID())) * 10000000000000 as decimal) as nvarchar(16)),14)
				WHILE exists(select WalletCd from WAL_Profile where WalletCd = @WalletCd)
				BEGIN
					set @WalletCd = right('0000000000000'+cast(CAST(RAND(CHECKSUM(NEWID())) * 10000000000000 as decimal) as nvarchar(16)),14)
				END

				INSERT INTO [dbo].WAL_Profile
				   ([WalletCd]
				   ,[BaseCif]
				   --,UserId
				   ,[AccountType]
				   ,[Legacy_AC]
				   --,[CCY_CD]
				   ,[CurrAmount]
				   ,[PaymentLimit]
				   ,[CreateDt])
				SELECT  @WalletCd
					,c.Cif_No
					--,@UserID
					,0
					,'331'
					--,'VND'
					,0
					,1000000
					,getdate()
				FROM  MAS_Contacts c
					WHERE c.Phone = @Phone
			end 
	else
		set @WalletCd = (SELECT [WalletCd] FROM WAL_Profile a inner join MAS_Contacts b on a.BaseCif = b.Cif_No WHERE b.Phone = @Phone)

	end
	else
	begin
		
			set @WalletCd = '11'+right('000000'+ replace(cast(CAST(RAND(CHECKSUM(NEWID())) * 1000000 as decimal) as nvarchar(6)),'4',''),6)
			WHILE exists(select WalletCd from WAL_Profile where WalletCd = @WalletCd)
			BEGIN
				set @WalletCd = '11'+right('000000'+ replace(cast(CAST(RAND(CHECKSUM(NEWID())) * 1000000 as decimal) as nvarchar(6)),'4',''),6)
			END

			INSERT INTO [dbo].WAL_Profile
				([WalletCd]
				,[BaseCif]
				--,UserId
				,[AccountType]
				,[Legacy_AC]
				--,[CCY_CD]
				,[CurrAmount]
				,[PaymentLimit]
				,[CreateDt])
			VALUES
				(@WalletCd
				,@Phone
				--,@UserID
				,1
				,'131'
				,0
				,0
				,getdate()
				)

			--set @WalletCd = (SELECT [WalletCd] FROM WAL_Profile WHERE UserId = @UserID)
	end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Create_New_Wallet' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'wallet', 'cre', @SessionID, @AddlInfo
	end catch