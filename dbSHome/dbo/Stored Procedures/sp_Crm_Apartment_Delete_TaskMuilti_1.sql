




create procedure [dbo].[sp_Crm_Apartment_Delete_TaskMuilti]
	@ExchangeIds	nvarchar(300)	
	
as
	begin try
			delete from CRM_Apartment_HandOver_Exchange where ExchangeId in (select cast(part as int) from SplitString(@ExchangeIds,','))
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Delete_TaskMuilti' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_Exchange', 'DEL', @SessionID, @AddlInfo
	end catch