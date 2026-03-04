
CREATE PROCEDURE [dbo].[sp_res_Card_Vehicle_Auth] @UserId NVARCHAR(50)
    , @RequestId INT
    , @CardVehicleId INT
    , @Status INT
AS
BEGIN TRY
    IF @CardVehicleId IS NULL
        OR @CardVehicleId = 0
    BEGIN
        IF @Status = 1
        BEGIN
            UPDATE t1
            SET [Status] = @Status
                , VehicleNum = isnull((
                        SELECT count(*)
                        FROM [MAS_CardVehicle] a
                        JOIN MAS_VehicleTypes b1
                            ON a.VehicleTypeId = b1.VehicleTypeId
                        JOIN MAS_VehicleTypes b2
                            ON b1.ServiceId = b2.ServiceId
                        WHERE ApartmentId = t1.ApartmentId
                            AND b2.VehicleTypeId = t1.VehicleTypeId
                            AND a.STATUS = 1
                        ), 0) + 1
            FROM MAS_CardVehicle t1
            WHERE t1.RequestId = @RequestId

            UPDATE t1
            SET [Status] = @Status
            FROM MAS_Requests t1
            INNER JOIN MAS_CardVehicle t2
                ON t1.RequestId = t2.RequestId
            WHERE t2.RequestId = @RequestId
        END
        ELSE
        BEGIN
            UPDATE t1
            SET [Status] = 3
            FROM MAS_CardVehicle t1
            WHERE t1.RequestId = @RequestId

            UPDATE t1
            SET [Status] = 3
            FROM MAS_Requests t1
            INNER JOIN MAS_CardVehicle t2
                ON t1.RequestId = t2.RequestId
            WHERE t2.RequestId = @RequestId
        END
    END
    ELSE
    BEGIN
        IF @Status = 1
        BEGIN
            UPDATE t1
            SET [Status] = @Status
                , VehicleNum = isnull((
                        SELECT count(*)
                        FROM [MAS_CardVehicle] a
                        JOIN MAS_VehicleTypes b1
                            ON a.VehicleTypeId = b1.VehicleTypeId
                        JOIN MAS_VehicleTypes b2
                            ON b1.ServiceId = b2.ServiceId
                        WHERE ApartmentId = t1.ApartmentId
                            AND b2.VehicleTypeId = t1.VehicleTypeId
                            AND a.STATUS = 1
                        ), 0) + 1
            FROM MAS_CardVehicle t1
            WHERE t1.CardVehicleId = @CardVehicleId

            UPDATE t1
            SET [Status] = @Status
            FROM MAS_Requests t1
            INNER JOIN MAS_CardVehicle t2
                ON t1.RequestId = t2.RequestId
            WHERE t2.CardVehicleId = @CardVehicleId
        END
        ELSE
        BEGIN
            UPDATE t1
            SET [Status] = 3
            FROM MAS_CardVehicle t1
            WHERE t1.CardVehicleId = @CardVehicleId

            UPDATE t1
            SET [Status] = 3
            FROM MAS_Requests t1
            INNER JOIN MAS_CardVehicle t2
                ON t1.RequestId = t2.RequestId
            WHERE t2.CardVehicleId = @CardVehicleId
        END
    END
    SELECT valid = 1, messages = N'Xác nhận thành công'
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_Card_Vehicle_Auth ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = '@UserID ' + @UserID

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'Card'
        , 'SET'
        , @SessionID
        , @AddlInfo
END CATCH