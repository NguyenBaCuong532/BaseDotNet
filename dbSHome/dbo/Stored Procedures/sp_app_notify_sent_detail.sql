


CREATE   procedure [dbo].[sp_app_notify_sent_detail]
    @userId uniqueidentifier = null,
	@acceptLanguage NVARCHAR(50) = N'vi-VN',
    @n_id   uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @now    datetime = GETDATE();
        DECLARE @p_user uniqueidentifier = TRY_CONVERT(uniqueidentifier, @UserId);

        /* Nếu userId không hợp lệ (không convert được), trả về rỗng */
        IF (@p_user IS NULL)
        BEGIN
            SELECT TOP (0)
                   a.n_id, a.[subject],
                   [description] = a.content_notify,
                   contentView   = a.content_notify,
                   contentEdit   = a.content_markdown,
                   isRead        = CAST(0 AS bit),
                   pushTimeAgo   = NULL,
                   pushDate      = NULL,
                   contentType   = 0,
                   a.external_event,
                   external_param = NULL,
                   notiAvatarUrl = a.notiAvatarUrl,
                   r.refName, r.refIcon
            FROM dbo.NotifyInbox a
            LEFT JOIN dbo.NotifyRef r ON a.source_ref = r.source_ref
            WHERE 1 = 0;
            RETURN;
        END

        /* ------------ Cập nhật trạng thái đọc: cực ngắn & chống deadlock ------------ */
        BEGIN TRAN;

        DECLARE @lockres nvarchar(200) =
            CONCAT(N'notify:', CONVERT(nvarchar(36), @n_id), N':', CONVERT(nvarchar(36), @p_user));

        -- Khóa ứng dụng để serialize theo (n_id, userId) -> loại trừ deadlock logic
        EXEC sys.sp_getapplock
             @Resource  = @lockres,
             @LockMode  = 'Exclusive',
             @LockOwner = 'Transaction',
             @LockTimeout = 1000; -- 1s, có thể tăng/giảm theo tải thực tế

        UPDATE c WITH (UPDLOCK, ROWLOCK)
        SET    c.read_st = 1,
               c.read_dt = @now
        FROM dbo.NotifySent  AS c
		WHERE  c.n_id    = @n_id
          AND  c.userId  = @p_user
          AND  c.read_st = 0;

        COMMIT TRAN;

        /* ------------ Đọc chi tiết sau khi đã commit ------------ */
        SELECT a.n_id,
               a.[subject],
               [description] = a.content_notify,
               contentView   = ISNULL(c.content_notify,  a.content_markdown),
               contentEdit   = ISNULL(c.content_email,   a.content_markdown),
               isRead        = ISNULL(c.read_st, 0),
               pushTimeAgo   = dbo.fn_Get_TimeAgo1(c.createDt, @now),
               pushDate      = CONVERT(varchar(10), c.createDt, 103) + ' ' + CONVERT(varchar(8), c.createDt, 108), -- dd/MM/yyyy HH:mm:ss
               contentType   = case a.[bodytype] when 'html' then 2 when 'markdown' then 1 else 0 end,
               a.external_event,
               c.external_param,
               notiAvatarUrl = (select top 1 m.file_url from meta_info m where m.sourceOid = try_cast(a.notiAvatarUrl as uniqueidentifier)),
               r.refName,
               r.refIcon
        FROM dbo.NotifyInbox AS a
		left join dbo.NotifySent  AS c ON a.n_id = c.n_id AND c.userId = @p_user
        LEFT JOIN dbo.NotifyRef AS r ON a.source_ref = r.source_ref
        WHERE a.n_id   = @n_id

		select Oid
			,n_id = a.n_id
            ,attach_name = f.file_name
            ,attach_url = file_url   
			,attach_type = f.file_type
			,attach_size = f.file_size
            ,f.sourceOid as groupFileId
			,lastModified = f.updated
        from dbo.meta_info f
			join NotifyInbox a on f.sourceOid = a.attachs
        where a.n_id = @n_id
        order by f.created

        OPTION (RECOMPILE);
    
	END TRY
    BEGIN CATCH
        IF (XACT_STATE() <> 0) ROLLBACK TRAN;

        DECLARE @ErrorNum  int,
                @ErrorMsg  varchar(200),
                @ErrorProc varchar(50),
                @SessionID int,
                @AddlInfo  varchar(max);

        SET @ErrorNum  = ERROR_NUMBER();
        SET @ErrorMsg  = 'sp_app_notify_sent_detail ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo  = CONCAT('@n_id ', CONVERT(nvarchar(36), @n_id), '; @UserId ', ISNULL(@UserId,''));

        EXEC dbo.utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotifySent', 'Get', @SessionID, @AddlInfo;
    END CATCH
END