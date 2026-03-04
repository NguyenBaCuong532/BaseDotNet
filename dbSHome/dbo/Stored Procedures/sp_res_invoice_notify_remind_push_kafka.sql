-- =============================================
-- Author:		namhm
-- Create date: 28/08/2025
-- Description:	Thông báo nhắc nợ kafka
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_invoice_notify_remind_push_kafka] 
	  @userId NVARCHAR(450) = NULL
    , @receiveIds NVARCHAR(max) = NULL
    , @projectcode NVARCHAR(30) = NULL

AS
BEGIN TRY
    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(100) = N'Done';
    DECLARE @inserted TABLE (n_id UNIQUEIDENTIFIER);
    DECLARE @ReceiveTable TABLE 
            (
                [id] [int] IDENTITY(1,1) NOT NULL,
                [recId] bigint NOT NULL
            );

    IF @receiveIds IS NULL OR @receiveIds = ''
    BEGIN
        SET @valid = 0;
        SET @messages = N'ReceiveId is NULL';
        GOTO FINAL;
    END;

    INSERT INTO @ReceiveTable(recId)
    SELECT CAST(part AS BIGINT)
    FROM [dbo].[SplitString](@receiveIds, ',');

    -- Kiểm tra nếu không có dữ liệu sau khi split
    IF NOT EXISTS (SELECT 1 FROM @ReceiveTable)
    BEGIN
        SET @valid = 0;
        SET @messages = N'No valid ReceiveIds found';
        GOTO FINAL;
    END;

    -- Tạo bảng tạm để lưu thông tin thông báo
    IF OBJECT_ID('tempdb..#temp_notify') IS NOT NULL
        DROP TABLE #temp_notify;

    -- Lưu thông tin thông báo vào bảng tạm (dựa trên template)
    SELECT DISTINCT
        [subject] = dbo.fn_get_notify_subject(
            n.[subject],
            ma.RoomCode,
            c.ProjectName,
            NULL,
            NULL,
            CAST(
                CASE 
                    WHEN ISNULL(t.reminded, 0) + 1 > 3 THEN 3 
                    ELSE ISNULL(t.reminded, 0) + 1 
                END AS NVARCHAR(5)
            ),
			NULL
        ),
        content_notify = N'NULL',  -- Hoặc giá trị phù hợp nếu cần
        content_markdown = N'NULL',
        content_email = dbo.fn_get_notify_content(
            n.content_markdown,
            d.FullName,
            ma.RoomCode,
            c.projectName,
            t.DebitAmt,
            CAST(MONTH(t.ToDt) AS NVARCHAR(5)) + '/' + CAST(YEAR(t.ToDt) AS NVARCHAR(5)),
            CAST(MONTH(t.ToDt) AS NVARCHAR(5)) + '/' + CAST(YEAR(t.ToDt) AS NVARCHAR(5)),
            CASE WHEN MONTH(t.ToDt) = 12 
                THEN '1/' + CAST(YEAR(t.ToDt)+1 AS NVARCHAR(5)) 
                ELSE CAST(MONTH(t.ToDt)+1 AS NVARCHAR(5)) + '/' + CAST(YEAR(t.ToDt) AS NVARCHAR(5)) END,
            CASE WHEN MONTH(t.ToDt) = 12 
                THEN '1/' + CAST(YEAR(t.ToDt)+1 AS NVARCHAR(5)) 
                ELSE CAST(MONTH(t.ToDt)+1 AS NVARCHAR(5)) + '/' + CAST(YEAR(t.ToDt) AS NVARCHAR(5)) END,
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
        content_sms = dbo.fn_get_notify_sms(
                  n.content_sms,
                  ma.RoomCode,
                  c.ProjectName,
                    CAST(
                        CASE 
                            WHEN ISNULL(t.reminded, 0) + 1 > 3 THEN 3 
                            ELSE ISNULL(t.reminded, 0) + 1 
                        END AS NVARCHAR(5)
                    ),
				  NULL,
				  NULL,
                  FORMAT(t.TotalAmt, '###,###,###'),
                  FORMAT(t.PaidAmt, '###,###,###'),
                  FORMAT(t.TotalAmt - t.PaidAmt, '###,###,###')
              ),
		bodytype = n.bodytype,
        notiDt = GETDATE(),
        isPublish = 1,
        notiType = 1,
        external_param = '',
        external_event = n.external_event,
        clientId = NULL,
        source_key = 'system',
        sourceId = t.entryId,
        source_ref = NULL,
        actionlist = n.actionlist,  -- Hoặc giá trị phù hợp từ template nếu cần
        content_type = 1,
        send_by = 'no-reply@sunshinemail.vn',
        send_name = 'S-Service',
        brand_name = 'Sunshine',
        external_key = '',
        external_sub = NULL,
        is_act_push = CASE WHEN CHARINDEX('push', n.actionlist, 0) > 0 THEN 1 ELSE 0 END,
        is_act_sms = CASE WHEN CHARINDEX('sms', n.actionlist, 0) > 0 THEN 1 ELSE 0 END,
        is_act_email = CASE WHEN CHARINDEX('email', n.actionlist, 0) > 0 THEN 1 ELSE 0 END,
        n_id = NEWID(),
        t.entryId AS source_entry_id,  
        ma.RoomCode,
        am.memberUserId as userId,
        d.custId,
        d.email,
        d.phone,
        d.fullName
    INTO #temp_notify
    FROM [dbo].NotifyTemplate n
    JOIN MAS_Service_ReceiveEntry t ON 1=1  -- Join để lấy dữ liệu
    JOIN MAS_Apartments ma ON t.ApartmentId = ma.ApartmentId
    JOIN MAS_Apartment_Member am ON ma.ApartmentId = am.ApartmentId AND (am.isNotification = 1)
    JOIN MAS_Customers d ON am.CustId = d.CustId
    JOIN MAS_Projects c ON ma.projectCd = c.projectCd AND c.sub_projectCd = ma.sub_projectCd
    WHERE am.isNotification = 1 
        AND n.tempId = '204FA5B3-A336-465E-B98D-AA159A3DBD80'
        AND (
            d.Email IS NOT NULL AND LTRIM(RTRIM(d.Email)) <> ''
            AND d.Phone IS NOT NULL AND LTRIM(RTRIM(d.Phone)) <> ''
        )
        AND t.ReceiveId IN (SELECT recId FROM @ReceiveTable)
        AND ISNULL(t.TotalAmt, 0) <> 0;

    -- Chèn vào NotifyInbox
    INSERT INTO [dbo].NotifyInbox
        ([subject], content_notify, content_markdown, content_email, content_sms, [bodytype], [notiDt], isPublish, notiType, external_param, external_event, clientId, source_key, sourceId, source_ref, actionlist, createDt, content_type, send_by, send_name, brand_name, external_key, external_sub, is_act_push, is_act_sms, is_act_email, attachs, n_id)
    OUTPUT inserted.n_id INTO @inserted
    SELECT 
        [subject],
        content_notify,
        content_markdown,
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
        attachs = n_id,  -- Lấy chính thông báo làm mã gắn tệp
        n_id
    FROM #temp_notify;

    -- Chèn vào NotifySent
    INSERT INTO [dbo].NotifySent
        (n_id, NotiId, [userId], [custId], [email], [phone], [fullName], [push_st], [sms_st], [email_st], createDt, subject, content_notify, content_email, content_sms, GuidId, room)
    SELECT 
        n.n_id,
        n.notiId, 
        CAST(t.userId AS VARCHAR(50)),
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

    -- Attach file bổ sung
    INSERT INTO [dbo].[meta_info]
        ([sourceOid], [file_url], [created])
    SELECT 
        te.n_id,
        t.[BillUrl],
        GETDATE()
    FROM MAS_Service_ReceiveEntry t
    JOIN #temp_notify te ON te.source_entry_id = t.entryId
    WHERE t.ReceiveId IN (SELECT recId FROM @ReceiveTable)
        AND NOT EXISTS(SELECT 1 FROM [dbo].[meta_info] m 
                       WHERE m.sourceOid = te.n_id);

    -- Cập nhật trạng thái isPush trong MAS_Service_ReceiveEntry
    UPDATE [dbo].[MAS_Service_ReceiveEntry]
    SET [isPush] = 1,
		[reminded] = ISNULL([reminded], 0) + 1
    WHERE ReceiveId IN (SELECT recId FROM @ReceiveTable);

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT = ERROR_NUMBER(),
            @ErrorMsg VARCHAR(200) = 'sp_res_invoice_notify_remind_push: ' + ERROR_MESSAGE(),
            @ErrorProc VARCHAR(50) = ERROR_PROCEDURE(),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX) = '';

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Service_ReceiveEntry', 'invoice', @SessionID, @AddlInfo;
END CATCH;
FINAL:
	select @valid as valid
		  ,@messages as [messages]
		  ,case when @valid = 1 then 1 else 0 end as notiQue

	select i.n_id 
			 ,action = n.actionlist
		from @inserted i
			join NotifyInbox n on n.n_id = i.n_id