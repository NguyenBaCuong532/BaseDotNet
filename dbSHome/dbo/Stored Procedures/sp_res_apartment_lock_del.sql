
CREATE PROCEDURE dbo.sp_res_apartment_lock_del
    @userId NVARCHAR(450),
    @oid UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        SET @userId = NULLIF(LTRIM(RTRIM(@userId)), N'');

        IF (@userId IS NULL OR @oid IS NULL)
        BEGIN
            SELECT CAST(0 AS BIT) AS valid, N'Dữ liệu không hợp lệ' AS [messages];
            RETURN;
        END

        DECLARE @status INT;

        SELECT @status = l.status
        FROM dbo.apartment_lock l
        WHERE l.oid = @oid AND l.is_deleted = 0;

        IF (@status IS NULL)
        BEGIN
            SELECT CAST(0 AS BIT) AS valid, N'Không tìm thấy thông tin trong hệ thống!' AS [messages];
            RETURN;
        END

        IF (@status = 1)
        BEGIN
            SELECT CAST(0 AS BIT) AS valid, N'Khóa đang hoạt động, cần khóa lại trước khi xóa!' AS [messages];
            RETURN;
        END

        UPDATE dbo.apartment_lock
        SET is_deleted = 1,
            updated_by = @userId,
            updated_dt = GETDATE()
        WHERE oid = @oid AND is_deleted = 0;

        IF (@@ROWCOUNT = 0)
        BEGIN
            SELECT CAST(0 AS BIT) AS valid, N'Xóa không thành công' AS [messages];
            RETURN;
        END

        SELECT CAST(1 AS BIT) AS valid, N'Xóa thành công' AS [messages];
    END TRY
    BEGIN CATCH
        SELECT CAST(0 AS BIT) AS valid, ERROR_MESSAGE() AS [messages];
    END CATCH
END