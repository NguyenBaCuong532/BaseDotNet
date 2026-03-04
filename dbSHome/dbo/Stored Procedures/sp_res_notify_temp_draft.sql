CREATE PROCEDURE [dbo].[sp_res_notify_temp_draft]
     @UserID			UNIQUEIDENTIFIER = NULL,
    @n_id				uniqueidentifier,
	@external_key		nvarchar(50),
	@tempId			uniqueidentifier,
	@tempName			nvarchar(200),
	@tempCd			nvarchar(50),
	@actionlist		nvarchar(200),
	@Subject			nvarchar(100),
	@content_notify	nvarchar(300),
	@content_sms		nvarchar(320),
	@content_type		int,
	@content_markdown	nvarchar(max),
	@content_email		nvarchar(max),
	@bodytype			nvarchar(10)	= 'text',	
	@source_key		nvarchar(50),
	@source_ref		uniqueidentifier = null,
	@external_event	nvarchar(50)	= null,
	@external_sub	nvarchar(50)	= null,
	@external_param	nvarchar(50)	= null,
	@send_by			nvarchar(50)	= null,
	@send_name			nvarchar(50)	= null,
	@brand_name		nvarchar(50)	= null,
	@app_st			bit,
    @attachs user_notify_attach READONLY,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
    DECLARE @valid BIT;
    DECLARE @messages NVARCHAR(300);

    BEGIN TRY
	SET NOCOUNT ON;

	DECLARE @tableKey NVARCHAR(100) = N'NotifyTemplate';
	DECLARE @groupKey NVARCHAR(200) = N'common_group';
	
        select n_id			= @n_id 
			  ,tempId		= @tempId
			  ,groupKey		= @groupKey
			  ,[tableKey]	= @tableKey

		SELECT *
		FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
		ORDER BY intOrder;

		SELECT a.id
			  ,a.[table_name]
			  ,a.[field_name]
			  ,a.[view_type]
			  ,a.[data_type]
			  ,a.[ordinal]
			  ,a.[columnLabel]
			  ,a.[group_cd]
			  ,columnValue = case a.[data_type] 
				  when 'nvarchar' then convert(nvarchar(max), case a.[field_name] 
						when 'subject' then @subject
						when 'actionlist' then @actionlist
						when 'content_notify' then @content_notify
						when 'content_sms' then @content_sms
						when 'content_markdown' then @content_markdown
						when 'content_email' then @content_email
						when 'bodytype' then @bodytype
						when 'external_key' then @external_key 
						when 'external_event' then @external_event
						when 'source_key' then @source_key
						when 'brand_name' then @brand_name
						when 'tempId' then lower(cast(@tempId as varchar(100)))
						when 'source_ref' then lower(cast(@source_ref as varchar(100)))
						when 'send_name' then @send_name
						when 'tempCd'	then @tempCd
					end) 
				  when 'datetime' then convert(nvarchar(100),case a.[field_name] 
						when 'notiDt' then format(getdate(),'dd/MM/yyyy HH:mm:ss')
						end)
				  else convert(nvarchar(50),case a.[field_name] 
						when 'content_type' then @content_type
						when 'app_st' then @app_st  
					end) end
			  ,a.[columnClass]
			  ,a.[columnType]
			  ,a.[columnObject]
			  ,a.[isSpecial]
			  ,a.[isRequire]
			  ,a.[isDisable]
			  ,[isVisiable] = case a.[field_name] 
								when 'content_sms' then case when charindex('sms',@actionlist,0) > 0 then 1 else 0 end
								when 'brand_name' then case when charindex('sms',@actionlist,0) > 0 then 1 else 0 end
								when 'subject' then case when charindex('email',@actionlist,1) > 0 then 1 else 0 end
								when 'content_markdown' then case when charindex('email',@actionlist,1) > 0 then 1 else 0 end
								when 'content_type' then case when charindex('email',@actionlist,0) > 0 then 1 else 0 end
								when 'bodytype' then case when charindex('email',@actionlist,0) > 0 then 1 else 0 end
								when 'send_name' then case when charindex('email',@actionlist,0) > 0 then 1 else 0 end
								when 'content_notify' then case when charindex('push',@actionlist,0) > 0 then 1 else 0 end
								when 'isHighLight' then case when charindex('push',@actionlist,0) > 0 then 1 else 0 end
								when 'isPublish' then case when charindex('push',@actionlist,0) > 0 then 1 else 0 end
								else a.[IsVisiable] end
								
			  ,a.[isEmpty]
			  ,columnTooltip = isnull(a.columnTooltip, a.[columnLabel])
			  ,a.[columnDisplay]
			  ,a.[isIgnore]
		  FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
		  WHERE (a.IsVisiable = 1 OR a.isRequire = 1)			
		  ORDER BY a.ordinal

		  select *
		  from @attachs a

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