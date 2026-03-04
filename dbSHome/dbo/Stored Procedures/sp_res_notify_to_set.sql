CREATE   PROCEDURE [dbo].[sp_res_notify_to_set]
     @UserID NVARCHAR(450)
    ,@acceptLanguage nvarchar(100) = N'vn-Vi'
    ,@n_id UNIQUEIDENTIFIER = NULL
    ,@access_role int
    ,@to_type int = NULL
    ,@notiTos user_notify_to READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(300);

    BEGIN TRY
        SET @valid    = 1;
        SET @messages = N'Sửa thông báo thành công';

        SET @to_type = ISNULL(@to_type, 1);

        BEGIN TRAN;

        /* 1) Cập nhật header */
        UPDATE dbo.NotifyInbox
           SET access_role = @access_role,
               isPublish  = 1
         WHERE n_id = @n_id;

        /* 2) Đồng bộ NotifyTo (xoá rỗng, update, insert) */
        DELETE d
          FROM dbo.NotifyTo d
         WHERE d.sourceId = @n_id
           AND (d.to_groups IS NULL OR d.to_groups = N''
                OR EXISTS ( SELECT 1
                            FROM @notiTos x
                            WHERE x.to_level = d.to_level
                              AND (x.to_groups IS NULL OR x.to_groups = N'') ) );

        UPDATE t
           SET t.[to_level]  = a.to_level,
               t.[to_groups] = a.to_groups
          FROM dbo.NotifyTo t
          JOIN @notiTos a ON t.id = a.id
         WHERE t.sourceId = @n_id;

        INSERT INTO dbo.NotifyTo
            (sourceId, [to_level], [to_groups], createId, createDt, [to_type])
        SELECT @n_id,
               a.to_level,
               a.to_groups,
               @UserId,
               GETDATE(),
               @to_type
        FROM @notiTos a
        WHERE NOT EXISTS (SELECT 1 FROM dbo.NotifyTo o WHERE o.id = a.id)
          AND a.to_level IS NOT NULL
          AND a.to_groups IS NOT NULL AND a.to_groups <> N'';

        ;WITH UpdateData AS
        (
            SELECT id, ROW_NUMBER() OVER (ORDER BY [createDt]) AS RN
            FROM dbo.NotifyTo
            WHERE sourceId = @n_id
        )
        UPDATE t
           SET t.to_row = u.RN
          FROM dbo.NotifyTo t
          JOIN UpdateData u ON t.id = u.id
         WHERE t.sourceId = @n_id;

        /* 3) Xây danh sách người nhận – KHỬ TRÙNG THEO identity */
        DECLARE @tbUser TABLE
        (
            [userId]   NVARCHAR(100) NULL,
            [custId]   UNIQUEIDENTIFIER NULL,
            [phone]    NVARCHAR(30)  NULL,
            [email]    NVARCHAR(300) NULL,
            [fullName] NVARCHAR(300) NULL,
            toId       UNIQUEIDENTIFIER NOT NULL,
            [room]     NVARCHAR(50)  NULL
        );

        ;WITH scope_to AS
        (
            SELECT id, to_level, to_groups
            FROM dbo.NotifyTo
            WHERE sourceId = @n_id
        ),
        RawUsers AS
        (
            SELECT
                u.[userId],
                u.[custId],
                u.[phone],
                u.[email],
                u.[fullName],
                u.[room],
                st.id AS toId,
                IdentityKey =
                    CASE 
                       -- WHEN u.userId IS NOT NULL THEN 'U:' + u.userId
                        WHEN u.custId IS NOT NULL THEN 'C:' + CONVERT(NVARCHAR(100), u.custId)
                        ELSE 'P:' + ISNULL(u.phone,'') + '|E:' + ISNULL(u.email,'')
                    END
            FROM scope_to st
            CROSS APPLY dbo.fn_get_user_push(@UserId, @to_type, st.to_level, st.to_groups) u
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

        /* 4) Đồng bộ NotifySent (xoá cái không còn / thêm cái thiếu, theo identity) */

        -- Xoá các NotifySent không còn trong danh sách recipient thực tế
        DELETE s
          FROM dbo.NotifySent s
         WHERE s.n_id = @n_id
           AND NOT EXISTS
               (
                 SELECT 1
                 FROM @tbUser a
                 WHERE 
                        (a.userId IS NOT NULL AND a.userId = s.userId)
                     OR (a.custId IS NOT NULL AND a.custId = s.custId)
                     OR (a.userId IS NULL AND a.custId IS NULL AND a.phone IS NOT NULL AND a.phone = s.phone)
                     OR (a.userId IS NULL AND a.custId IS NULL AND a.phone IS NULL AND a.email IS NOT NULL AND a.email = s.email)
               );

        -- Thêm mới bản ghi cần gửi còn thiếu (không cho trùng theo identity cho cùng n_id)
        INSERT INTO dbo.NotifySent
            ([userId], custId, [email], [phone], [fullName],
             [push_st], [sms_st], [email_st],
             createId, createDt, n_id, toId, room, NotiId)
        SELECT a.userId,
               a.custId,
               a.email,
               a.phone,
               a.fullName,
               0,
               CASE WHEN a.phone IS NOT NULL AND dbo.fn_check_phone_vn(a.phone) = 1 THEN 0 ELSE 4 END,
               CASE WHEN a.email IS NOT NULL AND dbo.fn_check_mail(a.email) = 1 THEN 0 ELSE 4 END,
               @UserId,
               GETDATE(),
               @n_id,
               a.toId,
               a.room,
               n.notiId
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

        -- Dọn trùng còn sót lại trong NotifySent cho cùng n_id (giữ bản mới nhất theo createDt)
        ;WITH D AS
        (
            SELECT
                s.*,
                rn = ROW_NUMBER() OVER
                (
                    PARTITION BY s.n_id,
                        CASE 
                            --WHEN s.userId IS NOT NULL THEN 'U:' + s.userId
                            WHEN s.custId IS NOT NULL THEN 'C:' + CONVERT(NVARCHAR(100), s.custId)
                            ELSE 'P:' + ISNULL(s.phone,'') + '|E:' + ISNULL(s.email,'')
                        END
                    ORDER BY s.createDt DESC
                )
            FROM dbo.NotifySent s
            WHERE s.n_id = @n_id
        )
        DELETE FROM D WHERE rn > 1;

        /* 5) Cập nhật đếm */
        UPDATE t
           SET t.[to_count] = (SELECT COUNT(id) FROM dbo.NotifySent WHERE toId = t.id)
          FROM dbo.NotifyTo t
         WHERE t.sourceId = @n_id;

        COMMIT TRAN;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;

        DECLARE @ErrorNum INT = ERROR_NUMBER(),
                @ErrorMsg VARCHAR(200) = 'sp_notify_info_set ' + 'Line: ' + CONVERT(nvarchar(300), ERROR_LINE()) + ': ' + ERROR_MESSAGE(),
                @ErrorProc VARCHAR(50) = ERROR_PROCEDURE(),
                @SessionID INT,
                @AddlInfo  VARCHAR(MAX) = '@NotiId ';

        SET @valid    = 0;
        SET @messages = ERROR_MESSAGE();

        EXEC dbo.utl_errorlog_set
             @ErrorNum, @ErrorMsg, @ErrorProc,
             'Notification', 'Set', @SessionID, @AddlInfo;
    END CATCH;

    SELECT @valid    AS valid,
           @messages AS [messages],
           @n_Id     AS id;
END