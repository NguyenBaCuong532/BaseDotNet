
CREATE   PROCEDURE [dbo].[sp_res_notify_info_set2]
    @UserID              NVARCHAR(450),
    @ClientId            NVARCHAR(50) = NULL,
    @n_id                UNIQUEIDENTIFIER = NULL,
    @tempId              UNIQUEIDENTIFIER = NULL,
    @actionlist          NVARCHAR(200),
    @Subject             NVARCHAR(500),
    @content_notify      NVARCHAR(300) = NULL,
    @content_sms         NVARCHAR(320),
    @content_type        INT,
    @content_markdown    NVARCHAR(MAX),
    @content_email       NVARCHAR(MAX),
    @bodytype            NVARCHAR(10) = N'html',
    @isPublish           BIT,
    @external_sub        NVARCHAR(100) = NULL,
    @external_key        NVARCHAR(50) = NULL,
    @source_ref          UNIQUEIDENTIFIER = NULL,
    @source_key          NVARCHAR(30),
    @external_event      NVARCHAR(50) = NULL,
    @brand_name          NVARCHAR(20) = NULL,
    @send_name           NVARCHAR(200) = NULL,
    @notiAvatarUrl       NVARCHAR(350) = NULL,
    @isHighLight         BIT = 0,
    @schedule            NVARCHAR(25) = NULL,
    @sendNow             INT = NULL,
	@template_field NVARCHAR(50) = NULL,
    @external_name       NVARCHAR(50) = NULL,
    @attachs             user_notify_attach READONLY,
    @notiTos             user_notify_to READONLY,
    @attachs_noti        UNIQUEIDENTIFIER = NULL,
    @to_type             NVARCHAR(10)     = NULL --- 0: crm, 1: resident
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @valid    BIT          = 0,
            @messages NVARCHAR(300);

    BEGIN TRY
        DECLARE @tbUser TABLE
        (
            [userId]   NVARCHAR(100) NULL,
            [custId]   NVARCHAR(100) NULL,
            [phone]    NVARCHAR(30)  NULL,
            [email]    NVARCHAR(300) NULL,
            [fullName] NVARCHAR(300) NULL,
            toId       UNIQUEIDENTIFIER NOT NULL,
            [room]     NVARCHAR(50) NULL
        );

        DROP TABLE IF EXISTS #notiTos;

        SELECT [id]        = ISNULL(t.id, NEWID()),
               [to_level],
               [to_groups],
               [to_row],
               [to_type]
        INTO #notiTos
        FROM @notiTos t;

        SET @actionlist    = ISNULL(@actionlist, N'push');
        SET @bodytype      = ISNULL(@bodytype,   N'html');
        SET @content_email = ISNULL(@content_email, @content_markdown);

        IF NOT EXISTS (SELECT 1 FROM dbo.NotifyInbox WHERE n_id = @n_id)
        BEGIN
            SET @n_id = NEWID();

            INSERT INTO dbo.NotifyInbox
            ( n_id, tempId, [subject], content_notify, content_markdown, content_email, content_sms,
              [bodytype], [notiDt], isPublish, notiType, external_key, external_sub, clientId,
              source_ref, source_key, actionlist, createId, content_type, external_event, brand_name,
              send_name, notiAvatarUrl, isHighLight, Schedule, attachs,
              is_act_push, is_act_sms, is_act_email,
              to_type, send_st
            )
            VALUES
            ( @n_id, @tempId, @Subject, @content_notify, @content_markdown, @content_email, @content_sms,
              @bodytype, GETDATE(), @isPublish, 0, @external_key, @external_sub, @ClientId,
              @source_ref, @source_key, @actionlist, @UserID, @content_type, @external_event, @brand_name,
              @send_name, @notiAvatarUrl, @isHighLight, CONVERT(DATETIME, @schedule, 103), @attachs_noti,
              CASE WHEN CHARINDEX('push',  @actionlist, 0) > 0 THEN 1 ELSE 0 END,
              CASE WHEN CHARINDEX('sms',   @actionlist, 0) > 0 THEN 1 ELSE 0 END,
              CASE WHEN CHARINDEX('email', @actionlist, 0) > 0 THEN 1 ELSE 0 END,
              @to_type,
              0
            );

            SET @valid    = 1;
            SET @messages = N'Thêm mới thông báo thành công';
        END
        ELSE
        BEGIN
            UPDATE dbo.NotifyInbox
               SET [subject]        = @Subject,
                   content_notify   = @content_notify,
                   content_markdown = @content_markdown,
                   content_email    = @content_email,
                   content_sms      = @content_sms,
                   [notiDt]         = GETDATE(),
                   isPublish        = @isPublish,
                   notiType         = 0,
                   external_key     = @external_key,
                   external_sub     = @external_sub,
                   bodytype         = @bodytype,
                   source_ref       = @source_ref,
                   source_key       = @source_key,
                   actionlist       = @actionlist,
                   createId         = ISNULL(createId, @UserID),
                   content_type     = @content_type,
                   external_event   = @external_event,
                   brand_name       = @brand_name,
                   send_name        = @send_name,
                   notiAvatarUrl    = @notiAvatarUrl,
                   isHighLight      = @isHighLight,
                   Schedule         = CONVERT(DATETIME, @schedule, 103),
                   attachs          = @attachs_noti,
                   is_act_push      = CASE WHEN CHARINDEX('push',  @actionlist, 0) > 0 THEN 1 ELSE 0 END,
                   is_act_sms       = CASE WHEN CHARINDEX('sms',   @actionlist, 0) > 0 THEN 1 ELSE 0 END,
                   is_act_email     = CASE WHEN CHARINDEX('email', @actionlist, 0) > 0 THEN 1 ELSE 0 END,
                   to_type          = @to_type,
                   send_st          = IIF(CONVERT(DATETIME, @schedule, 103) IS NOT NULL, 0, send_st)
             WHERE n_id = @n_id;

            SET @valid    = 1;
            SET @messages = N'Sửa thông báo thành công';
        END;

        /* ===== Attach sync (set-based) ===== */
        DELETE t
        FROM dbo.NotifyAttach AS t
        WHERE t.n_id = @n_id
          AND NOT EXISTS (SELECT 1 FROM @attachs a WHERE a.attach_url = t.attach_url);

        INSERT INTO dbo.NotifyAttach
            (notiId, attach_name, attach_url, attach_type, attach_sysdate, n_id)
        SELECT 0, a.attach_name, a.attach_url, a.attach_type, GETDATE(), @n_id
        FROM @attachs a
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.NotifyAttach o
            WHERE o.n_id = @n_id AND o.attach_url = a.attach_url
        );

        /* ===== NotifyTo upsert ===== */
        DELETE t
        FROM dbo.NotifyTo t
        WHERE t.sourceId = @n_id
          AND NOT EXISTS (SELECT 1 FROM #notiTos a WHERE a.id = t.id);

        UPDATE t
           SET [to_level]  = a.to_level,
               [to_groups] = a.to_groups
        FROM dbo.NotifyTo t
        JOIN #notiTos a ON t.id = a.id;

        INSERT INTO dbo.NotifyTo
            ([sourceId],[to_level],[to_groups],[createId],[createDt],[to_type])
        SELECT @n_id, a.to_level, a.to_groups, @UserId, GETDATE(), a.to_type
        FROM #notiTos a
        WHERE NOT EXISTS (SELECT 1 FROM dbo.NotifyTo o WHERE o.id = a.id);

        ;WITH UpdateData AS
        (
            SELECT id, ROW_NUMBER() OVER (ORDER BY [createDt]) AS RN
            FROM dbo.NotifyTo
            WHERE sourceId = @n_id
        )
        UPDATE t
           SET to_row = u.RN
        FROM dbo.NotifyTo t
        JOIN UpdateData u ON t.id = u.id
        WHERE t.sourceId = @n_id;

        /* ===== Build recipient list: loại trùng theo user/cust ===== */
        ;WITH RawUsers AS
        (
            SELECT
                u.[userId],
                u.[custId],
                u.[phone],
                u.[email],
                u.[fullName],
                u.[room],
                a.id AS toId,
                IdentityKey =
                    CASE 
                       -- WHEN u.userId IS NOT NULL THEN 'U:' + u.userId
                        WHEN u.custId IS NOT NULL THEN 'C:' + u.custId
                        ELSE 'P:' + ISNULL(u.phone,'') + '|E:' + ISNULL(u.email,'')
                    END
            FROM #notiTos a
            CROSS APPLY dbo.[fn_get_user_push](@UserId, a.to_type, a.to_level, a.to_groups) u
        ),
        Dedup AS
        (
            SELECT
                userId   = MAX(userId),
                custId   = MAX(custId),
                phone    = MAX(phone),
                email    = MAX(email),
                fullName = MAX(fullName),
                room     = MAX(room),
                toId     = MIN(toId),
                IdentityKey
            FROM RawUsers
            GROUP BY IdentityKey
        )
        INSERT INTO @tbUser ([userId],[custId],[phone],[email],[fullName], toId, room)
        SELECT userId, custId, phone, email, fullName, toId, room
        FROM Dedup;

        /* ===== Sync NotifySent (set-based) ===== */
        -- Xoá các bản ghi NotifySent không còn trong danh sách người nhận thực tế (@tbUser)
        DELETE s
        FROM dbo.NotifySent s
        WHERE s.n_id = @n_id
          AND s.toId IN (SELECT id FROM #notiTos)
          AND NOT EXISTS
            (
              SELECT 1
              FROM @tbUser u
              WHERE
                    (u.userId IS NOT NULL AND u.userId = s.userId)
                 OR (u.custId IS NOT NULL AND u.custId = s.custId)
                 OR (u.userId IS NULL AND u.custId IS NULL AND u.phone IS NOT NULL AND u.phone = s.phone)
                 OR (u.userId IS NULL AND u.custId IS NULL AND u.phone IS NULL AND u.email IS NOT NULL AND u.email = s.email)
            );

        -- Thêm mới bản ghi cần gửi còn thiếu (không cho trùng userId/custId/phone/email theo n_id)
        INSERT INTO dbo.NotifySent
        ( [userId],[custId],[email],[phone],[fullName],
          [push_st],[sms_st],[email_st],
          [createId], createDt, n_id, toId, NotiId, schedule, room)
        SELECT
            a.userId,
            a.custId,
            a.email,
            a.phone,
            a.fullName,
            0,
            CASE WHEN a.phone IS NOT NULL AND dbo.fn_check_phone_vn(a.phone) = 1 THEN 0 ELSE 4 END,
            CASE WHEN a.email IS NOT NULL AND dbo.fn_check_mail(a.email) = 1  THEN 0 ELSE 4 END,
            @UserId,
            GETDATE(),
            @n_id,
            a.toId,
            n.notiId,
            CONVERT(DATETIME, @schedule, 103),
            a.room
        FROM @tbUser a
        JOIN dbo.NotifyInbox n ON n.n_id = @n_id
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.NotifySent o
            WHERE o.n_id = @n_id
              AND (
                     (a.userId IS NOT NULL AND o.userId = a.userId)
                  OR (a.custId IS NOT NULL AND o.custId = a.custId)
                  OR (a.userId IS NULL AND a.custId IS NULL AND a.phone IS NOT NULL AND o.phone = a.phone)
                  OR (a.userId IS NULL AND a.custId IS NULL AND a.phone IS NULL AND a.email IS NOT NULL AND o.email = a.email)
                  )
        );

        -- Dọn trùng phòng khi đã tồn tại từ các lần chạy trước (1 user/cust cho 1 n_id)
        ;WITH D AS
        (
            SELECT
                s.*,
                rn = ROW_NUMBER() OVER
                (
                    PARTITION BY
                        s.n_id,
                        CASE 
                            --WHEN s.userId IS NOT NULL THEN 'U:' + s.userId
                            WHEN s.custId IS NOT NULL THEN 'C:' + s.custId
                            ELSE 'P:' + ISNULL(s.phone,'') + '|E:' + ISNULL(s.email,'')
                        END
                    ORDER BY s.createDt DESC
                )
            FROM dbo.NotifySent s
            WHERE s.n_id = @n_id
        )
        DELETE FROM D WHERE rn > 1;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum INT         = ERROR_NUMBER(),
                @ErrorMsg VARCHAR(200) = 'sp_res_notify_info_set2 ' + ERROR_MESSAGE(),
                @ErrorProc VARCHAR(50) = ERROR_PROCEDURE(),
                @SessionID INT,
                @AddlInfo VARCHAR(MAX) = '@NotiId ';

        SET @valid    = 0;
        SET @messages = ERROR_MESSAGE();

        EXEC dbo.utl_Insert_ErrorLog
             @ErrorNum, @ErrorMsg, @ErrorProc,
             'NotificationApp', 'Set', @SessionID, @AddlInfo;
    END CATCH;

    SELECT @valid      AS valid,
           @messages   AS [messages],
           @actionlist AS code,
           @n_id       AS id;
END