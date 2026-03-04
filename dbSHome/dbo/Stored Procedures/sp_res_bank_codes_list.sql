CREATE PROCEDURE [dbo].[sp_res_bank_codes_list]
    @userId NVARCHAR(450),
    @filter NVARCHAR(50) = NULL
AS
BEGIN TRY
	
    SELECT
        [value] = bank_code,
        [name] = bank_name
    FROM bank_codes
    ORDER BY bank_code

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_bank_codes_list' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'Project', 'GET', @SessionID, @AddlInfo;
END CATCH;