




CREATE procedure [dbo].[sp_Hom_Get_Service_Providers]
	@userId nvarchar(200),
	@ContractTypeId int
as
	begin try		

		SELECT a.[ProviderCd]
			  ,a.[ProviderShort]
			  ,a.[ProviderName]
			  ,a.[Address]
			  ,a.[LogoUrl]
			  ,a.[ContactName]
			  ,a.[Phone]
			  ,a.[Email]
			,b.ContractTypeId
	  FROM [dbo].[MAS_ServiceProvider] a 
		inner join MAS_ProviderContractType b on a.ProviderCd = b.ProviderCd 
	  WHERE b.ContractTypeId = @ContractTypeId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_ServiceProviders ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Provider', 'GET', @SessionID, @AddlInfo
	end catch