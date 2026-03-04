
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	lịch sử thông báo
-- Output:
-- =============================================
CREATE   PROCEDURE [dbo].[sp_app_notify_sent_byuserId] 
	  @userId uniqueidentifier = NULL
    , @filter NVARCHAR(30) = NULL
    , @code NVARCHAR(50) = NULL
    , @source_ref UNIQUEIDENTIFIER = NULL
    , @isHighLight INT = NULL
    , @gridWidth INT = 0
    , @Offset INT = 0
    , @PageSize INT = 10
    , @AcceptLanguage NVARCHAR(20) = NULL
AS
BEGIN TRY
    DECLARE @Total BIGINT
    DECLARE @GridKey NVARCHAR(100) = 'view_app_notify_sent_page'
	declare @room nvarchar(50) = (select top 1 a.RoomCode 
		from MAS_Apartment_Member ap 
		join MAS_Apartments a on ap.ApartmentId = a.ApartmentId
        JOIN UserInfo u ON ap.CustId = u.CustId
		where u.userId = @UserId and ap.main_st = 1)

    SET @Offset = isnull(@Offset, 0)
    SET @PageSize = isnull(@PageSize, 10)
    SET @Total = isnull(@Total, 0)
    SET @filter = isnull(@filter, '')

    IF @PageSize <= 0
        SET @PageSize = 10

    IF @Offset < 0
        SET @Offset = 0

    SELECT @Total = count(a.n_id)
    FROM NotifyInbox a
    left JOIN NotifySent b ON a.n_id = b.n_id and b.userId = @userId and b.room = @room
    WHERE a.IsPublish = 1
        AND (b.userId = @userId or a.access_role = 0)
		AND(@source_ref IS NULL OR a.source_ref = @source_ref)
		and (@isHighLight is null or a.isHighLight = @isHighLight)

    --root	
    SELECT recordsTotal = @Total
        , recordsFiltered = @Total
        , gridKey = @GridKey
        , valid = 1

    ----grid config
    --IF @Offset = 0
    --BEGIN
    --    SELECT 1
    --END

    SELECT a.[NotiId] AS notiId
        , a.[Subject] AS subject
        , a.content_notify as description
        , b.userId
        , b.fullName
        , b.phone
        , b.email
        , b.room roomCode
        , cd.value1 AS email_status
        , cd1.value1 AS push_status
        , cd2.value1 AS sms_status
        , b.id
        , a.content_type contentType
        , a.n_id
		, notiAvatarUrl = (select top 1 m.file_url from meta_info m 
					where m.sourceOid = try_cast(a.notiAvatarUrl as uniqueidentifier))
    FROM NotifyInbox a
    left JOIN NotifySent b ON a.n_id = b.n_id and b.userId = @userId and b.room = @room
    left JOIN dbo.sys_config_data cd ON cd.key_1 = 'email_st' AND b.email_st = cd.key_2 
    left JOIN dbo.sys_config_data cd1 ON cd1.key_1 = 'push_st' AND b.push_st = cd1.key_2
    left JOIN dbo.sys_config_data cd2 ON cd2.key_1 = 'sms_st' AND b.sms_st = cd2.key_2
    WHERE a.IsPublish = 1
        AND (b.userId = @userId or a.access_role = 0)
		AND(@source_ref IS NULL OR a.source_ref = @source_ref)
		and (@isHighLight is null or a.isHighLight = @isHighLight)
    ORDER BY NotiDt DESC offset @Offset rows
    FETCH NEXT @PageSize rows ONLY
        --end
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = @UserId

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'NotificationSent'
        , 'GET'
        , @SessionID
        , @AddlInfo
END CATCH