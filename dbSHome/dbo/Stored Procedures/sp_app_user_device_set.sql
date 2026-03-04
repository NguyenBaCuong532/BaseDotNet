

-- =============================================
-- Author:		duongpx
-- Create date: 26/11/2024 11:41:02 AM
-- Description:	lưu thiết bị từ app
-- =============================================
CREATE   procedure [dbo].[sp_app_user_device_set] 
	  @userId uniqueidentifier
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
    , @clientId NVARCHAR(150) = NULL
    , @clientIp NVARCHAR(50)
    , @udid NVARCHAR(150)
    , @deviceName NVARCHAR(250)
    , @deviceProvider NVARCHAR(250)
    , @deviceVersion NVARCHAR(150)
    , @playerId NVARCHAR(150)
    , @otp NVARCHAR(50)
AS
BEGIN
    DECLARE @valid BIT = 1
    DECLARE @messages NVARCHAR(100) = N'thành công'

    BEGIN TRY
        IF @userId IS NULL
        BEGIN
            SET @valid = 0
            SET @messages = N'Tài khoản chưa đăng ký'

            GOTO FINAL
        END

        IF NOT EXISTS (
                SELECT 1
                FROM UserInfo
                WHERE userid = @userId
                )
        BEGIN
            SET @valid = 0
            SET @messages = N'Tài khoản chưa có thông tin'

            GOTO FINAL
        END

        IF @udid IS NULL
            OR @udid = ''
        BEGIN
            SET @valid = 0
            SET @messages = N'Mã thiết bị không được để trắng'

            GOTO FINAL
        END

        IF NOT EXISTS (
                SELECT reg_userId
                FROM UserInfo
                WHERE userid = @userId
                )
        BEGIN
            SET @valid = 0
            SET @messages = N'Tài khoản chưa có thông tin'

            GOTO FINAL
        END

        IF NOT EXISTS (
                SELECT id
                FROM UserDevice
                WHERE udid = @udid
                    AND userid = @userId
                    AND [clientId] = @clientId
                )
        BEGIN
            DECLARE @regId BIGINT = (
                    SELECT reg_userId
                    FROM UserInfo
                    WHERE userId = @userId
                    )

            INSERT INTO [dbo].[UserDevice] (
                [id]
                , [udid]
                , [userId]
                , [reg_user_id]
                , [deviceName]
                , [deviceProvider]
                , [deviceVersion]
                , [playerId]
                , [clientId]
                , [etokenDevice]
                , [created_dt]
                , [update_dt]
                , [clientIp]
                , [etokenFail]
                )
            VALUES (
                newid()
                , @udid
                , @userId
                , @regId
                , @deviceName
                , @deviceProvider
                , @deviceVersion
                , @playerId
                , @clientId
                , 1
                , getdate()
                , NULL
                , @clientIp
                , 0
                )

            SET @messages = N'Đăng ký thiết bị thành công'
        END
        ELSE
        BEGIN
            UPDATE t
            SET [deviceName] = @deviceName
                , [deviceProvider] = @deviceProvider
                , [deviceVersion] = @deviceVersion
                , [playerId] = @playerId
                , [update_dt] = GETDATE()
                , [clientIp] = @clientIp
                , [etokenDevice] = 1
            FROM UserDevice t
            WHERE udid = @udid
                AND userid = @UserID
                AND [clientId] = @clientId

            SET @messages = N'Cập nhật thiết bị thành công'
        END

        DECLARE @custId UNIQUEIDENTIFIER = dbo.fn_get_customerid(@userId)
        DECLARE @apartment_id BIGINT = dbo.fn_get_apartment_main(@custId)

        --set main apartment
        IF NOT EXISTS (
                SELECT 1
                FROM MAS_Apartment_Member
                WHERE CustId = @custId
                    AND ApartmentId = @apartment_id
                    AND main_st = 1
                )
        BEGIN
            UPDATE MAS_Apartment_Member
            SET main_st = 1
            WHERE CustId = @custId
                AND ApartmentId = @apartment_id
        END

        SELECT @valid = [etokenDevice]
            , @messages = CASE 
                WHEN [etokenDevice] = 1
                    THEN N'Cập nhật thành công'
                ELSE N'Thiết bị chưa được xác thực'
                END
        FROM UserDevice t
        WHERE udid = @udid
            AND userid = @UserID
            AND [clientId] = @clientId
    END TRY

    BEGIN CATCH
        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(max)

        SET @ErrorNum = ERROR_NUMBER()
        SET @ErrorMsg = 'sp_app_user_device_Set ' + ERROR_MESSAGE()
        SET @ErrorProc = ERROR_PROCEDURE()
        SET @AddlInfo = '@UserID ' --+ ISNULL(@UserID, 'null')
        SET @valid = 0
        SET @messages = ERROR_MESSAGE()

        EXEC utl_errorLog_set @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'User'
            , 'Insert'
            , @SessionID
            , @AddlInfo
    END CATCH

    FINAL:

    SELECT @valid AS valid
        , @messages AS [messages]
END