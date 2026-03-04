CREATE PROCEDURE [dbo].[sp_res_elevator_role_del] 
    @UserId UNIQUEIDENTIFIER = NULL,
    @id INT,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);

    BEGIN TRY
        IF @id IS NULL OR @id = 0
        BEGIN
            SET @messages = N'Id truyền vào bị null. Không thể xóa';
        END
        ELSE IF EXISTS (
            SELECT 1
            FROM MAS_Elevator_Card c
            JOIN ELE_CardRole b ON c.CardRole = b.id
            WHERE b.id = @id
        )
        BEGIN
            SET @messages = N'Quyền đã được sử dụng. Không thể xóa';
        END
        ELSE IF NOT EXISTS (SELECT 1 FROM ELE_CardRole WHERE Id = @id)
        BEGIN
            SET @messages = N'Không có quyền này trong dữ liệu';
        END
        ELSE
        BEGIN
            DELETE FROM ELE_CardRole WHERE id = @id;
            SET @valid = 1;
            SET @messages = N'Xóa Quyền thành công';
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
                @SessionID INT, @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_elevator_role_del ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo = 'UserId=' + ISNULL(CAST(@UserId AS NVARCHAR(50)), '');

        EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_C', 'DEL', @SessionID, @AddlInfo;

        SET @valid = 0;
        SET @messages = ERROR_MESSAGE();
    END CATCH;

    -- chỉ trả về 1 lần duy nhất
    SELECT @valid AS valid, @messages AS [messages];
END;