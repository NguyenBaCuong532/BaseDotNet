
CREATE   PROCEDURE [dbo].[sp_Hom_Get_Page_Home_ByUserId]
    @UserId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @now datetime = GETDATE();

        ---------------------------------------------------------------------
        -- 0) Resolve user base info (1 dòng)
        ---------------------------------------------------------------------
        DECLARE @CustId nvarchar(50);
        DECLARE @loginName nvarchar(200);

        SELECT
            @CustId = u.CustId,
            @loginName = u.loginName
        FROM dbo.UserInfo u
        WHERE u.UserId = @UserId;

        IF @CustId IS NULL
        BEGIN
            -- Không có user -> trả rỗng resultset 1 (giữ shape)
            SELECT TOP 0
                CAST(NULL AS nvarchar(450)) AS UserId,
                CAST(NULL AS nvarchar(200)) AS UserLogin,
                CAST(NULL AS nvarchar(200)) AS FullName,
                CAST(NULL AS nvarchar(max)) AS AvatarUrl,
                CAST(NULL AS nvarchar(50))  AS Phone,
                CAST(NULL AS nvarchar(200)) AS Email,
                CAST(NULL AS nvarchar(50))  AS CifNo,
                CAST(NULL AS nvarchar(50))  AS [Floor],
                CAST(NULL AS bigint)        AS ApartmentId,
                CAST(NULL AS nvarchar(50))  AS RoomCode,
                CAST(NULL AS nvarchar(50))  AS BuildingCd,
                CAST(NULL AS nvarchar(max)) AS FamilyImageUrl,
                CAST(NULL AS nvarchar(200)) AS ProjectName,
                CAST(NULL AS nvarchar(50))  AS ProjectCd,
                CAST(NULL AS bigint)        AS CustId,
                CAST(-1 AS int)             AS UserType;

            -- resultset wallet vẫn trả (rỗng) bằng cách gọi SP ví nếu bạn muốn,
            -- nhưng thường nên return luôn để tránh query tiếp.
            RETURN;
        END

        ---------------------------------------------------------------------
        -- 1) UserType: tính trực tiếp (tránh scalar UDF)
        -- 0: admin, 3: cư dân, -1: khách
        ---------------------------------------------------------------------
        DECLARE @userType int;

        SELECT @userType =
            CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM dbo.Users x
                    WHERE x.UserId = @UserId
                      AND x.admin_st = 1
                ) THEN 0
                WHEN EXISTS (
                    SELECT 1
                    FROM dbo.MAS_Customers mc
                    JOIN dbo.MAS_Apartments ma ON ma.Cif_No = mc.Cif_No AND ma.IsReceived = 1
                    WHERE mc.CustId = @CustId
                ) THEN 3
                ELSE -1
            END;

        ---------------------------------------------------------------------
        -- 2) Profile (lọc sớm theo @CustId/@loginName) + OUTER APPLY lấy 1 apartment
        ---------------------------------------------------------------------
        SELECT TOP (1)
              u.UserId
            , u.loginName AS UserLogin
            , c.FullName
            , c.AvatarUrl
            , c.Phone
            , c.Email
            , c.Cif_No    AS CifNo
            , ap.[Floor]
            , ap.ApartmentId
            , ap.RoomCode
            , ap.BuildingCd
            , ap.FamilyImageUrl
            , ap.ProjectName
            , ap.ProjectCd
            , c.CustId
            , @userType   AS UserType
        FROM dbo.UserInfo u
        LEFT JOIN dbo.MAS_Customers c
               ON c.CustId = u.CustId
        OUTER APPLY
        (
            SELECT TOP (1)
                  a.ApartmentId
                , r.RoomCode
                , r.[Floor]
                , r.BuildingCd
                , a.FamilyImageUrl
                , b.ProjectName
                , b.ProjectCd
            FROM dbo.MAS_Apartments a
            JOIN dbo.MAS_Rooms r
                 ON r.RoomCode = a.RoomCode
            JOIN dbo.MAS_Buildings b
                 ON b.BuildingCd = r.BuildingCd
            WHERE a.UserLogin = @loginName
              AND (a.IsReceived = 1 OR a.IsReceived IS NULL)  -- nếu bạn chỉ muốn đã nhận thì để =1
            ORDER BY a.ApartmentId DESC
        ) ap
        WHERE u.UserId = @UserId;

        ---------------------------------------------------------------------
        -- 3) Wallet (SP khác)
        ---------------------------------------------------------------------
        EXEC dbo.sp_Pay_Get_Wallet_ByUserId @UserId;

        ---------------------------------------------------------------------
        -- 4) Update last login - tránh update vô nghĩa
        ---------------------------------------------------------------------
        UPDATE dbo.UserInfo
        SET last_dt = @now,
            last_st = 1
        WHERE UserId = @UserId
          AND (last_st <> 1 OR last_dt IS NULL OR last_dt < DATEADD(minute, -1, @now)); 
          -- (tuỳ bạn) giảm write nếu gọi liên tục

    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum int,
                @ErrorMsg varchar(200),
                @ErrorProc varchar(50),
                @SessionID int,
                @AddlInfo varchar(max);

        SET @ErrorNum  = ERROR_NUMBER();
        SET @ErrorMsg  = 'sp_Hom_Get_Page_Home_ByUserId ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo  = ' @UserId ' + cast(@UserId as varchar(50));

        EXEC dbo.utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'HomePage', 'GET', @SessionID, @AddlInfo;
    END CATCH
END