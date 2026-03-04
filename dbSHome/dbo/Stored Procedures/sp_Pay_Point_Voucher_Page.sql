
CREATE PROCEDURE [dbo].[sp_Pay_Point_Voucher_Page]
    @UserId              nvarchar(450),
    @CustId              nvarchar(50)  = NULL,
    @filter              nvarchar(50)  = NULL,
    @ServiceKey          varchar(30)   = NULL,
    @PosCd               varchar(30)   = NULL,
    @tranType            nvarchar(50)  = NULL,
    @dateFilter          int           = 0,
    @startDate           nvarchar(20)  = NULL,
    @endDate             nvarchar(20)  = NULL,
    @gridWidth           int           = 0,
    @Offset              int           = 0,
    @PageSize            int           = 10,
    @Total               int OUTPUT,
    @TotalFiltered       int OUTPUT,
    @gridKey             nvarchar(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Chuẩn hoá tham số
        SET @tranType   = N'voucher';
        SET @Offset     = ISNULL(@Offset, 0);
        SET @PageSize   = CASE WHEN ISNULL(@PageSize, 10) <= 0 THEN 10 ELSE @PageSize END;
        SET @Total      = ISNULL(@Total, 0);
        SET @ServiceKey = ISNULL(@ServiceKey, '');
        SET @PosCd      = ISNULL(@PosCd, '');
        SET @CustId     = ISNULL(@CustId, '');
        SET @filter     = ISNULL(@filter, '');
        SET @dateFilter = ISNULL(@dateFilter, 0);

        DECLARE @p_now      datetime = GETDATE();
        DECLARE @p_endDate  datetime = NULL;

        IF (@dateFilter = 1 AND @endDate IS NOT NULL AND LTRIM(RTRIM(@endDate)) <> '')
        BEGIN
            -- dd/MM/yyyy hoặc dd/MM/yyyy HH:mi:ss theo style 103 + time 108
            -- Ưu tiên lấy HH:mm:ss nếu có
            SET @p_endDate = TRY_CONVERT(datetime, @endDate, 103);
            IF (@p_endDate IS NULL)
            BEGIN
                -- thử parse nhanh ISO nếu dữ liệu đầu vào đã là yyyy-MM-dd
                SET @p_endDate = TRY_CONVERT(datetime, @endDate, 120);
            END
        END

        -- Suy ra @CustId từ @filter nếu cần (giữ nguyên logic)
        IF ((@CustId = '' OR @CustId IS NULL) AND @filter <> '')
        BEGIN
            SELECT TOP (1) @CustId = c.CustId
            FROM dbo.MAS_Customers AS c
            WHERE c.Phone = @filter AND c.Cif_No IS NOT NULL
            OPTION (FAST 1);
        END

        IF (@CustId IS NULL)
        BEGIN
            SELECT TOP (1) @CustId = u.CustId
            FROM dbo.UserInfo AS u
            JOIN dbo.MAS_Apartments AS a ON u.LoginName = a.UserLogin
            JOIN dbo.MAS_Customers  AS c ON u.CustId    = c.CustId
            JOIN dbo.MAS_Cards      AS d ON c.CustId    = d.CustId
            WHERE a.RoomCode = @filter
            OPTION (FAST 1);
        END

        IF (@CustId IS NULL)
        BEGIN
            SELECT TOP (1) @CustId = d.CustId
            FROM dbo.MAS_Cards AS d
            WHERE d.CardCd LIKE @filter
            OPTION (FAST 1);
        END

        -- Nếu vẫn NULL thì chuẩn hoá về rỗng để các điều kiện OR hoạt động nhất quán
        SET @CustId = ISNULL(@CustId, '');

        /* ========================
           Tính tổng (giữ nguyên logic cũ)
           ======================== */
        SELECT @Total = COUNT_BIG(1)
        FROM dbo.MAS_Points      AS mp
        JOIN dbo.MAS_Customers   AS c  ON c.CustId   = mp.CustId
        JOIN dbo.WAL_PointOrder  AS wa ON mp.PointCd = wa.PointCd
        WHERE wa.TranType = @tranType
          AND (@ServiceKey = '' OR wa.ServiceKey = @ServiceKey)
          AND (@PosCd      = '' OR wa.PosCd      = @PosCd)
          AND (@CustId     = '' OR mp.CustId     = @CustId)  -- sargable: dùng '=' khi có mã đầy đủ
          AND wa.expireDt < DATEADD(DAY, 365, @p_now)
          AND (wa.isFinal IS NULL OR wa.isFinal = 0)
        OPTION (RECOMPILE); -- tham số @CustId/@ServiceKey/@PosCd thay đổi nhiều

        SET @TotalFiltered = @Total;

        -- Trả cấu hình lưới nếu trang đầu
        IF (@Offset = 0)
        BEGIN
            SELECT *
            FROM dbo.[fn_config_list_gets] ('view_Crm_Get_Point_Voucher_Page', @gridWidth - 100)
            ORDER BY [ordinal];
        END

        /* ========================
           Trang dữ liệu
           - OUTER APPLY để tính creditPointAfter 1 lần
           - CONVERT thay cho FORMAT
           ======================== */
        ;WITH Base AS
        (
            SELECT
                wa.Ref_No          AS tranNo,
                wa.OrderAmount     AS orderAmount,
                wa.Point           AS point,
                wa.OrderInfo       AS orderInfo,
                wa.TranDt          AS tranDt_raw,
                wa.TransNo         AS cardCd,
                s.ServiceName      AS serviceName,
                p.PosName          AS posName,
                wa.expireDt        AS expireDt_raw,
                DATEDIFF(DAY, wa.expireDt, @p_now) AS expire_day,
                CASE WHEN wa.TranType = 'smember' THEN N'Thẻ thành viên' ELSE N'Tặng điểm' END AS tranTypeName,
                c.FullName         AS fullName,
                c.Phone            AS phone,
                c.Email            AS email,
                mp.CustId          AS custId,
                mp.CurrPoint       AS CurrPoint,
                wa.push_st         AS push_st,
                wa.push_dt         AS push_dt_raw,
                wa.push_exp_dt     AS push_exp_dt_raw,
                wa.PointCd         AS PointCd -- dùng lại trong APPLY
            FROM dbo.MAS_Points      AS mp
            JOIN dbo.MAS_Customers   AS c  ON c.CustId   = mp.CustId
            JOIN dbo.WAL_PointOrder  AS wa ON mp.PointCd = wa.PointCd
            LEFT JOIN dbo.WAL_Services   AS s ON wa.ServiceKey = s.ServiceKey
            LEFT JOIN dbo.WAL_ServicePOS AS p ON p.PosCd      = wa.PosCd
            WHERE wa.TranType = @tranType
              AND (@ServiceKey = '' OR wa.ServiceKey = @ServiceKey)
              AND (@PosCd      = '' OR wa.PosCd      = @PosCd)
              AND (@CustId     = '' OR mp.CustId     = @CustId)
              AND wa.expireDt < DATEADD(DAY, 365, @p_now)
              AND (wa.isFinal IS NULL OR wa.isFinal = 0)
        )
        SELECT
            b.tranNo,
            b.orderAmount,
            b.point,
            creditPoint = ISNULL(agg.creditPointAfter, 0),
            remainPoint = b.point - ISNULL(agg.creditPointAfter, 0),
            b.orderInfo,
            -- Hiển thị dạng dd/MM/yyyy HH:mm:ss mà không dùng FORMAT:
            tranDt     = CONVERT(varchar(10), b.tranDt_raw, 103) + ' ' + CONVERT(varchar(8), b.tranDt_raw, 108),
            b.cardCd,
            b.serviceName,
            b.posName,
            expire_Dt  = CONVERT(varchar(10), b.expireDt_raw, 103),
            b.expire_day,
            b.tranTypeName,
            b.fullName,
            b.phone,
            b.email,
            b.custId,
            b.CurrPoint,
            b.push_st,
            push_dt     = CASE WHEN b.push_dt_raw IS NULL THEN NULL
                               ELSE CONVERT(varchar(10), b.push_dt_raw, 103) + ' ' + CONVERT(varchar(8), b.push_dt_raw, 108) END,
            push_exp_dt = CASE WHEN b.push_exp_dt_raw IS NULL THEN NULL
                               ELSE CONVERT(varchar(10), b.push_exp_dt_raw, 103) END,
            apartments  =
                STUFF((
                    SELECT ',' + a.RoomCode
                    FROM dbo.MAS_Apartments a
                    JOIN dbo.MAS_Apartment_Member bmem ON a.ApartmentId = bmem.ApartmentId
                    JOIN dbo.MAS_Rooms r  ON a.RoomCode = r.RoomCode
                    JOIN dbo.MAS_Buildings mb ON r.BuildingCd = mb.BuildingCd
                    WHERE bmem.CustId = b.custId
                    FOR XML PATH(''), TYPE
                ).value('.', 'nvarchar(max)'), 1, 1, '')
        FROM Base AS b
        OUTER APPLY
        (
            SELECT SUM(t.CreditPoint) AS creditPointAfter
            FROM dbo.WAL_PointOrder AS t WITH (INDEX(IX_WAL_PointOrder_PointCd_TranDt_INCL))
            WHERE t.PointCd = b.PointCd
              AND t.TranDt  > b.tranDt_raw
              AND (
                    t.TranDt <= b.expireDt_raw
                 OR (@dateFilter = 1 AND @p_endDate IS NOT NULL AND t.TranDt <= @p_endDate AND @p_endDate > b.expireDt_raw)
              )
        ) AS agg
        WHERE b.point > ISNULL(agg.creditPointAfter, 0)
        ORDER BY b.tranDt_raw
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY
        OPTION (RECOMPILE);

    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum  int,
                @ErrorMsg  varchar(200),
                @ErrorProc varchar(128),
                @SessionID int,
                @AddlInfo  varchar(max);

        SET @ErrorNum  = ERROR_NUMBER();
        SET @ErrorMsg  = 'sp_Pay_Point_Voucher_Page ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo  = ' ';

        EXEC dbo.utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Transaction', 'GET', @SessionID, @AddlInfo;
    END CATCH
END