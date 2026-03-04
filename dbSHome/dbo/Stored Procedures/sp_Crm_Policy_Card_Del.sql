



Create procedure [dbo].[sp_Crm_Policy_Card_Del]
	@PolicyId int	
	
as
	begin try	
		 delete from [dbo].[CRM_CardPolicy] 
		 where PolicyId = @PolicyId;
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		
		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_Crm_Delete_Card_Policy]' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardPolicy', 'DEL', @SessionID, @AddlInfo
	end catch