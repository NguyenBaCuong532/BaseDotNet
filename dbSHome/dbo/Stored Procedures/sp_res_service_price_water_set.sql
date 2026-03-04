-- =============================================
-- Author:      ThanhMT
-- Create date: 29/08/2025
-- Description: Cấu hình giá dịch vụ - Nước - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_water_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid UNIQUEIDENTIFIER,
    @par_residence_type_oid UNIQUEIDENTIFIER,
    @par_service_price_type_oid UNIQUEIDENTIFIER,
    @effective_date VARCHAR(50),
    @expiry_date VARCHAR(50),
    @vat DECIMAL(18, 0),
    @environmental_fee DECIMAL(18, 0),
    @env_protection_tax DECIMAL(18, 0),
    @is_active BIT,
    @note NVARCHAR(100),
    @is_copy BIT = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    DECLARE @effective_date_value DATETIME = IIF(@effective_date IS NULL, NULL, CONVERT(DATE, @effective_date, 103));
    DECLARE @expiry_date_value DATETIME = IIF(@expiry_date IS NULL, NULL, CONVERT(DATE, @expiry_date, 103));
    
    DECLARE @water_oid UNIQUEIDENTIFIER = @oid;
    IF(@is_copy = 1)
        SET @oid = NULL;
    
    IF(@effective_date_value IS NULL)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Ngày bắt đầu có hiệu lực không được trống';
        GOTO FINALLY;
    END
    
    
    SELECT TOP 1 *
    INTO #par_water_check_date
    FROM par_water
    WHERE
        (@oid IS NULL OR oid <> @oid)
        AND project_code = @project_code
        AND par_residence_type_oid = @par_residence_type_oid
        AND (
                (effective_date IS NULL OR @expiry_date_value IS NULL OR effective_date <= @expiry_date_value)
                AND (expiry_date IS NULL OR @effective_date_value IS NULL OR expiry_date >= @effective_date_value)
            );
        
--         AND ((effective_date <= @effective_date_value AND @effective_date_value <= expiry_date AND expiry_date <= @expiry_date_value) -- 1
--         OR (@effective_date_value <= effective_date AND effective_date <= @expiry_date_value AND @expiry_date_value <= expiry_date) -- 2
--         OR (@effective_date_value <= effective_date AND effective_date <= @expiry_date_value) -- 3
--         OR (effective_date <= @effective_date_value AND @expiry_date_value <= effective_date) -- 4
--         OR (effective_date <= @effective_date_value AND effective_date IS NULL) -- 5
--         OR (@effective_date_value <= effective_date AND effective_date IS NULL) -- 6
--         OR (
--               ((@effective_date_value IS NULL AND effective_date IS NULL) OR (@effective_date_value IS NOT NULL AND @effective_date_value = effective_date))
--               AND ((@expiry_date_value IS NULL AND expiry_date IS NULL) OR (@expiry_date_value IS NOT NULL AND @expiry_date_value = expiry_date)))
--            ) -- 7
    
    IF EXISTS(SELECT TOP 1 1 FROM #par_water_check_date)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Ngày bắt đầu và và kết thúc hiệu lực không được giao nhau';
        GOTO FINALLY;
    END
    
    DECLARE @actions NVARCHAR(50) = 'insert';
    IF NOT EXISTS (SELECT 1 FROM par_water WHERE Oid = @Oid)
        BEGIN
            SET @Oid = NEWID();
            INSERT INTO par_water(oid, project_code, par_residence_type_oid, par_service_price_type_oid, effective_date, expiry_date, env_protection_tax, is_active, note, created_user, created_date, last_modified_by , last_modified_date,vat,environmental_fee)
            VALUES(@oid, @project_code, @par_residence_type_oid, @par_service_price_type_oid, @effective_date_value, @expiry_date_value, @env_protection_tax, @is_active, @note, @UserId, GETDATE(), @UserId, GETDATE(),@vat,@environmental_fee);

            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE par_water
            SET
                par_residence_type_oid = @par_residence_type_oid,
                par_service_price_type_oid = @par_service_price_type_oid,
                effective_date = @effective_date_value,
                expiry_date = @expiry_date_value,
                env_protection_tax = @env_protection_tax,
                is_active = @is_active,
                note = @note,
                last_modified_by = @UserId,
                last_modified_date = GETDATE(),
				vat = @vat,
				environmental_fee =@environmental_fee
            WHERE oid = @oid;
		
            SET @actions = 'update';
            SET @Messages = N'Cập nhật';
        END
	
    IF(@is_copy = 1)
    BEGIN
        INSERT INTO par_water_detail(oid, par_water_oid, config_name, start_value, end_value, unit_price, sort_order, created_user, created_date, last_modified_by, last_modified_date)
        SELECT NEWID(), @Oid, config_name, start_value, end_value, unit_price, sort_order, @UserId, GETDATE(), @UserId, GETDATE()
        FROM par_water_detail
        WHERE par_water_oid = @water_oid
    END
    
    EXEC sp_res_service_price_set_log @UserId, @project_code, @Oid, @actions, 'par_water';
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