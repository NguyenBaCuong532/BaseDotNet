CREATE PROCEDURE [dbo].[sp_resident_message_set]
    @userId NVARCHAR(255) = NULL,
    @messageId uniqueidentifier = NULL,
    @clientId NVARCHAR(50) = NULL,
    @clientIp NVARCHAR(100) = NULL,
    @phone NVARCHAR(20) = NULL,
    @custName NVARCHAR(150) = NULL,
    @custId NVARCHAR(100) = NULL,
    @message NVARCHAR(400) = NULL,
    @scheduleAt BIGINT = NULL,
    @brandName NVARCHAR(20) = NULL,
    @isSent BIT = 0,
    @sourceId NVARCHAR(450) = NULL,
    @partner NVARCHAR(10) = NULL,
    @remart NVARCHAR(25) = NULL,
	@AcceptLanguage nvarchar(50) = null
AS
BEGIN TRY
    IF @scheduleAt = 0
        SET @scheduleAt = NULL;

    IF @phone IS NOT NULL
       AND @message IS NOT NULL
       AND @phone <> '0983256416'
    BEGIN
        IF (
               @isSent = 0
               OR @isSent IS NULL
           )
           AND [dbo].funcSDT(@phone) = 1
            INSERT INTO [dbo].[MessageJobs]
            (
                [phone],
                [contents],
                [scheduleAt],
                [brandName],
                [createId],
                [createdDt],
                custName,
                custId,
                clientId,
                clientIp,
                sourceId,
                [partner],
                remart
            )
            VALUES
            (@phone, @message, @scheduleAt, @brandName, @userId, GETDATE(), @custName, @custId, @clientId, @clientIp,
             @sourceId, @partner, @remart);
        ELSE IF @isSent = 1
            INSERT INTO [dbo].[MessageSents]
            (
                [phone],
                [contents],
                [scheduleAt],
                [brandName],
                [isSent],
                [sendDt],
                [sendNum],
                [status],
                [sendFailed],
                [createId],
                [createdDt],
                custName,
                custId,
                clientId,
                clientIp,
                sourceId,
                [partner],
                remart
            )
            VALUES
            (@phone, @message, @scheduleAt, @brandName, @isSent, GETDATE(), 1, 1, 1, @userId, GETDATE(), @custName,
             @custId, @clientId, @clientIp, @sourceId, @partner, @remart);

        UPDATE t2
        SET [sms_st] = 2 -- update trạng thái pass = 2
        --,[sendDt] = getdate()
        FROM [dbo].NotifySent t2
            JOIN [MessageJobs] a ON t2.n_id = a.sourceId AND t2.custId = a.custId
        WHERE a.messageId = @messageId;

        UPDATE t
        SET sms_count = ISNULL(sms_count, 0) + 1
        FROM [dbo].NotifyInbox t
            JOIN [dbo].NotifySent t2
                ON t2.n_id = t.n_id
            JOIN [MessageJobs] a ON t2.n_id = a.sourceId AND t2.custId = a.custId
        WHERE a.messageId = @messageId;

        DELETE FROM [MessageJobs]
        WHERE messageId = @messageId;
    END;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_resident_message_set ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '@User ' + ISNULL(@userId, '') + ' Phone:' + ISNULL(@phone, '');

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'Message',
                          'Set',
                          @SessionID,
                          @AddlInfo;
END CATCH;