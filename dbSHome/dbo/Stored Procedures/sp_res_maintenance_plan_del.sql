CREATE   PROCEDURE [dbo].[sp_res_maintenance_plan_del]
    @Oid UNIQUEIDENTIFIER,
    @userId NVARCHAR(450) = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM maintenance_plan WHERE oid = @Oid)
    BEGIN
        SELECT valid = 0, message = 'Record not found';
        RETURN;
    END

    UPDATE maintenance_plan
    SET is_delete = 1,
        modify_by = @userId,
        modify_at = GETDATE()
    WHERE oid = @Oid;

    INSERT INTO maintenance_plan_history (plan_oid, action_type, action_by, notes)
    VALUES (@Oid, 'DELETE', @userId, N'Deleted plan');

    SELECT valid = 1, message = 'Success';

END TRY
BEGIN CATCH
    DECLARE @ErrorNum  INT, @ErrorMsg  VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum  = ERROR_NUMBER();
    SET @ErrorMsg  = 'sp_res_maintenance_plan_del ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'MaintenancePlan', 'Delete', @SessionID, @AddlInfo;
    SELECT valid = 0, message = @ErrorMsg;
END CATCH;