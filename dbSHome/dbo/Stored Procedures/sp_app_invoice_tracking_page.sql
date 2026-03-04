
-- =============================================
-- Author:	AnhTT
-- Create date: 2025-09-10 21:50:32
-- Description:	page of tracking
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_invoice_tracking_page] @userId UNIQUEIDENTIFIER = NULL
    , @id BIGINT
    , @filter NVARCHAR(30) = NULL
    , @Offset INT = 0
    , @PageSize INT = 10
    , @gridWidth INT = 0
    , @gridKey NVARCHAR(100) = NULL OUT
    , @Total INT = 0 OUT
    , @TotalFiltered INT = 0 OUT
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET @gridKey = 'view_app_invoice_tracking_page'
    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

    --
    IF @PageSize < 0
    BEGIN
        SET @PageSize = 10;
    END

    IF @PageSize = 0
        SET @PageSize = 10;

    IF @Offset < 0
        SET @Offset = 0;

    SELECT @Total = count(1)
    FROM [MAS_Service_Living_CalSheet] a
    WHERE a.TrackingId = @id

    SET @TotalFiltered = @Total;

    SELECT gridKey = @gridKey
        , recordsTotal = @Total
        , recordsFiltered = @TotalFiltered

    IF @Offset = 0
    BEGIN
        SELECT *
        FROM dbo.fn_config_list_gets_lang(@gridKey, @gridWidth, @acceptLanguage)
        ORDER BY [ordinal]
    END;

    -- Data
    SELECT a.[Id]
        , a.[TrackingId]
        , a.[stepPos]
        , a.[fromN]
        , a.[toN]
        , [consumption] = Quantity --ABS(ISNULL(toN,0) - ISNULL(fromN,0))
        --, a.[quantity]
        , [price] = FORMAT(a.price, 'N0')
        , [amount] = FORMAT(a.Amount, 'N0')
    FROM [MAS_Service_Living_CalSheet] a
    WHERE a.TrackingId = @id
    ORDER BY a.StepPos OFFSET @Offset ROWS

    FETCH NEXT @PageSize ROWS ONLY;
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
    SET @AddlInfo = '';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Service_Living_Tracking'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH