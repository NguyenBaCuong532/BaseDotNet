






CREATE procedure [dbo].[sp_Pay_Insert_Provider]
	@UserID	nvarchar(450),
	@ProviderId int,
	@ProviderCd nvarchar(50),
	@ProviderShort nvarchar(100),
	@ProviderName nvarchar(150),
	@LogoUrl nvarchar(250) = null,
	
	@ContactName nvarchar(100) = null,
	@Phone nvarchar(20) = null,
	@Email nvarchar(150) = null,
	@Address nvarchar(300) = null
	
as
	begin try		
		
			if not exists(SELECT ProviderCd FROM WAL_Providers WHERE ProviderId = @ProviderId)
			BEGIN
				set @ProviderCd = right('000000'+ replace(cast(CAST(RAND(CHECKSUM(NEWID())) * 100000 as decimal) as nvarchar(6)),'4',''),6)
				INSERT INTO [dbo].WAL_Providers
					   (ProviderCd
					   ,ProviderShort
					   ,ProviderName
					   ,LogoUrl
					   ,ContactName
					   ,Phone
					   ,Email	
					   ,[Address]
					   )
				 VALUES
					   (@ProviderCd
					   ,@ProviderShort
					   ,@ProviderName
					   ,@LogoUrl
					   ,@ContactName
					   ,@Phone
					   ,@Email	
					   ,@Address	
					   )

			END
			ELSE
			BEGIN
				UPDATE [dbo].WAL_Providers
				   SET ProviderShort = @ProviderShort
					  ,ProviderName = @ProviderName
					  ,ContactName = @ContactName
					  ,Phone = @Phone
					  ,LogoUrl = @LogoUrl
					  ,Email = @Email	
					  ,[Address] = @Address
				 WHERE ProviderId = @ProviderId
			END
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Provider ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Provider', 'Insert', @SessionID, @AddlInfo
	end catch