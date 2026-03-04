-- =============================================
-- Author:      ThanhMT
-- Create date: 15/12/2025
-- Description: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_billing_periods_status_list]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
DECLARE @oid uniqueidentifier;
DECLARE @Messages NVARCHAR(MAX) = N'Thực hiện thành công';
DECLARE @Valid BIT = 1;
BEGIN TRY
	
    SELECT
        name,
        [value] = code
    FROM par_billing_periods_status
    ORDER BY sort_order

END TRY
BEGIN CATCH
    SET @Valid = 0;
    SET @Messages = error_message();
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(MAX), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH

SELECT
    id = @oid,
    Valid = @Valid,
    Messages = @Messages