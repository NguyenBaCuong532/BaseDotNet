-- =============================================
-- Author:      ThanhMT
-- Create date: 20/01/2026
-- Description: Loại dịch vụ cung cấp cho cư dân - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_type_page]
    @UserId UNIQUEIDENTIFIER = null,
    @project_code NVARCHAR(50) = NULL,
    @ClientId nvarchar(50) = null,
    @Filter nvarchar(150) = NULL,
    @GridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @AcceptLanguage nvarchar(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @ViewGrid NVARCHAR(100) = 'service_type_page';--sys_config_list
    SET @OffSet = ISNULL(@OffSet, 0);
    SET @PageSize = ISNULL(@PageSize, 20);
    SET @Filter = ISNULL(@Filter, '');

    SELECT a.*
    INTO #service_type
    FROM service_type a
    -- WHERE
    -- 	(@Filter = '' OR (@Filter <> '' AND (a.Name LIKE N'%'+@Filter+'%')))
		
    SELECT *
    INTO #service_type_page
    FROM #service_type
    ORDER BY created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
	
    SELECT
        RecordsTotal = (SELECT COUNT(*) FROM #service_type),
        RecordsFiltered = (SELECT COUNT(*) FROM #service_type_page),
        GridKey = @ViewGrid
	IF(@OffSet <= 0)
		SELECT*FROM dbo.fn_config_list_gets_lang(@ViewGrid, @gridWidth, @AcceptLanguage) ORDER BY ordinal;
	
    SELECT * FROM #service_type_page

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH