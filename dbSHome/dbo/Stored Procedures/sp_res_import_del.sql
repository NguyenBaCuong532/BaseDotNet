
CREATE PROCEDURE [dbo].[sp_res_import_del] @userId NVARCHAR(50)
    , @impId UNIQUEIDENTIFIER
AS
BEGIN
    DECLARE @valid BIT = 1
    DECLARE @messages NVARCHAR(100) = 'Xóa thành công'

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM ImportFiles a
                WHERE a.impId = @impId
                )
        BEGIN
            SET @valid = 0
            SET @messages = N' không tìm thấy thông tin!'

            GOTO FINAL
        END

        IF EXISTS (
                SELECT 1
                FROM ImportFiles m
                WHERE m.impId = @impId
                    AND m.updated_st = 1
                )
        BEGIN
            SET @valid = 0
            SET @messages = N' Import đã cập nhật không thể xóa!'

            GOTO FINAL
        END

        DELETE
        FROM [dbo].ImportFiles
        WHERE impId = @impId
    END TRY

    BEGIN CATCH
        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(max)

        SET @ErrorNum = error_number()
        SET @ErrorMsg = 'sp_res_import_del' + error_message()
        SET @ErrorProc = error_procedure()
        SET @AddlInfo = '@userId ' + @userId
        SET @valid = 0
        SET @messages = error_message()

        EXEC utl_errorLog_set @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'import'
            , 'DEL'
            , @SessionID
            , @AddlInfo
    END CATCH

    FINAL:

    SELECT @valid AS valid
        , @messages AS [messages]
END