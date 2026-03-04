CREATE   procedure [dbo].[sp_res_notify_temp_fields]
	@UserId			UNIQUEIDENTIFIER = NULL,
	@tempId			uniqueidentifier = null,
	@n_id			uniqueidentifier = null,
	@external_key		nvarchar(50)	= null,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
	
	if exists(select tempId from NotifyTemplate where tempId = @tempId)
	begin
		select tempId as id
			,@n_id as n_id
			,tableKey = 'NotifyTemplate'
			,groupKey = 'common_group'
		from NotifyTemplate a
		where tempId = @tempId 

		SELECT *
		  FROM dbo.fn_get_field_group_lang('common_group', @acceptLanguage) 
			   order by intOrder

		SELECT a.id,
			  a.[table_name]
			  ,a.[field_name]
			  ,a.[view_type]
			  ,a.[data_type]
			  ,a.[ordinal]
			  ,a.[columnLabel]
			  ,a.group_cd
			  ,case [data_type] 
				  when 'uniqueidentifier' then convert(nvarchar(500), case [field_name] 
						when 'n_id' then lower(cast(@n_id as varchar(50)))
						when 'source_ref' then lower(cast(b.source_ref as varchar(100)))
						when 'tempId' then cast(@tempId as nvarchar(50))
						end)
				when 'nvarchar' then convert(nvarchar(max), case [field_name] 
						when 'subject' then b.[subject]
						when 'tempName' then b.tempName
						when 'actionlist' then b.actionlist
						when 'content_notify' then b.content_notify 
						when 'content_sms' then b.content_sms 
						when 'content_markdown' then b.content_markdown 
						when 'content_email' then b.content_email 
						when 'bodytype' then b.bodytype 						
						when 'tempCd' then b.tempCd
						when 'source_key' then b.source_key
					end)
				  else convert(nvarchar(50),case [field_name] 
						when 'content_type' then b.content_type
						when 'app_st' then b.app_st
					end) end as columnValue
			  ,[columnClass]
			  ,[columnType]
			  ,[columnObject]
			  ,[isSpecial]
			  ,[isRequire]
			  ,[isDisable]
			  ,[isVisiable] = case [field_name] 
								when 'content_sms' then case when charindex('sms',b.actionlist,0) > 0 then 1 else 0 end
								when 'brand_name' then case when charindex('sms',b.actionlist,0) > 0 then 1 else 0 end
								when 'subject' then case when charindex('email',b.actionlist,1) > 0 then 1 else 0 end
								when 'content_markdown' then case when charindex('email',b.actionlist,1) > 0 then 1 else 0 end
								when 'content_type' then case when charindex('email',b.actionlist,0) > 0 then 1 else 0 end
								when 'bodytype' then case when charindex('email',b.actionlist,0) > 0 then 1 else 0 end
								when 'send_name' then case when charindex('email',b.actionlist,0) > 0 then 1 else 0 end
								when 'content_notify' then case when charindex('push',b.actionlist,0) > 0 then 1 else 0 end
								when 'isHighLight' then case when charindex('push',b.actionlist,0) > 0 then 1 else 0 end
								when 'isPublish' then case when charindex('push',b.actionlist,0) > 0 then 1 else 0 end
								else [isVisiable] end
			  ,[IsEmpty]
			  ,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
			  ,columnDisplay
			  ,isIgnore
		  FROM fn_config_form_gets('NotifyTemplate', @acceptLanguage) a
			,NotifyTemplate b
		  --WHERE (isvisiable = 1 or isRequire = 1)
			where b.tempId = @tempId 
		  order by ordinal
	end
	else
	begin
		select @tempId as id
			,@n_id as n_id
			,tableKey = 'NotifyTemplate'
			,groupKey = 'common_group'

		SELECT *
		  FROM dbo.fn_get_field_group_lang('common_group', @acceptLanguage)
			   order by intOrder

		SELECT a.id,
			  a.[table_name]
			  ,a.[field_name]
			  ,a.[view_type]
			  ,a.[data_type]
			  ,a.[ordinal]
			  ,a.[columnLabel]
			  ,a.group_cd
			  ,case [data_type] 
				  when 'uniqueidentifier' then convert(nvarchar(500), case [field_name] 
						when 'n_id' then cast(@n_id as varchar(50))
						when 'source_ref' then lower(cast(b.source_ref as varchar(100)))
						when 'tempId' then cast(b.tempId as nvarchar(50))
						end)
				when 'nvarchar' then convert(nvarchar(max), case [field_name] 
						when 'subject' then b.[subject]
						when 'actionlist' then b.actionlist
						when 'content_notify' then b.content_notify 
						when 'content_sms' then b.content_sms 
						when 'content_markdown' then b.content_markdown 
						when 'content_email' then b.content_email 
						when 'bodytype' then b.bodytype 
						when 'external_key' then @external_key
						when 'source_key' then 'common'
					end)
				  else convert(nvarchar(50),case [field_name] 
						when 'content_type' then b.content_type
					end) end as columnValue
			  ,[columnClass]
			  ,[columnType]
			  ,[columnObject]
			  ,[isSpecial]
			  ,[isRequire]
			  ,[isDisable]	= case when [field_name] = 'source_key' and 'common' is null then 0 else [isDisable] end
			  ,[IsVisiable]
			  ,[IsEmpty]
			  ,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
			  ,columnDisplay
			  ,isIgnore
		  FROM fn_config_form_gets('NotifyTemplate', @acceptLanguage) a
			left join NotifyInbox b on b.n_id = @n_id 
		  --WHERE (isvisiable = 1 or isRequire = 1)			
		  order by ordinal

	end
		
	select a.n_id, a.attach_name, a.attach_url 
	from NotifyAttach a
	where n_id = @tempId 

	
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_temp_fields ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'notify_temp', 'GET', @SessionID, @AddlInfo
	end catch