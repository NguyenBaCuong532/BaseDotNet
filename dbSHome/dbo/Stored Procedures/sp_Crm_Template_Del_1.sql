



CREATE procedure [dbo].[sp_Crm_Template_Del]
	@userId nvarchar(450),
	@TemplateId int	
	
as
	begin try	

		 delete 
		 from [dbo].[CRM_Template] 
		 where TemplateId = @TemplateId;
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		
		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Template_Del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Template', 'DEL', @SessionID, @AddlInfo
	end catch