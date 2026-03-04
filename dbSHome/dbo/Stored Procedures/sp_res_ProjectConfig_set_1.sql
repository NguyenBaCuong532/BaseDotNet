-- =============================================
-- Author:      ThanhMT
-- Create date: 22/10/2025
-- Description: Cấu hình chung cho dự án - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_ProjectConfig_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier,
    @config_value VARCHAR(500) = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM par_project_config WHERE Oid = @Oid)
        BEGIN
            
            SET @Valid = 0;
            SET @Messages = N'Không được phép thêm mới cấu hình.';
            GOTO FINALLY;
            
            
            SET @Oid = NEWID();
            INSERT INTO par_project_config(oid, created_by, created_date, last_modified_by , last_modified_date)
            VALUES(@oid, @UserId, GETDATE(), @UserId, GETDATE());

            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE par_project_config
            SET
                config_value = @config_value,
                last_modified_by = @UserId,
                last_modified_date = GETDATE()
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