

CREATE FUNCTION [dbo].[fn_Hom_Vehicle_Payday_project] 
(
    @prjectCd NVARCHAR(30),
    @endDate  DATETIME
)
RETURNS 
@ReturnTable TABLE 
(
    CardVehicleId      BIGINT NOT NULL INDEX IX2_CardVehicleId NONCLUSTERED,
    StartDate          DATETIME NULL,
    endDate            DATETIME NULL,
    Quantity           FLOAT NULL,
    Price              DECIMAL(18,0),
    Amount             DECIMAL(18,0),
    VehNum             INT,
    Remart             NVARCHAR(350) NULL,
    RoomCode           NVARCHAR(50)  NULL,
    VehicleTypeName    NVARCHAR(50)  NULL,
    VehicleTypeId      INT           NULL
)
AS
BEGIN
    /* 0) Lấy cấu hình bảng giá theo project */
    DECLARE @Par_vehicle_oid UNIQUEIDENTIFIER;

    SELECT TOP (1) @Par_vehicle_oid = oid
    FROM par_vehicle
    WHERE project_code = @prjectCd 
      AND is_active = 1;

    /* Kỳ tính phí trong THÁNG của @endDate */
    DECLARE @StartOfMonth DATE = DATEFROMPARTS(YEAR(@endDate), MONTH(@endDate), 1);
    DECLARE @PeriodEnd    DATE = CAST(@endDate AS DATE);

    /* Bảng tổng hợp ngày hủy theo CardVehicleId (nếu có) */
    DECLARE @Cancel TABLE
    (
        CardVehicleId BIGINT PRIMARY KEY,
        CancelDate    DATETIME NULL
    );

    INSERT INTO @Cancel (CardVehicleId, CancelDate)
    SELECT 
        CardVehicleId, 
        MAX(CancelDate) AS CancelDate
    FROM mas_cancel_vehicle_card
    GROUP BY CardVehicleId;

    /* 0.1) Map VehicleTypeId -> VehicleTypeNorm (nhóm) */
    DECLARE @VehTypeGroup TABLE 
    (
        VehicleTypeId   INT,
        VehicleTypeNorm INT
    );

    ;WITH Cfg AS
    (
        SELECT
            t.oid,
            t.sort_order,
            value AS VehicleTypeIdStr
        FROM par_vehicle_type t
        CROSS APPLY STRING_SPLIT(REPLACE(ISNULL(t.vehicle_type_id,''),' ',''), ',') s
        WHERE t.project_code = @prjectCd
    ),
    CfgRank AS
    (
        SELECT
            TRY_CAST(VehicleTypeIdStr AS INT) AS VehicleTypeId,
            VehicleTypeNorm = DENSE_RANK() OVER (ORDER BY sort_order, oid)
        FROM Cfg
    )
    INSERT INTO @VehTypeGroup (VehicleTypeId, VehicleTypeNorm)
    SELECT VehicleTypeId, VehicleTypeNorm
    FROM CfgRank
    WHERE VehicleTypeId IS NOT NULL;

    /* 1) Lấy danh sách xe và đánh số thứ tự trong nhóm
          - Status IN (1,5)
          - Chỉ lấy những xe CHƯA bị hủy trước đầu tháng (@StartOfMonth):
            + Nếu CancelDate < @StartOfMonth  => loại
            + Nếu CancelDate IS NULL hoặc >= @StartOfMonth => còn hiệu lực trong kỳ
    */
    DECLARE @veh TABLE
    (
        CardVehicleId     BIGINT PRIMARY KEY,
        ApartmentId       INT,
        VehicleTypeNorm   INT,
        VehicleName       NVARCHAR(255),
        VehicleNo         NVARCHAR(100),
        isVehicleNone     BIT,
        StartTime         DATETIME,
        EndTime           DATETIME,
        RoomCode          NVARCHAR(50),
        VehSeq            INT,
        VehicleTypeName   NVARCHAR(50),
        VehicleTypeId     INT
    );

    ;WITH BaseVehicle AS
    (
        SELECT DISTINCT
            v.CardVehicleId,
            v.ApartmentId,
            VehicleTypeNorm = ISNULL(g.VehicleTypeNorm, v.VehicleTypeId),
            v.VehicleName,
            v.VehicleNo,
            v.isVehicleNone,
            v.StartTime,
            v.EndTime,
            a.RoomCode,
            v.VehicleNum,
            v.sysDt,
            b.VehicleTypeName,
            v.VehicleTypeId,
            c.CancelDate
        FROM MAS_CardVehicle v
        INNER JOIN MAS_Apartments   a ON a.ApartmentId   = v.ApartmentId
        INNER JOIN MAS_VehicleTypes b ON v.VehicleTypeId = b.VehicleTypeId
        LEFT  JOIN @VehTypeGroup    g ON g.VehicleTypeId = v.VehicleTypeId
        LEFT  JOIN @Cancel          c ON c.CardVehicleId = v.CardVehicleId
        WHERE a.projectCd = @prjectCd
          AND v.Status    IN (1,5)              -- chỉ lấy xe trạng thái 1, 5
          AND (c.CancelDate IS NULL 
               OR c.CancelDate >= @StartOfMonth) -- chưa bị hủy trước kỳ tính
         -- NEW: xe nào đã gia hạn EndTime lớn hơn thời gian dự thu tháng này thì không tính phí
          AND (v.EndTime IS NULL OR CAST(v.EndTime AS DATE) < @PeriodEnd)
    ),
    VehEnum AS
    (
        SELECT
            b.CardVehicleId,
            b.ApartmentId,
            b.VehicleTypeNorm,
            b.VehicleName,
            b.VehicleNo,
            b.isVehicleNone,
            b.StartTime,
            b.EndTime,
            b.RoomCode,
            b.VehicleTypeName,
            b.VehicleTypeId,
            VehSeq = ROW_NUMBER() OVER
            (
                PARTITION BY b.ApartmentId, b.VehicleTypeNorm
                ORDER BY ISNULL(b.sysDt,'19000101'),
                         ISNULL(b.VehicleNum,999999),
                         b.CardVehicleId
            )
        FROM BaseVehicle b
    )
    INSERT INTO @veh
    SELECT 
        CardVehicleId, ApartmentId, VehicleTypeNorm, VehicleName, VehicleNo, isVehicleNone,
        StartTime, EndTime, RoomCode, VehSeq, VehicleTypeName, VehicleTypeId
    FROM VehEnum;

    /* 2) Bảng giá theo bậc */
    DECLARE @price TABLE
    (
        CardVehicleId BIGINT PRIMARY KEY,
        Price         DECIMAL(18,0)
    );

    INSERT INTO @price (CardVehicleId, Price)
    SELECT
        e.CardVehicleId,
        ISNULL((
            SELECT TOP (1) pd.unit_price
            FROM par_vehicle_detail pd
            WHERE pd.par_vehicle_oid = @Par_vehicle_oid
              AND EXISTS (
                    SELECT 1
                    FROM STRING_SPLIT(REPLACE(ISNULL(pd.vehicleTypeId,''),' ',''), ',') s
                    WHERE TRY_CAST(s.value AS INT) = e.VehicleTypeId
              )
              AND pd.start_value <= e.VehSeq
              AND (pd.end_value IS NULL OR e.VehSeq <= pd.end_value)
            ORDER BY pd.sort_order
        ), 0)
    FROM @veh e;

    /* 3) Áp dụng logic tính phí theo CancelDate trong tháng của @endDate */
    INSERT INTO @ReturnTable
    SELECT
        e.CardVehicleId,
        @StartOfMonth AS StartDate,
        @PeriodEnd    AS endDate,
        Quantity =
            CASE
                -- Hủy trước đầu tháng -> đã loại từ BaseVehicle, an toàn nhưng vẫn để đúng logic nếu còn sót
                WHEN c.CancelDate IS NOT NULL
                     AND c.CancelDate < @StartOfMonth
                THEN 0

                -- Hủy trong khoảng [StartOfMonth, PeriodEnd] -> 0.5 hoặc 1
                WHEN c.CancelDate IS NOT NULL
                     AND c.CancelDate >= @StartOfMonth
                     AND c.CancelDate <= @PeriodEnd
                THEN
                    CASE 
                        -- Số ngày từ đầu tháng đến ngày hủy (tính cả ngày hủy)
                        WHEN DATEDIFF(DAY, @StartOfMonth, c.CancelDate) + 1 <= 15 THEN 0.5
                        ELSE 1
                    END

                -- Không có ngày hủy hoặc hủy sau @endDate -> tính đủ tháng
                ELSE 1
            END,
        p.Price,
        Amount = p.Price *
            CASE
                WHEN c.CancelDate IS NOT NULL
                     AND c.CancelDate < @StartOfMonth
                THEN 0
                WHEN c.CancelDate IS NOT NULL
                     AND c.CancelDate >= @StartOfMonth
                     AND c.CancelDate <= @PeriodEnd
                THEN
                    CASE 
                        WHEN DATEDIFF(DAY, @StartOfMonth, c.CancelDate) + 1 <= 15 THEN 0.5
                        ELSE 1
                    END
                ELSE 1
            END,
        e.VehSeq AS VehNum,
        N'Gia hạn xe: ' 
            + CASE WHEN e.isVehicleNone = 1 THEN e.VehicleName ELSE e.VehicleNo END
            + N' đến ngày ' 
            + CONVERT(NVARCHAR(10),
                      CASE 
                          WHEN c.CancelDate IS NOT NULL 
                               AND c.CancelDate BETWEEN @StartOfMonth AND @PeriodEnd 
                          THEN c.CancelDate
                          ELSE @PeriodEnd
                      END, 103) AS Remart,
        e.RoomCode,
        e.VehicleTypeName,
        e.VehicleTypeId
    FROM @veh e
    JOIN @price p 
        ON p.CardVehicleId = e.CardVehicleId
    LEFT JOIN @Cancel c 
        ON c.CardVehicleId = e.CardVehicleId;

    RETURN;
END