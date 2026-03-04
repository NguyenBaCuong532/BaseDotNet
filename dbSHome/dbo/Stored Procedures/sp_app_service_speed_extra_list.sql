
-- =============================================
-- Author: AnhTT
-- Create date: 2025-09-23
-- Description: danh sách thời lượng dọn
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_service_speed_extra_list] @userId UNIQUEIDENTIFIER = NULL
    , @packageId UNIQUEIDENTIFIER = NULL
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @expected_time DECIMAL = 0

    IF @packageId IS NOT NULL
        SELECT @expected_time = estimated_time
        FROM service_package
        WHERE id = @packageId

    SELECT [value] = lower(a.[id])
        , [name] = dbo.fn_convert_selection_list_html_price(a.name,CONCAT (N'+',FORMAT(a.price,'#,#.#'), N' đ'), '' )
        , a.price
        , [subTitle] = CONCAT (
            N'Dự kiến '
            , ISNULL(a.[description], @expected_time)
            , N' giờ'
            )
    FROM [service_speed_extra] a
    ORDER BY a.ordinal
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