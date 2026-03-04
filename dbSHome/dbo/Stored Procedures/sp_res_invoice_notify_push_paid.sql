
-- =============================================
-- Author:		NamHM
-- Create date: 27/06/2025
-- Description:	Thông báo đã thanh toán hóa đơn
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_invoice_notify_push_paid] 
	-- Add the parameters for the stored procedure here
	@userId nvarchar(50) = null
   ,@acceptLanguage nvarchar(50) = 'vi-VN'
   ,@virtualAccount nvarchar(100) = null
AS

BEGIN TRY
		DECLARE @receiveIds NVARCHAR(100) = (SELECT re.ReceiveId FROM transaction_payment_draft tpd
											INNER JOIN MAS_Service_ReceiveEntry re ON tpd.sourceOid = re.entryId
											WHERE tpd.virtualAcc = @virtualAccount)

    DECLARE @action NVARCHAR(100) = 'push, email'

    IF OBJECT_ID('tempdb..#temp_notify1') IS NOT NULL
        DROP TABLE #temp_notify1;

    DECLARE @inserted TABLE (n_id UNIQUEIDENTIFIER)

    SELECT TOP 1
          t.ReceiveId AS Id
        , sourceId = t.entryId
        , Subject = N'Xác nhận thanh toán thành công căn hộ ' + ma.RoomCode
        , content_notify = N'BQLTN ' + c.ProjectName + N' xác nhận thanh toán thành công cho hóa đơn tháng ' + CAST(MONTH(t.ToDt) AS NVARCHAR(5)) + N'/' + CAST(YEAR(t.ToDt) AS NVARCHAR(5)) + N' của căn hộ ' + ma.RoomCode + N'. Số tiền thanh toán: ' + FORMAT(ISNULL(t.PaidAmt, 0), '###,###,###') + N'đ. Xin cảm ơn Quý khách!'
        , content_sms = N'BQLTN ' + c.ProjectName + ' xac nhan thanh toan thanh cong hoa don thang ' + CAST(MONTH(t.ToDt) AS NVARCHAR(5)) + ' can ho ' + ma.RoomCode + '. So tien: ' + FORMAT(ISNULL(t.PaidAmt, 0), '###,###,###') + 'd. Xin cam on!'
		, content_email = N'
			<div class="row-container" style="font-size:16px; font-family: sans-serif;">
				<div style="text-align: justify;">
					<h3><i>Kính gửi ông/bà: ' + ISNULL(d.FullName, '') + N' - Căn hộ ' + ISNULL(ma.RoomCode, '') + N'</i></h3>
					<h3><i>Dear Mr./Ms.: ' + ISNULL(d.FullName, '') + N' - Apartment ' + ISNULL(ma.RoomCode, '') + N'</i></h3>
				</div>
				<div class="translate" style="float: left; width: 100%;">
					<p>Ban Quản lý Tòa nhà ' + ISNULL(c.projectName, '') + N' xin trân trọng cảm ơn Quý Cư dân/Quý khách hàng đã hoàn tất thanh toán hóa đơn.</p>
					<p><i>The ' + ISNULL(c.projectName, '') + N' Building Management would like to thank you for completing your invoice payment.</i></p>
				</div>
				<div style="clear: both;"></div>
			</div>
			<div class="row-container" style="font-size:16px; font-family: sans-serif;">
				<p>Chúng tôi xác nhận đã ghi nhận thanh toán thành công cho hóa đơn tháng <b>' + CAST(MONTH(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) + N'/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) + N'</b> của căn hộ <b>' + ISNULL(ma.RoomCode, '') + N'</b>.</p>
				<p><i>We confirm the successful payment for the invoice of month <b>' + CAST(MONTH(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) + N'/' + CAST(YEAR(ISNULL(t.ToDt, GETDATE())) AS NVARCHAR(5)) + N'</b> for apartment <b>' + ISNULL(ma.RoomCode, '') + N'</b>.</i></p>
				<ul>
					<li>&nbsp;&nbsp;&nbsp;&nbsp;Số tiền đã thanh toán/<i>Paid amount</i>: <span style="color:blue"><b>' + FORMAT(ISNULL(t.PaidAmt, 0), '###,###,###') + N' VNĐ.</span></b></li>
					<li>&nbsp;&nbsp;&nbsp;&nbsp;Ngày thanh toán/<i>Payment date</i>: <span style="color:blue"><b>' + CONVERT(NVARCHAR(10), ISNULL(t.PayedDt, GETDATE()), 103) + N'</span></b></li>
				</ul>
				<p>Một lần nữa, chúng tôi xin chân thành cảm ơn sự hợp tác của bạn.</p>
				<p><i>Once again, we sincerely thank you for your cooperation.</i></p>
				<br>
				<p>Xin cám ơn!</p>
				<p><i>Thank you!</i></p>
			</div>'
        , [action_list] = @action
        , 'new' AS [status]
        , '0987654321' as Phone
        , 'namhm01@unicloud' as Email
        , d.FullName
        , ISNULL(u2.userId, u.UserId) AS userId
        , ISNULL(u2.AvatarUrl, u.AvatarUrl) AS AvatarUrl
        , u.CustId
        , brand_name = 'Sunshine'
        , external_key = 's-resident'
        , t.BillUrl AS attach_file
        , ISNULL(c.mailSender, 'no-reply@sunshinemail.vn') AS mailSender
        , ISNULL(c.investorName, 'Ban QLTN ' + c.projectName) AS send_name
        , external_sub = c.projectCd
        , NEWID() AS n_id
    INTO #temp_notify1
    FROM MAS_Service_ReceiveEntry t
    JOIN MAS_Apartments ma ON t.ApartmentId = ma.ApartmentId
    LEFT JOIN UserInfo u ON ma.UserLogin = u.loginName
    JOIN MAS_Apartment_Member am ON ma.ApartmentId = am.ApartmentId AND (u.CustId = am.CustId OR am.isNotification = 1)
    JOIN MAS_Customers d ON am.CustId = d.CustId
    JOIN MAS_Projects c ON ma.projectCd = c.projectCd AND c.sub_projectCd = ma.sub_projectCd
    LEFT JOIN UserInfo u2 ON d.CustId = u2.custId --AND u2.userType = 2
    WHERE t.ReceiveId = @receiveIds

	---tacknotify
    INSERT INTO [dbo].NotifyInbox (
        [Subject], content_notify, content_markdown, content_email, content_sms,
        [bodytype], [NotiDt], IsPublish, notiType, external_param, external_event,
        clientId, source_key, source_id, actionlist, createId, content_type,
        send_by, send_name, brand_name, external_key, external_sub, n_id
    )
    OUTPUT inserted.n_id INTO @inserted
    SELECT
        n.Subject, n.content_notify, n.content_notify, n.content_email, n.content_sms,
        'html', GETDATE(), 1, 0, '', 'notify', '', 'system', n.sourceId, n.action_list,
        n.UserID, 1, mailSender, n.send_name, n.brand_name, n.external_key,
        n.external_sub, n_id
    FROM #temp_notify1 n

    INSERT INTO NotifyAttach (
        n_id, attach_name, attach_url, attach_type, attach_size, notiId
    )
    SELECT i.n_id, NULL, a.attach_file, '', 0, n.notiId
    FROM #temp_notify1 a
    JOIN NotifyInbox n ON a.sourceId = n.source_id AND a.n_id = n.n_id
    JOIN @inserted i ON n.n_id = i.n_id
    WHERE a.attach_file IS NOT NULL AND a.sourceId IS NOT NULL

    INSERT INTO [dbo].NotifySent (
        n_id, [userId], [custId], [email], [phone], [fullName],
        [push_st], [sms_st], [email_st], [createId], createDt, NotiId
    )
    SELECT DISTINCT i.n_id, userId, custid, email, phone, fullName,
        CASE WHEN userId IS NOT NULL AND userId != '' THEN 2 ELSE 4 END,
        CASE WHEN phone IS NOT NULL AND [dbo].funcSDT(phone) = 1 THEN 0 ELSE 4 END,
        CASE WHEN email IS NOT NULL AND [dbo].fn_check_mail(email) = 1 THEN 0 ELSE 4 END,
        @UserId, GETDATE(), n.notiId
    FROM #temp_notify1 a
    JOIN NotifyInbox n ON a.sourceId = n.source_id AND a.n_id = n.n_id
    JOIN @inserted i ON n.n_id = i.n_id
    WHERE a.sourceId IS NOT NULL

    IF CHARINDEX('push', @action) > 0
    BEGIN
        UPDATE t
        SET [push_st] = CASE WHEN t.userId IS NOT NULL THEN 1 ELSE 4 END, createDt = GETDATE()
        FROM NotifySent t
        JOIN @inserted i ON t.n_id = i.n_id
        WHERE (t.push_st = 0 OR t.push_st = 2)
    END

    IF CHARINDEX('sms', @action) > 0
    BEGIN
        UPDATE t
        SET [sms_st] = 1, createDt = GETDATE()
        FROM NotifySent t
        JOIN @inserted i ON t.n_id = i.n_id
        WHERE (t.sms_st = 0)
        
        INSERT INTO [dbo].[MessageJobs] (
            [messageId], [phone], [custName], [custId], [contents], [scheduleAt],
            [brandName], [createId], createdDt, [clientId], [clientIp], [sourceId],
            [remart], [partner]
        )
        SELECT NEWID(), RTRIM(LTRIM(a.phone)), a.[fullName], a.[custId], b.content_sms,
            NULL, ISNULL(b.brand_name, 'Sunshine'), @UserID, GETDATE(), b.clientId,
            NULL, b.n_id, a.room, 'iris'
        FROM NotifySent a
        JOIN NotifyInbox b ON a.n_id = b.n_id
        JOIN @inserted i ON b.n_id = i.n_id
        WHERE (a.sms_st = 1)
            AND [dbo].[funcSDT](a.phone) = 1
            AND (b.content_sms IS NOT NULL AND b.content_sms <> '')
    END

    IF CHARINDEX('email', @action) > 0
    BEGIN
        UPDATE t
        SET [email_st] = 1, createDt = GETDATE()
        FROM NotifySent t
        JOIN @inserted i ON t.n_id = i.n_id
        WHERE (email_st = 0)
        
        INSERT INTO [dbo].EmailJobs (
            [mailto], [Cc], [Bcc], [SendBy], [Subject], [Contents], [BodyType], [Status],
            [createdDate], [Send], [SendDate], [SendType], [SendName], [createId], [custId],
            [clientId], [sourceId], sourceKey, [remart]
        )
        SELECT
            a.email, NULL, b.bcc, ISNULL(b.send_by, 'no-reply@sunshinemail.vn'),
            b.subject, b.content_email, ISNULL(b.bodytype, 'text'), 0, GETDATE(),
            0, NULL, 0, ISNULL(b.send_name, 'Sunshine Service'), @UserID, a.custId,
            b.clientId, b.n_id, b.source_key, a.room
        FROM NotifySent a
        JOIN NotifyInbox b ON a.n_id = b.n_id
        JOIN @inserted i ON b.n_id = i.n_id
        WHERE (a.email_st = 1)
            AND a.email IS NOT NULL AND a.email <> ''
            AND (b.content_email IS NOT NULL AND b.content_email <> '')
    END

    SELECT part INTO #temp1 FROM dbo.fn_split_string(@receiveIds, ',')
    CREATE INDEX id_temp1 ON #temp1(part)

    UPDATE t
    SET IsPush = 1, push_dt = GETDATE(), push_count = ISNULL(push_count, 0) + 1
    FROM MAS_Service_ReceiveEntry t
    JOIN MAS_Apartments a ON t.ApartmentId = a.ApartmentId
    LEFT JOIN UserInfo u ON a.UserLogin = u.loginName
    WHERE t.ReceiveId IN (SELECT part FROM #temp1)
        AND (
            a.isLinkApp = 1
            OR EXISTS (
                SELECT 1
                FROM MAS_Apartment_Member am
                JOIN MAS_Customers c ON am.CustId = c.CustId
                WHERE am.ApartmentId = a.ApartmentId
                    AND (am.CustId = u.CustId OR isNotification = 1)
                    AND (c.Email IS NOT NULL OR c.Phone IS NOT NULL)
                    AND (c.Email <> '' OR c.Phone <> '')
            )
        )


END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_Receipt_SetInfo ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = '@CustId ' + @userId

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Receipts'
        , 'Insert'
        , @SessionID
        , @AddlInfo
END CATCH
FINAL:
select * from #temp_notify1