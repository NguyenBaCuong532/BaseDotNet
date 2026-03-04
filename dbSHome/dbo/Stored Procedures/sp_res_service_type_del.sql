-- =============================================
-- Author:      ThanhMT
-- Create date: 20/01/2026
-- Description: Loại dịch vụ cung cấp cho cư dân - Xóa bản ghi
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_type_del]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @ArrOid NVARCHAR(MAX),
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
DECLARE @oid uniqueidentifier;
DECLARE @Messages NVARCHAR(100) = N'Thực hiện thành công';
DECLARE @Valid BIT = 1;
BEGIN TRY

    SELECT oid = [Value]
    INTO #ArrOid
    FROM fn_SplitString(@ArrOid, ',')
	
    DELETE a
    FROM
        service_type a
        INNER JOIN #ArrOid b ON a.id = b.oid

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
    id = @oid,
    Valid = @Valid,
    Messages = @Messages