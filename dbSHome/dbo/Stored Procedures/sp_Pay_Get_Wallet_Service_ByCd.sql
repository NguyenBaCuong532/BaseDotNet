









CREATE procedure [dbo].[sp_Pay_Get_Wallet_Service_ByCd]
	@UserId	nvarchar(450),
	@serviceKey nvarchar(50)
as
	begin try
	
	--1
		SELECT [WalServiceCd] as [ServiceCd]
			  ,[IconKey]
			  ,[ServiceName]
			  ,[ServiceViewUrl]
			  ,[intOrder]
			  --,[IsInPay]
			  --,[IsInRecharge]
			  --,[IsInList]
			  ,[IsFlage]
			  ,t.[ProviderCd]
			  ,[PosCd]
			  ,[IsWallet]
			  ,t.[CreateDt]
			  ,b.ProviderShort
			  ,b.ProviderName
			  ,b.Phone
			  ,t.ServiceKey
		  FROM [WAL_Services] t
			left join WAL_Providers b on t.ProviderCd = b.ProviderCd 
		WHERE t.serviceKey = @serviceKey

		--2
		SELECT [PosCd]
			  ,[ServiceKey]
			  ,[PosName]
			  ,[Address]
			  ,[IsPayment]
			  ,[IsRecharge]
			  ,[IsSPay]
			  ,[IsActive]
			  ,[CreateDt]
		  FROM [dbo].[WAL_ServicePOS]
		  WHERE [ServiceKey] = @serviceKey

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_Service_ByCd ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WalService', 'GET', @SessionID, @AddlInfo
	end catch