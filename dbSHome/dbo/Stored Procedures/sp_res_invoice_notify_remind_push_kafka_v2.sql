CREATE PROCEDURE [dbo].[sp_res_invoice_notify_remind_push_kafka_v2]
    @userId NVARCHAR(50) = NULL,
    @receiveIds NVARCHAR(MAX),
    @projectcode NVARCHAR(30) = NULL,
    @tempId UNIQUEIDENTIFIER = '204FA5B3-A336-465E-B98D-AA159A3DBD80'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @formula NVARCHAR(MAX);

    -- Lấy tempId + formula
    SELECT 
        @tempId = t.tempId,
        @formula = f.formula
    FROM NotifyTemplate t
    JOIN NotifyFormula f ON t.formulaId = f.formulaId
    WHERE t.projectCd = @projectcode
      AND t.tempCd = 'DEBT_REMINDER';

    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(100) = N'Done';
    DECLARE @n_id UNIQUEIDENTIFIER = NEWID();

    DECLARE @ReceiveTable TABLE (recId BIGINT);

    -- Parse receiveIds
    INSERT INTO @ReceiveTable(recId)
    SELECT CAST(part AS BIGINT)
    FROM dbo.SplitString(@receiveIds, ',');

    IF NOT EXISTS (SELECT 1 FROM @ReceiveTable)
    BEGIN
        SET @valid = 0;
        SET @messages = N'No valid ReceiveIds found';
        GOTO FINAL;
    END

    -- Lấy danh sách người nhận
    SELECT DISTINCT
        t.entryId AS sourceId,
        ma.RoomCode,
        am.memberUserId AS userId,
        d.custId,
        d.email,
        d.phone,
        d.fullName
    INTO #temp_recipients
    FROM MAS_Service_ReceiveEntry t
    JOIN MAS_Apartments ma ON t.ApartmentId = ma.ApartmentId
    JOIN MAS_Apartment_Member am ON ma.ApartmentId = am.ApartmentId AND am.isNotification = 1
    JOIN MAS_Customers d ON am.CustId = d.CustId
    WHERE am.isNotification = 1
      AND (
            (d.Email IS NOT NULL AND LTRIM(RTRIM(d.Email)) <> '')
         OR (d.Phone IS NOT NULL AND LTRIM(RTRIM(d.Phone)) <> '')
      )
      AND t.ReceiveId IN (SELECT recId FROM @ReceiveTable)
      AND ISNULL(t.TotalAmt, 0) <> 0;

    /* =========================
       1. NotifyInbox (1 record)
       ========================= */
    DECLARE 
        @actionlist NVARCHAR(150),
        @subjectTemplate NVARCHAR(300),
        @contentEmailTemplate NVARCHAR(MAX),
        @contentSmsTemplate NVARCHAR(1000),
        @contentNotifyTemplate NVARCHAR(300);

    SELECT
        @actionlist = actionlist,
        @subjectTemplate = [subject],
        @contentEmailTemplate = content_markdown,
        @contentSmsTemplate = content_sms,
        @contentNotifyTemplate = content_notify
    FROM NotifyTemplate
    WHERE tempId = @tempId;

    INSERT INTO NotifyInbox (
        n_id, tempId, [subject], content_notify, content_email, content_sms,
        bodytype, notiDt, isPublish, notiType, external_event, source_key,
        actionlist, content_type, send_by, send_name, brand_name,
        is_act_push, is_act_sms, is_act_email, createDt, sourceId
    )
    VALUES (
        @n_id, @tempId, @subjectTemplate, @contentNotifyTemplate,
        @contentEmailTemplate, @contentSmsTemplate,
        'html', GETDATE(), 1, 1, 'notify', 'system',
        @actionlist, 1, 'no-reply@sunshinemail.vn', 'S-Service', 'Sunshine',
        CASE WHEN CHARINDEX('push', @actionlist) > 0 THEN 1 ELSE 0 END,
        CASE WHEN CHARINDEX('sms', @actionlist) > 0 THEN 1 ELSE 0 END,
        CASE WHEN CHARINDEX('email', @actionlist) > 0 THEN 1 ELSE 0 END,
        GETDATE(), NULL
    );

    DECLARE @notiId BIGINT;
    SELECT @notiId = notiId FROM NotifyInbox WHERE n_id = @n_id;

    /* =========================
       2. NotifySent (N records)
       ========================= */
    DECLARE 
        @currSourceId UNIQUEIDENTIFIER,
        @currCustId NVARCHAR(100),
        @currUserId NVARCHAR(50),
        @currEmail NVARCHAR(200),
        @currPhone NVARCHAR(50),
        @currFullName NVARCHAR(200),
        @currRoomCode NVARCHAR(50),
        @currSubject NVARCHAR(300),
        @currContentEmail NVARCHAR(MAX),
        @currContentSms NVARCHAR(1000),
        @currContentNotify NVARCHAR(300);

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT sourceId, custId, userId, email, phone, fullName, RoomCode
    FROM #temp_recipients;

    OPEN cur;
    FETCH NEXT FROM cur INTO
        @currSourceId, @currCustId, @currUserId,
        @currEmail, @currPhone, @currFullName, @currRoomCode;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @currSubject = @subjectTemplate;
        SET @currContentEmail = @contentEmailTemplate;
        SET @currContentSms = @contentSmsTemplate;
        SET @currContentNotify = @contentNotifyTemplate;

        EXEC dbo.sp_res_build_notify_content
            @formula = @formula,
            @sourceId = @currSourceId,
            @projectCd = @projectcode,
            @additionalData = NULL,
            @subject = @currSubject OUTPUT,
            @content_email = @currContentEmail OUTPUT,
            @content_sms = @currContentSms OUTPUT,
            @content_notify = @currContentNotify OUTPUT;

        INSERT INTO NotifySent (
            n_id, NotiId, userId, custId, email, phone, fullName, room,
            subject, content_notify, content_email, content_sms,
            push_st, sms_st, email_st, createDt, GuidId, attachs
        )
        VALUES (
            @n_id, @notiId, @currUserId, @currCustId,
            @currEmail, @currPhone, @currFullName, @currRoomCode,
            @currSubject, @currContentNotify,
            @currContentEmail, @currContentSms,
            CASE WHEN @currUserId IS NOT NULL AND @currUserId <> '' THEN 1 ELSE 4 END,
            CASE WHEN dbo.fn_check_phone_vn(@currPhone) = 1 THEN 1 ELSE 4 END,
            CASE WHEN dbo.fn_check_mail(@currEmail) = 1 THEN 1 ELSE 4 END,
            GETDATE(), NEWID(), @currSourceId
        );

        FETCH NEXT FROM cur INTO
            @currSourceId, @currCustId, @currUserId,
            @currEmail, @currPhone, @currFullName, @currRoomCode;
    END

    CLOSE cur;
    DEALLOCATE cur;

    /* =========================
       3. Attach file (meta_info)
       ========================= */
    MERGE meta_info AS t
    USING (
        SELECT entryId, BillUrl
        FROM MAS_Service_ReceiveEntry
        WHERE ReceiveId IN (SELECT recId FROM @ReceiveTable)
          AND BillUrl IS NOT NULL
    ) s
    ON t.sourceOid = s.entryId
    WHEN MATCHED THEN
        UPDATE SET file_url = s.BillUrl, created = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (sourceOid, file_url, created)
        VALUES (s.entryId, s.BillUrl, GETDATE());

    /* =========================
       4. Update nghiệp vụ
       ========================= */
    UPDATE MAS_Service_ReceiveEntry
    SET isPush = 1,
        reminded = ISNULL(reminded, 0) + 1
    WHERE ReceiveId IN (SELECT recId FROM @ReceiveTable);

    DROP TABLE IF EXISTS #temp_recipients;

END TRY
BEGIN CATCH
    DECLARE 
        @ErrorNum INT = ERROR_NUMBER(),
        @ErrorMsg VARCHAR(200) = 'sp_res_invoice_notify_remind_push_kafka_v2: ' + ERROR_MESSAGE(),
        @ErrorProc VARCHAR(50) = ERROR_PROCEDURE(),
        @SessionID INT,
        @AddlInfo VARCHAR(MAX) = '';

    EXEC utl_Insert_ErrorLog 
        @ErrorNum, @ErrorMsg, @ErrorProc,
        'Receivable', 'DebtReminder', @SessionID, @AddlInfo;

    SET @valid = 0;
    SET @messages = LEFT(@ErrorMsg, 100);
END CATCH;

FINAL:
SELECT 
    @valid AS valid,
    @messages AS [messages],
    CASE WHEN @valid = 1 THEN 1 ELSE 0 END AS notiQue;

SELECT 
    @n_id AS n_id,
    @actionlist AS action;