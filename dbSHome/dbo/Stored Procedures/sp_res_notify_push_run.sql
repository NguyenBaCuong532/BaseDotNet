
CREATE procedure [dbo].[sp_res_notify_push_run]
	@UserID		nvarchar(450) = null,
	--@NotiId		bigint	= 0,
	@n_id		uniqueidentifier	= null,
	@ids		nvarchar(max),
	@action		nvarchar(50),
	@run_act	int = 0
	
as
	begin try	

    insert into audit_email_sms (receiveIds,userId,projectCd,[type],n_id) values (@ids,@userId,@action,'thong_bao',@n_id)

	declare @tbIds table(id int)
	set @run_act = 2
	if @action is null or @action = '' 
	select @action = actionlist 
	from NotifyInbox where n_id = @n_id

    set @run_act = isnull(@run_act, 1)
    set @ids = isnull(@ids, '')

    if @ids = ''
        begin
            if charindex('push', @action) > 0
                begin
                    update t
                    set [push_st] = case when t.userId is not null then 1 else 4 end
                      , createDt  = getdate()
                    from NotifySent t
                    where n_id = @n_id
                      and (t.push_st <= 1 or @run_act > 1)
                end

            if charindex('sms', @action) > 0
                update t
                set [sms_st] = 1
                  , createDt = getdate()
                from NotifySent t
                where (n_id = @n_id)
                  and (t.sms_st = 0 or @run_act > 1)


            if charindex('email', @action) > 0
                update t
                set [email_st] = 1
                  , createDt   = getdate()
                from NotifySent t
                where (n_id = @n_id)
                  and (email_st = 0 or @run_act > 1)

        end
    else
        begin
			insert into @tbIds 
			select try_cast(r.part as int) from [dbo].[SplitString](@ids, ',') r

            if charindex('push', @action) > 0
                begin
                    update t
                    set [push_st] = case when t.userId is not null then 1 else 4 end
                      , createDt  = getdate()
                    from NotifySent t
                             join @tbIds r on r.id = t.id
                    where n_id = @n_id
                      and (t.push_st <= 1 or @run_act > 1)

                end

            if charindex('sms', @action) > 0
                update t
                set [sms_st] = 1
                  , createDt = getdate()
                from NotifySent t
                         join @tbIds r on r.id = t.id
                where n_id = @n_id
                  and (t.sms_st = 0 or @run_act > 1)

            if charindex('email', @action) > 0
                update t
                set [email_st] = 1
                  , createDt   = getdate()
                from NotifySent t
                         join @tbIds r on r.id = t.id
                where n_id = @n_id
                  and (email_st = 0 or @run_act > 1)
        end
    -- Build nội dung cá nhân hóa nếu có formula
    EXEC [dbo].[sp_res_notify_build_personal_content] @UserID = @UserID, @n_id = @n_id;

    select [subject]
        , a.content_notify
        , a.content_markdown
        , a.content_email
        , a.content_sms
        , [notiDt]
        , [isPublish]
        , notiType
        , external_key
        , external_sub
        , external_param
        , external_event
        , content_type
        , ISNULL(@action,a.actionlist)  as action_list
        , n_id
    from [dbo].NotifyInbox a
    where n_id = @n_id
		and (a.[Schedule] is null or a.[Schedule] <= dateadd(day,-1, GETDATE()))

    select cast(a.[id] as nvarchar(50)) as id
        , cast(a.[userId] as varchar(50)) as [userId]
        , cast(a.custId as varchar(50)) [custId]        
        , a.[email]
        , a.[phone]
        , a.[fullName]
        , a.[push_st]
        , a.[sms_st]
        , a.[email_st]
        , a.createId
        , a.createDt
        , a.n_id
    from [dbo].NotifySent a
    where n_id = @n_id
	  and (a.[Schedule] is null or a.[Schedule] <= dateadd(day,-1, GETDATE()))
      and ((charindex('push', @action) > 0 and a.push_st = 1)
        or (charindex('sms', @action) > 0 and a.sms_st = 1)
        or (charindex('email', @action) > 0 and a.email_st = 1))
      and (@ids = '' or
           exists(select 1 from @tbIds r where r.id = a.id))
		   	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_notify_push_run ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@n_id ' + cast(@n_id as varchar(50))

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'NotiSent', 'Insert', @SessionID, @AddlInfo
	end catch