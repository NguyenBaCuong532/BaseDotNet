








CREATE procedure [dbo].[sp_Crm_Template_Get]
	@UserId	nvarchar(450), 
	@TemplateId int
as
	begin try 
		 
		SELECT t.[TemplateId]
			  ,t.[TemplateContent]
			  ,t.[TransTypeId]
			  ,r.TransTypeName
			  ,t.[TemplateTypeId]
			  ,y.[TemplateTypeName] 
			  ,t.[TemplateName]
			  ,t.isShared
			  ,t.TemplateUrl
			  ,t.thumbnailUrl
			  ,t.isHtml
	 FROM  [CRM_Template] t
		join  [CRM_TransactionType] r on t.TransTypeId = r.TransTypeId
		left join  [CRM_TemplateType] y on t.TemplateTypeId = y.TemplateTypeId
	  where  t.TemplateId = @TemplateId 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Template_Get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Template', 'GET', @SessionID, @AddlInfo
	end catch