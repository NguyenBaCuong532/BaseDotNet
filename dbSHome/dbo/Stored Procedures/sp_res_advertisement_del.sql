CREATE PROCEDURE [dbo].[sp_res_advertisement_del]
    @id UNIQUEIDENTIFIER,
    @user_id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @current_dt DATETIME = GETUTCDATE();

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM advertisement_info WHERE id = @id AND is_deleted = 0)
        BEGIN
            SELECT 0 AS isValid, 'Advertisement not found' AS message;
            RETURN;
        END

        -- Soft delete
        UPDATE advertisement_info
        SET is_deleted = 1,
            updated_dt = @current_dt,
            updated_by = @user_id
        WHERE id = @id;

        SELECT 1 AS isValid, 'Advertisement deleted successfully' AS message;
    END TRY
    BEGIN CATCH
        SELECT 0 AS isValid, ERROR_MESSAGE() AS message;
    END CATCH
END
GO