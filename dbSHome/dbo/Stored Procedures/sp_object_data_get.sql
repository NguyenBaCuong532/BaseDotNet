
CREATE PROCEDURE [dbo].[sp_object_data_get]
    @UserID UNIQUEIDENTIFIER,
    @objKey NVARCHAR(50),
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SELECT objName AS name, objValue AS value
    FROM [dbo].fn_config_data_gets_lang(@objKey, @acceptLanguage)
    ORDER BY intOrder;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_object_data_get ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'ObjectDataGet',
                          'Get',
                          @SessionID,
                          @AddlInfo;
END CATCH;