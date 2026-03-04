-- =============================================
-- Author:      ThanhMT
-- Create date: 19/08/2025
-- Description: Cấu hình giá dịch vụ chung - Lưu thông tin chỉnh sửa hoặc thêm mới
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_common_set]
    @UserId uniqueidentifier,
    @Oid UNIQUEIDENTIFIER,
    @project_code NVARCHAR(100),
    @par_residence_type_oid UNIQUEIDENTIFIER,
    @service_name NVARCHAR(100),
    @unit_measure NVARCHAR(100),
    @value DECIMAL(18, 0),
    @effective_date NVARCHAR(100),
    @expiry_date NVARCHAR(100),
    @tax_percent DECIMAL(18, 0),
    @is_active BIT,
    @note NVARCHAR(100),
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    DECLARE @effective_date_value DATE = CONVERT(DATE, @effective_date, 103);
    DECLARE @expiry_date_value DATE = CONVERT(DATE, @expiry_date, 103);
    DECLARE @actions NVARCHAR(50);
    
    IF(@effective_date IS NULL OR @effective_date_value IS NULL)
        BEGIN
            SET @Messages = N'Ngày có hiệu lực không được để trống';
            SET @Valid = 0;
            GOTO FINALLY;
        END
    
    IF(@value < 0)
        BEGIN
            SET @Messages = N'Đơn giá không được nhỏ hơn 0';
            SET @Valid = 0;
            GOTO FINALLY;
        END
    
    IF(@effective_date_value > @expiry_date_value)
        BEGIN
            SET @Messages = N'Ngày bắt đầu không được lớn hơn ngày kết thúc';
            SET @Valid = 0;
            GOTO FINALLY;
        END
    
    SELECT a.*
    INTO #par_common
    FROM par_common a
    WHERE
        a.project_code = @project_code
        AND a.par_residence_type_oid = @par_residence_type_oid
        AND ((a.effective_date <= @effective_date_value AND @effective_date_value <= a.expiry_date)
            OR (@effective_date_value <= a.effective_date AND a.expiry_date <= @expiry_date_value)
            OR (@effective_date_value <= a.effective_date AND @expiry_date_value >= a.expiry_date)
            OR (a.expiry_date <= @expiry_date_value AND @expiry_date_value <= a.expiry_date)
            OR (((@expiry_date_value IS NULL AND a.expiry_date IS NULL) OR (a.expiry_date = @expiry_date_value)) AND (@expiry_date_value IS NULL AND a.expiry_date IS NULL) OR (@expiry_date_value = a.expiry_date)))
    
    DECLARE @par_common_count INT = (SELECT COUNT(*) FROM #par_common);
    IF(@par_common_count >= 2  OR EXISTS(SELECT TOP 1 1 FROM #par_common WHERE @oid IS NULL OR @oid <> oid))
        BEGIN
            SET @Messages = N'Đã tồn tại cấu hình với khoảng thời gian đã nhập';
            SET @Valid = 0;
            GOTO FINALLY;
        END
    
    IF NOT EXISTS (SELECT 1 FROM par_common WHERE Oid = @Oid)
        BEGIN
            SET @Oid = NEWID();
            INSERT INTO par_common(Oid, project_code, par_residence_type_oid, service_name, unit_measure, value, effective_date, expiry_date, tax_percent, is_active, note, created_user, created_date, last_modified_by , last_modified_date)
            valueS(@Oid, @project_code, @par_residence_type_oid, @service_name, @unit_measure, @value, @effective_date_value, @expiry_date_value, @tax_percent, @is_active, @note, @UserId, GETDATE(), @UserId, GETDATE());

            SET @actions = 'insert';
            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE par_common
            SET
                project_code = @project_code,
                par_residence_type_oid = @par_residence_type_oid,
                service_name = @service_name,
                unit_measure = @unit_measure,
                value = @value,
                effective_date = @effective_date_value,
                expiry_date = @expiry_date_value,
                tax_percent = @tax_percent,
                is_active = @is_active,
                note = @note,
                last_modified_by = @UserId,
                last_modified_date = GETDATE()
            WHERE Oid = @Oid;
		
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
        id = @Oid,
        Valid = @Valid,
        Messages = @Messages