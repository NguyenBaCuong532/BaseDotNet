
-- =============================================
-- Author: ANHTT
-- Create date: 2025-11-07
-- Description:	Lưu thông báo
-- Output: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_notify_inbox_set] @userId NVARCHAR(50) = NULL
    , @notiType INT
    , @subject NVARCHAR(500)
    , @actionlist NVARCHAR(150)
    , @content_notify NVARCHAR(2000)
    , @content_sms NVARCHAR(2000)
    , @content_type INT
    , @content_markdown NVARCHAR(MAX)
    , @content_email NVARCHAR(MAX)
    , @attachs UNIQUEIDENTIFIER
    , @bodytype NVARCHAR(10)
    , @isPublish BIT
    , @external_key NVARCHAR(50)
    , @external_param NVARCHAR(MAX)
    , @external_event NVARCHAR(50)
    , @source_key NVARCHAR(50)
    , @source_ref UNIQUEIDENTIFIER
    , @clientId NVARCHAR(50)
    , @send_by NVARCHAR(200)
    , @send_name NVARCHAR(50)
    , @brand_name NVARCHAR(20)
    , @bcc NVARCHAR(MAX)
    , @n_id UNIQUEIDENTIFIER
    , @source_id UNIQUEIDENTIFIER
    , @push_count INT
    , @sms_count INT
    , @email_count INT
    , @notiAvatarUrl NVARCHAR(350)
    , @isHighLight BIT
    , @external_sub NVARCHAR(50)
    , @tempId UNIQUEIDENTIFIER
    , @Schedule DATETIME
    , @send_st INT
    , @sourceId UNIQUEIDENTIFIER
    , @is_act_push BIT
    , @is_act_sms BIT
    , @is_act_email BIT
    , @access_role INT
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @valid BIT = 1
        , @messages NVARCHAR(250) = N'Lưu thông báo thành công'

    INSERT INTO NotifyInbox (
        notiType
        , subject
        , actionlist
        , content_notify
        , content_sms
        , content_type
        , content_markdown
        , content_email
        , attachs
        , bodytype
        , isPublish
        , external_key
        , external_param
        , external_event
        , source_key
        , source_ref
        , clientId
        , send_by
        , send_name
        , brand_name
        , bcc
        , n_id
        , source_id
        , push_count
        , sms_count
        , email_count
        , notiAvatarUrl
        , isHighLight
        , external_sub
        , tempId
        , Schedule
        , send_st
        , sourceId
        , is_act_push
        , is_act_sms
        , is_act_email
        , access_role
        , notiDt
        )
    VALUES (
        @notiType
        , @subject
        , @actionlist
        , @content_notify
        , @content_sms
        , @content_type
        , @content_markdown
        , @content_email
        , @attachs
        , @bodytype
        , @isPublish
        , @external_key
        , @external_param
        , @external_event
        , @source_key
        , @source_ref
        , @clientId
        , @send_by
        , @send_name
        , @brand_name
        , @bcc
        , @n_id
        , @source_id
        , @push_count
        , @sms_count
        , @email_count
        , @notiAvatarUrl
        , @isHighLight
        , @external_sub
        , @tempId
        , @Schedule
        , @send_st
        , @sourceId
        , @is_act_push
        , @is_act_sms
        , @is_act_email
        , @access_role
        , GETDATE()
        );

    DECLARE @notiId BIGINT = SCOPE_IDENTITY();

    SELECT valid = @valid
        , messages = @messages
        , [data] = @notiId
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    --SET @AddlInfo = NULL;
    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'NotifyInbox'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;