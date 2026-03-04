Create PROCEDURE [dbo].[sp_res_notify_info_set]
    @UserID NVARCHAR(450),
    @ClientId NVARCHAR(50) = null,
    --@NotiId BIGINT = 0,
    @n_id UNIQUEIDENTIFIER = NULL,
    @actionlist NVARCHAR(200),
    @Subject NVARCHAR(100),
    @content_notify NVARCHAR(300),
    @content_sms NVARCHAR(320),
    @content_type INT,
    @content_markdown NVARCHAR(MAX),
    @content_email NVARCHAR(MAX),
    @bodytype NVARCHAR(10) = 'text',
    @IsPublish BIT,
    @external_sub NVARCHAR(100),
    @external_key NVARCHAR(50) = NULL,
    @source_ref UNIQUEIDENTIFIER = NULL,
    @source_key NVARCHAR(30),
    @external_event NVARCHAR(50) = NULL,
    @brand_name NVARCHAR(20) = NULL,
    @send_name NVARCHAR(200) = NULL,
    @notiAvatarUrl NVARCHAR(350) = NULL,
    @isHighLight BIT = 0,
    @attachs user_notify_attach READONLY
AS
BEGIN
    DECLARE @valid BIT;
    DECLARE @messages NVARCHAR(300);

    BEGIN TRY
        DECLARE @actionType INT;
        --DECLARE @inserted TABLE
        --(
        --    n_id UNIQUEIDENTIFIER
        --);
        SET @actionlist = ISNULL(@actionlist, 'push');

        SET @bodytype = ISNULL(@bodytype, 'html');

        IF NOT EXISTS
        (
            SELECT notiId
            FROM NotifyInbox
            WHERE n_id = @n_id
        )
        BEGIN
			set @n_id = newid()
            INSERT INTO NotifyInbox
            (	n_id,
                [subject],
                content_notify,
                content_markdown,
                content_email,
                content_sms,
                [bodytype],
                [notiDt],
                isPublish,
                notiType,
                external_key,
                external_sub,
                clientId,
                source_ref,
                source_key,
                actionlist,
                createId,
                content_type,
                external_event,
                brand_name,
                send_name,
                notiAvatarUrl,
                isHighLight
            )
            --OUTPUT inserted.n_id
            --INTO @inserted
            VALUES
            (@n_id,@Subject, @content_notify, @content_markdown, @content_email, @content_sms, @bodytype, GETDATE(),
             @IsPublish, 0, @external_key, @external_sub, @ClientId, @source_ref, @source_key, @actionlist, @UserID,
             @content_type, @external_event, @brand_name, @send_name, @notiAvatarUrl, @isHighLight);
            --SET @NotiId = @@IDENTITY;
            SET @valid = 1;
            SET @messages = N'Thêm mới thông báo thành công';
        END;
        ELSE
        BEGIN
            UPDATE NotifyInbox
            SET [subject] = @Subject,
                content_notify = @content_notify,
                content_markdown = @content_markdown,
                content_email = @content_email,
                content_sms = @content_sms,
                [notiDt] = GETDATE(),
                isPublish = @IsPublish,
                notiType = 0,
                external_key = @external_key,
                external_sub = @external_sub,
                bodytype = @bodytype,
                source_ref = @source_ref,
                source_key = @source_key,
                actionlist = @actionlist,
                createId = ISNULL(createId, @UserID),
                content_type = @content_type,
                external_event = @external_event,
                brand_name = @brand_name,
                send_name = @send_name,
                notiAvatarUrl = @notiAvatarUrl,
                isHighLight = @isHighLight
            WHERE n_id = @n_id;

            --INSERT INTO @inserted
            --SELECT n_id
            --FROM NotifyInbox
            --WHERE n_id = @n_id;


            SET @valid = 1;
            SET @messages = N'Sửa thông báo thành công';

        END;

        DELETE t
        FROM NotifyAttach t
        WHERE t.n_id = @n_id
              AND NOT EXISTS
        (
            SELECT 1 FROM @attachs a WHERE a.attach_url = t.attach_url
        );

        INSERT INTO [NotifyAttach]
        (
            [notiId],
            [attach_name],
            [attach_url],
            attach_type,
            [attach_sysdate],
            n_id
        )
        SELECT [notiId] = 0,
               [attach_name],
               [attach_url],
               attach_type,
               GETDATE(),
               @n_id
        FROM @attachs a
             --@inserted i
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM NotifyAttach o
            WHERE o.n_id = @n_id
                  AND o.attach_url = a.attach_url
        );

    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum INT,
                @ErrorMsg VARCHAR(200),
                @ErrorProc VARCHAR(50),
                @SessionID INT,
                @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_notify_info_set ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();

        SET @AddlInfo = '@n_id ' + CAST(@n_id AS VARCHAR);
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