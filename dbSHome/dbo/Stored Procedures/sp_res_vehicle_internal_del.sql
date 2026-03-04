-- Xóa thẻ xe nội bộ. Hỗ trợ @cardVehicleOid (MAS_CardVehicle.oid). Gọi sp_res_card_vehicle_del.
CREATE PROCEDURE [dbo].[sp_res_vehicle_internal_del]
    @UserId UNIQUEIDENTIFIER = NULL,
    @cardVehicleId BIGINT = NULL,
    @cardVehicleOid UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
    IF @cardVehicleOid IS NOT NULL
        SET @cardVehicleId = (SELECT CardVehicleId FROM MAS_CardVehicle WHERE oid = @cardVehicleOid);
    EXEC [dbo].[sp_res_card_vehicle_del] @UserId = @UserId, @cardVehicleId = @cardVehicleId, @cardVehicleOid = NULL, @acceptLanguage = @acceptLanguage;
END;
