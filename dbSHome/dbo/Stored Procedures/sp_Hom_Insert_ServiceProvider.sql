





CREATE procedure [dbo].[sp_Hom_Insert_ServiceProvider]
	@UserID	nvarchar(450),
	@ProviderCd nvarchar(50),
	@ProviderShort nvarchar(100),
	@ProviderName nvarchar(150),
	@LogoUrl nvarchar(250),
	
	@ContactName nvarchar(100),
	@Phone nvarchar(20),
	@Email nvarchar(150),
    @ContractTypeId int
    --@IsMobile bit

as
	begin try		
		
			if not exists(SELECT ProviderCd FROM MAS_ServiceProvider WHERE ProviderCd = @ProviderCd)
			BEGIN
				INSERT INTO [dbo].MAS_ServiceProvider
					   (ProviderCd
					   ,ProviderShort
					   ,ProviderName
					   ,LogoUrl
					   ,ContactName
					   ,Phone
					   ,Email	
					   ,ContractTypeId				  
					   )
				 VALUES
					   (@ProviderCd
					   ,@ProviderShort
					   ,@ProviderName
					   ,@LogoUrl
					   ,@ContactName
					   ,@Phone
					   ,@Email		
					   ,@ContractTypeId			   
					   )

			END
			ELSE
				UPDATE [dbo].MAS_ServiceProvider
				   SET ProviderShort = @ProviderShort
					  ,ProviderName = @ProviderName
					  ,ContactName = @ContactName
					  ,Phone = @Phone
					  ,Email = @Email	
					  ,ContractTypeId = @ContractTypeId				  
				 WHERE ProviderCd = @ProviderCd
		
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Insert_ServiceProvider ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Provider', 'Insert', @SessionID, @AddlInfo
	end catch