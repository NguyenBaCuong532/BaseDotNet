
CREATE PROCEDURE dbo.sp_res_apartment_lock_unlock
    @userId NVARCHAR(450),
    @clientId NVARCHAR(450) = NULL,
    @oid UNIQUEIDENTIFIER,
    @apartment_id BIGINT = NULL,
    @reason NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        SET @userId = NULLIF(LTRIM(RTRIM(@userId)), N'');
        SET @reason = NULLIF(LTRIM(RTRIM(ISNULL(@reason, N''))), N'');

        IF (@userId IS NULL OR @oid IS NULL)
        BEGIN
            SELECT CAST(0 AS BIT) AS valid, N'Dữ liệu không hợp lệ' AS [messages];
            RETURN;
        END

        DECLARE @projectCd NVARCHAR(50);
        DECLARE @lockApartmentId BIGINT;
        DECLARE @status INT;

        SELECT
            @projectCd = l.project_cd,
            @lockApartmentId = l.apartment_id,
            @status = ISNULL(l.status, 0)
        FROM dbo.apartment_lock l
        WHERE l.oid = @oid AND l.is_deleted = 0;

        IF (@projectCd IS NULL)
        BEGIN
            SELECT CAST(0 AS BIT) AS valid, N'Không tìm thấy khóa' AS [messages];
            RETURN;
        END

        IF (@apartment_id IS NOT NULL AND @apartment_id <> @lockApartmentId)
        BEGIN
            SELECT CAST(0 AS BIT) AS valid, N'Khóa không thuộc căn hộ' AS [messages];
            RETURN;
        END

        IF (@status <> 1)
        BEGIN
            SELECT CAST(0 AS BIT) AS valid, N'Khóa đang không hoạt động' AS [messages];
            RETURN;
        END

        BEGIN TRAN;

        UPDATE dbo.apartment_lock
        SET last_unlock_dt = GETDATE(),
            last_unlock_by = @userId
        WHERE oid = @oid
          AND is_deleted = 0;

        INSERT INTO dbo.lock_history
        (
            project_cd,
            lock_id,
            apartment_id,
            action_type,
            action_by,
            action_dt,
            result_code,
            message,
            client_id,
            request_id
        )
        VALUES
        (
            @projectCd,
            @oid,
            @lockApartmentId,
            N'UNLOCK',
            @userId,
            GETDATE(),
            1,
            ISNULL(@reason, N'Unlock'),
            @clientId,
            NULL
        );

        COMMIT;

        SELECT CAST(1 AS BIT) AS valid, N'Mở khóa thành công' AS [messages];
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        SELECT CAST(0 AS BIT) AS valid, ERROR_MESSAGE() AS [messages];
    END CATCH
END