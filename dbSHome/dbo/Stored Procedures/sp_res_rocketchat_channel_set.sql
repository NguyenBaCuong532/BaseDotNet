
-- =============================================
-- Author: ANHTT
-- Create date: 2025-12-17
-- Description: set channel
-- Output: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_rocketchat_channel_set] @userId NVARCHAR(50) = NULL
    , @id VARCHAR(50)
    , @projectCd NVARCHAR(100) = NULL
    , @name NVARCHAR(250)
    , @avatar NVARCHAR(MAX) = NULL
    , @description NVARCHAR(250)
    , @private BIT = NULL
    , @readOnly BIT = NULL
    , @approval BIT = NULL
    , @metaData NVARCHAR(MAX) = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @valid BIT = 1
        , @messages NVARCHAR(250)

    IF NOT EXISTS (
            SELECT 1
            FROM rocketchat_channel
            WHERE id = @id
            )
    BEGIN
        INSERT INTO rocketchat_channel (
            id
            , projectCd
            , [name]
            , [description]
            , [private]
            , [read_only]
            , [approval]
            , meta_data
            )
        VALUES (
            @id
            , @projectCd
            , @name
            , @description
            , @private
            , @readOnly
            , @approval
            , @metaData
            )
    END
    ELSE
    BEGIN
        UPDATE rocketchat_channel
        SET meta_data = @metaData
        WHERE id = @id
    END

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
        , 'rocketchat_channel'
        , 'SET'
        , @SessionID
        , @AddlInfo;
END CATCH;