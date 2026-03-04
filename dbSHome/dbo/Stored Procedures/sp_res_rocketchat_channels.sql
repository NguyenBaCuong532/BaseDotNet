
-- =============================================
-- Author: ANHTT
-- Create date: 2025-12-17
-- Description: list channel
-- Output: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_rocketchat_channels] @userId NVARCHAR(50) = NULL
    , @projectCd NVARCHAR(100) = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    SELECT [id]
        , [projectCd]
        , [name]
        , [description]
        , [private]
        , [readOnly] = [read_only]
        , [approval]
        , [metaData] = [meta_data]
    FROM rocketchat_channel
    WHERE projectCd = @projectCd
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
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;