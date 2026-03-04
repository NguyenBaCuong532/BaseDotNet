-- =============================================
-- Author:      ThanhMT
-- Create date: 20/10/2025
-- Description: Kỳ tính dự thu - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_RevenuePeriods_locked]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier = NULL,
    @set_unlocked BIT,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
DECLARE @Messages NVARCHAR(100) = N'Thực hiện thành công';
DECLARE @Valid BIT = 1;
BEGIN TRY
    
    UPDATE a
    SET a.locked = IIF(@set_unlocked = 1, 0, 1)
    FROM mas_revenue_periods a
    WHERE oid = @oid

END TRY
BEGIN CATCH
    SET @Valid = 0;
    SET @Messages = error_message();

    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
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