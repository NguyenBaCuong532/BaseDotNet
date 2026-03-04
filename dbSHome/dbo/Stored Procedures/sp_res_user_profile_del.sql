-- =============================================
-- Author:		<sonpt02>
-- Create date: <11/12/2024>
-- Description:	<Delete users>
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_user_profile_del] 
	@userId nvarchar(50) = null
	-- , @isAdmin bit
AS
BEGIN TRY
	DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(100) = N'Có lỗi xảy ra';

	--IF @isAdmin is null or @isAdmin = 0
	--BEGIN
 --       SET @valid = 0;
 --       SET @messages = N'Bạn không có quyền quản trị để xóa tài khoản!';
 --   END

	--ELSE

	BEGIN
        DELETE FROM dbo.Users
        WHERE userId = @userId
		--
		SET @valid = 1;
		SET @messages = N'Xóa thành công';	
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
    SET @ErrorMsg = 'sp_user_profile_del' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'Users',
                             'DEL',
                             @SessionID,
                             @AddlInfo;
END CATCH