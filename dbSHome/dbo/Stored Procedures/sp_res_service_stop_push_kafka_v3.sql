CREATE PROCEDURE [dbo].[sp_res_service_stop_push_kafka_v3]
(
    @userId NVARCHAR(50) = NULL,
    @apartmentIds NVARCHAR(MAX),
    @projectcode NVARCHAR(30) = NULL,
    @tempId UNIQUEIDENTIFIER = NULL
)
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE 
        @valid BIT = 1,
        @messages NVARCHAR(100) = N'Done',
        @n_id UNIQUEIDENTIFIER = NEWID(),
        @formula NVARCHAR(MAX),
        @actionlist NVARCHAR(150);

    /* =========================
       0. Parse apartmentIds
       ========================= */
    DECLARE @ApartmentTable TABLE (apartmentId BIGINT);
    INSERT INTO @ApartmentTable(apartmentId)
    SELECT TRY_CAST(value AS BIGINT)
    FROM STRING_SPLIT(ISNULL(@apartmentIds,''), ',')
    WHERE TRY_CAST(value AS BIGINT) IS NOT NULL;

    IF NOT EXISTS (SELECT 1 FROM @ApartmentTable)
    BEGIN
        SET @valid = 0;
        SET @messages = N'No valid ApartmentIds found';
        GOTO FINAL;
    END

    /* =========================
       1. Load template & formula
       ========================= */
    SELECT 
        @tempId = t.tempId,
        @formula = f.formula,
        @actionlist = t.actionlist
    FROM NotifyTemplate t
    JOIN NotifyFormula f ON t.formulaId = f.formulaId
    WHERE t.projectCd = @projectcode
      AND t.tempCd = 'SERVICE_STOP';

    IF @formula IS NULL OR @tempId IS NULL
    BEGIN
        SET @valid = 0;
        SET @messages = N'Notify template or formula not found';
        GOTO FINAL;
    END

    /* =========================
       2. RECIPIENTS
       ========================= */
    SELECT DISTINCT
        t.entryId AS sourceId,
        ma.RoomCode,
        am.memberUserId AS userId,
        CAST(d.CustId AS NVARCHAR(50)) AS custId,
        d.email,
        d.phone,
        d.fullName
    INTO #Recipients
    FROM MAS_Service_ReceiveEntry t
    JOIN MAS_Apartments ma 
        ON t.ApartmentId = ma.ApartmentId
    JOIN MAS_Apartment_Member am 
        ON ma.ApartmentId = am.ApartmentId 
       AND am.isNotification = 1
    JOIN MAS_Customers d 
        ON am.CustId = d.CustId
    WHERE ma.IsReceived = 1
      AND t.isExpected = 1
      AND t.IsPayed = 0
      AND ma.ApartmentId IN (SELECT apartmentId FROM @ApartmentTable)
      AND ISNULL(t.TotalAmt, 0) <> 0
      AND MONTH(DATEADD(MONTH, 1, t.ToDt)) = MONTH(GETDATE())
      AND (
            (d.Email IS NOT NULL AND LTRIM(RTRIM(d.Email)) <> '')
         OR (d.Phone IS NOT NULL AND LTRIM(RTRIM(d.Phone)) <> '')
      );

    IF NOT EXISTS (SELECT 1 FROM #Recipients)
    BEGIN
        SET @valid = 0;
        SET @messages = N'No recipients found';
        DROP TABLE IF EXISTS #Recipients;
        GOTO FINAL;
    END

    /* =========================
       3. BUILD DATA JSON (BY FORMULA)
       ========================= */
    CREATE TABLE #NotifyData
    (
        sourceId UNIQUEIDENTIFIER NOT NULL,
        custId   NVARCHAR(50)     NOT NULL,
        dataJson NVARCHAR(MAX)    NULL
    );

    DECLARE @SourceIds dbo.GuidList;
    INSERT INTO @SourceIds
    SELECT DISTINCT sourceId FROM #Recipients;

    EXEC dbo.sp_res_notify_build_data_by_formula
        @formula     = @formula,
        @projectCd   = @projectcode,
        @SourceTable = @SourceIds;

    IF NOT EXISTS (SELECT 1 FROM #NotifyData)
    BEGIN
        SET @valid = 0;
        SET @messages = N'No notify data built';
        DROP TABLE IF EXISTS #Recipients;
        DROP TABLE IF EXISTS #NotifyData;
        GOTO FINAL;
    END

    /* =========================
       4. NotifyInbox
       ========================= */
    DECLARE 
        @subjectTemplate NVARCHAR(300),
        @contentEmailTemplate NVARCHAR(MAX),
        @contentSmsTemplate NVARCHAR(1000),
        @contentNotifyTemplate NVARCHAR(300),
        @send_by NVARCHAR(200),
        @send_name NVARCHAR(200);

    SELECT
        @actionlist = actionlist,
        @subjectTemplate = [subject],
        @contentEmailTemplate = content_markdown,
        @contentSmsTemplate = content_sms,
        @contentNotifyTemplate = content_notify
    FROM NotifyTemplate
    WHERE tempId = @tempId;

    /* Sender theo dự án */
    SELECT TOP 1
        @send_by = ISNULL(p.mailSender, 'no-reply@sunshinemail.vn'),
        @send_name = ISNULL(p.investorName, 'Ban QLTN ' + p.ProjectName)
    FROM MAS_Apartments a
    JOIN MAS_Projects p 
        ON a.projectCd = p.projectCd AND a.sub_projectCd = p.sub_projectCd
    WHERE a.ApartmentId IN (SELECT apartmentId FROM @ApartmentTable);

    INSERT INTO NotifyInbox
    (
        n_id, tempId, [subject], content_notify, content_email, content_sms,
        bodytype, notiDt, isPublish, notiType, external_event, source_key,
        actionlist, content_type, send_by, send_name, brand_name,
        is_act_push, is_act_sms, is_act_email, createDt, sourceId
    )
    VALUES
    (
        @n_id, @tempId, @subjectTemplate, @contentNotifyTemplate,
        @contentEmailTemplate, @contentSmsTemplate,
        'html', GETDATE(), 1, 1, 'notify', 'system',
        @actionlist, 1, @send_by, @send_name, 'Sunshine',
        CASE WHEN CHARINDEX('push', ISNULL(@actionlist,'')) > 0 THEN 1 ELSE 0 END,
        CASE WHEN CHARINDEX('sms', ISNULL(@actionlist,'')) > 0 THEN 1 ELSE 0 END,
        CASE WHEN CHARINDEX('email', ISNULL(@actionlist,'')) > 0 THEN 1 ELSE 0 END,
        GETDATE(), NULL
    );

    DECLARE @notiId BIGINT;
    SELECT @notiId = notiId FROM NotifyInbox WHERE n_id = @n_id;

    /* =========================
       5. NotifySent (JOIN by sourceId + custId)
       ========================= */
    INSERT INTO NotifySent
    (
        n_id, notiId, userId, custId, email, phone, fullName, room,
        subject, content_email, content_sms, content_notify,
        push_st, sms_st, email_st, createDt, GuidId, attachs
    )
    SELECT
        @n_id,
        @notiId,
        r.userId,
        r.custId,
        r.email,
        r.phone,
        r.fullName,
        r.RoomCode,

        c.subject,
        c.content_email,
        c.content_sms,
        c.content_notify,

        CASE 
            WHEN CHARINDEX('push', ISNULL(@actionlist,'')) > 0 
                 AND r.userId IS NOT NULL AND r.userId <> '' THEN 1 
            ELSE 4 
        END,

        CASE 
            WHEN CHARINDEX('sms', ISNULL(@actionlist,'')) > 0 
                 AND dbo.fn_check_phone_vn(r.phone) = 1 THEN 1 
            ELSE 4 
        END,

        CASE 
            WHEN CHARINDEX('email', ISNULL(@actionlist,'')) > 0 
                 AND dbo.fn_check_mail(r.email) = 1 THEN 1 
            ELSE 4 
        END,

        GETDATE(),
        NEWID(),
        r.sourceId
    FROM #Recipients r
    JOIN #NotifyData d
      ON r.sourceId = d.sourceId
     AND r.custId   = d.custId
    JOIN NotifyTemplate t ON t.tempId = @tempId
    CROSS APPLY dbo.fn_res_notify_build_content
    (
        t.[subject],
        t.content_markdown,
        t.content_sms,
        t.content_notify,
        d.dataJson
    ) c;

    /* =========================
       6. Update nghiệp vụ
       ========================= */
    UPDATE MAS_Service_ReceiveEntry
    SET isPush = 1,
        reminded = ISNULL(reminded, 0) + 1
    WHERE ApartmentId IN (SELECT apartmentId FROM @ApartmentTable);

    DROP TABLE IF EXISTS #Recipients;
    DROP TABLE IF EXISTS #NotifyData;

FINAL:
    SELECT 
        @valid AS valid,
        @messages AS [messages],
        CASE WHEN @valid = 1 THEN 1 ELSE 0 END AS notiQue;

    SELECT 
        @n_id AS n_id,
        @actionlist AS action;

END TRY
BEGIN CATCH
    DECLARE 
        @ErrorNum INT = ERROR_NUMBER(),
        @ErrorMsg NVARCHAR(4000) = 'sp_res_service_stop_push_kafka_v3: ' + ERROR_MESSAGE(),
        @ErrorProc NVARCHAR(200) = ERROR_PROCEDURE(),
        @SessionID INT = NULL,
        @AddlInfo NVARCHAR(MAX) = N'';

    EXEC utl_Insert_ErrorLog 
        @ErrorNum, @ErrorMsg, @ErrorProc,
        'Receivable', 'ServiceStop', @SessionID, @AddlInfo;

    IF OBJECT_ID('tempdb..#Recipients') IS NOT NULL DROP TABLE #Recipients;
    IF OBJECT_ID('tempdb..#NotifyData') IS NOT NULL DROP TABLE #NotifyData;

    SELECT 
        0 AS valid,
        LEFT(@ErrorMsg, 100) AS [messages],
        0 AS notiQue;

    SELECT 
        @n_id AS n_id,
        @actionlist AS action;
END CATCH;