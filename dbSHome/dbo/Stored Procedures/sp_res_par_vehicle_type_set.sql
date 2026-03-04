-- =============================================
-- Author:      ThanhMT
-- Create date: 14/11/2025
-- Description: Gom nhóm các loại xe để cấu hình tính số lượng - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_par_vehicle_type_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid UNIQUEIDENTIFIER,
    @config_name NVARCHAR(100),
    @sort_order INT,
    @block_pricing bit,
    @vehicle_type_id NVARCHAR(100)
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM par_vehicle_type WHERE Oid = @Oid)
        BEGIN
            SET @Oid = NEWID();
            INSERT INTO par_vehicle_type(oid, project_code, config_name, block_pricing, sort_order, vehicle_type_id, created_user, created_date, last_modified_by , last_modified_date)
            VALUES(@oid, @project_code, @config_name, @block_pricing, @sort_order, @vehicle_type_id, @UserId, GETDATE(), @UserId, GETDATE());

            SET @Messages = N'Thêm mới';
        END
    ELSE
        BEGIN
            UPDATE par_vehicle_type
            SET
                config_name = @config_name,
                block_pricing = @block_pricing,
                sort_order = @sort_order,
                vehicle_type_id = @vehicle_type_id,
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