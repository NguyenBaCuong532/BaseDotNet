-- =============================================
-- Author:      System
-- Create date: 2026-01-16
-- Description: Thông báo hóa đơn kafka - Cấu trúc mới
--              - 1 NotifyInbox (template chung)
--              - Nhiều NotifySent (nội dung đã replace + attachs riêng)
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_invoice_notify_push_kafka_v2]
    @userId NVARCHAR(50) = NULL,
    @receiveIds NVARCHAR(MAX),
    @projectcode NVARCHAR(30) = NULL,
    @tempId UNIQUEIDENTIFIER = 'E50623A1-9E5D-4858-80FB-8C5EBF83F28A'
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    DECLARE @formula NVARCHAR(MAX);

    -- Lấy tempId theo projectCode
    SELECT @tempId = tempId,
           @formula = f.formula
    FROM NotifyTemplate t
    JOIN NotifyFormula f ON t.formulaId = f.formulaId
    WHERE projectCd = @projectcode AND tempCd = 'SERVICE_FEE';

    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(100) = N'Done';
    DECLARE @n_id UNIQUEIDENTIFIER = NEWID(); -- 1 n_id cho tất cả
    DECLARE @ReceiveTable TABLE (recId BIGINT);

    -- Parse receiveIds
    INSERT INTO @ReceiveTable(recId)
    SELECT CAST(part AS BIGINT)
    FROM [dbo].[SplitString](@receiveIds, ',');

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
        AND (d.Email IS NOT NULL AND LTRIM(RTRIM(d.Email)) <> ''
             OR d.Phone IS NOT NULL AND LTRIM(RTRIM(d.Phone)) <> '')
        AND t.ReceiveId IN (SELECT recId FROM @ReceiveTable)
        AND ISNULL(t.TotalAmt, 0) <> 0;

    -- 1. Tạo NotifyInbox (1 record - template chung)
    DECLARE @actionlist NVARCHAR(150);
    DECLARE @subjectTemplate NVARCHAR(300);
    DECLARE @contentEmailTemplate NVARCHAR(MAX);
    DECLARE @contentSmsTemplate NVARCHAR(1000);
    DECLARE @contentNotifyTemplate NVARCHAR(300);
    
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
        @n_id, @tempId, @subjectTemplate, @contentNotifyTemplate, @contentEmailTemplate, @contentSmsTemplate,
        'html', GETDATE(), 1, 1, 'notify', 'system',
        @actionlist, 1, 'no-reply@sunshinemail.vn', 'S-Service', 'Sunshine',
        CASE WHEN CHARINDEX('push', @actionlist) > 0 THEN 1 ELSE 0 END,
        CASE WHEN CHARINDEX('sms', @actionlist) > 0 THEN 1 ELSE 0 END,
        CASE WHEN CHARINDEX('email', @actionlist) > 0 THEN 1 ELSE 0 END,
        GETDATE(), NULL
    );

    -- 2. Tạo NotifySent (nhiều records - nội dung cá nhân hóa)
    DECLARE @currSourceId UNIQUEIDENTIFIER;
    DECLARE @currCustId NVARCHAR(100);
    DECLARE @currUserId NVARCHAR(100);
    DECLARE @currEmail NVARCHAR(200);
    DECLARE @currPhone NVARCHAR(50);
    DECLARE @currFullName NVARCHAR(200);
    DECLARE @currRoomCode NVARCHAR(50);
    DECLARE @currSubject NVARCHAR(300) = @subjectTemplate;
    DECLARE @currContentEmail NVARCHAR(MAX) = @contentEmailTemplate;
    DECLARE @currContentSms NVARCHAR(1000) = @contentSmsTemplate;
    DECLARE @currContentNotify NVARCHAR(300) = @contentNotifyTemplate;
    DECLARE @notiId BIGINT;
    
    SELECT @notiId = notiId FROM NotifyInbox WHERE n_id = @n_id;

    DECLARE recipient_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT sourceId, custId, userId, email, phone, fullName, RoomCode
    FROM #temp_recipients;

    OPEN recipient_cursor;
    FETCH NEXT FROM recipient_cursor INTO @currSourceId, @currCustId, @currUserId, @currEmail, @currPhone, @currFullName, @currRoomCode;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Gọi SP build nội dung cá nhân hóa
        EXEC [dbo].[sp_res_build_notify_content]
            @formula = @formula,
            @sourceId = @currSourceId,
            @projectCd = @projectcode,
            @additionalData = NULL,
            @subject = @currSubject OUTPUT,
            @content_email = @currContentEmail OUTPUT,
            @content_sms = @currContentSms OUTPUT,
            @content_notify = @currContentNotify OUTPUT;

        -- Insert vào NotifySent với nội dung đã cá nhân hóa
        INSERT INTO NotifySent (
            n_id, NotiId, userId, custId, email, phone, fullName, room,
            subject, content_notify, content_email, content_sms,
            push_st, sms_st, email_st, createDt, GuidId,
            attachs  -- = entryId
        )
        VALUES (
            @n_id, @notiId, @currUserId, @currCustId, @currEmail, @currPhone, @currFullName, @currRoomCode,
            @currSubject, @currContentNotify, @currContentEmail, @currContentSms,
            CASE WHEN @currUserId IS NOT NULL AND @currUserId <> '' THEN 1 ELSE 4 END,
            CASE WHEN [dbo].fn_check_phone_vn(@currPhone) = 1 THEN 1 ELSE 4 END,
            CASE WHEN [dbo].fn_check_mail(@currEmail) = 1 THEN 1 ELSE 4 END,
            GETDATE(), NEWID(),
            @currSourceId  -- attachs = entryId
        );

        FETCH NEXT FROM recipient_cursor INTO @currSourceId, @currCustId, @currUserId, @currEmail, @currPhone, @currFullName, @currRoomCode;
    END

    CLOSE recipient_cursor;
    DEALLOCATE recipient_cursor;

    -- 3. Xử lý file đính kèm trong meta_info
    -- INSERT nếu chưa có, UPDATE nếu đã có
    MERGE INTO meta_info AS target
    USING (
        SELECT DISTINCT
            t.entryId AS sourceOid,
            t.BillUrl AS file_url
        FROM MAS_Service_ReceiveEntry t
        WHERE t.ReceiveId IN (SELECT recId FROM @ReceiveTable)
            AND t.BillUrl IS NOT NULL
    ) AS source
    ON target.sourceOid = source.sourceOid
    WHEN MATCHED THEN
        UPDATE SET file_url = source.file_url, created = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (sourceOid, file_url, created)
        VALUES (source.sourceOid, source.file_url, GETDATE());

    -- 4. Cập nhật trạng thái isPush
    UPDATE MAS_Service_ReceiveEntry
    SET isPush = 1, reminded = ISNULL(reminded, 0) + 1
    WHERE ReceiveId IN (SELECT recId FROM @ReceiveTable);

    -- Cleanup
    DROP TABLE IF EXISTS #temp_recipients;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT = ERROR_NUMBER(),
            @ErrorMsg VARCHAR(200) = 'sp_res_invoice_notify_push_kafka_v2: ' + ERROR_MESSAGE(),
            @ErrorProc VARCHAR(50) = ERROR_PROCEDURE(),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX) = '';

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receivable', 'Bill', @SessionID, @AddlInfo;
    
    SET @valid = 0;
    SET @messages = LEFT(@ErrorMsg, 100);
END CATCH;

-- Trả về kết quả
SELECT 
    @valid AS valid,
    @messages AS [messages],
    CASE WHEN @valid = 1 THEN 1 ELSE 0 END AS notiQue;

SELECT 
    @n_id AS n_id,
    @actionlist AS action;