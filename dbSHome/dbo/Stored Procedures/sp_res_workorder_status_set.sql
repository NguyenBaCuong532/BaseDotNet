-- =============================================
-- Author:      Agent
-- Create date: 2026-01-28
-- Description: Change Work Order status
-- =============================================
CREATE   PROCEDURE [dbo].[sp_res_workorder_status_set]
    @Oid UNIQUEIDENTIFIER,
    @NewStatus INT,
    @Notes NVARCHAR(MAX) = NULL,
    @UserId NVARCHAR(450) = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @Message NVARCHAR(500) = N'';
    DECLARE @Valid BIT = 1;
    DECLARE @OldStatus INT;

    -- Check if work order exists
    IF NOT EXISTS (SELECT 1 FROM maintenance_work_order WHERE oid = @Oid AND is_delete = 0)
    BEGIN
        SET @Message = N'Phiếu bảo trì không tồn tại';
        SET @Valid = 0;
        SELECT @Valid AS valid, @Message AS [message];
        RETURN;
    END

    -- Get current status
    SELECT @OldStatus = status
    FROM maintenance_work_order
    WHERE oid = @Oid;

    -- Validate status transition
    -- 0: Scheduled -> 1: In Progress, 4: Cancelled
    -- 1: In Progress -> 2: Completed, 3: Overdue
    -- 2: Completed -> (no further transitions)
    -- 3: Overdue -> 2: Completed
    -- 4: Cancelled -> (no further transitions)
    
    IF @OldStatus = @NewStatus
    BEGIN
        SET @Message = N'Trạng thái không thay đổi';
        SET @Valid = 0;
        SELECT @Valid AS valid, @Message AS [message];
        RETURN;
    END

    IF @OldStatus = 2 OR @OldStatus = 4
    BEGIN
        SET @Message = N'Không thể thay đổi trạng thái của phiếu đã hoàn thành hoặc đã hủy';
        SET @Valid = 0;
        SELECT @Valid AS valid, @Message AS [message];
        RETURN;
    END

    -- Update status
    UPDATE maintenance_work_order
    SET status = @NewStatus,
        actual_start = CASE WHEN @NewStatus = 1 AND actual_start IS NULL THEN GETDATE() ELSE actual_start END,
        actual_end = CASE WHEN @NewStatus = 2 THEN GETDATE() ELSE actual_end END,
        completion_notes = CASE WHEN @NewStatus = 2 AND @Notes IS NOT NULL THEN @Notes ELSE completion_notes END,
        updated_at = GETDATE(),
        updated_by = @UserId
    WHERE oid = @Oid;

    -- Log history
    DECLARE @ActionType NVARCHAR(50);
    SET @ActionType = CASE @NewStatus
        WHEN 1 THEN 'started'
        WHEN 2 THEN 'completed'
        WHEN 3 THEN 'overdue'
        WHEN 4 THEN 'cancelled'
        ELSE 'status_changed'
    END;

    INSERT INTO maintenance_work_order_history (work_order_oid, action_type, old_status, new_status, notes, action_by)
    VALUES (@Oid, @ActionType, @OldStatus, @NewStatus, @Notes, @UserId);

    -- Build success message
    SET @Message = CASE @NewStatus
        WHEN 1 THEN N'Đã bắt đầu thực hiện phiếu bảo trì'
        WHEN 2 THEN N'Đã hoàn thành phiếu bảo trì'
        WHEN 3 THEN N'Phiếu bảo trì đã quá hạn'
        WHEN 4 THEN N'Đã hủy phiếu bảo trì'
        ELSE N'Cập nhật trạng thái thành công'
    END;

    SELECT 1 AS valid, @Message AS [message];

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_workorder_status_set ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'WorkOrder',
                          'SetStatus',
                          @SessionID,
                          @AddlInfo;

    SELECT 0 AS valid, N'Có lỗi xảy ra: ' + ERROR_MESSAGE() AS [message];
END CATCH;