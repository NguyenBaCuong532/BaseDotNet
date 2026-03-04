


CREATE PROCEDURE [dbo].[sp_res_invoice_notify_push_kafka]
    @userId NVARCHAR(50) = NULL,
    @receiveIds NVARCHAR(MAX),
    @projectcode NVARCHAR(30) = NULL
AS
BEGIN TRY
    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(100) = N'Done';
    DECLARE @inserted TABLE (n_id UNIQUEIDENTIFIER);
	declare @ReceiveTable TABLE 
			(
				[id] [int] IDENTITY(1,1) NOT NULL,
				[recId] bigint not NULL
			)

		Insert Into @ReceiveTable(recId)
        select cast(part as bigint)
        FROM [dbo].[SplitString](@receiveIds, ',')

    -- Tạo bảng tạm để lưu thông tin thông báo
    IF OBJECT_ID('tempdb..#temp_notify') IS NOT NULL
        DROP TABLE #temp_notify;

    -- Lưu thông tin thông báo vào bảng tạm
    SELECT DISTINCT
        t.ReceiveId AS Id,
        sourceId = t.entryId,
		--N'BQLTN ' + c.ProjectName + N' thông báo phí điện, nước tháng ' + CAST(MONTH(t.ToDt) AS NVARCHAR(5)) + N' và phí dịch vụ, phí gửi xe tháng ' + CASE MONTH(t.ToDt) WHEN 12 THEN '1' ELSE CAST(MONTH(t.ToDt) + 1 AS NVARCHAR(5)) END + N' căn hộ ' + ma.RoomCode
        [subject] = dbo.fn_get_notify_subject(
            n.[subject],
            ma.RoomCode,
            c.ProjectName,
            CAST(MONTH(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)),
            CASE MONTH(ISNULL(t.ToDt, GETDATE())) WHEN 12 
				THEN '1' 
			ELSE CAST(MONTH(ISNULL(t.ToDt, GETDATE())) + 1 AS NVARCHAR(5)) END,
            CAST(
                CASE 
                    WHEN ISNULL(t.reminded, 0) + 1 > 3 THEN 3 
                    ELSE ISNULL(t.reminded, 0) + 1 
                END AS NVARCHAR(5)
            ),
			NULL
        ),
        content_notify = N'BQLTN ' + c.ProjectName + N' thông báo phí sử dụng căn hộ ' + ma.RoomCode + N'' + N' tính đến ' + CONVERT(NVARCHAR(10), ISNULL(t.ToDt, GETDATE()), 103) + '. ' + N'Qúy Khách căn ' + ma.RoomCode + N' có hóa đơn: ' + FORMAT(t.TotalAmt, '###,###,###') + N'đ. ' + CASE 
            WHEN t.DebitAmt > 0 THEN N'Trong đó số nợ kỳ trước ' + FORMAT(t.DebitAmt, '###,###,###') + N'đ. ' ELSE '' END + N'Quý Khách vui lòng thanh toán trước ngày ' + CONVERT(NVARCHAR(10), ISNULL(t.ExpireDate, GETDATE()), 103) + N'LH 02473037888. ' + CHAR(13) + N'. Trân trọng cảm ơn!',
        content_sms = dbo.fn_get_notify_sms(
                  n.content_sms,
                  ma.RoomCode,
                  c.ProjectName,
                  NULL, -- @remindTime không dùng trong mẫu này
                  CAST(MONTH(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) + '/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)), -- @electricMonth
                  CASE WHEN MONTH(ISNULL(t.ToDt, GETDATE())) = 12 
                           THEN '1/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE()))+1 AS NVARCHAR(5)) 
                       ELSE CAST(MONTH(ISNULL(t.ToDt, GETDATE()))+1 AS NVARCHAR(5)) + '/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) 
                  END, -- @serviceMonth
                  FORMAT(t.TotalAmt, '###,###,###'), -- @totalAmt
                  NULL, -- @paidAmt không dùng trong mẫu này
                  NULL  -- @remainAmt không dùng trong mẫu này
              ),
            content_email = dbo.fn_get_notify_content(
            n.content_markdown,
            d.FullName,
            ma.RoomCode,
            c.projectName,
            t.DebitAmt,
            CAST(MONTH(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) + '/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)),
            CAST(MONTH(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) + '/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)),
            CASE WHEN MONTH(ISNULL(t.ToDt, GETDATE())) = 12 
                THEN '1/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE()))+1 AS NVARCHAR(5)) 
                ELSE CAST(MONTH(ISNULL(t.ToDt, GETDATE()))+1 AS NVARCHAR(5)) + '/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) END,
            CASE WHEN MONTH(ISNULL(t.ToDt, GETDATE())) = 12 
                THEN '1/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE()))+1 AS NVARCHAR(5)) 
                ELSE CAST(MONTH(ISNULL(t.ToDt, GETDATE()))+1 AS NVARCHAR(5)) + '/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) END,
            t.TotalAmt,
            t.PaidAmt,
            t.TotalAmt - t.PaidAmt,
            t.BillViewUrl,
            c.timeWorking,
            c.bank_name,
            c.bank_branch,
            c.bank_acc_no,
            c.bank_acc_name,
			NULL,NULL,NULL,NULL,NULL,NULL
        ),
        bodytype = 'html',
        notiDt = GETDATE(),
        isPublish = 1,
        notiType = 1,
        external_param = '',
        external_event = 'notify',
        clientId = NULL,
        source_key = 'system',
        actionlist = n.actionlist,
        content_type = 1,
        send_by = 'no-reply@sunshinemail.vn',
        send_name = 'S-Service',
        brand_name = 'Sunshine',
        external_key = '',
        external_sub = NULL,
        is_act_push = CASE WHEN CHARINDEX('push', 'email') > 0 THEN 1 ELSE 0 END,
        is_act_sms = CASE WHEN CHARINDEX('sms', 'email') > 0 THEN 1 ELSE 0 END,
        is_act_email = CASE WHEN CHARINDEX('email', 'email') > 0 THEN 1 ELSE 0 END,
        n_id = NEWID(),
        ma.RoomCode,
        am.memberUserId as userId,
        d.custId,
        d.email,
        d.phone,
        d.fullName
    INTO #temp_notify
    FROM NotifyTemplate n, MAS_Service_ReceiveEntry t
    JOIN MAS_Apartments ma ON t.ApartmentId = ma.ApartmentId
    JOIN MAS_Apartment_Member am ON ma.ApartmentId = am.ApartmentId
        AND (am.isNotification = 1)
    JOIN MAS_Customers d ON am.CustId = d.CustId
    JOIN MAS_Projects c ON ma.projectCd = c.projectCd AND c.sub_projectCd = ma.sub_projectCd
    WHERE am.isNotification = 1 and n.tempId = 'E50623A1-9E5D-4858-80FB-8C5EBF83F28A'
		AND (
			d.Email IS NOT NULL AND LTRIM(RTRIM(d.Email)) <> ''
			OR d.Phone IS NOT NULL AND LTRIM(RTRIM(d.Phone)) <> ''
		)
        AND t.ReceiveId IN (SELECT recId FROM @ReceiveTable)
        AND ISNULL(t.TotalAmt, 0) <> 0;

    
    -- Chèn vào NotifyInbox
    INSERT INTO [dbo].NotifyInbox
        ([subject], content_notify, content_markdown, content_email, content_sms, [bodytype], [notiDt], isPublish, notiType, external_param, external_event, clientId, source_key, sourceId, source_ref, actionlist, createDt, content_type, send_by, send_name, brand_name, external_key, external_sub, is_act_push, is_act_sms, is_act_email
		,attachs, n_id)
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
		attachs = n_id, --lấy chính thông báo làm mã gắt tệp
        n_id
    FROM #temp_notify;

    -- Chèn vào NotifySent
    INSERT INTO [dbo].NotifySent
        (n_id, NotiId, [userId], [custId], [email], [phone], [fullName], [push_st], [sms_st], [email_st], createDt, subject, content_notify, content_email, content_sms, GuidId, room)
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
    FROM #temp_notify t
    JOIN NotifyInbox n ON n.n_id = t.n_id
    JOIN @inserted i ON n.n_id = i.n_id;

	 --attach bỏ sung gắn file
	 INSERT INTO [dbo].[meta_info]
				([sourceOid],
				[file_url],
				[created])
	 SELECT te.n_id,
			t.[BillUrl],
			GETDATE()
	FROM MAS_Service_ReceiveEntry t
	join #temp_notify te on te.sourceId = t.entryId
	WHERE  t.ReceiveId IN (SELECT recId FROM @ReceiveTable)
			AND NOT EXISTS(SELECT 1 FROM [dbo].[meta_info] m 
						WHERE m.sourceOid = te.n_id)

		-- Cập nhật trạng thái isPush trong MAS_Service_ReceiveEntry
		UPDATE [dbo].[MAS_Service_ReceiveEntry]
		SET 
			[isPush] = 1,
			[reminded] = ISNULL([reminded], 0) + 1
		WHERE ReceiveId IN (SELECT recId FROM @ReceiveTable);

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT = ERROR_NUMBER(),
            @ErrorMsg VARCHAR(200) = 'sp_res_invoice_notify_push_kafka: ' + ERROR_MESSAGE(),
            @ErrorProc VARCHAR(50) = ERROR_PROCEDURE(),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX) = '';

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receivable', 'Bill', @SessionID, @AddlInfo;
END CATCH;

SELECT 
    @valid AS valid,
    @messages AS [messages],
    CASE WHEN @valid = 1 THEN 1 ELSE 0 END AS notiQue;

SELECT 
    i.n_id,
    action = n.actionlist
FROM @inserted i
JOIN NotifyInbox n ON n.n_id = i.n_id;