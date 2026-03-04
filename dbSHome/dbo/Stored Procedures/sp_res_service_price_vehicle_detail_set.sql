-- =============================================
-- Author:      ThanhMT
-- Create date: 27/08/2025
-- Description: Cấu hình giá dịch vụ - Gửi xe tháng - chi tiết - Lưu thông tin chỉnh sửa hoặc thêm mới
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_vehicle_detail_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid UNIQUEIDENTIFIER,
    @par_vehicle_oid UNIQUEIDENTIFIER,
    @par_vehicle_type_oid UNIQUEIDENTIFIER,
    @config_name NVARCHAR(100),
    @start_value DECIMAL(18, 0),
    @end_value DECIMAL(18, 0),
    @unit_price DECIMAL(18, 0),
    @sort_order INT,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(MAX) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    
    -- Tìm tất cả các khoảng giao với giá trị nhập vào
    SELECT a.*
    INTO #par_vehicle_detail
    FROM par_vehicle_detail a
    WHERE
        a.par_vehicle_oid = @par_vehicle_oid
        AND a.par_vehicle_type_oid = @par_vehicle_type_oid
        AND ((a.start_value <= @start_value AND a.end_value >= @start_value)
        OR (a.start_value >= @start_value AND a.end_value <= @end_value)
        OR (a.start_value <= @end_value AND a.end_value >= @end_value)
        OR (a.start_value <= @start_value AND a.end_value >= @end_value))
    
    DECLARE @par_vehicle_detail_count INT = (SELECT COUNT(*) FROM #par_vehicle_detail);
    IF(@par_vehicle_detail_count > 1)
        BEGIN
            SET @Valid = 0;
            SET @Messages = N'1. Giá trị không được giao nhau so với giá trị đã nhập trước đó';
            GOTO FINALLY;
        END
        
    -- Nếu tồn tại chỉ duy nhất 1 bản ghi bị giao thì kiểm tra tiếp là thêm mới hay sửa
    IF(@par_vehicle_detail_count = 1 AND (@oid IS NULL OR (@oid IS NOT NULL AND EXISTS(SELECT TOP 1 1 FROM #par_vehicle_detail WHERE oid <> @oid))))
        BEGIN
            SET @Messages = IIF(@oid IS NULL, N'"Thêm mới"', N'"Sửa"');
            SET @Valid = 0;
            SET @Messages = CONCAT(@Messages, N': Giá trị không được giao nhau so với giá trị đã nhập trước đó');
            GOTO FINALLY;
        END
    
    IF(@unit_price < 0)
        BEGIN
            SET @Valid = 0;
            SET @Messages = N'Đơn giá không được nhỏ hơn 0';
            GOTO FINALLY;
        END
    
    DECLARE @actions NVARCHAR(50) = 'insert';
    DECLARE @VehicleTypeId NVARCHAR(50) = (SELECT TOP 1 vehicle_type_id FROM par_vehicle_type WHERE oid = @par_vehicle_type_oid);
    IF NOT EXISTS (SELECT 1 FROM par_vehicle_detail WHERE Oid = @Oid)
        BEGIN
            SET @Oid = NEWID();
            INSERT INTO par_vehicle_detail(oid, par_vehicle_oid, par_vehicle_type_oid, VehicleTypeId, config_name, start_value, end_value, unit_price, sort_order, created_user, created_date, last_modified_by , last_modified_date)
            VALUES(@oid, @par_vehicle_oid, @par_vehicle_type_oid, @VehicleTypeId, @config_name, @start_value, @end_value, @unit_price, @sort_order, @UserId, GETDATE(), @UserId, GETDATE());

            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE par_vehicle_detail
            SET
                oid = @oid,
                par_vehicle_oid = @par_vehicle_oid,
                par_vehicle_type_oid = @par_vehicle_type_oid,
                VehicleTypeId = @VehicleTypeId,
                config_name = @config_name,
                start_value = @start_value,
                end_value = @end_value,
                unit_price = @unit_price,
                sort_order = @sort_order,
                last_modified_by = @UserId,
                last_modified_date = GETDATE()
            WHERE oid = @oid;
		
            SET @actions = 'update';
            SET @Messages = N'Cập nhật';
        END
	
    EXEC sp_res_service_price_set_log @UserId, @project_code, @Oid, @actions, 'par_vehicle_detail';
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