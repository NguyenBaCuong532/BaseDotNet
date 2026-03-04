
CREATE   PROCEDURE [dbo].[sp_Pay_Get_Wallet_ByUserId]
    @userId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        --------------------------------------------------------------------
        -- 0) Resolve CustId (1 dòng) + tránh join lặp
        --------------------------------------------------------------------
        DECLARE @custId nvarchar(50);

        SELECT @custId = u.CustId
        FROM dbo.UserInfo u
        WHERE u.UserId = @userId;

        -- Nếu không có user -> vẫn trả 2 resultsets rỗng theo đúng format
        IF @custId IS NULL
        BEGIN
            -- resultset 1 (empty)
            SELECT
                CAST(NULL AS nvarchar(50)) AS WalletCd,
                CAST(NULL AS bigint)       AS CustId,
                CAST(0 AS decimal(18,2))   AS CurrentAmount,
                CAST(0 AS decimal(18,2))   AS PayLimitAmount,
                CAST(0 AS bigint)          AS LinkID,
                CAST(NULL AS bit)          AS isRequirePincode,
                CAST(0 AS bigint)          AS CurrentPoint
            WHERE 1 = 1;

            -- resultset 2 (empty)
            SELECT
                CAST(NULL AS bigint)       AS LinkedID,
                CAST(NULL AS nvarchar(50)) AS WalletCd,
                CAST(NULL AS nvarchar(50)) AS TranferCd,
                CAST(NULL AS nvarchar(50)) AS SourceCd,
                CAST(NULL AS nvarchar(200)) AS ShortName,
                CAST(NULL AS nvarchar(200)) AS SourceName,
                CAST(NULL AS nvarchar(500)) AS LogoUrl,
                CAST(NULL AS nvarchar(max)) AS LinkedToken
            WHERE 1 = 0;

            RETURN;
        END

        --------------------------------------------------------------------
        -- 1) Tập CIF của user (CustId -> Cif_No) và wallet của user
        --------------------------------------------------------------------
        DROP TABLE IF EXISTS #UserCif;
        SELECT DISTINCT c.Cif_No
        INTO #UserCif
        FROM dbo.MAS_Contacts c
        WHERE c.CustId = @custId;

        CREATE UNIQUE CLUSTERED INDEX IX_#UserCif ON #UserCif(Cif_No);

        DROP TABLE IF EXISTS #UserWallet;
        SELECT w.WalletCd, w.LinkedID, w.BaseCif, w.CurrAmount, w.PaymentLimit, w.LinkID, w.isRequirePincode
        INTO #UserWallet
        FROM dbo.WAL_Profile w
        JOIN #UserCif uc ON uc.Cif_No = w.BaseCif;

        CREATE INDEX IX_#UserWallet_Wallet ON #UserWallet(WalletCd, LinkedID);

		if not exists(select 1 from #UserWallet)
		BEGIN
            -- resultset 1 (empty)
            SELECT
                CAST(NULL AS nvarchar(50)) AS WalletCd,
                CAST(NULL AS bigint)       AS CustId,
                CAST(0 AS decimal(18,2))   AS CurrentAmount,
                CAST(0 AS decimal(18,2))   AS PayLimitAmount,
                CAST(0 AS bigint)          AS LinkID,
                CAST(NULL AS bit)          AS isRequirePincode,
                CAST(0 AS bigint)          AS CurrentPoint
            WHERE 1 = 1;

            -- resultset 2 (empty)
            SELECT
                CAST(NULL AS bigint)       AS LinkedID,
                CAST(NULL AS nvarchar(50)) AS WalletCd,
                CAST(NULL AS nvarchar(50)) AS TranferCd,
                CAST(NULL AS nvarchar(50)) AS SourceCd,
                CAST(NULL AS nvarchar(200)) AS ShortName,
                CAST(NULL AS nvarchar(200)) AS SourceName,
                CAST(NULL AS nvarchar(500)) AS LogoUrl,
                CAST(NULL AS nvarchar(max)) AS LinkedToken
            WHERE 1 = 0;

            RETURN;
        END
        --------------------------------------------------------------------
        -- Resultset 1: wallet summary (giữ logic như cũ)
        -- Lưu ý: nếu 1 CustId có nhiều contact/cif, bản gốc có thể bị nhân dòng;
        -- bản tối ưu này trả theo WAL_Profile (thực tế thường đúng hơn).
        --------------------------------------------------------------------
        SELECT
            w.WalletCd,
            CustId = @custId,
            CurrentAmount   = ISNULL(w.CurrAmount, 0),
            PayLimitAmount  = ISNULL(w.PaymentLimit, 0),
            LinkID          = ISNULL(w.LinkID, 0),
            w.isRequirePincode,
            CurrentPoint    = ISNULL(p.CurrPoint, 0)
        FROM #UserWallet w
        LEFT JOIN dbo.MAS_Points p ON p.CustId = @custId;

        --------------------------------------------------------------------
        -- Resultset 2: linked banks (bỏ EXISTS lồng -> join thẳng)
        --------------------------------------------------------------------
        SELECT
            a.LinkedID,
            a.WalletCd,
            a.TranferCd,
            a.SourceCd,
            b.ShortName,
            b.SourceName,
            b.LogoUrl,
            a.LinkedToken
        FROM dbo.WAL_TranferLinked a
        JOIN #UserWallet uw
             ON uw.WalletCd = a.WalletCd
            AND uw.LinkedID = a.LinkedID
        LEFT JOIN dbo.WAL_Banks b
               ON a.SourceCd = b.SourceCd
        WHERE a.IsLinked = 1;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum int,
                @ErrorMsg varchar(200),
                @ErrorProc varchar(50),
                @SessionID int,
                @AddlInfo varchar(max);

        SET @ErrorNum  = ERROR_NUMBER();
        SET @ErrorMsg  = 'sp_Pay_Get_Wallet_ByUserId ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo  = ' @userId ' + cast(@userId as varchar(50));

        EXEC dbo.utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Wallet', 'GET', @SessionID, @AddlInfo;
    END CATCH
END