
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	list of card type
-- Output: list name,value
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_card_types] 
	  @userId UNIQUEIDENTIFIER = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY

    SELECT [name] = a.CardTypeId
        , [value] = a.CardTypeName
    FROM MAS_CardTypes a
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
        , 'MAS_CardTypes'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;