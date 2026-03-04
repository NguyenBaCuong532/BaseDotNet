
CREATE PROCEDURE [dbo].[sp_res_vehicle_payment_set]
     @userId NVARCHAR(450) = NULL
    ,@acceptLanguage NVARCHAR(50) = N'vi-VN'
    ,@id int = NULL
    ,@PayId int = NULL

    ,@CardVehicleId int = NULL
    ,@PayDt   NVARCHAR(50) = NULL
    ,@empUserId NVARCHAR(450) = NULL
    ,@Amount NVARCHAR(50) = NULL
    ,@StartDt NVARCHAR(50) = NULL
    ,@EndDt   NVARCHAR(50) = NULL
    ,@Remart NVARCHAR(1000) = NULL

    ,@paymentId  NVARCHAR(50) = NULL      -- GUID string từ UI
    ,@price_oid  NVARCHAR(50) = NULL
    ,@month_price NVARCHAR(50) = NULL
    ,@month_num   NVARCHAR(50) = NULL
    ,@payment_st int = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    -- ✅ declare ngoài TRY để CATCH dùng được
    DECLARE @paymentId_uid uniqueidentifier = TRY_CONVERT(uniqueidentifier, NULLIF(LTRIM(RTRIM(@paymentId)), N''));
    DECLARE @price_oid_uid uniqueidentifier = TRY_CONVERT(uniqueidentifier, NULLIF(LTRIM(RTRIM(@price_oid)), N''));

    BEGIN TRY
        SET @id = COALESCE(@id, @PayId);

        -- ✅ empUserId NOT NULL
        SET @empUserId = NULLIF(LTRIM(RTRIM(@empUserId)), N'');
        IF @empUserId IS NULL SET @empUserId = NULLIF(LTRIM(RTRIM(@userId)), N'');

        IF @empUserId IS NULL
        BEGIN
            SELECT CAST(0 AS bit) AS valid,
                   N'Thiếu empUserId (hoặc userId).' AS [messages],
                   CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS id,
                   N'ERROR' AS action;
            RETURN;
        END

        DECLARE @valid BIT = 0;
        DECLARE @messages NVARCHAR(250) = N'';
        DECLARE @action NVARCHAR(20) = N'';

        /* Parse datetime/date */
        DECLARE @PayDt_dt datetime2(0) =
            COALESCE(
                TRY_CONVERT(datetime2(0), @PayDt, 126),
                TRY_CONVERT(datetime2(0), @PayDt, 127),
                TRY_CONVERT(datetime2(0), @PayDt, 121),
                TRY_CONVERT(datetime2(0), @PayDt, 120),
                TRY_CONVERT(datetime2(0), @PayDt, 103),
                TRY_CONVERT(datetime2(0), @PayDt, 101),
                TRY_CONVERT(datetime2(0), @PayDt)
            );

        DECLARE @StartDt_d date =
            COALESCE(
                TRY_CONVERT(date, @StartDt, 23),
                TRY_CONVERT(date, @StartDt, 103),
                TRY_CONVERT(date, @StartDt, 101),
                TRY_CONVERT(date, @StartDt)
            );

        DECLARE @EndDt_d date =
            COALESCE(
                TRY_CONVERT(date, @EndDt, 23),
                TRY_CONVERT(date, @EndDt, 103),
                TRY_CONVERT(date, @EndDt, 101),
                TRY_CONVERT(date, @EndDt)
            );

        IF (@PayDt IS NOT NULL AND LTRIM(RTRIM(@PayDt)) <> N'' AND @PayDt_dt IS NULL)
        BEGIN
            SELECT CAST(0 AS bit) AS valid,
                   N'PayDt sai định dạng.' AS [messages],
                   CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS id,
                   N'ERROR' AS action;
            RETURN;
        END

        /* Parse số */
        DECLARE @Amount_dec decimal(18,2) =
            TRY_CONVERT(decimal(18,2), REPLACE(REPLACE(@Amount, ',', ''), ' ', ''));

        DECLARE @month_price_dec decimal(18,2) =
            TRY_CONVERT(decimal(18,2), REPLACE(REPLACE(@month_price, ',', ''), ' ', ''));

        DECLARE @month_num_f float =
            TRY_CONVERT(float, REPLACE(REPLACE(@month_num, ',', ''), ' ', ''));

        /* ===== Update / Insert ===== */
        IF EXISTS (SELECT 1 FROM dbo.MAS_CardVehicle_Pay WHERE PayId = @id)
        BEGIN
            SET @action = N'UPDATE';

            -- ✅ nếu UI không gửi paymentId thì lấy theo DB (và nếu DB null thì tạo mới)
            IF @paymentId_uid IS NULL
                SELECT @paymentId_uid = paymentId FROM dbo.MAS_CardVehicle_Pay WHERE PayId = @id;

            IF @paymentId_uid IS NULL
                SET @paymentId_uid = NEWID();

            UPDATE dbo.MAS_CardVehicle_Pay
            SET CardVehicleId = @CardVehicleId,
                PayDt         = @PayDt_dt,
                empUserId     = @empUserId,
                Amount        = @Amount_dec,
                StartDt       = @StartDt_d,
                EndDt         = @EndDt_d,
                Remart        = @Remart,
                paymentId     = @paymentId_uid,      -- ✅ luôn có GUID
                price_oid     = @price_oid_uid,
                month_price   = @month_price_dec,
                month_num     = @month_num_f,
                payment_st    = @payment_st
            WHERE PayId = @id;

            SET @valid = 1;
            SET @messages = N'Cập nhật thành công (PayId=' + CAST(@id AS nvarchar(20)) + N')';
        END
        ELSE
        BEGIN
            SET @action = N'INSERT';

            -- ✅ insert luôn có paymentId
            IF @paymentId_uid IS NULL
                SET @paymentId_uid = NEWID();

            DECLARE @isIdentity bit =
                CASE WHEN COLUMNPROPERTY(OBJECT_ID('dbo.MAS_CardVehicle_Pay'), 'PayId', 'IsIdentity') = 1 THEN 1 ELSE 0 END;

            IF (@isIdentity = 1)
            BEGIN
                INSERT INTO dbo.MAS_CardVehicle_Pay
                    (CardVehicleId, PayDt, empUserId, Amount, StartDt, EndDt, Remart, paymentId, price_oid, month_price, month_num, payment_st)
                VALUES
                    (@CardVehicleId, @PayDt_dt, @empUserId, @Amount_dec, @StartDt_d, @EndDt_d, @Remart, @paymentId_uid, @price_oid_uid, @month_price_dec, @month_num_f, @payment_st);

                SET @id = CONVERT(int, SCOPE_IDENTITY());
            END
            ELSE
            BEGIN
                IF @id IS NULL
                BEGIN
                    SELECT CAST(0 AS bit) AS valid,
                           N'PayId không phải IDENTITY nên bắt buộc truyền @id/@PayId khi thêm mới' AS [messages],
                           CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS id,
                           N'ERROR' AS action;
                    RETURN;
                END

                INSERT INTO dbo.MAS_CardVehicle_Pay
                    (PayId, CardVehicleId, PayDt, empUserId, Amount, StartDt, EndDt, Remart, paymentId, price_oid, month_price, month_num, payment_st)
                VALUES
                    (@id, @CardVehicleId, @PayDt_dt, @empUserId, @Amount_dec, @StartDt_d, @EndDt_d, @Remart, @paymentId_uid, @price_oid_uid, @month_price_dec, @month_num_f, @payment_st);
            END

            SET @valid = 1;
            SET @messages = N'Thêm mới thành công (PayId=' + CAST(@id AS nvarchar(20)) + N')';
        END

        -- ✅ QUAN TRỌNG: trả id = GUID để đúng chuẩn Dapper đang map
        SELECT CAST(@valid AS bit) AS valid,
               CAST(@messages AS nvarchar(250)) AS [messages],
               @paymentId_uid AS id,
               CAST(@action AS nvarchar(20)) AS action;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum INT = ERROR_NUMBER(),
                @ErrorMsg VARCHAR(200) = ERROR_MESSAGE(),
                @ErrorProc VARCHAR(50) = ERROR_PROCEDURE(),
                @SessionID INT = NULL,
                @AddlInfo VARCHAR(MAX) =
                    N'@Userid: ' + ISNULL(@userId, N'NULL') + N', @id: ' + ISNULL(CAST(@id AS NVARCHAR(50)), N'NULL');

        BEGIN TRY
            EXEC dbo.utl_errorlog_set
                @ErrorNum, @ErrorMsg, @ErrorProc,
                N'MAS_CardVehicle_Pay', N'SET',
                @SessionID, @AddlInfo
            WITH RESULT SETS NONE;
        END TRY
        BEGIN CATCH
        END CATCH;

        SELECT CAST(0 AS bit) AS valid,
               N'Lỗi: ' + ERROR_MESSAGE() AS [messages],
               ISNULL(@paymentId_uid, CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier)) AS id,
               N'ERROR' AS action;
    END CATCH
END