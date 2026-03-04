-- =============================================
-- Author:      ThanhMT
-- Create date: 06/10/2025
-- Description: Quản lý số lượng chỗ đỗ xe - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_parking_space_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid UNIQUEIDENTIFIER,
    @vehicle_type INT,
    @space_count INT,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    IF EXISTS(SELECT 1 FROM par_parking_space WHERE @Oid IS NULL AND vehicle_type = @vehicle_type AND project_code = @project_code)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Mỗi loại phương tiện chỉ được cấu hình 1 lần. Vui lòng điều chỉnh lại số lượng';
        GOTO FINALLY;
    END
    
    IF(@space_count <= 0)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'"Tổng số lượng" phải lớn hơn 0';
        GOTO FINALLY;
    END
    
    
    IF NOT EXISTS (SELECT 1 FROM par_parking_space WHERE Oid = @Oid)
        BEGIN
            SET @Oid = NEWID();
            INSERT INTO par_parking_space(oid, project_code, vehicle_type, space_count, created_user, created_date, last_modified_by , last_modified_date)
            VALUES(@oid, @project_code, @vehicle_type, @space_count, @UserId, GETDATE(), @UserId, GETDATE());

            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE par_parking_space
            SET
                oid = @oid,
                vehicle_type = @vehicle_type,
                space_count = @space_count,
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