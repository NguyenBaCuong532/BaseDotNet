-- Lịch sử gửi tin nhắn theo căn hộ
CREATE PROCEDURE [dbo].[sp_res_apartment_message_sent_page]
    @UserId UNIQUEIDENTIFIER = NULL,
    @ApartmentId  int,
    @filter NVARCHAR(30),
    @gridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
    --@Total BIGINT OUT,
    --@TotalFiltered BIGINT OUT,
    --@GridKey NVARCHAR(200) OUT
AS
BEGIN TRY
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_messageSent_byApartment_page'
    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

    IF @PageSize <= 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;
	
	select CustId into #Tmp1
		from MAS_Apartment_Member 
		where ApartmentId = @ApartmentId
		and CustId is not NULL

    SELECT @Total = COUNT(a.notiId)
    FROM NotifyInbox a
		JOIN dbo.NotifySent s ON s.NotiId = a.notiId
        JOIN dbo.MessageSents b ON a.n_id = b.sourceId  and s.custId = b.custId
		JOIN dbo.sys_config_data cd2 ON  cd2.key_1 = 'sms_st' AND s.sms_st = cd2.key_2
		JOIN #Tmp1 d on s.custId = d.CustId

    --root	
	select recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1
    --grid config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].[fn_config_list_gets_lang](@GridKey, 0, @AcceptLanguage)
        ORDER BY [ordinal];
    END;

	SELECT --DISTINCT
           (a.[notiId]),
           --b.messageId,
           s.phone,
           ISNULL(s.content_sms, a.content_email) AS content_sms,
           --b.scheduleAt,
           a.brand_name,
           c.FullName AS custName,
           --sendDt = FORMAT(b.sendDt,'dd/MM/yyy'),
           --b.sendNum,
           status = cd2.value1,
           --b.sendFailed,
           --createId = ui.fullName,--a.createId
           createDt = FORMAT(a.createDt,'dd/MM/yyy HH:mm:ss')
    FROM NotifyInbox a
		JOIN dbo.NotifySent s ON s.NotiId = a.notiId
        --LEFT JOIN dbo.MessageSents b ON a.n_id = b.sourceId and s.custId = b.custId
		JOIN dbo.sys_config_data cd2 ON  cd2.key_1 = 'sms_st' AND s.sms_st = cd2.key_2
		join #Tmp1 d on s.custId = d.CustId
		LEFT JOIN dbo.MAS_Customers c ON c.CustId = d.CustId
		 ORDER BY a.createDt DESC,
             a.[notiId] desc
	OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_message_sent_byApartment_page ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '@UserId ' + cast(@UserId as varchar(50));

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'NotificationSent',
                             'GET',
                             @SessionID,
                             @AddlInfo;
END CATCH;