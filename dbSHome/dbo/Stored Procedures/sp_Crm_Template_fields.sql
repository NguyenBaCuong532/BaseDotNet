









CREATE procedure [dbo].[sp_Crm_Template_fields]
	@UserId	nvarchar(450), 
	@TemplateId int
as
	begin try 
		 
	if @TemplateId is not null and not exists(select 1 from CRM_Template where TemplateId = @TemplateId) set @TemplateId = null

	select @TemplateId id
		  ,tableKey = 'CRM_Template' 
		  ,groupKey = 'common_group'
	--2- cac group
	select * from DBO.fn_get_field_group('common_group')
	--2 tung o trong group
	if OBJECT_ID('tempdb..#temp') is not null drop table #temp
	-- data
	exec sp_config_data_fields @TemplateId,'TemplateId','CRM_Template'


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