-- =============================================
-- Author:		Namhm
-- Create date: 28/08/2025
-- Description:	thông báo cắt phí dịch vụ kafka
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_stop_push_kafka]
	@userId NVARCHAR(50) = NULL,
	@apartmentIds NVARCHAR(MAX),
	@projectcode NVARCHAR(30) = NULL
AS
BEGIN TRY

    declare @valid		bit = 1
    declare @messages	nvarchar(100) = N'Done'
    declare @inserted table (n_id uniqueidentifier)
	
    declare @ApartmentTable TABLE([id] [int] IDENTITY(1,1) NOT NULL,
                                  [apartmentId] bigint not NULL)

		Insert Into @ApartmentTable(apartmentId)
    select cast(part as bigint)
    FROM [dbo].[SplitString](@apartmentIds, ',')

    -- Tạo bảng tạm thời để lưu thông tin thông báo
    IF OBJECT_ID('tempdb..#temp_notify') IS NOT NULL
        DROP TABLE #temp_notify;

    -- Lưu thông tin thông báo vào bảng tạm
    SELECT
        t.ApartmentId AS Id,
        sourceId = t.entryId,
        [subject] = dbo.fn_get_notify_subject(
                                                n.[subject],
                                                ma.RoomCode,
                                                c.ProjectName,
                                                NULL, -- electricMonth
                                                NULL, -- serviceMonth
                                                NULL, -- remindTime
                                                CONVERT(NVARCHAR(10), ISNULL(t.ToDt, GETDATE()), 103) -- toDate
                                              ),
        content_notify = 'NULL',
        content_markdown = 'NULL',
        content_email = dbo.fn_get_notify_content(
                                                    n.content_markdown,
                                                    d.FullName,
                                                    ma.RoomCode,
                                                    c.ProjectName,
                                                    t.DebitAmt,
                                                    CAST(MONTH(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)),
                                                    CAST(MONTH(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)),
                                                    CASE WHEN MONTH(ISNULL(t.ToDt, GETDATE())) = 12 
                                                       THEN '1/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) + 1 AS NVARCHAR(5))
                                                       ELSE CAST(MONTH(ISNULL(t.ToDt, GETDATE())) + 1 AS NVARCHAR(5)) + '/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) END,
                                                    CASE WHEN MONTH(ISNULL(t.ToDt, GETDATE())) = 12 
                                                       THEN '1/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) + 1 AS NVARCHAR(5))
                                                       ELSE CAST(MONTH(ISNULL(t.ToDt, GETDATE())) + 1 AS NVARCHAR(5)) + '/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) END,
                                                    t.TotalAmt,
                                                    t.PaidAmt,
                                                    t.TotalAmt - t.PaidAmt,
                                                    t.BillViewUrl,
                                                    c.timeWorking,
                                                    c.bank_name,
                                                    c.bank_branch,
                                                    c.bank_acc_no,
                                                    c.bank_acc_name,
                                                    ISNULL(TRY_CAST(c.dayOfNotice1 AS DATE), GETDATE()),
                                                    ISNULL(TRY_CAST(c.dayOfNotice2 AS DATE), GETDATE()),
                                                    ISNULL(TRY_CAST(c.dayOfNotice3 AS DATE), GETDATE()),
                                                    ISNULL(TRY_CAST(c.dayStopService AS DATETIME), GETDATE()),
                                                    c.address,
                                                    CAST(YEAR(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5))
                                                  ),
        content_sms = [dbo].[fChuyenCoDauThanhKhongDau](N'BQLTN ' + c.ProjectName + N' Thông báo ngừng cung cấp dịch vụ điện, nước và xe căn hộ ' + ma.RoomCode + N' Ban QLTN ' 
                                                        + c.ProjectName + N' đã gửi thông báo tới quý Ông/Bà ' + d.FullName + N' - ' + ma.RoomCode + N' bằng thông báo lần 01 ngày ' 
                                                        + CONVERT(NVARCHAR(10), ISNULL(TRY_CAST(c.dayOfNotice1 AS DATE), GETDATE()), 103) + N', thông báo lần 02 ngày ' 
                                                        + CONVERT(NVARCHAR(10), ISNULL(TRY_CAST(c.dayOfNotice2 AS DATE), GETDATE()), 103) + N', thông báo lần 03 ngày ' 
                                                        + CONVERT(NVARCHAR(10), ISNULL(TRY_CAST(c.dayOfNotice3 AS DATE), GETDATE()), 103) + N' V/v đóng tiền điện, nước tháng ' 
                                                        + CAST(MONTH(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) + '/' 
                                                        + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) + N' và gửi xe tháng '
                                                        + CASE MONTH(ISNULL(t.ToDt, GETDATE()))
                                                              WHEN 12 THEN '1/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) + 1 AS NVARCHAR(5))
                                                              ELSE CAST(MONTH(ISNULL(t.ToDt, GETDATE())) + 1 AS NVARCHAR(5)) + '/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5))
                                                          END + N' nhưng đến nay, Ban QLTN vẫn chưa nhận được đủ các chi phí nêu trên từ quý Ông/Bà Trân trọng cảm ơn!'),
        bodytype = 'html',
        [notiDt] = GETDATE(),
        isPublish = 1,
        notiType = 1,
        external_param = '',
        external_event = 'notify', 
        clientId = NULL,
        source_key = 'system',
        actionlist = 'email',
        content_type = 1,
        send_by = ISNULL(c.mailSender, 'no-reply@sunshinemail.vn'),
        send_name = ISNULL(c.investorName, 'Ban QLTN ' + c.ProjectName),
        brand_name = 'Sunshine',
        external_key = '',
        external_sub = NULL,
        is_act_push = CASE WHEN CHARINDEX('push-notification', 'push-notification,email', 0) > 0 THEN 1 ELSE 0 END,
        is_act_sms = CASE WHEN CHARINDEX('sms', 'push-notification,email', 0) > 0 THEN 1 ELSE 0 END,
        is_act_email = CASE WHEN CHARINDEX('email', 'push-notification,email', 0) > 0 THEN 1 ELSE 0 END,
        n_id = NEWID(),
        ma.RoomCode,
        am.CustId,
        d.custId AS userId,
        d.email,
        d.phone,
        d.fullName
		INTO #temp_notify
		FROM
        NotifyTemplate n,
        MAS_Service_ReceiveEntry t
        JOIN MAS_Apartments ma ON t.ApartmentId = ma.ApartmentId
        JOIN MAS_Apartment_Member am ON ma.ApartmentId = am.ApartmentId AND (am.isNotification = 1)
        JOIN MAS_Customers d ON am.CustId = d.CustId
        JOIN MAS_Projects c ON ma.projectCd = c.projectCd AND c.sub_projectCd = ma.sub_projectCd
		WHERE
        am.isNotification = 1
        AND n.tempId = 'ffcf0484-7075-4ce6-b0b6-45c6356eb1c8'
        AND d.Email IS NOT NULL AND LTRIM(RTRIM(d.Email)) <> ''
        AND ma.IsReceived = 1
        AND t.isExpected = 1
        AND t.IsPayed = 0
        AND ma.ApartmentId IN (SELECT apartmentId FROM @ApartmentTable)
        AND ISNULL(t.TotalAmt, 0) <> 0
        AND MONTH(DATEADD(mm,1,t.ToDt)) = MONTH(GETDATE());
    
    -- Chèn vào NotifyInbox
    PRINT 'DEBUG: About to insert into NotifyInbox'
    INSERT INTO [dbo].NotifyInbox([subject], content_notify, content_markdown, content_email, content_sms, [bodytype], [notiDt], isPublish, notiType, external_param, external_event,
                                  clientId, source_key, sourceId, source_ref, actionlist, createDt, content_type, send_by, send_name, brand_name, external_key, external_sub,
                                  is_act_push, is_act_sms, is_act_email, attachs, n_id)
    OUTPUT inserted.n_id INTO @inserted
    SELECT
        [subject],
        content_notify,
        NULL AS content_markdown,
        content_email,
        content_sms,
        bodytype,
        notiDt,
        isPublish,
        notiType,
        external_param,
        external_event,
        clientId,
        source_key,
        sourceId,
        NULL AS source_ref,
        actionlist,
        GETDATE(),
        content_type,
        send_by,
        send_name,
        brand_name,
        external_key,
        external_sub,
        is_act_push,
        is_act_sms,
        is_act_email,
        attachs = n_id, --lưu chính thông báo lấy mới gửi tới
        n_id
    FROM #temp_notify;
    
    INSERT INTO [dbo].NotifySent(n_id, NotiId, [userId], [custId], [email], [phone], [fullName], [push_st], [sms_st], [email_st], 
                                 createDt, subject, content_notify, content_email, content_sms, GuidId, room)
    SELECT 
        n.n_id,
        n.notiId,
        t.userId,
        t.custId,
        t.email,
        t.phone,
        t.fullName,
        CASE WHEN t.userId IS NOT NULL AND t.userId <> '' THEN 1 ELSE 4 END,
        CASE WHEN [dbo].fn_check_phone_vn(t.phone) = 1 THEN 1 ELSE 4 END,
        CASE WHEN [dbo].fn_check_mail(t.email) = 1 THEN 1 ELSE 4 END,
        GETDATE(),
        n.subject,
        n.content_notify,
        n.content_email,
        n.content_sms,
        NEWID(),
        t.RoomCode
    FROM
        #temp_notify t
        JOIN NotifyInbox n ON n.n_id = t.n_id
        JOIN @inserted i ON n.n_id = i.n_id;

    UPDATE [dbo].[MAS_Service_ReceiveEntry]
    SET 
        [isPush] = 1,
        [reminded] = ISNULL([reminded], 0) + 1
    WHERE ApartmentId IN (SELECT apartmentId FROM @ApartmentTable);

GOTO FINAL;
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(max)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_service_stop_push_kafka: ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ''
    
    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Service_ReceiveEntry', 'invoice', @SessionID, @AddlInfo
END CATCH
FINAL:
    SELECT
        @valid AS valid,
        @messages AS [messages],
        CASE WHEN @valid = 1 THEN 1 ELSE 0 END AS notiQue;

    SELECT 
        i.n_id,
        action = n.actionlist
    FROM @inserted i
    JOIN NotifyInbox n ON n.n_id = i.n_id;