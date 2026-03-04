-- =============================================
-- Author:      ThanhMT
-- Create date: 21/08/2025
-- Description: Danh sách cho Dropdown Control
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_vehicle_daily_type_get_name_value]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @Filter NVARCHAR(50) = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    SET @Filter = ISNULL(@Filter, '');
	
    SELECT
        [Value] = CONVERT(NVARCHAR(50), a.oid),
        [Name] = a.config_name
    FROM par_vehicle_daily_type a
    -- WHERE (@Filter = '' OR (@Filter <> '' AND (a.Name LIKE N'%'+@Filter+'%')))
	
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH