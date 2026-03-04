


CREATE procedure [dbo].[sp_res_notify_to_get]
	 @UserId		UNIQUEIDENTIFIER
	,@sourceId		uniqueidentifier
	,@id			uniqueidentifier = null
	,@to_type		int = 0
	,@to_level		nvarchar(10) = '0'
	,@to_groups		nvarchar(max)
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
	--1	
	declare @project_code nvarchar(50)
	select
			   
			  --,@actions	= isnull(a.actionlist,'')
			   @project_code = isnull(a.external_sub,'')
			  --,@source_ref = source_ref
		from NotifyInbox a
		where n_id = @sourceId

	if exists(select 1 from NotifyTo where sourceId = @sourceId and id = @id)
	begin
	   set @to_type = 0 --isnull((select top 1 to_type from NotifyTo where sourceId = cast(@sourceId as nvarchar(50))),0)

	   select sourceId = @sourceId 
			 ,tableKey = 'NotifyTo' + cast(@to_type as varchar(10))
			 ,groupKey = 'custom_group'
			 --,to_count = (select count(id) from NotifyTo where sourceId = cast(@sourceId as nvarchar(50)))
			 ,@id as id

		SELECT group_key	= 'custom_group'
			  ,[group_cd]	= 1
			  ,group_name	= ''
			  ,group_column = 'col-12'
			  ,intOrder		= (ROW_NUMBER() OVER(ORDER BY b.createDt))
			  ,createDt
		  FROM NotifyTo b
		  where b.sourceId = @sourceId 	
			and id = @id
		order by createDt

		SELECT [table_name]
			  ,[field_name]
			  ,[view_type]
			  ,[data_type]
			  ,[ordinal]
			  ,[columnLabel]
			  ,[group_cd]
			  ,case [data_type] 
				  when 'nvarchar' then convert(nvarchar(max), case [field_name] 						
						when 'to_groups' then b.to_groups 
					end) 
				  when 'uniqueidentifier' then lower(convert(nvarchar(100),case [field_name] 
						when 'id' then b.id
						end))
				  when 'datetime' then convert(nvarchar(100),case [field_name] 
						when 'createDt' then format(b.createDt,'dd/MM/yyyy HH:mm:ss')
						end)
				  else convert(nvarchar(50),case [field_name] 
						when 'to_level' then b.to_level
						when 'to_row' then b.to_row
						when 'to_type' then @to_type
					end) end as columnValue
			  ,[columnClass]
			  ,[columnType]		= case when field_name = 'to_groups' then l.objGroup else case when field_name = 'to_groups' and b.to_level = 0 then 'chips' else [columnType] end end
			  ,[columnObject]	= case when field_name = 'to_groups' then replace(
									case b.to_level when 2 then replace(l.objValue1,'userIds=','userIds='+isnull(b.to_groups,'')) 
										when 3 then replace(l.objValue1,'custIds=','custIds='+isnull(b.to_groups,'')) 
										else l.objValue1 end ,'projectCd=','projectCd=' + isnull(@project_code, '')) 
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
			join NotifyTo b on b.sourceId = @sourceId and b.id = @id
			left join fn_config_data_gets_lang('notify_to_level' + @to_level, @acceptLanguage) l on l.objValue = b.to_level --and @to_type = 0
		  where (isvisiable = 1 or isRequire = 1)
		  order by [group_cd], ordinal
	end
	else
	begin
		set @to_type = isnull(@to_type,0)

		select @sourceId as sourceId
			  ,tableKey = 'NotifyTo' + cast(@to_type as varchar(10))
			  ,groupKey = 'custom_group'
			  ,to_count = 1		
			  ,@id as id

		SELECT group_key	= 'custom_group'
			  ,[group_cd]	= 1
			  ,group_name	= ''
			  ,group_column = 'col-12'
			  ,intOrder		= 1
		
		SELECT [table_name]
			  ,[field_name]
			  ,[view_type]
			  ,[data_type]
			  ,[ordinal]
			  ,[columnLabel]
			  ,[group_cd]	= 1
			  ,case [data_type] 
				  when 'nvarchar' then convert(nvarchar(max), case [field_name] 						
						when 'to_groups' then @to_groups
					end) 
				  when 'uniqueidentifier' then lower(convert(nvarchar(100),case [field_name] 
						when 'id' then newid()
						end))
				  when 'datetime' then convert(nvarchar(100),case [field_name] 
						when 'createDt' then format(getdate(),'dd/MM/yyyy HH:mm:ss')
						end)
				  else convert(nvarchar(50),case [field_name] 
						when 'to_level' then @to_level
						when 'to_row' then 1
						when 'to_type' then @to_type
					end) end as columnValue
			  ,[columnClass]
			  ,[columnType]		= case when field_name = 'to_groups' then l.objGroup else case when field_name = 'to_groups' and @to_level = 0 then 'chips' else [columnType] end end
			  ,[columnObject]	= case when field_name = 'to_groups' then replace(
									case @to_level when 2 then replace(l.objValue1,'userIds=','userIds='+isnull(@to_groups,''))  
												   when 3 then replace(l.objValue1,'custIds=','custIds='+isnull(@to_groups,'')) 
												   else l.objValue1 end ,'projectCd=','projectCd=' + isnull(@project_code, '')) 
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
			left join fn_config_data_gets_lang('notify_to_level'+@to_level, @acceptLanguage) l on l.objValue = @to_level
		  where (isvisiable = 1 or isRequire = 1)
		  order by [group_cd], ordinal

	end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_to_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'Field', 'GET', @SessionID, @AddlInfo
	end catch