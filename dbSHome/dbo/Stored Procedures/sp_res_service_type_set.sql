-- =============================================
-- Author:      ThanhMT
-- Create date: 20/01/2026
-- Description: Loại dịch vụ cung cấp cho cư dân - Lưu thông tin chỉnh sửa hoặc thêm mới
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_type_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM service_type WHERE id = @Oid)
        BEGIN
            SET @Oid = NEWID();
--             INSERT INTO service_type(oid, created_by, created_at, updated_by , updated_at)
--             VALUES(@oid, @UserId, GETDATE(), @UserId, GETDATE());

            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
--             UPDATE service_type
--             SET
--                 updated_by = @UserId,
--                 updated_at = GETDATE()
--             WHERE oid = @oid;
		
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