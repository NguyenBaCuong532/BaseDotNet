CREATE PROCEDURE [dbo].[sp_res_notify_info_draft]
    @UserID			UNIQUEIDENTIFIER,
    @tempId			uniqueidentifier = null,
    @n_id			UNIQUEIDENTIFIER = NULL,
    @actionlist		NVARCHAR(200),
    @Subject		NVARCHAR(100),
    @content_notify NVARCHAR(300) = null,
    @content_sms	NVARCHAR(320),
    @content_type	INT,
    @content_markdown NVARCHAR(MAX),
    @content_email	NVARCHAR(MAX),
    @bodytype		NVARCHAR(10) = 'text',
    @IsPublish		bit = null,
    @external_sub	NVARCHAR(100) = null,
	@external_name NVARCHAR(100) = null,
    @external_key	NVARCHAR(50) = NULL,
    @source_ref		UNIQUEIDENTIFIER = NULL,
    @source_key		NVARCHAR(30),
    @external_event NVARCHAR(50) = NULL,
    @brand_name		NVARCHAR(20) = NULL,
    @send_name		NVARCHAR(200) = NULL,
    @notiAvatarUrl	NVARCHAR(350) = NULL,
	@Schedule		NVARCHAR(25) = null,
	@template_field NVARCHAR(50) = NULL,
    @isHighLight	BIT = null,
    @attachs user_notify_attach READONLY
	,	@to_type		nvarchar(10) = NULL 
	,@notiTos		user_notify_to	readonly
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
    DECLARE @valid BIT;
    DECLARE @messages NVARCHAR(300);
	declare @to_level int = 0
	declare @to_groups nvarchar(max) = ''
	set @to_type = isnull(@to_type,'0')
    BEGIN TRY
	
        select n_id			= @n_id 
			  ,tempId		= @tempId
			  ,external_sub = @external_sub
			  ,groupKey		= 'common_group'
			  ,[tableKey]	= 'NotifyInbox1'
			  ,to_count = (select count(*) from @notiTos)

		SELECT *
		FROM [dbo].[fn_get_field_group_lang]('common_group', @acceptLanguage)
		

		SELECT a.[id]
			  ,a.[table_name]
			  ,a.[field_name]
			  ,a.[view_type]
			  ,a.[data_type]
			  ,a.[ordinal]
			  ,a.[columnLabel]
			  ,a.[group_cd]
			  ,case [data_type] 
				  when 'nvarchar' then convert(nvarchar(max), case [field_name] 
						when 'subject' then isnull(@subject,b.subject)
						when 'actionlist' then isnull(@actionlist,b.actionlist)
						when 'content_notify' then isnull(@content_notify,b.content_notify) 
						when 'content_sms' then isnull(@content_sms,b.content_sms) 
						when 'content_markdown' then isnull(@content_markdown,b.content_markdown) 
						when 'content_email' then isnull(@content_email,b.content_email) 
						when 'bodytype' then isnull(@bodytype,b.bodytype) 
						when 'external_key' then @external_key 
						when 'external_sub' then @external_sub 
						when 'external_event' then @external_event
						when 'source_key' then @source_key
						when 'brand_name' then isnull(@brand_name,b.brand_name)
						when 'notiAvatarUrl' then @notiAvatarUrl
						when 'tempId' then lower(cast(@tempId as varchar(100)))
						when 'source_ref' then lower(cast(@source_ref as varchar(100)))
						when 'send_name' then isnull(@send_name,b.send_name)
						when 'to_type' then @to_type
					end) 
				  when 'datetime' then convert(nvarchar(100),case [field_name] 
						when 'notiDt' then format(getdate(),'dd/MM/yyyy HH:mm:ss')
						when 'schedule' then @Schedule
          end)
          when 'bit' then convert(nvarchar(100),case [field_name] 
						when 'isHighLight' then IIF(@isHighLight = 1, 'true', 'false')
          end)
				  else convert(nvarchar(50),case [field_name] 
						when 'content_type' then isnull(@content_type,b.content_type)
						when 'isPublish' then @isPublish  
-- 						when 'isHighLight' then @isHighLight
					end) end as columnValue
			  ,[columnClass]
			  ,[columnType]
			  ,case [field_name]
				when 'content_markdown' then a.columnObject + convert(varchar(50), @tempId)
				ELSE a.columnObject
			   END AS [columnObject]
			  ,[isSpecial]
			  ,[isRequire]
			  ,[isDisable]
			  ,[isVisiable] = case [field_name] 
								when 'content_sms' then case when charindex('sms',isnull(@actionlist,b.actionlist),0) > 0 then 1 else 0 end
								when 'brand_name' then case when charindex('sms',isnull(@actionlist,b.actionlist),0) > 0 then 1 else 0 end
								when 'subject' then case when charindex('email',isnull(@actionlist,b.actionlist),1) > 0 then 1 else 0 end
								when 'content_markdown' then case when charindex('email',isnull(@actionlist,b.actionlist),1) > 0 then 1 else 0 end
								when 'content_type' then case when charindex('email',isnull(@actionlist,b.actionlist),0) > 0 then 1 else 0 end
								when 'bodytype' then case when charindex('email',isnull(@actionlist,b.actionlist),0) > 0 then 1 else 0 end
								when 'send_name' then case when charindex('email',isnull(@actionlist,b.actionlist),0) > 0 then 1 else 0 end
								when 'content_notify' then case when charindex('push',isnull(@actionlist,b.actionlist),0) > 0 then 1 else 0 end
								when 'isHighLight' then case when charindex('push',isnull(@actionlist,b.actionlist),0) > 0 then 1 else 0 end
								when 'isPublish' then case when charindex('push',isnull(@actionlist,b.actionlist),0) > 0 then 1 else 0 end
								else [isVisiable] end
								
			  ,[isEmpty]
			  ,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
			  ,a.columnDisplay
			  ,a.isIgnore
		  FROM fn_config_form_gets('NotifyInbox1', @acceptLanguage) a
			left join NotifyTemplate b on b.tempId = @tempId
		  where (a.isvisiable = 1 or a.isRequire = 1)		
		  order by ordinal

		  select *
		  from @attachs a

		  select * from [dbo].[fn_config_list_gets_lang] ('view_notify_to_page', 0, @acceptLanguage) 
			order by [ordinal]
		
		SELECT b.id 
			  ,b.to_level 
			  ,b.to_groups 
			  ,b.to_type
			  ,b.to_row 
			  ,to_level_name = cd1.par_desc
		FROM @notiTos b 
		LEFT JOIN dbo.sys_config_data cd1 ON cd1.key_2 = b.to_level AND cd1.key_1 ='notify_to_level'
		

    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum INT,
                @ErrorMsg VARCHAR(200),
                @ErrorProc VARCHAR(50),
                @SessionID INT,
                @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_notify_info_draft ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();

        SET @AddlInfo = '@NotiId ' ;
        SET @valid = 0;
        SET @messages = ERROR_MESSAGE();

        EXEC utl_Insert_ErrorLog @ErrorNum,
                                 @ErrorMsg,
                                 @ErrorProc,
                                 'NotificationApp',
                                 'Set',
                                 @SessionID,
                                 @AddlInfo;
    END CATCH;

    SELECT @valid AS valid,
           @messages AS [messages],
           @n_id AS id;

END;