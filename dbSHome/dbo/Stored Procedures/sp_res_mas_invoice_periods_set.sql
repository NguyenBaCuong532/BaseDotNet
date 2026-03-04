-- =============================================
-- Author:      ThanhMT
-- Create date: 19/11/2025
-- Description: Kỳ hóa đơn - Lấy thông tin thêm mới hoặc chỉnh sửa
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_mas_invoice_periods_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier = NULL,
    @name NVARCHAR(100) = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    IF(@oid IS NULL)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Không được phép thêm mới. Kỳ hóa đơn sẽ tự động tạo khi khóa kỳ dự thu.';
        GOTO FINALLY;
    END


    UPDATE mas_invoice_periods
    SET
        name = @name,
        last_updated_by = @UserId,
        last_updated_date = GETDATE()
    WHERE oid = @oid;
	
    SET @Messages = @Messages + N' bản ghi thành công'
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

FINALLY:
    SELECT
        id = @oid,
        Valid = @Valid,
        Messages = @Messages