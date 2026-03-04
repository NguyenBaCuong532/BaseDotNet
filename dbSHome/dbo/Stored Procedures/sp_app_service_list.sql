-- =============================================
-- Author: duongpx
-- Create date: 2025-09-18 09:05:37
-- Modified: 2026-02-06 - Added acceptLanguage support
-- Description: danh sách dịch vụ (service list with multi-language support)
-- =============================================
CREATE   PROCEDURE [dbo].[sp_app_service_list] 
    @userId UNIQUEIDENTIFIER = NULL,
    @isFavorite BIT = NULL,
    @filter NVARCHAR(30) = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY

    SELECT [value] = IIF(a.is_active = 1, LOWER(a.[id]), NULL),
        [name] = a.service_name,
        [is_icon] = 1,
        [icon] = a.[icon_url],
        a.[ordinal]
    FROM [dbo].[fn_get_service_lang](@acceptLanguage) a
    --WHERE is_active = 1
    ORDER BY a.ordinal;

END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT,
        @ErrorMsg VARCHAR(200),
        @ErrorProc VARCHAR(50),
        @SessionID INT,
        @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = N'@Userid: ' + ISNULL(CAST(@userId AS VARCHAR(50)), N'NULL');

    EXEC utl_errorlog_set @ErrorNum,
        @ErrorMsg,
        @ErrorProc,
        N'service',
        N'GET',
        @SessionID,
        @AddlInfo;

    -- Trả về lỗi
    SELECT 0 AS valid,
        N'Lỗi: ' + ERROR_MESSAGE() AS [messages];
END CATCH