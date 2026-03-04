-- =============================================
-- Author:      ThanhMT
-- Create date: 21/08/2025
-- Description: Cấu hình giá dịch vụ - Gửi xe ngày - Lưu thông tin chỉnh sửa hoặc thêm mới
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_vehicle_daily_set]
    @UserId uniqueidentifier = NULL,
    @oid UNIQUEIDENTIFIER,
    @project_code NVARCHAR(100),
    @par_vehicle_type_oid UNIQUEIDENTIFIER = NULL,
    @effective_date NVARCHAR(50),
    @expiry_date NVARCHAR(50),
    @is_active BIT,
    @note NVARCHAR(100),
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    DECLARE @actions NVARCHAR(50);
    
    DECLARE @effective_date_value DATETIME = IIF(@effective_date IS NULL OR TRIM(@effective_date) = '', NULL, CONVERT(DATETIME, @effective_date, 103));
    DECLARE @expiry_date_value DATETIME = IIF(@expiry_date IS NULL OR TRIM(@expiry_date) = '', NULL, CONVERT(DATETIME, @expiry_date, 103));
    IF(@oid IS NOT NULL AND (SELECT TOP 1 IIF(@par_vehicle_type_oid = par_vehicle_type_oid, 0, 1) FROM par_vehicle_daily WHERE Oid = @oid) = 1)
        BEGIN
            DECLARE @IsBlockPricing BIT = (SELECT TOP 1 b.block_pricing
                                          FROM
                                              par_vehicle_daily a
                                              LEFT JOIN par_vehicle_type b ON b.oid = a.par_vehicle_type_oid
                                          WHERE a.oid = @Oid)
            IF(NOT EXISTS(SELECT TOP 1 1 FROM par_vehicle_type WHERE oid = @par_vehicle_type_oid AND block_pricing = @IsBlockPricing))
                BEGIN
                    SET @Valid = 0;
                    SET @Messages = N'Chỉ được thay đổi loại phương tiện có cùng kiểu tính "block" hoặc "thời gian"';
                    GOTO FINALLY;
                END
        END
    
    IF NOT EXISTS (SELECT 1 FROM par_vehicle_daily WHERE Oid = @Oid)
        BEGIN
            SET @Oid = NEWID();
            INSERT INTO par_vehicle_daily(Oid, project_code, par_vehicle_type_oid, effective_date, expiry_date, is_active, note, created_user, created_date, last_modified_by , last_modified_date)
            VALUES(@Oid, @project_code, @par_vehicle_type_oid, @effective_date_value, @expiry_date_value, @is_active, @note, @UserId, GETDATE(), @UserId, GETDATE());

            SET @actions = 'insert';
            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE par_vehicle_daily
            SET
                project_code = @project_code,
--                 par_vehicle_type_oid = @par_vehicle_type_oid,
                effective_date = @effective_date_value,
                expiry_date = @expiry_date_value,
                is_active = @is_active,
                note = @note,
                last_modified_by = @UserId,
                last_modified_date = GETDATE()
            WHERE Oid = @Oid;
		
            SET @actions = 'update';
            SET @Messages = N'Cập nhật';
        END
	
    EXEC sp_res_service_price_set_log @UserId, @project_code, @Oid, @actions, 'par_vehicle_daily';
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
        id = @Oid,
        Valid = @Valid,
        Messages = @Messages