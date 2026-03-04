CREATE   PROCEDURE [dbo].[sp_Hom_Service_Vehicle_Number_Again_All]
AS
BEGIN TRY
    SET NOCOUNT ON;

    ;WITH src AS
    (
        SELECT
            t.CardVehicleId,
            t.VehicleNum,
            t.VehicleTypeId,
            b.RoomCode,
            b.ProjectCd,
            CASE
                WHEN b.ProjectCd NOT IN ('01','02') AND t.VehicleTypeId IN (2,3)
                    THEN N'23'
                ELSE CONVERT(nvarchar(10), t.VehicleTypeId)
            END AS GroupTmp
        FROM dbo.MAS_CardVehicle AS t
        INNER JOIN dbo.MAS_Apartments AS b
            ON t.ApartmentId = b.ApartmentId
        WHERE
            t.ApartmentId IS NOT NULL
            AND t.ApartmentId <> 0
    ),
    renumber AS
    (
        SELECT
            s.CardVehicleId,
            ROW_NUMBER() OVER
            (
                PARTITION BY s.RoomCode, s.GroupTmp
                ORDER BY
                    CASE WHEN s.VehicleNum IS NULL THEN 1 ELSE 0 END, -- đẩy NULL xuống
                    s.VehicleNum,
                    s.CardVehicleId
            ) AS VehicleNumNew
        FROM src AS s
    )
    UPDATE t
        SET t.VehicleNum = r.VehicleNumNew
    FROM dbo.MAS_CardVehicle AS t
    INNER JOIN renumber AS r
        ON t.CardVehicleId = r.CardVehicleId;

    -- Kiểm tra nhanh (tuỳ chọn):
    -- SELECT b.RoomCode,
    --        CASE WHEN b.ProjectCd NOT IN ('01','02') AND t.VehicleTypeId IN (2,3) THEN '23' ELSE CONVERT(nvarchar(10), t.VehicleTypeId) END AS GroupTmp,
    --        t.VehicleTypeId, t.CardVehicleId, t.VehicleNum
    -- FROM dbo.MAS_CardVehicle t
    -- JOIN dbo.MAS_Apartments b ON t.ApartmentId = b.ApartmentId
    -- WHERE t.ApartmentId IS NOT NULL AND t.ApartmentId <> 0
    -- ORDER BY b.RoomCode, GroupTmp, t.VehicleNum, t.CardVehicleId;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum  int          = ERROR_NUMBER(),
            @ErrorMsg  varchar(200) = 'sp_Hom_Service_Vehicle_Number_Again_All ' + ERROR_MESSAGE(),
            @ErrorProc varchar(50)  = ERROR_PROCEDURE(),
            @SessionID int,
            @AddlInfo  varchar(max) = ' ';

    EXEC dbo.utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_CardVehicle', 'POST,PUT', @SessionID, @AddlInfo;
END CATCH;