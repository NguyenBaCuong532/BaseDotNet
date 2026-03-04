






CREATE procedure [dbo].[sp_Pay_Insert_Wallet_Service]
		 @UserID	nvarchar(450)
		,@ServiceCd nvarchar(50)
		,@ServiceName nvarchar(150)
		,@ServiceViewUrl nvarchar(250) = null
		,@ProviderCd nvarchar(50) = null
		,@IconKey nvarchar(50) = null
		,@IsFlage bit
		,@intOrder int
as
	begin try		
	declare @serviceKey nvarchar(16)

	if not exists(select [WalServiceCd] from WAL_Services where [WalServiceCd] = @ServiceCd)
		begin
			set @serviceKey = 'SK'+ right('000000'+ replace(cast(CAST(RAND(CHECKSUM(NEWID())) * 10000000 as decimal) as nvarchar(8)),'4',''),6)
			INSERT INTO [dbo].[WAL_Services]
				   (ServiceKey
				   ,[WalServiceCd]
				   ,[IconKey]
				   ,[ServiceName]
				   ,[ServiceViewUrl]
				   ,[intOrder]
				   --,[IsInPay]
				   --,[IsInRecharge]
				   ,[IsInList]
				   ,[IsFlage]
				   ,[ProviderCd]
				   --,[WalletCd]
				   ,[CreateDt])
			 VALUES
				   (@serviceKey
				   ,@ServiceCd
				   ,@IconKey
				   ,@ServiceName
				   ,@ServiceViewUrl
				   ,@intOrder
				   --,@IsInPay
				   --,@IsInRecharge
				   ,1
				   ,@IsFlage
				   ,@ProviderCd
				   --,@WalletCd
				   ,getdate()
				   )

		end
		ELSE
		begin
			UPDATE [dbo].[WAL_Services]
			   SET [IconKey] = @IconKey
				  ,[ServiceName] = @ServiceName
				  ,[ServiceViewUrl] = @ServiceViewUrl
				  ,[intOrder] = @intOrder
				  --,[IsInPay] = @IsInPay
				  --,[IsInRecharge] = @IsInRecharge
				  --,[IsInList] = @IsInList
				  ,[IsFlage] = @IsFlage
				  ,[ProviderCd] = @ProviderCd
				  --,[WalletCd] = @WalletCd
				  --,[CreateDt] = @CreateDt
			 WHERE [WalServiceCd] = @ServiceCd
		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Wallet_Service ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WalletService', 'Insert', @SessionID, @AddlInfo
	end catch