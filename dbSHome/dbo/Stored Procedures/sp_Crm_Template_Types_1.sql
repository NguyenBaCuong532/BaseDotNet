








CREATE procedure [dbo].[sp_Crm_Template_Types]
	@userId nvarchar(450)
	--@Total				int out,
	--@TotalFiltered		int out
as
	begin try 
		
		--select	@Total					= count(t.TemplateTypeId)
		--	FROM  [CRM_TemplateType] t 
		--set	@TotalFiltered = @Total
	
		--1
		SELECT   t.[TemplateTypeId] as value
				,t.[TemplateTypeName] as name
			FROM  [CRM_TemplateType] t 
		ORDER BY t.[TemplateTypeName] 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Template_Type_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'TemplateType', 'GET', @SessionID, @AddlInfo
	end catch