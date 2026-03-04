-- =============================================
-- Author:      ThanhMT
-- Create date: 19/01/2026
-- Description: Phân công trưởng nhóm và các thành viên xử lý nhóm yêu cầu hỗ trợ - Lưu thông tin chỉnh sửa hoặc thêm mới
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_support_service_users_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid UNIQUEIDENTIFIER,
    @service_type_oid UNIQUEIDENTIFIER,
    @support_service_oid UNIQUEIDENTIFIER,
    @user_oid UNIQUEIDENTIFIER,
    @service_role NVARCHAR(100),
    @is_active BIT,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    
    SELECT TOP 1 *
    INTO #support_service_users_check
    FROM support_service_users
    WHERE
        (@oid IS NULL OR oid <> @oid)
        AND support_service_oid = @support_service_oid
        AND is_active = 1
        AND service_role = 'leader'
        AND @service_role = 'leader'
        
    IF EXISTS (SELECT TOP 1 1 FROM #support_service_users_check)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Đã có cấu hình người phụ trách chính cho dịch vụ này. Vui lòng kiểm tra lại !';
        GOTO FINALLY;
    END
    
    SELECT TOP 1 *
    INTO #support_service_users_check_2
    FROM support_service_users
    WHERE
        (@oid IS NULL OR oid <> @oid)
        AND support_service_oid = @support_service_oid
        AND user_oid = @user_oid
    
    IF EXISTS (SELECT TOP 1 1 FROM #support_service_users_check_2)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Nhân viên đã được gán trước đó. Vui lòng kiểm tra lại !';
        GOTO FINALLY;
    END
    
    IF NOT EXISTS (SELECT 1 FROM support_service_users WHERE Oid = @Oid)
        BEGIN
            SET @Oid = NEWID();
            INSERT INTO support_service_users(oid, support_service_oid, user_oid, service_role, is_active, created_by, created_at, updated_by , updated_at)
            VALUES(@oid, @support_service_oid, @user_oid, @service_role, @is_active, @UserId, GETDATE(), @UserId, GETDATE());

            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE support_service_users
            SET
                support_service_oid = @support_service_oid,
                user_oid = @user_oid,
                service_role = @service_role,
                is_active = @is_active,
                updated_by = @UserId,
                updated_at = GETDATE()
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