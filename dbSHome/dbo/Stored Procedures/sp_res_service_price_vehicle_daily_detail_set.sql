-- =============================================
-- Author:      ThanhMT
-- Create date: 21/08/2025
-- Description: Cấu hình giá dịch vụ - Gửi xe ngày block - Lưu thông tin chỉnh sửa hoặc thêm mới
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_vehicle_daily_detail_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid UNIQUEIDENTIFIER,
    @par_vehicle_daily_oid UNIQUEIDENTIFIER,
    @par_vehicle_daily_type_oid UNIQUEIDENTIFIER,
    @config_name NVARCHAR(100),
    @start_value INT,
    @end_value INT,
    @start_time NVARCHAR(100),
    @end_time NVARCHAR(100),
    @unit_price NVARCHAR(100),
    @sort_order INT,
    @note NVARCHAR(100),
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    DECLARE @actions NVARCHAR(50);
    IF NOT EXISTS (SELECT 1 FROM par_vehicle_daily_detail WHERE oid = @oid)
        BEGIN
            SET @oid = NEWID();
            INSERT INTO par_vehicle_daily_detail(oid, par_vehicle_daily_oid, par_vehicle_daily_type_oid, config_name, start_value, end_value, start_time, end_time, unit_price, sort_order, note, created_user, created_date, last_modified_by, last_modified_date)
            VALUES(@oid, @par_vehicle_daily_oid, @par_vehicle_daily_type_oid, @config_name, @start_value, @end_value, @start_time, @end_time, @unit_price, @sort_order, @note, @UserId, GETDATE(), @UserId, GETDATE());

            SET @actions = 'insert';
            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE par_vehicle_daily_detail
            SET
                oid = @oid,
                par_vehicle_daily_oid = @par_vehicle_daily_oid,
                par_vehicle_daily_type_oid = @par_vehicle_daily_type_oid,
                config_name = @config_name,
                start_value = @start_value,
                end_value = @end_value,
                start_time = @start_time,
                end_time = @end_time,
                unit_price = @unit_price,
                sort_order = @sort_order,
                note = @note,
                last_modified_by = @UserId,
                last_modified_date = GETDATE()
            WHERE oid = @oid;
		
            SET @actions = 'update';
            SET @Messages = N'Cập nhật';
        END
	
    EXEC sp_res_service_price_set_log @UserId, @project_code, @Oid, @actions, 'par_common';
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