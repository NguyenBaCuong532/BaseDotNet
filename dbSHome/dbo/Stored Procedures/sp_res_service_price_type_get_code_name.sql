-- =============================================
-- Author:      ThanhMT
-- Create date: 29/08/2025
-- Description: Lấy danh sách cho Dropdown Control
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_type_get_code_name]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @Filter NVARCHAR(50) = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    SET @Filter = ISNULL(@Filter, '');
	
    SELECT
        [value] = CONVERT(NVARCHAR(50), a.oid),
        [name] = a.config_name
    FROM par_service_price_type a
    ORDER BY a.sort_order
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