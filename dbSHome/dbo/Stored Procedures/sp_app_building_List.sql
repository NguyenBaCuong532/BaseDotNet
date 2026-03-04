
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	list project
-- Output:
-- =============================================
CREATE
    

 PROCEDURE [dbo].[sp_app_building_List] 
	  @userId UNIQUEIDENTIFIER = NULL
    , @projectCd NVARCHAR(50) = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    SELECT [projectName] AS name
        , [projectCd] AS value
    FROM MAS_Buildings
    WHERE ProjectCd = @projectCd
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
        , 'MAS_Projects'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;