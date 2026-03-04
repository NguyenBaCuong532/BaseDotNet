-- =============================================
-- Author:      ThanhMT
-- Create date: 12/12/2025
-- Description: Kỳ thanh toán (dự thu/hóađơn) - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_billing_periods_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid UNIQUEIDENTIFIER,
    @period_code NVARCHAR(100),
    @reference_date NVARCHAR(100),
    @period_name NVARCHAR(100),
    @start_date NVARCHAR(100),
    @end_date NVARCHAR(100),
    @note NVARCHAR(100),
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    DECLARE @reference_date_value DATE = CONVERT(DATE, CONCAT('01/', @reference_date), 103);
    DECLARE @start_date_value DATE = CONVERT(DATE, @start_date, 103);
    DECLARE @end_date_value DATE = CONVERT(DATE, @end_date, 103);
    DECLARE @status INT = 0;
    
    IF(@start_date_value > @end_date_value)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Ngày kết thúc không được phép lớn hơn ngày bắt đầu.'
        GOTO FINALLY;
    END
    
    IF(EXISTS(SELECT TOP 1 1 FROM mas_billing_periods WHERE project_code = @project_code AND (@oid IS NULL OR oid <> @oid) AND NOT (@end_date_value < start_date OR @start_date_value > end_date) ))
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Khoảng thời gian bắt đầu và kết thúc k được giao nhau với các đợt khác.'
        GOTO FINALLY;
    END
    
    IF NOT EXISTS (SELECT 1 FROM mas_billing_periods WHERE Oid = @Oid)
        BEGIN
            SET @Oid = NEWID();
            INSERT INTO mas_billing_periods(oid, project_code, period_code, reference_date, period_name, start_date, end_date, status, note, created_user, created_date, last_modified_by , last_modified_date)
            VALUES(@oid, @project_code, @period_code, @reference_date_value, @period_name, @start_date_value, @end_date_value, @status, @note, @UserId, GETDATE(), @UserId, GETDATE());

            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE mas_billing_periods
            SET
                oid = @oid,
                project_code = @project_code,
                period_code = @period_code,
                reference_date = @reference_date_value,
                period_name = @period_name,
                start_date = @start_date_value,
                end_date = @end_date_value,
                note = @note,
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