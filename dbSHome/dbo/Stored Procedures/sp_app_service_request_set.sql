

-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-23
-- Description:	set service_request
-- Output:
-- =============================================
CREATE   procedure [dbo].[sp_app_service_request_set] @userId uniqueidentifier
    , @id UNIQUEIDENTIFIER = NULL
    , @apartment_id BIGINT
    , @package_id UNIQUEIDENTIFIER
    , @is_quick_support BIT
    , @service_date NVARCHAR(20)
    , @service_time TIME
    , @speed_extra_id UNIQUEIDENTIFIER
    , @service_extra NVARCHAR(MAX) = NULL
    , @acceptLanguage NVARCHAR(10) = 'vi'
AS
BEGIN TRY
 IF @package_id IS NULL
    BEGIN
        RAISERROR(N'Gói dịch vụ (package_id) không được để trống.', 16, 1);
        RETURN;
    END
    DECLARE @valid BIT
    DECLARE @messages NVARCHAR(250)
    DECLARE @service_id UNIQUEIDENTIFIER = (
            SELECT service_id
            FROM service_package
            WHERE id = @package_id
            )
    DECLARE @estimated_amount DECIMAL
    DECLARE @package_amount DECIMAL
    DECLARE @speed_extra_amount DECIMAL

    SELECT @package_amount = SUM(ISNULL(price, 0))
    FROM service_package
    WHERE id = @package_id
        OR id IN (
            SELECT [value]
            FROM string_split(@service_extra, ',')
            )
        AND is_extra = 1

    SELECT @speed_extra_amount = ISNULL(price, 0)
    FROM service_speed_extra
    WHERE id = @speed_extra_id

    SET @estimated_amount = ISNULL(@package_amount, 0) + ISNULL(@speed_extra_amount, 0)

    --todo: calculate @estimated_amount
    IF @id IS NULL
    BEGIN
        SET @id = NEWID()

        DECLARE @apartment_code NVARCHAR(50)
        DECLARE @request_code NVARCHAR(50)
        DECLARE @current_code BIGINT

        SELECT @apartment_code = RoomCode
        FROM MAS_Apartments
        WHERE ApartmentId = @apartment_id

        SELECT @current_code = MAX(RIGHT(request_code, CHARINDEX('-', REVERSE(request_code)) - 1))
        FROM service_request
        WHERE apartment_id = @apartment_id

        SET @current_code = ISNULL(@current_code,0) + 1
        SET @request_code = CONCAT(@apartment_code , '-' ,FORMAT(@current_code,'0000'))

        BEGIN TRAN

        INSERT INTO [dbo].service_request (
            id
            , [request_code]
            , [apartment_id]
            , [service_id]
            , [package_id]
            , [is_quick_support]
            , [service_date]
            , [service_time]
            , [speed_extra_id]
            , [estimated_amount]
            , [status]
            , created_by
            )
        VALUES (
            @id
            , @request_code
            , @apartment_id
            , @service_id
            , @package_id
            , @is_quick_support
            , CONVERT(DATE, @service_date, 103)
            , @service_time
            , @speed_extra_id
            , @estimated_amount
            , 0
            , @UserId
            )

        --PRINT 1

        IF ISNULL(@service_extra, '') <> ''
        BEGIN
            INSERT INTO service_request_extra (
                [service_request_id]
                , [service_package_id]
                , [price]
                )
            SELECT [service_request_id] = @id
                , [service_package_id] = a.id
                , [price] = ISNULL(a.price, 0)
            FROM service_package a
            WHERE a.id IN (
                    SELECT [value]
                    FROM string_split(@service_extra, ',')
                    )
        END

        --PRINT 2

        COMMIT

        SET @valid = 1
        SET @messages = N'Đặt dịch vụ thành công'
    END

    SELECT [Data] = @id
        , [id] = @id
        , [valid] = @valid
        , [messages] = @messages
END TRY

BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK

    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ''

    PRINT @ErrorMsg

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'service_request'
        , 'SET'
        , @SessionID
        , @AddlInfo
END CATCH