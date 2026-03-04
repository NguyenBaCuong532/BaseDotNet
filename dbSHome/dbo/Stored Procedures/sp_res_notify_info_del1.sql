

CREATE PROCEDURE [dbo].[sp_res_notify_info_del1]
    @userId NVARCHAR(450),
    @n_id	uniqueidentifier
AS
BEGIN
    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(300) = N'Xóa thông báo thành công';
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM NotifyInbox WHERE n_id = @n_id)
			BEGIN
				SET @valid = 0;
				SET @messages = N'Không tìm thấy thông báo!';
			END;
        ELSE IF EXISTS
        (SELECT 1 FROM NotifyInbox WHERE n_id = @n_id AND isPublish = 1
        )
			BEGIN
				SET @valid = 0;
				SET @messages = N'Thông báo đang được công bố không được xóa!';
			END;
        ELSE
        BEGIN

			DELETE m FROM meta_info m
			join NotifyInbox n on m.sourceOid = n.attachs
            WHERE n.n_id = @n_id;

            DELETE FROM NotifyComment
            WHERE n_id = @n_id;

            DELETE FROM NotifySent
            WHERE n_id = @n_id;

			DELETE FROM NotifyTo
            WHERE sourceId = @n_id;

            DELETE FROM NotifyInbox
            WHERE n_id = @n_id;
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum INT,
                @ErrorMsg VARCHAR(200),
                @ErrorProc VARCHAR(50),
                @SessionID INT,
                @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_notify_info_del' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();

        SET @AddlInfo = '';

        EXEC utl_Insert_ErrorLog @ErrorNum,
                                 @ErrorMsg,
                                 @ErrorProc,
                                 'NotificationApp',
                                 'DEL',
                                 @SessionID,
                                 @AddlInfo;
    END CATCH;

    SELECT @valid AS valid,
           @messages AS [messages];

END;