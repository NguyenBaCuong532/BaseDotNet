

CREATE PROCEDURE [dbo].[sp_User_locked]
    @userId NVARCHAR(450),
    @isLock BIT
AS
BEGIN TRY
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);

    IF NOT EXISTS (SELECT 1 FROM [User] WHERE userId = @userId)
    BEGIN
        SET @messages = N'Bản ghi không tồn tại';
        GOTO FINAL;
    END;

    UPDATE [User]
    SET is_locked = @isLock
    WHERE userId = @userId;
    ----
    SET @valid = 1;
    SET @messages = N'Khóa thành công';
    ----
	FINAL:
    SELECT @valid AS valid,
           @messages AS [messages];
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_User_locked' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '@User ';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'sp_User_locked',
                          'Set',
                          @SessionID,
                          @AddlInfo;
END CATCH;