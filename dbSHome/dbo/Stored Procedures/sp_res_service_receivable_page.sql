CREATE PROCEDURE [dbo].[sp_res_service_receivable_page]
    @UserID UNIQUEIDENTIFIER = NULL,
    @project_code NVARCHAR(50) = NULL,
    @InvoicePeriodOid NVARCHAR(50) = NULL,
    @clientId NVARCHAR(50) = NULL,
    @ProjectCd NVARCHAR(10) = NULL,
    @filter NVARCHAR(100) = '',
    @isDateFilter BIT = 0,
    @ToDate NVARCHAR(10) = NULL,
    @StatusPayed INT = -1,
    @IsBill INT = -1,
    @IsPush INT = -1,
    @gridWidth INT = 100,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    declare @Total		bigint
    declare @GridKey	nvarchar(100) = 'view_service_receivable_page'
    DECLARE @ToDt DATETIME;
    DECLARE @periods_oid UNIQUEIDENTIFIER;
    
    /* ============ Start Kỳ hóa đơn ============ */
    IF(@project_code IS NOT NULL AND TRIM(@project_code) <> '')
        SET @ProjectCd = @project_code;
        
    SET @StatusPayed = ISNULL(@StatusPayed, -1)
    SET @IsBill = ISNULL(@IsBill, -1)
    SET @IsPush = ISNULL(@IsPush, -1)
    
    SELECT TOP 1 *
    INTO #mas_invoice_periods
    FROM mas_invoice_periods
    WHERE oid = @InvoicePeriodOid
    
    IF(@InvoicePeriodOid IS NOT NULL AND EXISTS(SELECT TOP 1 1 FROM #mas_invoice_periods))
    BEGIN
        SET @isDateFilter = 1;
        SELECT TOP 1
            @ToDate = FORMAT(b.end_date, 'dd/MM/yyyy'),
            @periods_oid = b.oid
        FROM
            #mas_invoice_periods a
            INNER JOIN mas_revenue_periods b ON a.revenue_periods_oid = b.oid
    END
    /* ============ End Kỳ hóa đơn ============ */

    IF @isDateFilter = 1
        SET @ToDt = EOMONTH(CONVERT(DATETIME, @ToDate, 103));
        
    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');
    
    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    SELECT @Total = COUNT(e.[ReceiveId])
    FROM
        MAS_Service_ReceiveEntry e
        JOIN MAS_Apartments b ON e.ApartmentId = b.ApartmentId
        LEFT JOIN MAS_Buildings c ON b.buildingOid = c.oid
        LEFT JOIN dbo.UserInfo u ON b.UserLogin = u.loginName
        LEFT JOIN dbo.MAS_Customers d ON u.CustId = d.CustId
		WHERE
        (@filter = '' OR b.RoomCode LIKE '%' + @filter + '%')
        AND (@ProjectCd ='-1' or b.projectCd = @ProjectCd) 
        and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
        AND e.isExpected = 1
        AND (@StatusPayed = -1 OR (@StatusPayed = 0 AND e.TotalAmt - ISNULL(e.PaidAmt, 0) <> 0)
            OR (@StatusPayed = 1 AND e.PaidAmt = 0)
            OR (@StatusPayed = 2 AND e.IsPayed = 1))
		  and (@IsBill = -1 Or ISNULL(e.IsBill, 0) = @IsBill)
		  and (@IsPush = -1 Or ISNULL(e.isPush, 0) = @IsPush)
      AND (@isDateFilter = 0
          OR (@isDateFilter = 1
              AND DAY(e.ToDt) <= DAY(@ToDt)
              AND MONTH(e.ToDt) = MONTH(@ToDt)
              AND YEAR(e.ToDt) = YEAR(@ToDt)))
      AND (@periods_oid IS NULL OR e.periods_oid = @periods_oid)
          
    --root	
    select
      recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1
      
    --grid config
    IF @Offset = 0
        SELECT * FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage) ORDER BY [ordinal];
            
    --1
    SELECT e.[ReceiveId],
           e.[ApartmentId],
           FORMAT(e.[ReceiveDt], 'dd/MM/yyyy hh:mm:ss') AS ReceiveDate,
           CONVERT(NVARCHAR(10), e.[ToDt], 103) AS ToDate,
           e.TotalAmt,
           CONVERT(NVARCHAR(10), e.[ExpireDate], 103) AS [ExpireDate],
           e.[IsPayed],
           e.PaidAmt,
           e.[IsDebt],
           FORMAT(e.PayedDt, 'dd/MM/yyyy hh:mm:ss') AS PayedDate,
           e.TotalAmt - ISNULL(e.PaidAmt, 0) AS RemainAmt,
           b.RoomCode,
--            d.FullName,
           h.FullName,
           b.WaterwayArea,
           e.IsBill,
           e.BillUrl,
           e.IsPush,
           e.BillViewUrl,
           [ReceiptNos] = STUFF((SELECT ',' + [ReceiptNo]
                                 FROM MAS_Service_Receipts mr
                                 WHERE mr.ReceiveId = e.ReceiveId
                                 FOR XML PATH('')), 1, 1, '' )
    FROM
        MAS_Service_ReceiveEntry e
        JOIN MAS_Apartments b ON e.ApartmentId = b.ApartmentId
        LEFT JOIN MAS_Buildings c ON b.buildingOid = c.oid
        LEFT JOIN dbo.UserInfo u ON b.UserLogin = u.loginName
        LEFT JOIN dbo.MAS_Customers d ON u.CustId = d.CustId
        OUTER APPLY (SELECT TOp(1) t1.*
                      FROM
                          MAS_Customers t1
                          join MAS_Apartment_Member b1 on t1.CustId = b1.CustId 
                          left join MAS_Customer_Relation d1 on b1.RelationId = d1.RelationId
                      WHERE b1.ApartmentId = b.ApartmentId and b1.RelationId = 0) h
    WHERE
        (@filter = '' OR b.RoomCode LIKE '%' + @filter + '%')
        AND (@ProjectCd ='-1' or b.projectCd = @ProjectCd) 
        and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
        AND e.isExpected = 1
        AND (@StatusPayed = -1
            OR (@StatusPayed = 0 AND e.TotalAmt - ISNULL(e.PaidAmt, 0) <> 0)
            OR (@StatusPayed = 1 AND e.PaidAmt = 0)
            OR (@StatusPayed = 2 AND e.IsPayed = 1))
        and (@IsBill = -1 Or ISNULL(e.IsBill, 0) = @IsBill)
        and (@IsPush = -1 Or ISNULL(e.isPush, 0) = @IsPush)
        AND (@isDateFilter = 0
            OR (@isDateFilter = 1
                AND DAY(e.ToDt) <= DAY(@ToDt)
                AND MONTH(e.ToDt) = MONTH(@ToDt)
                AND YEAR(e.ToDt) = YEAR(@ToDt)))
        AND (@periods_oid IS NULL OR e.periods_oid = @periods_oid)
    ORDER BY
        e.[ReceiveDt] DESC,
        b.RoomCode
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_receivable_get ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '@UserID ' + cast(@UserID as varchar(50));
    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Service_ReceiveEntry', 'Get', @SessionID, @AddlInfo;
END CATCH;