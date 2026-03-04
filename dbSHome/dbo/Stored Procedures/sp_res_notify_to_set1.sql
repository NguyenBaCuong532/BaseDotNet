CREATE PROCEDURE [dbo].[sp_res_notify_to_set1]
     @userId      NVARCHAR(450)
    ,@sourceId    UNIQUEIDENTIFIER
    ,@Id          UNIQUEIDENTIFIER
    ,@to_row      INT
    ,@to_groups   NVARCHAR(MAX)
    ,@to_level    INT
    ,@to_type     INT = 0
AS
BEGIN
    DECLARE @valid    BIT           = 1;
    DECLARE @messages NVARCHAR(300) = N'Thành công';

    BEGIN TRY
        DECLARE @tbUser TABLE
        (
            [userId]   NVARCHAR(100) NULL,
            [custId]   NVARCHAR(100) NULL,
            [phone]    NVARCHAR(30)  NULL,
            [email]    NVARCHAR(300) NULL,
            [fullName] NVARCHAR(300) NULL,
            [room]     NVARCHAR(50)  NULL,
            IdentityKey NVARCHAR(500) NULL
        );

        ------------------------------------------------
        -- 1. Upsert NotifyTo
        ------------------------------------------------
        IF EXISTS (SELECT 1 FROM NotifyTo WHERE id = @Id)
        BEGIN
            UPDATE t
               SET [to_level]  = @to_level,
                   [to_groups] = @to_groups
            FROM [dbo].[NotifyTo] t 
            WHERE t.id = @Id;
        END
        ELSE
        BEGIN
            SET @Id = NEWID();

            INSERT INTO [dbo].[NotifyTo]
                   ([sourceId]
                   ,[to_level]
                   ,[to_groups]
                   ,[createId]
                   ,[createDt]
                   ,[to_type]
                   ,id)
            SELECT @sourceId,
                   @to_level,
                   @to_groups,
                   @userId,
                   GETDATE(),
                   @to_type,
                   @Id;

            ;WITH UpdateData AS
            (
                SELECT id,
                       ROW_NUMBER() OVER (ORDER BY [createDt]) AS RN
                FROM [NotifyTo] o
                WHERE sourceId = @sourceId
            )
            UPDATE t 
               SET to_row = RN
            FROM [NotifyTo] t
            INNER JOIN UpdateData ON t.id = UpdateData.id
            WHERE t.sourceId = @sourceId;
        END

        ------------------------------------------------
        -- 2. Lấy danh sách user từ fn_get_user_push và KHỬ TRÙNG
        ------------------------------------------------
        ;WITH RawUsers AS
        (
            SELECT
                u.[userId],
                u.[custId],
                u.[phone],
                u.[email],
                u.[fullName],
                u.[room],
                IdentityKey =
                    CASE 
                        --WHEN u.userId IS NOT NULL THEN 'U:' + u.userId
                        WHEN u.custId IS NOT NULL THEN 'C:' + u.custId
                        ELSE 'P:' + ISNULL(u.phone,'') + '|E:' + ISNULL(u.email,'')
                    END
            FROM dbo.[fn_get_user_push](@userId, @to_type, @to_level, @to_groups) u
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
                IdentityKey
            FROM RawUsers
            GROUP BY IdentityKey
        )
        INSERT INTO @tbUser ([userId],[custId],[phone],[email],[fullName],[room],IdentityKey)
        SELECT userId, custId, phone, email, fullName, room, IdentityKey
        FROM Dedup;

        ------------------------------------------------
        -- 3. Đồng bộ NotifySent cho sourceId/id hiện tại
        --    (không trùng userId/custId/phone/email cho cùng n_id)
        ------------------------------------------------
        -- Xoá những bản ghi NotifySent của @sourceId/@Id mà không còn trong @tbUser (theo identity)
        DELETE t
        FROM NotifySent t
        WHERE t.n_id = @sourceId 
          AND t.toId = @Id
          AND NOT EXISTS
              (
                SELECT 1
                FROM @tbUser a
                WHERE
                       (a.userId IS NOT NULL AND a.userId = t.userId)
                    OR (a.custId IS NOT NULL AND a.custId = t.custId)
                    OR (a.userId IS NULL AND a.custId IS NULL AND a.phone IS NOT NULL AND a.phone = t.phone)
                    OR (a.userId IS NULL AND a.custId IS NULL AND a.phone IS NULL AND a.email IS NOT NULL AND a.email = t.email)
              );

        -- Thêm mới những người nhận còn thiếu (check trùng theo identity cho cùng n_id)
        INSERT INTO [dbo].NotifySent
            ([userId]
            ,[custId]
            ,[email]
            ,[phone]
            ,[fullName]
            ,[push_st]
            ,[sms_st]
            ,[email_st]
            ,[createId]
            ,createDt
            ,n_id
            ,toId
            ,NotiId
            ,GuidId
            ,room)
        SELECT a.userId,
               a.custId,
               a.email,
               a.phone,
               a.fullName,
               0,
               CASE WHEN a.phone IS NOT NULL AND [dbo].fn_check_phone_vn(a.phone) = 1 THEN 0 ELSE 4 END,
               CASE WHEN a.email IS NOT NULL AND dbo.fn_check_mail(a.email) = 1  THEN 0 ELSE 4 END,
               @UserId,
               GETDATE(),
               @sourceId,
               @Id,
               n.notiId,
               NEWID(),
               a.room
        FROM @tbUser a
        JOIN NotifyInbox n ON n.n_id = @sourceId
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM NotifySent o 
            WHERE o.n_id = @sourceId 
              AND (
                     (a.userId IS NOT NULL AND o.userId = a.userId)
                  OR (a.custId IS NOT NULL AND o.custId = a.custId)
                  OR (a.userId IS NULL AND a.custId IS NULL AND a.phone IS NOT NULL AND o.phone = a.phone)
                  OR (a.userId IS NULL AND a.custId IS NULL AND a.phone IS NULL AND a.email IS NOT NULL AND o.email = a.email)
                  )
        );

        ------------------------------------------------
        -- 4. Dọn trùng toàn bộ NotifySent cho n_id hiện tại (giữ bản mới nhất theo createDt)
        ------------------------------------------------
        ;WITH D AS
        (
            SELECT
                s.*,
                rn = ROW_NUMBER() OVER
                (
                    PARTITION BY s.n_id,
                        CASE 
                            --WHEN s.userId IS NOT NULL THEN 'U:' + s.userId
                            WHEN s.custId IS NOT NULL THEN 'C:' + s.custId
                            ELSE 'P:' + ISNULL(s.phone,'') + '|E:' + ISNULL(s.email,'')
                        END
                    ORDER BY s.createDt DESC
                )
            FROM dbo.NotifySent s
            WHERE s.n_id = @sourceId
        )
        DELETE FROM D WHERE rn > 1;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum  INT,
                @ErrorMsg  VARCHAR(200),
                @ErrorProc VARCHAR(50),
                @SessionID INT,
                @AddlInfo  VARCHAR(MAX);

        SET @ErrorNum  = ERROR_NUMBER();
        SET @ErrorMsg  = 'sp_res_notify_to_set1 ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo  = '@tempId ';

        SET @valid    = 0;
        SET @messages = ERROR_MESSAGE();

        EXEC utl_errorLog_set 
             @ErrorNum, @ErrorMsg, @ErrorProc, 'to_set', 'Set', @SessionID, @AddlInfo;
    END CATCH;

    SELECT @valid    AS valid,
           @messages AS [messages];
END