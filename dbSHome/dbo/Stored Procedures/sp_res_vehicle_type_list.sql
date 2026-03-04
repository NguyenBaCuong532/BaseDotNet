
CREATE PROCEDURE [dbo].[sp_res_vehicle_type_list]
AS
BEGIN TRY
    SELECT [value] = [VehicleTypeId]
        , [name] = [VehicleTypeName]
    FROM [MAS_VehicleTypes]
    ORDER BY [VehicleTypeId]
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_rest_vehicle_type_list ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_VehicleTypes'
        , 'GET'
        , @SessionID
        , @AddlInfo
END CATCH