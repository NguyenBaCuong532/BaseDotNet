

CREATE PROCEDURE [dbo].[sp_res_user_config_set] 	
	@userId nvarchar(450),
	@categoryIds nvarchar(450)
AS
BEGIN
    DECLARE @valid BIT = 0
        , @messages NVARCHAR(250) = '';

    BEGIN TRY
		if exists (select * from UserConfig where userId = @userId)
        BEGIN
            update UserConfig set categoryIds = @categoryIds 
			WHERE userId = @userId
			--
			SET @valid = 1;
            SET @messages = N'Cập nhật người dùng thành công';
        END
        ELSE
        BEGIN
			INSERT INTO UserConfig(userId,categoryIds)
			VALUES(@userId,@categoryIds)
			--
			SET @valid = 1;
			SET @messages = N'Thêm mới người dùng thành công';
        END;
    END TRY

    BEGIN CATCH
        

        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_userConfig_set' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo = '@userId' + @userId;

        EXEC utl_errorlog_set @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'apartment_family_member'
            , 'Set'
            , @SessionID
            , @AddlInfo;

        SET @messages = @ErrorMsg
    END CATCH;

    SELECT @valid AS valid
        , @messages AS [messages];
END;