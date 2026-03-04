-- =============================================
-- Author:      ThanhMT
-- Create date: 21/08/2025
-- Description: Cấu hình giá dịch vụ - Gửi xe ngày block - Xóa bản ghi
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_vehicle_daily_detail_del]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @ArrOid NVARCHAR(MAX),
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
DECLARE @Oid uniqueidentifier;
DECLARE @Messages NVARCHAR(100) = N'Thực hiện thành công';
DECLARE @Valid BIT = 1;
BEGIN TRY

    SELECT [Value] AS Oid
    INTO #ArrOid
    FROM fn_SplitString(@ArrOid, ',')
	
    DELETE a
    FROM
        par_vehicle_daily_detail a
        INNER JOIN #ArrOid b ON a.oid = b.oid

END TRY
BEGIN CATCH
    SET @Valid = 0;
    SET @Messages = error_message();

    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH

SELECT
    id = @Oid,
    Valid = @Valid,
    Messages = @Messages