-- =============================================
-- Author:      Agent
-- Create date: 2026-01-28
-- Description: Delete Work Order (soft delete)
-- =============================================
CREATE   PROCEDURE [dbo].[sp_res_workorder_del]
    @Oid UNIQUEIDENTIFIER,
    @UserId NVARCHAR(450) = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @Message NVARCHAR(500) = N'';
    DECLARE @Valid BIT = 1;
    DECLARE @CurrentStatus INT;

    -- Check if work order exists
    IF NOT EXISTS (SELECT 1 FROM maintenance_work_order WHERE oid = @Oid)
    BEGIN
        SET @Message = N'Phiếu bảo trì không tồn tại';
        SET @Valid = 0;
        SELECT @Valid AS valid, @Message AS [message];
        RETURN;
    END

    -- Get current status
    SELECT @CurrentStatus = status
    FROM maintenance_work_order
    WHERE oid = @Oid;

    -- Only allow delete for scheduled work orders (status = 0)
    IF @CurrentStatus <> 0
    BEGIN
        SET @Message = N'Chỉ có thể xóa phiếu bảo trì ở trạng thái "Đã lên lịch"';
        SET @Valid = 0;
        SELECT @Valid AS valid, @Message AS [message];
        RETURN;
    END

    -- Soft delete
    UPDATE maintenance_work_order
    SET is_delete = 1,
        updated_at = GETDATE(),
        updated_by = @UserId
    WHERE oid = @Oid;

    -- Log history
    INSERT INTO maintenance_work_order_history (work_order_oid, action_type, old_status, new_status, notes, action_by)
    VALUES (@Oid, 'deleted', @CurrentStatus, NULL, N'Xóa phiếu bảo trì', @UserId);

    SET @Message = N'Xóa phiếu bảo trì thành công';
    SELECT 1 AS valid, @Message AS [message];

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_workorder_del ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'WorkOrder',
                          'Delete',
                          @SessionID,
                          @AddlInfo;

    SELECT 0 AS valid, N'Có lỗi xảy ra: ' + ERROR_MESSAGE() AS [message];
END CATCH;