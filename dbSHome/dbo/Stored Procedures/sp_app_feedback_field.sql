-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	details of feedback
-- Output: form configuration
-- =============================================
CREATE   procedure [dbo].[sp_app_feedback_field] @userId uniqueidentifier = NULL
    , @id UNIQUEIDENTIFIER = NULL
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;
    DECLARE @tableKey VARCHAR(50) = 'app_MAS_Feedbacks'
    DECLARE @groupKey VARCHAR(50) = 'common_group'
    DECLARE @status_key NVARCHAR(50) = 'feedback_status_new'
    DECLARE @workId UNIQUEIDENTIFIER = ISNULL(@id, NEWID());

    -- 1. Thông tin chung (root info)
    IF @id IS NULL OR NOT EXISTS (SELECT 1 FROM MAS_Feedbacks WHERE Oid = @id)
    BEGIN
        SELECT 
            @workId AS id,
            @tableKey AS tableKey,
            @groupKey AS groupKey,
            NULL AS statusId,
            N'' AS statusName;
    END
    ELSE
    BEGIN
        SELECT 
            a.Oid AS id,
            @tableKey AS tableKey,
            @groupKey AS groupKey,
            a.Status AS statusId,
            ISNULL(s.objValue1, N'Chưa xác định') AS StatusName
        FROM MAS_Feedbacks a
        LEFT JOIN dbo.fn_config_data_gets_lang(@status_key, @acceptLanguage) s ON s.objCode = a.[Status]
        WHERE a.Oid = @id;
    END

    -- 2. Các group
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
    ORDER BY intOrder

    -- 3. Dữ liệu fields (#temp)
    CREATE TABLE #temp (
        Oid UNIQUEIDENTIFIER NULL,
        FeedbackId INT NULL,
        regUserId NVARCHAR(450) NULL,
        userId NVARCHAR(450) NULL,
        FeedbackTypeId INT NULL,
        Title NVARCHAR(500) NULL,
        Comment NVARCHAR(MAX) NULL,
        InputDate DATETIME NULL,
        ClientId INT NULL,
        AppId INT NULL,
        ApartmentId INT NULL,
        statusId NVARCHAR(50) NULL,
        StatusName NVARCHAR(255) NULL,
        Attach UNIQUEIDENTIFIER NULL
    );

    INSERT INTO #temp (
        Oid, FeedbackId, regUserId, userId, FeedbackTypeId, Title, Comment, InputDate, ClientId, AppId, ApartmentId, statusId, StatusName, Attach
    )
    SELECT a.[Oid]
        , a.[FeedbackId]
        , a.[regUserId]
        , a.[userId]
        , a.[FeedbackTypeId]
        , a.[Title]
        , a.[Comment]
        , a.[InputDate]
        , a.[ClientId]
        , a.[AppId]
        , a.[ApartmentId]
        , a.[Status] AS statusId
        , ISNULL(s.objValue1, N'Chưa xác định') AS StatusName
        , a.AttachOid
    FROM MAS_Feedbacks a
    LEFT JOIN dbo.fn_config_data_gets(@status_key) s ON s.objCode = a.[Status]
    WHERE a.Oid = @workId

    IF NOT EXISTS (
            SELECT 1
            FROM #temp
            )
        INSERT INTO #temp (
            Oid, FeedbackId, regUserId, userId, FeedbackTypeId, Title, Comment, InputDate, ClientId, AppId, ApartmentId, statusId, StatusName, Attach
        )
        VALUES (
            @workId, NULL, NULL, NULL, NULL, N'', N'', GETDATE(), NULL, NULL, NULL, NULL, N'', NULL
        )

    EXEC [sp_config_data_fields_v2] @id = @workId
        , @key_name = 'Oid'
        , @table_name = @tableKey
        , @dataTableName = '#temp'
        , @acceptLanguage = @acceptLanguage;
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
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , @tableKey
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;