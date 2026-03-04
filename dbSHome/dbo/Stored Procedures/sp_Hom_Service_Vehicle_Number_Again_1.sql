CREATE   PROCEDURE [dbo].[sp_Hom_Service_Vehicle_Number_Again]
     @UserId         nvarchar(450)
    ,@ApartmentId    int
    ,@VehicleTypeId  nvarchar(255)
AS
BEGIN TRY
    SET NOCOUNT ON;

    ;WITH src AS
    (
        SELECT
            t.CardVehicleId,
            t.VehicleNum,
            b.RoomCode
        FROM dbo.MAS_CardVehicle AS t
        INNER JOIN dbo.MAS_Apartments AS b
            ON t.ApartmentId = b.ApartmentId
        WHERE
            t.VehicleTypeId = @VehicleTypeId
            AND t.ApartmentId IS NOT NULL
            AND t.ApartmentId <> 0
            AND t.ApartmentId = @ApartmentId
    ),
    renumber AS
    (
        SELECT
            s.CardVehicleId,
            -- Đánh số lại theo từng RoomCode.
            -- Ưu tiên thứ tự hiện tại theo VehicleNum; nếu trùng/NULL thì ổn định bằng CardVehicleId.
            ROW_NUMBER() OVER
            (
                PARTITION BY s.RoomCode
                ORDER BY
                    CASE WHEN s.VehicleNum IS NULL THEN 1 ELSE 0 END,  -- đẩy NULL xuống cuối
                    s.VehicleNum,
                    s.CardVehicleId
            ) AS VehicleNumNew
        FROM src AS s
    )
    UPDATE t
        SET t.VehicleNum = r.VehicleNumNew
    FROM dbo.MAS_CardVehicle AS t
    INNER JOIN renumber AS r
        ON t.CardVehicleId = r.CardVehicleId
    WHERE
        t.ApartmentId = @ApartmentId;  -- bảo vệ phạm vi cập nhật

    -- Nếu muốn trả kết quả để kiểm tra nhanh, có thể mở comment:
    -- SELECT t.CardVehicleId, b.RoomCode, t.VehicleNum
    -- FROM dbo.MAS_CardVehicle t
    -- JOIN dbo.MAS_Apartments b ON t.ApartmentId = b.ApartmentId
    -- WHERE t.ApartmentId = @ApartmentId AND t.VehicleTypeId = @VehicleTypeId
    -- ORDER BY b.RoomCode, t.VehicleNum;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum  int          = ERROR_NUMBER(),
            @ErrorMsg  varchar(200) = 'sp_Hom_Service_Vehicle_Number_Again ' + ERROR_MESSAGE(),
            @ErrorProc varchar(50)  = ERROR_PROCEDURE(),
            @SessionID int,
            @AddlInfo  varchar(max) = ' ';

    EXEC dbo.utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_CardVehicle', 'POST,PUT', @SessionID, @AddlInfo;
END CATCH;