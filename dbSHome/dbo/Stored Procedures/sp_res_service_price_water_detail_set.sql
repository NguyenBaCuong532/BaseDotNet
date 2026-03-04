-- =============================================
-- Author:      ThanhMT
-- Create date: 29/08/2025
-- Description: Cấu hình giá dịch vụ - Nước - Chi tiết - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_water_detail_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid UNIQUEIDENTIFIER,
    @par_water_oid UNIQUEIDENTIFIER,
    @config_name NVARCHAR(100) = NULL,
    @start_value DECIMAL(18, 0),
    @end_value DECIMAL(18, 0),
    @unit_price DECIMAL(18, 0),
    @sort_order INT,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    
    IF(@unit_price < 0)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Đơn giá không được nhỏ hơn 0';
        GOTO FINALLY;
    END
        
    IF(@start_value > @end_value)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Giá trị "Bắt đầu" không được nhỏ hơn giá trị "Kết thúc"';
        GOTO FINALLY;
    END
    
    IF(@start_value <= 0 OR @end_value <= 0)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Giá trị "Bắt đầu" và "Kết thúc" không được nhỏ hơn 1';
        GOTO FINALLY;
    END
    
    SELECT TOP 1 *
    INTO #par_water_detail
    FROM par_water_detail
    WHERE
        oid <> @oid
        AND par_water_oid = @par_water_oid
        AND (
                (start_value <= @start_value AND @start_value <= end_value AND end_value <= @end_value) -- 1
                OR (@start_value <= start_value AND start_value <= @end_value AND @end_value <= end_value) -- 2
                OR (@start_value <= start_value AND end_value <= @end_value) -- 3
                OR (start_value <= @start_value AND @end_value <= end_value) -- 4
                OR (start_value <= @start_value AND @end_value IS NULL) -- 5
                OR (@start_value <= start_value AND start_value <= @end_value AND @end_value IS NULL) -- 6
            )
    
    IF EXISTS(SELECT TOP 1 1 FROM #par_water_detail)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Giá trị "Bắt đầu" và "Kết thúc" không được giao nhau';
        GOTO FINALLY;
    END
    
    DECLARE @actions NVARCHAR(50) = 'insert';
    IF NOT EXISTS (SELECT 1 FROM par_water_detail WHERE Oid = @Oid)
        BEGIN
            SET @Oid = NEWID();
            INSERT INTO par_water_detail(oid, par_water_oid, config_name, start_value, end_value, unit_price, sort_order, created_user, created_date, last_modified_by , last_modified_date)
            VALUES(@oid, @par_water_oid, @config_name, @start_value, @end_value, @unit_price, @sort_order, @UserId, GETDATE(), @UserId, GETDATE());

            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE par_water_detail
            SET
                par_water_oid = @par_water_oid,
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
	
    EXEC sp_res_service_price_set_log @UserId, @project_code, @Oid, @actions, 'par_water_detail';
    SET @Messages = @Messages + N' bản ghi thành công';
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