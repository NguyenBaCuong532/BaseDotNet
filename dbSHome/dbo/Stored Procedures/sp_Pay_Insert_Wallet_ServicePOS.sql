







CREATE procedure [dbo].[sp_Pay_Insert_Wallet_ServicePOS]
		 @UserID	nvarchar(450)
		,@PosCd nvarchar(50)
		,@ServiceKey nvarchar(50)
		,@PosName nvarchar(250)
		,@Address nvarchar(250)
		,@IsPayment bit
		,@IsRecharge bit
		,@IsSPay bit
as
	begin try		
	
	if not exists(select ServiceKey from [WAL_ServicePOS] where PosCd = @PosCd)
		begin
			set @PosCd = 'PC'+right('0000000000'+ cast(CAST(RAND(CHECKSUM(NEWID())) * 10000000000 as decimal) as nvarchar(11)),10)

			INSERT INTO [dbo].[WAL_ServicePOS]
				   ([PosCd]
				   ,ServiceKey
				   ,[PosName]
				   ,[Address]
				   ,[IsPayment]
				   ,[IsRecharge]
				   ,[IsSPay]
				   ,[IsActive]
				   ,[CreateDt])
			 VALUES
				   (@PosCd
				   ,@ServiceKey
				   ,@PosName
				   ,@Address
				   ,@IsPayment
				   ,@IsRecharge
				   ,@IsSPay
				   ,1
				   ,getdate()
				   )

		end
		ELSE
		begin
			UPDATE [dbo].[WAL_ServicePOS]
			   SET [PosCd] = @PosCd
				  ,ServiceKey = @ServiceKey
				  ,[PosName] = @PosName
				  ,[Address] = @Address
				  ,[IsPayment] = @IsPayment
				  ,[IsRecharge] = @IsRecharge
				  ,[IsSPay] = @IsSPay
				  --,[IsActive] = @IsActive, bit,>
			 WHERE PosCd = @PosCd
		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Wallet_ServicePOS ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServicePOS', 'Insert', @SessionID, @AddlInfo
	end catch