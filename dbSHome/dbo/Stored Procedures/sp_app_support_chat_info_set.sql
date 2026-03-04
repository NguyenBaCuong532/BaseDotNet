

-- =============================================
-- Author: ANHTT
-- Create date: 2025-10-17 12:38:38
-- Description: cập nhật thông tin chat hỗ trợ
-- Output: 
-- =============================================
CREATE   procedure [dbo].[sp_app_support_chat_info_set] 
	  @userId uniqueidentifier = NULL
    , @id UNIQUEIDENTIFIER
    , @requestId UNIQUEIDENTIFIER
    , @userName NVARCHAR(100) = NULL
    , @name NVARCHAR(255) = NULL
    , @visitorId NVARCHAR(255) = NULL
    , @token NVARCHAR(255)
    , @department NVARCHAR(50) = NULL
    , @roomId NVARCHAR(50) = NULL
    , @open BIT = 1
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @valid BIT = 1
        , @messages NVARCHAR(250)
    DECLARE @source_type NVARCHAR(50)
    DECLARE @department_id NVARCHAR(50) = '6909baf2c05dfc9dfcd9726c'
    DECLARE @service_type_id NVARCHAR(50)
    DECLARE @provider_id UNIQUEIDENTIFIER
    DECLARE @is_open BIT

    IF @requestId IS NULL
        SET @requestId = @token

    IF @visitorId IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM user_rocketchat_vistor
            WHERE id = @visitorId
            )
    BEGIN
        INSERT INTO user_rocketchat_vistor (
            [id]
            , [user_id]
            , [department_id]
            , [token]
            )
        VALUES (
            @visitorId
            , @userId
            , @department
            , @token
            )
    END

    UPDATE request_chat
    SET is_open = 0
    WHERE request_id = @requestId
        AND id <> @id

    UPDATE request_chat
    SET [token] = @token
        , [chat_room_id] = @roomId
        , [visitor_id] = @visitorId
        , is_open = 1
    WHERE id = @id

    IF NOT EXISTS (
            SELECT 1
            FROM request_chat
            WHERE id = @id
            )
    BEGIN
        INSERT INTO request_chat (
            [id]
            , [visitor_id]
            , [userId]
            , [request_id]
            , [provider_id]
            , [source_type]
            , [token]
            , [department_id]
            , [chat_room_id]
            , [is_open]
            )
        VALUES (
            @id
            , @visitorId
            , @userId
            , @requestId
            , @provider_id
            , @source_type
            , @token
            , @department
            , @roomId
            , @open
            )
    END

    -- IF @modCd = '204'
    -- BEGIN
    -- END
    SELECT valid = @valid
        , messages = @messages
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

    PRINT @ErrorMsg

    --SET @AddlInfo = NULL;
    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'request_chat'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;