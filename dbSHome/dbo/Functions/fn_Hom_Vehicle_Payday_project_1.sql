
--select * from fn_Hom_Vehicle_Payday_project_1('02','2025-10-31') where RoomCode ='G1-0303'


CREATE FUNCTION [dbo].[fn_Hom_Vehicle_Payday_project_1] 
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
    WHERE project_code = @prjectCd and is_active = 1;

    /* 0.1) Map VehicleTypeId -> VehicleTypeNorm (nhóm) theo bảng par_vehicle_type */
    DECLARE @VehTypeGroup TABLE
    (
        VehicleTypeId   INT        NOT NULL,
        VehicleTypeNorm INT        NOT NULL
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

    /* 1) Biến bảng lưu xe đã đánh số lại (thay cho dùng CTE nhiều lần) */
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
            -- Nhóm theo cấu hình ở par_vehicle_type, nếu không có thì mỗi VehicleTypeId là 1 nhóm riêng
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
            v.VehicleTypeId
        FROM MAS_CardVehicle v
        INNER JOIN MAS_Apartments   a ON a.ApartmentId   = v.ApartmentId
        INNER JOIN MAS_VehicleTypes b ON v.VehicleTypeId = b.VehicleTypeId
        LEFT  JOIN @VehTypeGroup    g ON g.VehicleTypeId = v.VehicleTypeId
        WHERE a.projectCd = @prjectCd
          AND v.Status    = 1
    ),
    VehEnum AS
    (
        SELECT
            b.*,
            -- Đánh số thứ tự theo CĂN HỘ + NHÓM XE (VehicleTypeNorm)
            VehSeq = ROW_NUMBER() OVER
            (
                PARTITION BY b.ApartmentId, b.VehicleTypeNorm
                ORDER BY ISNULL(b.sysDt,'19000101'),
                         ISNULL(b.VehicleNum,999999),
                         b.CardVehicleId
            )
        FROM BaseVehicle b
    )
    INSERT INTO @veh (CardVehicleId, ApartmentId, VehicleTypeNorm, VehicleName, VehicleNo, isVehicleNone,
                      StartTime, EndTime, RoomCode, VehSeq, VehicleTypeName, VehicleTypeId)
    SELECT CardVehicleId, ApartmentId, VehicleTypeNorm, VehicleName, VehicleNo, isVehicleNone,
           StartTime, EndTime, RoomCode, VehSeq, VehicleTypeName, VehicleTypeId
    FROM VehEnum;

    /* 2) Bảng giá theo bậc dựa trên VehSeq + nhóm cấu hình ở par_vehicle_detail */
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
              -- Dòng cấu hình nào có vehicleTypeId chứa VehicleTypeId của xe
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

    /* 3) Kết quả cuối */
    INSERT INTO @ReturnTable
    SELECT
        e.CardVehicleId,
        -- Nếu anh muốn giữ như cũ thì để ISNULL(EndTime, StartTime); 
        -- nếu muốn "ngày bắt đầu" đúng nghĩa thì dùng e.StartTime
        ISNULL(e.EndTime, e.StartTime) AS StartDate,
        @endDate                       AS endDate,
        Quantity = CASE 
                     WHEN 0 < DATEDIFF(DAY, ISNULL(e.EndTime,e.StartTime), @endDate)
                      AND DATEDIFF(DAY, ISNULL(e.EndTime,e.StartTime), @endDate) <= 15 THEN 0.5
                     WHEN DATEDIFF(DAY, ISNULL(e.EndTime,e.StartTime), @endDate) <= 0 THEN 0
                     ELSE 1
                   END,
        p.Price,
        Amount  = CASE 
                    WHEN 0 < DATEDIFF(DAY, ISNULL(e.EndTime,e.StartTime), @endDate)
                     AND DATEDIFF(DAY, ISNULL(e.EndTime,e.StartTime), @endDate) <= 15 THEN 0.5 * p.Price
                    WHEN DATEDIFF(DAY, ISNULL(e.EndTime,e.StartTime), @endDate) <= 0 THEN 0
                    ELSE 1 * p.Price
                  END,
        e.VehSeq AS VehNum,   -- đây là thứ tự trong NHÓM xe theo cấu hình
        N'Gia hạn xe: ' + CASE WHEN e.isVehicleNone = 1 THEN e.VehicleName ELSE e.VehicleNo END
            + N' đến ngày ' + CONVERT(NVARCHAR(10), @endDate, 103)
            + CASE 
                WHEN CONVERT(FLOAT, DATEDIFF(MONTH, ISNULL(e.EndTime,e.StartTime), @endDate)) = 0 
                     THEN CONVERT(NVARCHAR(10),
                          DATEDIFF(DAY, DATEADD(MONTH, DATEDIFF(MONTH, ISNULL(e.EndTime,e.StartTime), @endDate), ISNULL(e.EndTime,e.StartTime)), @endDate))
                ELSE CONVERT(NVARCHAR(10),
                          CONVERT(FLOAT, DATEDIFF(MONTH, ISNULL(e.EndTime,e.StartTime), @endDate)))
                     + N' tháng '
                     + CONVERT(NVARCHAR(10),
                          DATEDIFF(DAY, DATEADD(MONTH, DATEDIFF(MONTH, ISNULL(e.EndTime,e.StartTime), @endDate), ISNULL(e.EndTime,e.StartTime)), @endDate))
              END AS Remart,
        e.RoomCode,
        e.VehicleTypeName,
        e.VehicleTypeId
    FROM @veh   e
    JOIN @price p ON p.CardVehicleId = e.CardVehicleId;

    RETURN;
END