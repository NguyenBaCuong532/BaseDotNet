
-- =============================================
-- Author:	AnhTT
-- Create date: 2025-09-10 21:50:32
-- Description:	page of invoice
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_invoice_page] 
	  @userId UNIQUEIDENTIFIER = NULL
    , @apartmentId BIGINT
    , @filter NVARCHAR(30) = NULL
    , @StatusPayed INT = - 1
    , @Offset INT = 0
    , @PageSize INT = 10
    , @gridWidth INT = 0
    , @gridKey NVARCHAR(100) = NULL OUT
    , @Total INT = 0 OUT
    , @TotalFiltered INT = 0 OUT
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    SET @gridKey = 'sp_app_invoice_page'
    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');
    SET @StatusPayed = - 1

    DECLARE @current_period DATE = GETDATE()
    DECLARE @check_date DATE

    SET @check_date = EOMONTH(@current_period, - 2)

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
    FROM [dbo].MAS_Service_ReceiveEntry a
    WHERE a.isExpected = 1
        AND IsBill = 1
        AND a.ApartmentId = @apartmentId
        AND (
            @StatusPayed = - 1
            OR (
                @StatusPayed = 0
                AND a.TotalAmt - ISNULL(a.PaidAmt, 0) <> 0
                )
            OR (
                @StatusPayed = 1
                AND a.PaidAmt = 0
                )
            OR (
                @StatusPayed = 2
                AND a.IsPayed = 1
                )
            )

    SET @TotalFiltered = @Total;

    SELECT ApartmentId = @apartmentId
        , gridKey = @gridKey
        , recordsTotal = @Total
        , recordsFiltered = @TotalFiltered

    IF @Offset = 0
    BEGIN
        SELECT 1
    END;

    -- Data
    WITH cte
    AS (
        SELECT a.ReceiveId
            --,cast(month(a.ToDt) as varchar) [PeriodMonth]
            --,cast(year(a.ToDt) as varchar) [PeriodYear]
            , format(a.ToDt, 'MM/yyyy') AS PeriodMonth
            , convert(NVARCHAR(10), a.ReceiveDt, 103) AS ReceivableDate
            , format(a.PaidAmt, '###,###,###') AS PaidAmt
            , format(TotalAmt, '###,###,###') AS [TotalAmt]
            , convert(NVARCHAR(10), a.[ExpireDate], 103) AS [ExpireDate]
            , a.[IsPayed]
            , convert(NVARCHAR(10), a.ToDt, 103) AS toDate
            , StatusPayed = dbo.fn_get_invoice_status(a.IsPayed,a.TotalAmt, a.PaidAmt, a.ToDt, a.IsDebt)
            --  CASE
            --     WHEN IsPayed = 1  OR  a.PaidAmt - a.TotalAmt >= 0 THEN 2
            --     WHEN a.PaidAmt > 0 THEN 0
            --     WHEN a.IsPayed = 0 THEN IIF(a.ToDt <= @check_date, 3, 1)
            --     END
            , N'Hóa đơn tháng ' + cast(month(DATEADD(MONTH, 1, a.ToDt)) AS VARCHAR) + N'/' + cast(year(a.ToDt) AS VARCHAR) AS Remark
            , [YearName] = CONCAT (
                N'Năm '
                , CONVERT(NVARCHAR(4), year(DATEADD(MONTH, 1, a.ToDt)))
                )
        FROM [dbo].MAS_Service_ReceiveEntry a
        WHERE a.isExpected = 1
            AND a.ApartmentId = @apartmentId
            AND a.IsBill = 1
            --(
            -- @filter = ''
            -- OR b.RoomCode LIKE '%' + @filter + '%'
            -- )
            --AND (@ProjectCd ='-1' or b.projectCd = @ProjectCd) 
            -- AND EXISTS (
            --     SELECT 1
            --     FROM UserProject up
            --     WHERE up.userId = @userId
            --         AND up.projectCd = @ProjectCd
            --     )
            AND (
                @StatusPayed = - 1
                OR (
                    @StatusPayed = 0
                    AND a.TotalAmt - ISNULL(a.PaidAmt, 0) <> 0
                    )
                OR (
                    @StatusPayed = 1
                    AND a.PaidAmt = 0
                    )
                OR (
                    @StatusPayed = 2
                    AND a.IsPayed = 1
                    )
                )
        -- and (@IsBill = -1 Or ISNULL(a.IsBill, 0) = @IsBill)
        -- and (@IsPush = -1 Or ISNULL(a.isPush, 0) = @IsPush)
        ORDER BY a.ReceiveDt DESC OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY
        )
    SELECT a.[ReceiveId]
        , a.[PeriodMonth]
        , a.[ReceivableDate]
        , a.[PaidAmt]
        , a.[TotalAmt]
        , a.[ExpireDate]
        , a.[IsPayed]
        , a.[toDate]
        , [status] = a.[StatusPayed]
        , a.[Remark]
        , a.[YearName]
        , [statusName] = [s].[objClass]
    FROM cte a
    LEFT JOIN dbo.fn_config_data_gets_lang('invoice_status', @acceptLanguage) s
        ON a.StatusPayed = s.objCode
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
        , 'MAS_Apartment_Reg'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH