CREATE PROCEDURE [dbo].[sp_res_apartment_lock_del_hard]
    @userId NVARCHAR(450),
    @id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        SET @id = ISNULL(@id, 0);
        SET @userId = NULLIF(LTRIM(RTRIM(@userId)), N'');

        IF (@userId IS NULL OR @id <= 0)
        BEGIN
            SELECT CAST(0 AS BIT) AS valid, N'Dữ liệu không hợp lệ' AS [messages];
            RETURN;
        END

        DECLARE @status INT;

        SELECT @status = l.status
        FROM dbo.apartment_lock l
        WHERE l.oid = @id;

        IF (@status IS NULL)
        BEGIN
            SELECT CAST(0 AS BIT) AS valid,
                   N'Không tìm thấy thông tin [' + CAST(@id AS NVARCHAR(50)) + N'] trong hệ thống!' AS [messages];
            RETURN;
        END

        IF (@status = 1)
        BEGIN
            SELECT CAST(0 AS BIT) AS valid,
                   N'Khóa [' + CAST(@id AS NVARCHAR(50)) + N'] đang hoạt động, cần khóa lại trước khi xóa!' AS [messages];
            RETURN;
        END

        BEGIN TRAN;

        DELETE FROM dbo.lock_history
        WHERE lock_id = @id;

        DELETE FROM dbo.apartment_lock
        WHERE oid = @id;

        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK;
            SELECT CAST(0 AS BIT) AS valid, N'Xóa không thành công' AS [messages];
            RETURN;
        END

        COMMIT;

        SELECT CAST(1 AS BIT) AS valid, N'Xóa thành công' AS [messages];
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;

        DECLARE @ErrorNum INT,
                @ErrorMsg VARCHAR(200),
                @ErrorProc VARCHAR(50),
                @SessionID INT,
                @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_apartment_lock_del_hard ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo = '@userId=' + ISNULL(@userId, '') + ';@id=' + CAST(ISNULL(@id,0) AS VARCHAR(50));

        EXEC dbo.utl_Insert_ErrorLog
            @ErrorNum,
            @ErrorMsg,
            @ErrorProc,
            'ApartmentLock',
            'DEL_HARD',
            @SessionID,
            @AddlInfo;

        SELECT CAST(0 AS BIT) AS valid,
               CASE WHEN ERROR_NUMBER() = 547
                    THEN N'Không thể xóa vì còn dữ liệu liên quan (FK). Cần xóa dữ liệu con trước.'
                    ELSE ERROR_MESSAGE()
               END AS [messages];
    END CATCH
END