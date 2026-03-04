-- =============================================
-- Deploy: sp_app_service_package_list
-- Date: 2026-02-12
-- Changes: Added English support for estimated time subtitle
-- =============================================

CREATE   PROCEDURE [dbo].[sp_app_service_package_list] 
    @userId UNIQUEIDENTIFIER = NULL,
    @serviceId UNIQUEIDENTIFIER = NULL,
    @isExtra BIT = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    -- Language-specific text
    DECLARE @estimatedPrefix NVARCHAR(50), @hourSuffix NVARCHAR(20)
    
    IF @acceptLanguage = 'en'
    BEGIN
        SET @estimatedPrefix = N'Estimated: '
        SET @hourSuffix = N' hour'
    END
    ELSE
    BEGIN
        SET @estimatedPrefix = N'Dự kiến: '
        SET @hourSuffix = N' giờ'
    END

    SELECT 
        [value] = LOWER(a.[id]),
        [name] = dbo.fn_convert_selection_list_html_price(
            a.package_name,
            CONCAT(@estimatedPrefix, a.estimated_time, @hourSuffix),
            CONCAT(FORMAT(a.price,'#,#.#'), N' đ')
        ),
        [subTitle] = CONCAT(@estimatedPrefix, a.estimated_time, @hourSuffix),
        a.[price],
        isHtml = 1
    FROM dbo.fn_get_service_package_lang(@acceptLanguage) a
    WHERE a.is_active = 1
        AND (a.service_id = @serviceId OR (@serviceId IS NULL AND is_extra = @isExtra))
    ORDER BY a.ordinal, a.package_name;
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = N'@Userid: ' + ISNULL(cast(@userId AS VARCHAR(50)), N'NULL')

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , N'service_package'
        , N'GET'
        , @SessionID
        , @AddlInfo;

    -- Trả về lỗi
    SELECT 0 AS valid
        , N'Lỗi: ' + ERROR_MESSAGE() AS [messages];
END CATCH