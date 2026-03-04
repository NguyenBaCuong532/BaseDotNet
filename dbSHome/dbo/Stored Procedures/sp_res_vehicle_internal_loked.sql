-- Khóa/mở thẻ xe nội bộ. Hỗ trợ @cardVehicleOid (MAS_CardVehicle.oid).
CREATE PROCEDURE [dbo].[sp_res_vehicle_internal_loked]
	@UserID NVARCHAR(450) = NULL,
	@CardVehicleId INT = NULL,
	@Status INT = 1,
	@cardVehicleOid UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    IF @cardVehicleOid IS NOT NULL
        SET @CardVehicleId = (SELECT CardVehicleId FROM MAS_CardVehicle WHERE oid = @cardVehicleOid);
    DECLARE @valid BIT = 0, @messages NVARCHAR(250);
    SET @Status = ISNULL(@Status, 1);
    IF @Status = 1
    BEGIN
        INSERT INTO [dbo].[MAS_CardVehicle_H] ([CardVehicleId],[AssignDate],[CardId],[CustId],[VehicleNo],[VehicleTypeId],[VehicleName],[VehicleColor],[StartTime],[EndTime],[Status],[ServiceId],[RegCardVehicleId],[RequestId],[isVehicleNone],[monthlyType],[VehicleNum],[lastReceivable],[Mkr_Id],[Mkr_Dt],[Auth_id],[Auth_Dt],[ProjectCd],[ApartmentId],[Reason],[SaveDate],[SaveId])
        SELECT [CardVehicleId],[AssignDate],[CardId],[CustId],[VehicleNo],[VehicleTypeId],[VehicleName],[VehicleColor],[StartTime],[EndTime],[Status],[ServiceId],[RegCardVehicleId],[RequestId],[isVehicleNone],[monthlyType],[VehicleNum],[lastReceivable],[Mkr_Id],[Mkr_Dt],[Auth_id],[Auth_Dt],[ProjectCd],[ApartmentId],'Locked',GETDATE(),@UserId
        FROM [dbo].[MAS_CardVehicle] WHERE CardVehicleId = @CardVehicleId;
        UPDATE t1 SET [Status] = 3, locked_dt = GETDATE() FROM MAS_CardVehicle t1 WHERE CardVehicleId = @CardVehicleId;
        UPDATE t SET [VehicleNum] = t.VehicleNum - 1 FROM [dbo].[MAS_CardVehicle] t JOIN [dbo].[MAS_CardVehicle] a ON t.ApartmentId = a.ApartmentId AND t.VehicleTypeId = a.VehicleTypeId AND t.VehicleNum > a.VehicleNum WHERE t.[Status] = 1 AND a.CardVehicleId = @CardVehicleId;
        SET @valid = 1; SET @messages = N'Khóa thẻ thành công';
    END
    ELSE
    BEGIN
        UPDATE t1 SET Card_St = 1 FROM MAS_Cards t1 JOIN MAS_CardVehicle t2 ON t1.CardId = t2.CardId WHERE t2.CardVehicleId = @CardVehicleId;
        UPDATE t1 SET [Status] = 1, locked_dt = NULL FROM MAS_CardVehicle t1 WHERE CardVehicleId = @CardVehicleId;
        UPDATE t SET [VehicleNum] = t.VehicleNum + 1 FROM [dbo].[MAS_CardVehicle] t JOIN [dbo].[MAS_CardVehicle] a ON t.ApartmentId = a.ApartmentId AND t.VehicleTypeId = a.VehicleTypeId AND t.VehicleNum >= a.VehicleNum WHERE t.[Status] = 1 AND a.CardVehicleId = @CardVehicleId AND t.CardVehicleId <> @CardVehicleId;
        SET @valid = 1; SET @messages = N'Mở thẻ thành công';
    END;
    SELECT @valid AS valid, @messages AS [messages];
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER(); SET @ErrorMsg = 'sp_res_vehicle_internal_loked' + ERROR_MESSAGE(); SET @ErrorProc = ERROR_PROCEDURE();
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'VehicleInternal', 'SET', @SessionID, @AddlInfo;
END CATCH;
