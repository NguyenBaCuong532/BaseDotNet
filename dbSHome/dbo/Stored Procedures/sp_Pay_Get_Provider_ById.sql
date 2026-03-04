





CREATE procedure [dbo].[sp_Pay_Get_Provider_ById]
	@userId nvarchar(200),
	@ProviderId int
as
	begin try		

		SELECT [ProviderCd]
		  ,[ProviderShort]
		  ,[ProviderName]
		  ,[Address]
		  ,[LogoUrl]
		  ,[ContactName]
		  ,[Phone]
		  ,[Email]
		  ,ProviderId
	  FROM [dbo].WAL_Providers
	  WHERE ProviderId = @ProviderId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Provider_ById ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Provider', 'GET', @SessionID, @AddlInfo
	end catch