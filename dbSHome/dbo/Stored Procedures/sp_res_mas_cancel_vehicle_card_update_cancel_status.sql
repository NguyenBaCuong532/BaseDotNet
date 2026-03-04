CREATE PROCEDURE [dbo].sp_res_mas_cancel_vehicle_card_update_cancel_status
      @UserId uniqueidentifier = NULL,
      @project_code VARCHAR(50) = NULL
AS
BEGIN TRY
    
    UPDATE a
    SET a.Status = 5
    FROM
        MAS_CardVehicle a
        INNER JOIN mas_cancel_vehicle_card b ON a.CardVehicleId = b.CardVehicleId
    WHERE
        a.Status <> 5
        AND b.CancelDate <= CAST(GETDATE() AS DATE)
    
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH