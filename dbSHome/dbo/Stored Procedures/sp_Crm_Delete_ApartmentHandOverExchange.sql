



CREATE procedure [dbo].[sp_Crm_Delete_ApartmentHandOverExchange]
	@UserID nvarchar(450),
	@ExchangeId	bigint	
as
	begin try			
			if exists (select ExchangeId from CRM_Apartment_HandOver_Exchange where ExchangeId = @ExchangeId and CreatedBy = @UserID)
				begin
					Delete from CRM_Apartment_HandOver_Exchange_Detail where ExchangeId = @ExchangeId
					Delete from CRM_Apartment_HandOver_Exchange where ExchangeId = @ExchangeId
				end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Delete_ApartmentHandOverExchange' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Delete_ApartmentHandOverExchange', 'DEL', @SessionID, @AddlInfo
	end catch