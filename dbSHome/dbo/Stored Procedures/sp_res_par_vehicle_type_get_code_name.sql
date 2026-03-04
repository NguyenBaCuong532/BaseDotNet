CREATE PROCEDURE [dbo].[sp_res_par_vehicle_type_get_code_name]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @tabVehicleTypeIdExist TABLE(VehicleTypeId INT);
    
    INSERT INTO @tabVehicleTypeIdExist(VehicleTypeId)
    SELECT b.value
    FROM
        par_vehicle_type a
        CROSS APPLY fn_SplitString(a.vehicle_type_id, ',') b
    WHERE
        a.project_code = @project_code
        AND (@oid IS NULL OR oid <> @oid)
    
    SELECT
        [Value] = CONVERT(NVARCHAR(50), a.VehicleTypeId),
        [Name] = a.VehicleTypeName
    FROM MAS_VehicleTypes a
    WHERE a.VehicleTypeId NOT IN(SELECT VehicleTypeId FROM @tabVehicleTypeIdExist)
    ORDER BY a.VehicleTypeId
	
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH