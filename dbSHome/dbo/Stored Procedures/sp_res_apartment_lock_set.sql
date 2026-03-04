
CREATE PROCEDURE dbo.sp_res_apartment_lock_set
    @userId       UNIQUEIDENTIFIER = NULL,
    @oid          UNIQUEIDENTIFIER = NULL,
    @project_cd   NVARCHAR(50) = NULL,
    @apartment_id BIGINT = NULL,
    @device_id    BIGINT = NULL,
    @lock_name    NVARCHAR(200) = NULL,
    @door_code    NVARCHAR(100) = NULL,
    @status       INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        SET @userId = NULLIF(LTRIM(RTRIM(@userId)), N'');
        SET @project_cd = NULLIF(LTRIM(RTRIM(ISNULL(@project_cd, N''))), N'');
        SET @lock_name = NULLIF(LTRIM(RTRIM(ISNULL(@lock_name, N''))), N'');
        SET @door_code = NULLIF(LTRIM(RTRIM(ISNULL(@door_code, N''))), N'');
        SET @status = ISNULL(@status, 0);
        SET @apartment_id = NULLIF(@apartment_id, 0);
        SET @device_id = NULLIF(@device_id, 0);

        IF (@userId IS NULL OR @project_cd IS NULL OR @apartment_id IS NULL OR @lock_name IS NULL OR @door_code IS NULL)
        BEGIN
            SELECT CAST(0 AS BIT) AS valid, N'Dữ liệu không hợp lệ' AS [messages];
            RETURN;
        END

        IF (@device_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.lock_device WHERE oid = @device_id AND is_deleted = 0))
        BEGIN
            SELECT CAST(0 AS BIT) AS valid, N'Thiết bị không tồn tại hoặc đã bị xóa' AS [messages];
            RETURN;
        END

        IF (@oid IS NULL)
        BEGIN
            INSERT INTO dbo.apartment_lock
            (
                project_cd,
                apartment_id,
                device_id,
                lock_name,
                door_code,
                status,
                is_deleted,
                created_by,
                created_dt
            )
            VALUES
            (
                @project_cd,
                @apartment_id,
                @device_id,
                @lock_name,
                @door_code,
                @status,
                0,
                @userId,
                GETDATE()
            );

            SELECT CAST(1 AS BIT) AS valid, N'Thêm mới thành công' AS [messages];
            RETURN;
        END

        UPDATE l
        SET project_cd = @project_cd,
            apartment_id = @apartment_id,
            device_id = @device_id,
            lock_name = @lock_name,
            door_code = @door_code,
            status = @status,
            updated_by = @userId,
            updated_dt = GETDATE()
        FROM dbo.apartment_lock l
        WHERE l.oid = @oid
          AND l.is_deleted = 0;

        IF (@@ROWCOUNT = 0)
        BEGIN
            SELECT CAST(0 AS BIT) AS valid, N'Không tìm thấy dữ liệu' AS [messages];
            RETURN;
        END

        SELECT CAST(1 AS BIT) AS valid, N'Cập nhật thành công' AS [messages];
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            SELECT CAST(0 AS BIT) AS valid, N'Đã tồn tại mã cửa' AS [messages];
        ELSE
            SELECT CAST(0 AS BIT) AS valid, ERROR_MESSAGE() AS [messages];
    END CATCH
END