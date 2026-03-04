


-- =============================================
-- Author:		duongpx
-- Create date: 11/25/2024 9:26:14 AM
-- Description:	Lấy thông báo cần gửi đi cho job
-- =============================================
CREATE procedure [dbo].[sp_res_notify_sent_get]
    @Oid    uniqueidentifier = 'bfdf903d-e466-42de-9fac-0297e11f7cde', -- mã id của thông báo
    @ids    nvarchar(max) = null,
    @action nvarchar(150) = '', -- push, sms, email
    @isAll  bit = 0
as
begin try
    -- 0 là nháp
    -- 1 là đang gửi
    -- 2 là đã gửi
    -- 3 là không gửi được
    -- khác N/A    
    set @ids = ''
    declare @isPush bit = iif(charindex('push', @action) > 0, 1, 0)
    declare @isSms bit = iif(charindex('sms', @action) > 0, 1, 0)
    declare @isEmail bit = iif(charindex('email', @action) > 0, 1, 0)

    select
        [subject]
        , a.content_notify
        , a.content_markdown
        , a.send_by

        , a.send_name
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
        , n_id

        , brand_name
        , a.content_sms
        , attachs
        , iif(isnull(@action, '') <> '', @action, a.actionlist) as action_list
    from [dbo].NotifyInbox a
    where n_id = @Oid

    drop table if exists #tmpIds
    create table #tmpIds (
        id uniqueidentifier primary key
    )

    IF (LEN(@ids) > 0)
	BEGIN
		INSERT INTO #tmpIds (id)
		SELECT TRY_CAST(value AS UNIQUEIDENTIFIER)
		FROM fn_SplitString(@ids, ',')
		WHERE TRY_CAST(value AS UNIQUEIDENTIFIER) IS NOT NULL;
	END

    select convert(nvarchar(50), a.GuidId)                     as id
        , ISNULL(TRY_CAST(a.userId AS uniqueidentifier),'00000000-0000-0000-0000-000000000000') AS userId
        , cast(a.custId as varchar(50))                  as [custId]
        , [email]
        , [phone]
        , a.[fullName]
        , a.[push_st]
        , a.[sms_st]
        , a.[email_st]
        , a.createId
        , a.createDt
        , a.n_id
        , isnull(a.subject, n.subject)                   as subject
        , isnull(a.content_notify, n.content_notify)     as content_notify
        , isnull(a.content_email, n.content_email) as content_email
        , isnull(a.content_sms, n.content_sms) as content_sms
        , external_param = isnull(a.external_param,n.external_param)
        , a.attachs
    from [dbo].NotifySent a
             join [dbo].NotifyInbox n on a.n_id = n.n_id
    where a.n_id = @Oid
      and (
        (@isPush = 1 and a.push_st = 1)
            or (@isSms = 1 and a.sms_st = 1)
            or (@isEmail = 1 and a.email_st = 1)
            or (@isAll = 1))
      and (@ids = '' or
           exists(select 1 from #tmpIds r where r.id = a.n_id))
    order by a.createDt

    select
        ns.id
        , ud.playerId
        , ud.userId as userId
    from UserDevice ud
       inner join NotifySent ns on ns.userId = ud.userId
    where @isPush = 1
      and ns.push_st = 1
      and ns.n_id = @Oid
      and isnull(ud.playerId, '') <> ''
      and (@ids = '' or
           exists(select 1 from #tmpIds r where r.id = ns.n_id))


end try
begin catch
    declare @ErrorNum int,
        @ErrorMsg varchar(200),
        @ErrorProc varchar(50),

        @SessionID int,
        @AddlInfo varchar(max)

    set @ErrorNum = error_number()
    set @ErrorMsg = 'sp_notify_sent_get ' + error_message()
    set @ErrorProc = error_procedure()

    set @AddlInfo = '@n_id ' + cast(@Oid as varchar(50))

    exec utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotiSent', 'GET', @SessionID, @AddlInfo
end catch