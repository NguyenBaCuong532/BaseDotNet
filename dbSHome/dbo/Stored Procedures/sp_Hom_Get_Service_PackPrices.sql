







CREATE procedure [dbo].[sp_Hom_Get_Service_PackPrices]
	@UserId nvarchar(450),
	@ProjectCd nvarchar(30),
	@ProviderCd nvarchar(50)
as
	begin try		

		SELECT [PriceId] as PackPriceId
			  ,[ProjectCd]
			  ,[ProviderCd]
			  ,[PriceCode]
			  ,[PriceName]
			  ,[SpeedUD]
			  ,[BaseFee]
			  ,[BasePrice]
			  ,[SixPrice]
			  --,[SixFee]
			  ,[YearPrice]
			  --,[YearFee]
			  ,[DevicePrice]
		  FROM [PAR_TelecomPrice]
		  WHERE ProjectCd = @ProjectCd
			AND ProviderCd = @ProviderCd

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_CardTypes ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardTypes', 'GET', @SessionID, @AddlInfo
	end catch