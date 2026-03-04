









CREATE procedure [dbo].[sp_Crm_Policy_Card_Fields]
	@UserId	nvarchar(450), 
	@PolicyId int
as
	begin try 
		 
	if @PolicyId is not null and not exists(select 1 from CRM_CardPolicy where PolicyId = @PolicyId) set @PolicyId = null

	select @PolicyId id
		  ,tableKey = 'CRM_CardPolicy' 
		  ,groupKey = 'common_group'
	--2- cac group
	select * from DBO.fn_get_field_group('common_group')
	--2 tung o trong group
	if OBJECT_ID('tempdb..#temp') is not null drop table #temp
	-- data
	exec sp_config_data_fields @PolicyId,'PolicyId','CRM_CardPolicy'


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_CRM_CardPolicy_Get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Template', 'GET', @SessionID, @AddlInfo
	end catch