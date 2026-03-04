

-- =============================================
-- Author:		duongpx
-- Create date: 11/25/2024 9:26:40 AM 
-- Description:	Cap nhat trang thai gui thong bao cua job
-- =============================================
CREATE procedure [dbo].[sp_res_notify_sent_set]
    @Oid              uniqueidentifier = null, -- mã id của thông báo
    @InboxStatus      int = null, -- 1: đang gửi, 2: đã gửi    
    @NotifySentStatus NotifySentStatusType readonly
as
begin try
    -- Step 2 update trạng thái NotifySent
    -- 0 là nháp
    -- 1 là đang gửi
    -- 2 là đã gửi
    -- 3 là không gửi được
    -- khác N/A
	SET NOCOUNT ON;
	DECLARE @email_count INT,
			@push_count INT,
			@sms_count INT;

	SELECT 
		@email_count = SUM(CASE WHEN email_st = 2 THEN 1 ELSE 0 END),
		@push_count  = SUM(CASE WHEN push_st = 2 THEN 1 ELSE 0 END),
		@sms_count   = SUM(CASE WHEN sms_st = 2 THEN 1 ELSE 0 END)
	FROM @NotifySentStatus;

	BEGIN TRAN;
    if @Oid is not null
        begin
            update NotifyInbox
            set send_st = @InboxStatus,
				email_count	 = @email_count,
				sms_count = @sms_count,
				push_count = @push_count
            where n_id = @Oid
        end

     update ns
		set sms_st           = nss.sms_st
		  , email_st         = nss.email_st
		  , push_st          = nss.push_st
		  , sms_st_message   = nss.sms_st_message
		  , email_st_message = nss.email_st_message
		  , push_st_message  = nss.push_st_message
		from NotifySent ns WITH (ROWLOCK, UPDLOCK)
		  inner join @NotifySentStatus nss on ns.GuidId = nss.id
	COMMIT TRAN

end try
begin catch
    declare @ErrorNum int,
        @ErrorMsg varchar(200),
        @ErrorProc varchar(50),

        @SessionID int,
        @AddlInfo varchar(max)

    set @ErrorNum = error_number()
    set @ErrorMsg = 'sp_notify_sent_set ' + error_message()
    set @ErrorProc = error_procedure()

    set @AddlInfo = '@n_id ' + cast(@Oid as varchar(50))

    exec utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotifySent', 'GET', @SessionID, @AddlInfo
end catch


/****** Object:  StoredProcedure [dbo].[sp_bzz_notify_sent_get]    Script Date: 11/25/2024 9:26:14 AM ******/
SET ANSI_NULLS ON