-- =============================================
-- Author:      ThanhMT
-- Create date: 22/10/2025
-- Description: Cấu hình chung cho dự án - Gán giá trị mặc định cho các cấu hình nếu chưa có cáu hình hoặc k có tùy chỉnh của dự án
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_ProjectConfig_set_default_value]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @config_code VARCHAR(500) = NULL,
    @config_value VARCHAR(500) = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    
    -- Cập nhật lại giá trị vào bảng thông tin mặc định
    UPDATE a
    SET a.config_value_default = @config_value
    FROM par_project_config_default a
    WHERE a.config_code = @config_code
    
    SET @Messages = + N'Thực hiện thành công'
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
        Valid = @Valid,
        Messages = @Messages