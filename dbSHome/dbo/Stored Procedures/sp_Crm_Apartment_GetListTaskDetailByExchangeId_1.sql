

CREATE procedure [dbo].[sp_Crm_Apartment_GetListTaskDetailByExchangeId]
	@UserId nvarchar(450)=null,
	@ExchangeId bigint
as
	begin try		
		 select ExchangeId,
				PercentDone as PercentDone
		 from CRM_Apartment_HandOver_Exchange where ExchangeId = @ExchangeId
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_GetListTaskDetailByExchangeId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_Detail', 'GET', @SessionID, @AddlInfo
	end catch