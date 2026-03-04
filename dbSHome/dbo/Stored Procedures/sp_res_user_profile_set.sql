-- =============================================
-- Author:		sonpt02
-- Create date: 4/12/2024
-- Description:	set users details
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_user_profile_set] 
	@userId nvarchar(50) = NULL
	, @Oid nvarchar(50) = null
	, @fullName nvarchar(150) = null
	, @email nvarchar(150) = null
	, @position nvarchar(150) = null
	, @isAdmin bit = 0
	, @loginName nvarchar(150) = null
	, @phone nvarchar(20) = null
	, @active bit = 1
AS
BEGIN TRY
	DECLARE @valid BIT = 0,
            @messages NVARCHAR(250) = N'';

	IF EXISTS (
        SELECT 1 
        FROM dbo.Users 
        WHERE userId = @Oid
    )
    BEGIN
        UPDATE t1
        SET 
            fullName = COALESCE(@fullName, t1.fullName),
            email = COALESCE(@email, t1.email),
            position = COALESCE(@position, t1.position),
            admin_st = @isAdmin,
            loginName = COALESCE(@loginName, t1.loginName),
            phone = COALESCE(@phone, t1.phone),
            active = @active
        FROM dbo.Users t1
        WHERE t1.userId = @Oid;
        --
        SET @valid = 1;
        SET @messages = N'Cập nhật thành công';
    END
	ELSE
	BEGIN
        INSERT INTO dbo.Users(
            userId, 
            admin_st, 
            fullName, 
            loginName, 
            phone, 
            email, 
            position, 
            active
        ) 
        VALUES(
            NEWID(), 
            @isAdmin, 
            @fullName, 
            @loginName, 
            @phone, 
            @email, 
            @position, 
            @active
        );
        --
        SET @valid = 1;
        SET @messages = N'Thêm người dùng mới thành công.';
    END

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
    SET @ErrorMsg = 'sp_user_profile_set: ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '@userId: ' + @Oid;

    EXEC utl_errorlog_set 
        @ErrorNum,
        @ErrorMsg,
        @ErrorProc,
        'Users',
        'Set',
        @SessionID,
        @AddlInfo;

    -- Trả về thông báo lỗi
    SELECT 0 AS valid, 
           @ErrorMsg AS [messages];
END CATCH;