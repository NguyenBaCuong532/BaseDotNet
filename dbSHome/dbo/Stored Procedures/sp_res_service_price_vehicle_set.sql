-- =============================================
-- Author:      ThanhMT
-- Create date: 22/08/2025
-- Description: Cấu hình giá dịch vụ - Gửi xe tháng - Lưu thông tin chỉnh sửa hoặc thêm mới
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_vehicle_set]
    @UserId uniqueidentifier = NULL,
    @oid UNIQUEIDENTIFIER,
    @project_code NVARCHAR(100),
    @par_residence_type_oid UNIQUEIDENTIFIER,
    @effective_date NVARCHAR(50),
    @expiry_date NVARCHAR(50),
    @register_value INT = 0,
    @register_by_day BIT = 0,
    @cancel_value INT = 0,
    @cancel_by_day BIT = 0,
    @is_active BIT,
    @note NVARCHAR(100),
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(200) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    DECLARE @effective_date_value DATETIME = IIF(@effective_date IS NULL OR TRIM(@effective_date) = '', NULL, CONVERT(DATE, @effective_date, 103));
    DECLARE @expiry_date_value DATETIME = IIF(@expiry_date IS NULL OR TRIM(@expiry_date) = '', NULL, CONVERT(DATE, @expiry_date, 103));
    DECLARE @actions NVARCHAR(50) = 'insert';
    
    IF NOT EXISTS (SELECT 1 FROM par_vehicle WHERE Oid = @oid)
        BEGIN
            SET @oid = NEWID();
            INSERT INTO par_vehicle(oid, project_code, par_residence_type_oid, effective_date, expiry_date, register_by_day, register_value, cancel_by_day, cancel_value, is_active, note, created_user, created_date, last_modified_by , last_modified_date)
            VALUES(@oid, @project_code, @par_residence_type_oid, @effective_date_value, @expiry_date_value, @register_by_day, @register_value, @cancel_by_day, @cancel_value, @is_active, @note, @UserId, GETDATE(), @UserId, GETDATE());

            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE par_vehicle
            SET
                project_code = @project_code,
                par_residence_type_oid = @par_residence_type_oid,
                effective_date = @effective_date_value,
                expiry_date = @expiry_date_value,
                register_by_day = @register_by_day,
                register_value = @register_value,
                cancel_by_day = @cancel_by_day,
                cancel_value = @cancel_value,
                is_active = @is_active,
                note = @note,
                last_modified_by = @UserId,
                last_modified_date = GETDATE()
            WHERE Oid = @oid;
		
            SET @actions = 'update';
            SET @Messages = N'Cập nhật';
        END
	
    EXEC sp_res_service_price_set_log @UserId, @project_code, @Oid, @actions, 'par_vehicle';
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