-- =============================================
-- Author:      ThanhMT
-- Create date: 20/10/2025
-- Description: Kỳ tính dự thu - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_RevenuePeriods_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid UNIQUEIDENTIFIER,
    @period_code NVARCHAR(100),
    @period_name NVARCHAR(100),
    @start_date NVARCHAR(50),
    @end_date NVARCHAR(50),
    @locked BIT,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    DECLARE @start_date_value DATETIME = CONVERT(DATE, @start_date, 103);
    DECLARE @end_date_value DATETIME = CONVERT(DATE, @end_date, 103);
    
    IF(EXISTS(SELECT TOP 1 1 FROM mas_revenue_periods WHERE period_code = @period_code AND (@oid IS NULL OR oid <> @oid)))
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Mã đợt đã tồn tại. Vui lòng kiểm tra lại.'
        GOTO FINALLY;
    END
    
    IF(@start_date_value > @end_date_value)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Ngày kết thúc không được phép lớn hơn ngày bắt đầu.'
        GOTO FINALLY;
    END
    
    IF(EXISTS(SELECT TOP 1 1 FROM mas_revenue_periods WHERE project_code = @project_code AND (@oid IS NULL OR oid <> @oid) AND NOT (@end_date_value < start_date OR @start_date_value > end_date) ))
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Khoảng thời gian bắt đầu và kết thúc k được giao nhau với các đợt khác.'
        GOTO FINALLY;
    END
    
    IF NOT EXISTS (SELECT 1 FROM mas_revenue_periods WHERE Oid = @Oid)
        BEGIN
            SET @Oid = NEWID();
            INSERT INTO mas_revenue_periods(oid, project_code, period_code, period_name, start_date, end_date, locked, created_by, created_date, last_updated_by , last_updated_date)
            VALUES(@oid, @project_code, @period_code, @period_name, @start_date_value, @end_date_value, @locked, @UserId, GETDATE(), @UserId, GETDATE());

            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE mas_revenue_periods
            SET
                period_code = @period_code,
                locked = @locked,
                period_name = @period_name,
                start_date = @start_date_value,
                end_date = @end_date_value,
                last_updated_by = @UserId,
                last_updated_date = GETDATE()
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