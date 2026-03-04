-- =============================================
-- Author:      ThanhMT
-- Create date: 17/10/2025
-- Description: Cấu hình thứ tự ưu tiên thanh toán dịch vụ căn hộ - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_payment_priority_configs_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid UNIQUEIDENTIFIER,
    @service_name NVARCHAR(100) = NULL,
    @priority_order INT,
    @is_collect_fee BIT,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM mas_payment_priority_configs WHERE Oid = @Oid)
        BEGIN
            SET @Oid = NEWID();
            INSERT INTO mas_payment_priority_configs(oid, priority_order, is_collect_fee, created_by, created_time, last_modified_by , last_modified_time)
            VALUES(NEWID(), @priority_order, @is_collect_fee, @UserId, GETDATE(), @UserId, GETDATE());

            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE mas_payment_priority_configs
            SET
                priority_order = @priority_order,
                is_collect_fee = @is_collect_fee,
                last_modified_by = @UserId,
                last_modified_time = GETDATE()
            WHERE oid = @oid;
		
            SET @Messages = N'Cập nhật';
        END
	
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