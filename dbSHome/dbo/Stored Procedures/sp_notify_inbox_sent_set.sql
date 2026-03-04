
-- =============================================
-- Author: ANHTT
-- Create date: 2025-11-07
-- Description:	Lưu thông báo gửi đi
-- Output: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_notify_inbox_sent_set] @userId NVARCHAR(50) = NULL
    , @NotiId BIGINT
    , @custId NVARCHAR(100) = NULL
    , @email NVARCHAR(200) = NULL
    , @phone NVARCHAR(100) = NULL
    , @fullName NVARCHAR(250) = NULL
    , @room NVARCHAR(50) = NULL
    , @push_st INT = NULL
    , @sms_st INT = NULL
    , @read_st BIT = NULL
    , @email_st INT = NULL
    , @createId NVARCHAR(100) = NULL
    , @n_id UNIQUEIDENTIFIER = NULL
    , @toId UNIQUEIDENTIFIER = NULL
    , @Schedule DATETIME = NULL
    , @subject NVARCHAR(300) = NULL
    , @content_notify NVARCHAR(MAX) = NULL
    , @content_sms NVARCHAR(600) = NULL
    , @content_email NVARCHAR(MAX) = NULL
    , @push_st_message NVARCHAR(2000) = NULL
    , @sms_st_message NVARCHAR(512) = NULL
    , @email_st_message NVARCHAR(512) = NULL
    , @external_param NVARCHAR(1024) = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @valid BIT = 1
        , @messages NVARCHAR(250) = N'Lưu thông báo thành công'

    SET NOCOUNT ON;

    INSERT INTO NotifySent (
        NotiId
        , custId
        , email
        , phone
        , fullName
        , room
        , push_st
        , sms_st
        , read_st
        , email_st
        , createId
        , n_id
        , toId
        , Schedule
        , subject
        , content_notify
        , content_sms
        , content_email
        , push_st_message
        , sms_st_message
        , email_st_message
        , external_param
        )
    VALUES (
        @NotiId
        , @custId
        , @email
        , @phone
        , @fullName
        , @room
        , @push_st
        , @sms_st
        , @read_st
        , @email_st
        , @createId
        , @n_id
        , @toId
        , @Schedule
        , @subject
        , @content_notify
        , @content_sms
        , @content_email
        , @push_st_message
        , @sms_st_message
        , @email_st_message
        , @external_param
        );

    DECLARE @newId BIGINT = SCOPE_IDENTITY();

    SELECT valid = @valid
        , messages = @messages
        , [data] = @newId
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
        , 'NotifySent'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;