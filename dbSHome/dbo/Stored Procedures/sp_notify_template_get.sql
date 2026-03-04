
-- =============================================
-- Author: ANHTT
-- Create date: 2025-11-07
-- Description:	Mẫu thông báo
-- Output: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_notify_template_get] @userId NVARCHAR(50) = NULL
    , @id UNIQUEIDENTIFIER = NULL
    , @code NVARCHAR(50) = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    SELECT [id] = [tempId]
        , [code] = tempCd
        , [subject]
        , [actionlist]
        , contentNotify = [content_notify]
        , contentSms = [content_sms]
        , contentType = [content_type]
        , contentMarkdown = [content_markdown]
        , contentEmail = [content_email]
        , [bodytype]
        , sourceKey = [source_key]
        , externalKey = [external_key]
    FROM NotifyTemplate
    WHERE tempId = @id
        OR tempCd = @code
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
        , 'NotifyTemplate'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;