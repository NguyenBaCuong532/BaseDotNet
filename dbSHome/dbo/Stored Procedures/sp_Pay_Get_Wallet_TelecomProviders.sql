





CREATE procedure [dbo].[sp_Pay_Get_Wallet_TelecomProviders]
	@userId nvarchar(200)
	--@ContractTypeId int
as
	begin try		
		declare @ContractTypeId int
		set @ContractTypeId = 1
		SELECT a.[ProviderCd]
			  ,a.[ProviderShort]
			  ,a.[ProviderName]
			  ,a.[Address]
			  ,a.[LogoUrl]
			  ,a.[ContactName]
			  ,a.[Phone]
			  ,a.[Email]
		  
	  FROM [dbo].WAL_Providers a 
		inner join WAL_Service_Provider b on a.ProviderId = b.ProviderId 
	  WHERE b.ServiceKey ='SK057733'-- a.isTelephone = 1

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