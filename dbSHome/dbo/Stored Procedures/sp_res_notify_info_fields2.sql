CREATE PROCEDURE [dbo].[sp_res_notify_info_fields2]
	 @UserId			UNIQUEIDENTIFIER = NULL
	,@tempId		uniqueidentifier
	,@n_id			uniqueidentifier	= null
	,@actions		nvarchar(50) = 'email'
	,@to_level		int
	,@to_groups		nvarchar(max)
	,@external_key	NVARCHAR(50)
	,@external_sub	NVARCHAR(50) = null
	,@to_type		int = 0 --0 crm, 1 resident
	,@source_ref	nvarchar(50) = null
	,@AcceptLanguage VARCHAR(20) = 'vi-VN'
as
	begin try
	--1
	declare @group_cd nvarchar(10) = 't1'

	if exists(select notiId from NotifyInbox where n_id = @n_id) --and external_key = @external_key)
	begin
		select a.n_id-- as id
			  ,a.tempId
			  ,a.external_sub
			  ,to_count = (select count(id) from NotifyTo where sourceId = a.n_id)
			  ,[tableKey]	= 'NotifyInbox1'
			  ,groupKey		= 'common_group'
		from NotifyInbox a
		where n_id = @n_id

		SELECT *
		FROM [dbo].[fn_get_field_group_lang]('common_group', @AcceptLanguage)		

		SELECT [table_name]
			  ,[field_name]
			  ,[view_type]
			  ,[data_type]
			  ,[ordinal]
			  ,[columnLabel]
			  ,[group_cd]
			  ,case [data_type] 
				  when 'nvarchar' then convert(nvarchar(max), case [field_name] 
						when 'subject' then b.subject 
						when 'actionlist' then b.actionlist 
						when 'content_notify' then b.content_notify 
						when 'content_sms' then b.content_sms 
						when 'content_markdown' then b.content_markdown 
						when 'content_email' then b.content_email 
						when 'bodytype' then b.bodytype 
						when 'external_key' then b.external_key 
						when 'external_sub' then b.external_sub 
						when 'external_event' then b.external_event
						when 'source_key' then b.source_key
						when 'brand_name' then b.brand_name
						when 'notiAvatarUrl' then b.notiAvatarUrl
						when 'tempId' then lower(cast(b.tempId as varchar(100)))
						when 'source_ref' then lower(cast(b.source_ref as varchar(100)))
						when 'send_name' then b.send_name
						when 'to_type' then cast(b.to_type as nvarchar(10))
					end) 
					when 'uniqueidentifier' then convert(nvarchar(50), case [field_name] 
						when 'attachs' then b.attachs
					end)
				  when 'bit' then convert(nvarchar(100),case [field_name] 
						when 'isPublish' then iif(b.isPublish = 1, 'true','false')
						when 'isHighLight' then iif(b.isHighLight = 1, 'true','false')
						end)
				  when 'datetime' then convert(nvarchar(100),case [field_name] 
						when 'notiDt' then format(b.notiDt,'dd/MM/yyyy HH:mm:ss')
						when 'schedule' then format(b.schedule,'dd/MM/yyyy HH:mm:ss')
						end)
				  else convert(nvarchar(50),case [field_name] 
						when 'notiId' then b.notiId
						when 'content_type' then b.content_type
					end) end as columnValue
			  ,[columnClass]
			  ,[columnType]
			  ,[columnObject] = 
					case 
						when field_name = 'attachs' then [columnObject] + isnull(cast(b.attachs as nvarchar(50)),'')
						when field_name = 'notiAvatarUrl' then [columnObject] + isnull(cast(b.notiAvatarUrl as nvarchar(50)),'')
					else [columnObject] end
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
								when 'notiAvatarUrl' then case when charindex('push',b.actionlist,0) = 0 then 0 else [isVisiable] end
								else [isVisiable] end
			  ,[isEmpty]
			  ,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
			  ,columnDisplay
			  ,isIgnore
		  FROM dbo.fn_config_form_gets('NotifyInbox1', @AcceptLanguage) a
			,NotifyInbox b
		  where (b.n_id = @n_id)
			order by ordinal
		
	end
	else
	begin
		if @to_type = 1 set @actions = 'email,push'

		select n_id			= @n_id 
			  ,tempId		= @tempId
			  ,external_sub = @external_sub
			  ,to_count		= 1
			  ,groupKey		= 'common_group'
			  ,[tableKey]	= 'NotifyInbox1'

		SELECT * 
		FROM [dbo].[fn_get_field_group]('common_group')
		

		SELECT [table_name]
			  ,[field_name]
			  ,[view_type]
			  ,[data_type]
			  ,[ordinal]
			  ,[columnLabel]
			  ,[group_cd]
			  ,case [data_type] 
				  when 'nvarchar' then convert(nvarchar(max), case [field_name] 
						when 'subject' then b.subject
						when 'actionlist' then isnull(b.actionlist,isnull(@actions,a.columnDefault))
						when 'content_notify' then b.content_notify 
						when 'content_sms' then b.content_sms 
						when 'content_markdown' then b.content_markdown 
						when 'content_email' then b.content_email 
						when 'bodytype' then isnull(b.bodytype ,a.columnDefault)
						when 'external_key' then @external_key
						when 'external_sub' then @external_sub 
						when 'external_event' then b.external_event
						when 'source_key' then isnull(b.source_key,a.columnDefault)
						when 'brand_name' then isnull(b.brand_name,a.columnDefault)
						when 'notiAvatarUrl' then dbo.fn_url_absolute(b.notiAvatarUrl)
						when 'tempId' then lower(cast(b.tempId as varchar(100)))
						when 'source_ref' then lower(cast(b.source_ref as varchar(100)))
						when 'send_name' then b.send_name
						when 'to_type' then cast(@to_type as nvarchar(10))
					end) 
				  when 'bit' then convert(nvarchar(100),case [field_name] 
						when 'isPublish' then 'true'
						when 'isHighLight' then 'false'
						end)
				  when 'datetime' then convert(nvarchar(100),case [field_name] 
						when 'notiDt' then format(getdate(),'dd/MM/yyyy HH:mm:ss')
						end)
				  else convert(nvarchar(50),case [field_name] 
						when 'content_type' then isnull(b.content_type,a.columnDefault)
					end) end as columnValue
			  ,[columnClass]
			  ,[columnType]
			  ,[columnObject]
			  ,[isSpecial]
			  ,[isRequire]
			  ,[isDisable]
			  ,[isVisiable] = case [field_name] 
								when 'content_sms' then case when charindex('sms',isnull(b.actionlist,isnull(@actions,a.columnDefault)),0) > 0 then 1 else 0 end
								when 'brand_name' then case when charindex('sms',isnull(b.actionlist,isnull(@actions,a.columnDefault)),0) > 0 then 1 else 0 end
								when 'subject' then case when charindex('email',isnull(b.actionlist,isnull(@actions,a.columnDefault)),1) > 0 then 1 else 0 end
								when 'content_markdown' then case when charindex('email',isnull(b.actionlist,isnull(@actions,a.columnDefault)),1) > 0 then 1 else 0 end
								when 'content_type' then case when charindex('email',isnull(b.actionlist,isnull(@actions,a.columnDefault)),0) > 0 then 1 else 0 end
								when 'bodytype' then case when charindex('email',isnull(b.actionlist,isnull(@actions,a.columnDefault)),0) > 0 then 1 else 0 end
								when 'send_name' then case when charindex('email',isnull(b.actionlist,isnull(@actions,a.columnDefault)),0) > 0 then 1 else 0 end
								when 'content_notify' then case when charindex('push',isnull(b.actionlist,isnull(@actions,a.columnDefault)),0) > 0 then 1 else 0 end
								when 'isHighLight' then case when charindex('push',isnull(b.actionlist,isnull(@actions,a.columnDefault)),0) > 0 then 1 else 0 end
								when 'isPublish' then case when charindex('push',isnull(b.actionlist,isnull(@actions,a.columnDefault)),0) > 0 then 1 else 0 end
								else [isVisiable] end
			  ,[isEmpty]
			  ,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
			  ,columnDisplay
			  ,isIgnore
		  FROM
          dbo.fn_config_form_gets('NotifyInbox1', @AcceptLanguage) a
          left join NotifyTemplate b on b.tempId = @tempId
		  where (table_name = 'NotifyInbox1' and (isvisiable = 1 or isRequire = 1))
		  order by [group_cd], ordinal

	end
		
	select a.notiId
		  ,a.attach_name
		  ,a.attach_url 
		  ,a.attach_type
	from NotifyAttach a
	where n_id = @n_id

	select * from [dbo].[fn_config_list_gets_lang] ('view_notify_to_page', 0, @AcceptLanguage) 
	order by [ordinal]
		
		SELECT b.id 
			  ,b.to_level 
			  ,b.to_groups 
			  ,b.to_type
			  ,b.to_row 
			  ,b.createDt
			  ,to_groups_name = case b.to_level when 0 then STUFF((
									  SELECT ',' +  tt.categoryName 
									  FROM MAS_Category tt 
									  WHERE tt.categoryCd in (select s.part from dbo.fn_split_string(b.to_groups,',') s)
									  FOR XML PATH('')), 1, 1, '') 
								when 1 then STUFF((
									  SELECT ',' +  tt.categoryName 
									  FROM MAS_Category tt 
									  WHERE tt.categoryCd in (select s.part from dbo.fn_split_string(b.to_groups,',') s)
									  FOR XML PATH('')), 1, 1, '')
								when 2 then STUFF((
									  SELECT ',' +  tt.GroupName 
									  FROM CRM_Group tt 
									  WHERE tt.GroupId in (select s.part from dbo.fn_split_string(b.to_groups,',') s)
									  FOR XML PATH('')), 1, 1, '')
								when 3 then STUFF((
									  SELECT ',' +  tt.FullName
									  FROM MAS_Customers tt 
									  WHERE tt.CustId in (select s.part from dbo.fn_split_string(b.to_groups,',') s)
									  FOR XML PATH('')), 1, 1, '')
								else b.to_groups end
			  ,to_level_name = cd1.par_desc
		FROM NotifyTo b 
		LEFT JOIN dbo.sys_config_data cd1 ON cd1.key_2 = b.to_level AND cd1.key_1 ='notify_to_level'
		WHERE b.sourceId = @n_id 
		union
		SELECT id = null
			  ,to_level = @to_level
			  ,to_groups = @to_groups
			  ,to_type = 0
			  ,to_row = 1
			  ,getdate() as createDt
			  ,to_groups_name = case @to_level when 0 then STUFF((
									  SELECT ',' +  tt.categoryName 
									  FROM MAS_Category tt 
									  WHERE tt.categoryCd in (select s.part from dbo.fn_split_string(@to_groups,',') s)
									  FOR XML PATH('')), 1, 1, '') 
								when 1 then STUFF((
									  SELECT ',' +  tt.categoryName 
									  FROM MAS_Category tt 
									  WHERE tt.categoryCd in (select s.part from dbo.fn_split_string(@to_groups,',') s)
									  FOR XML PATH('')), 1, 1, '')
								when 2 then STUFF((
									  SELECT ',' +  tt.GroupName 
									  FROM CRM_Group tt 
									  WHERE tt.GroupId in (select s.part from dbo.fn_split_string(@to_groups,',') s)
									  FOR XML PATH('')), 1, 1, '')
								when 3 then STUFF((
									  SELECT ',' +  tt.FullName
									  FROM MAS_Customers tt 
									  WHERE tt.CustId in (select s.part from dbo.fn_split_string(@to_groups,',') s)
									  FOR XML PATH('')), 1, 1, '')
								else @to_groups end
			  ,to_level_name = (select top 1 cd1.par_desc 
					from dbo.sys_config_data cd1 
					where cd1.key_2 = @to_level AND cd1.key_1 ='notify_to_level')
		where @to_level is not null and @to_groups is not null and @to_groups <> ''

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_info_fields1 ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'SchemeField', 'GET', @SessionID, @AddlInfo
	end catch