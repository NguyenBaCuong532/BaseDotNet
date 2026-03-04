-- =============================================
-- Author:      ThanhMT
-- Create date: 07/01/2026
-- Description: Khóa/mở khóa kỳ thanh toán
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_billing_periods_set_locked]
    @UserId uniqueidentifier,
    @project_code NVARCHAR(50) = NULL,
    @oid uniqueidentifier,
    @locked BIT,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
DECLARE @Messages NVARCHAR(MAX) = N'Thực hiện thành công';
DECLARE @Valid BIT = 1;
BEGIN TRY
	
    UPDATE a
    SET
        a.locked = @locked,
        a.last_modified_by = @UserId,
        a.last_modified_date = GETDATE()
    FROM mas_billing_periods a
    WHERE oid = @oid
    
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
    id = @Oid,
    Valid = @Valid,
    Messages = @Messages