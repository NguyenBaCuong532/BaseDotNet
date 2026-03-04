
-- =============================================
-- Author: ANHTT
-- Create date: 2025-10-17 12:38:38
-- Description:	lock card Người dùng tự khóa/ mở thẻ
-- Output: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_card_lock] @userId NVARCHAR(50) = NULL
    , @cardCd NVARCHAR(50)
    , @isLock BIT
    , @memberCard BIT = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @valid BIT = 0
        , @messages NVARCHAR(250)
    DECLARE @customerId UNIQUEIDENTIFIER = dbo.fn_get_customerid(@userId)
    DECLARE @cardcustomerId UNIQUEIDENTIFIER
    DECLARE @card_lock_status INT = 3
    DECLARE @apartmentId BIGINT

    SELECT @apartmentId = ApartmentId
        , @cardcustomerId = CustId
    FROM MAS_Cards
    WHERE CardCd = @cardCd

    --Khóa thẻ thành viên
    IF @memberCard = 1
    BEGIN
        IF @userId <> dbo.fn_get_apartment_host_userid(@apartmentId)
        BEGIN
            SET @messages = N'Bạn không có quyền thao tác thẻ thành viên, với mã thẻ ' + @cardCd

            GOTO FINAL
        END
    END
    ELSE IF @customerId <> @cardcustomerId --tự khóa
    BEGIN
        SET @messages = N'Bạn không có quyền thao tác với mã thẻ ' + @cardCd

        GOTO FINAL
    END

    UPDATE MAS_Cards
    SET SelfLock = @isLock
        , Card_St = @card_lock_status
    WHERE CardCd = @cardCd

    SET @valid = 1
    SET @messages = N'Thực hiện thành công'

    FINAL:

    SELECT [valid] = @valid
        , [messages] = @messages
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    --SET @AddlInfo = NULL;
    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Cards'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;