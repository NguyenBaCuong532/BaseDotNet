

-- =============================================
-- Author: ANHTT
-- Create date: 2025-10-17 12:38:38
-- Description:	thông tin chat hỗ trợ
-- Output: 
-- =============================================
CREATE   procedure [dbo].[sp_app_support_chat_info_get] 
	  @userId uniqueidentifier = NULL
    , @requestId UNIQUEIDENTIFIER
    , @modCd NVARCHAR(50) = '204'
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @id UNIQUEIDENTIFIER
    DECLARE @source_type NVARCHAR(50)
    DECLARE @user_name NVARCHAR(50)
    DECLARE @request_name NVARCHAR(250)
    DECLARE @department_id NVARCHAR(50) = '69155c15535a424d0e59c46a'--'6909baf2c05dfc9dfcd9726c'
    DECLARE @chat_room_id NVARCHAR(50)
    DECLARE @service_type_id NVARCHAR(50)
    DECLARE @provider_id UNIQUEIDENTIFIER
    DECLARE @token NVARCHAR(256)
    DECLARE @is_open BIT

    SELECT @user_name = loginName
    FROM UserInfo
    WHERE userId = @userId

    SELECT TOP 1 @id = id
        , @source_type = [source_type]
        , @token = [token]
        , @department_id = [department_id]
        , @provider_id = [provider_id]
        , @chat_room_id = [chat_room_id]
        , @is_open = [is_open]
    FROM [request_chat]
    WHERE request_id = @requestId

    SELECT @request_name = '[' + isnull(a.thread_id, 'RQ') + '] ' + b.requestTypeName
    FROM MAS_Requests a
    JOIN MAS_Request_Types b
        ON a.requestTypeId = b.requestTypeId
    WHERE a.[Oid] = @requestId

    IF @id IS NULL
    BEGIN
        SET @id = NEWID()
        --TODO: Lấy thông tin department
        SET @department_id = '69155c15535a424d0e59c46a'--'6909baf2c05dfc9dfcd9726c'

        --tạo thông tin chat
        INSERT INTO request_chat (
            [id]
            , [userId]
            , [request_id]
            , [provider_id]
            , [source_type]
            , [department_id]
            )
        SELECT @id
            , @userId
            , @requestId
            , @provider_id
            , [source_type] = 'request'
            , @department_id
            -- IF @modCd = '204'
            -- BEGIN
            -- END
    END

    SELECT id = @id
        , userId = @userId
        , requestId = @requestId
        , source_type = @source_type
        , token = @token
        , department = @department_id
        , [userName] = @user_name
        , [name] = @request_name
        , provider_id = @provider_id
        , roomId = @chat_room_id
        , [open] = @is_open
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
        , 'request_chat'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;