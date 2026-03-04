
CREATE procedure [dbo].[sp_res_notify_to_draft1]
	 @userId		UNIQUEIDENTIFIER
	,@sourceId		uniqueidentifier
	,@Id			uniqueidentifier
	,@to_row		int
	,@to_groups		nvarchar(max)
	,@to_level		int
	,@to_type		nvarchar(10) = '0'
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
	--,@notiTos		user_notify_to	readonly
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(300) = N'Thành công'
	declare @project_code nvarchar(50),@source_ref uniqueidentifier
	begin try	
	  
	  select
			   
			  --,@actions	= isnull(a.actionlist,'')
			   @project_code = isnull(a.external_sub,'')
			  --,@source_ref = source_ref
		from NotifyInbox a
		where n_id = @sourceId

	  select @sourceId as sourceId
			,tableKey = 'NotifyTo' + cast(@to_type as varchar(10))
			,groupKey = 'common_group'
			,id = @Id
					

		SELECT *
		  FROM dbo.fn_get_field_group_lang ('common_group', @acceptLanguage) 
			   order by intOrder
	
		SELECT [table_name]
			  ,[field_name]
			  ,[view_type]
			  ,[data_type]
			  ,[ordinal]
			  ,[columnLabel]
			  ,[group_cd]	
			  ,case [data_type] 
				  when 'nvarchar' then convert(nvarchar(max), case [field_name] 						
						when 'to_groups' then @to_groups 
					end) 
				  when 'uniqueidentifier' then lower(convert(nvarchar(100),case [field_name] 
						when 'id' then @id
						end))
				  when 'datetime' then convert(nvarchar(100),case [field_name] 
						when 'createDt' then format(getdate(),'dd/MM/yyyy HH:mm:ss')
						end)
				  else convert(nvarchar(50),case [field_name] 
						when 'to_level' then @to_level
						when 'to_row' then @to_row
						when 'to_type' then @to_type
					end) end as columnValue
			  ,[columnClass]
			  ,[columnType]		= case when field_name = 'to_groups' then l.objGroup else case when field_name = 'to_groups' and @to_level = 0 then 'chips' else [columnType] end end
			  ,[columnObject]	= case when field_name = 'to_groups' then replace(
									case @to_level when 2 then replace(l.objValue1,'userIds=','userIds='+isnull(@to_groups,'')) 
										when 3 then replace(replace(l.objValue1,'custIds=','custIds='+isnull(@to_groups,'')) 
											,'oids=','oids='+isnull(@to_groups,'')) 
										else objValue1 end,'projectCd=','projectCd=' + isnull(@project_code, '')) 
									else [columnObject] end 
			  ,[isSpecial]
			  ,[isRequire]
			  ,[isDisable]
			  ,[IsVisiable]
			  ,[IsEmpty]
			  ,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
			  ,columnDisplay
			  ,isIgnore
		  FROM dbo.fn_config_form_gets('NotifyTo' + cast(@to_type as varchar(10)), @acceptLanguage) a			
			left join fn_config_data_gets_lang('notify_to_level'+@to_type, @acceptLanguage) l on l.objCode = cast(@to_level as varchar(10)) 
		  where (isvisiable = 1 or isRequire = 1)		
		  order by [group_cd], ordinal
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_to_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@tempId ' 
		set @valid = 0
		set @messages = error_message()

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'to_set', 'Set', @SessionID, @AddlInfo
	end catch

	select @valid as valid
	      ,@messages as [messages]

	end