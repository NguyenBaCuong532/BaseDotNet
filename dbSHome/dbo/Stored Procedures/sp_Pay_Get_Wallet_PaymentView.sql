









CREATE procedure [dbo].[sp_Pay_Get_Wallet_PaymentView]
		 @UserID	nvarchar(450)
		,@PosCd nvarchar(50)
		,@ServiceKey nvarchar(50)
		,@PaymentType nvarchar(50)
		,@Amount decimal
	
as
	begin try		
	declare @rate decimal
	set @rate = 0.00
	select 
			 @Amount as Amount, 0 as FeeAmt
			,case when b.WalServiceCd = 'SCard' then @rate else 0 end as promotionAmt
			,@Amount - round(@Amount*case when b.WalServiceCd = 'SCard' then @rate else 0 end,0) as totalAmt
			,'Sunshine Pay' as SourceName
	from WAL_ServicePOS a 
		join [WAL_Services] b on a.ServiceKey = b.ServiceKey
	where a.PosCd = @PosCd and b.ServiceKey = @ServiceKey
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_PaymentView ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'PaymentView', 'Get', @SessionID, @AddlInfo
	end catch