



CREATE procedure [dbo].[sp_Crm_Card_Del]
	@userId nvarchar(50),
	@CardCd nvarchar(50)
as
	begin try	
		 delete from [dbo].[CRM_Card] 
		 where CardCd = @CardCd;
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		
		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Card_Del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'DEL', @SessionID, @AddlInfo
	end catch