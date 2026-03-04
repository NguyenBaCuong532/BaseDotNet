CREATE PROCEDURE [dbo].[sp_res_service_expected_page_new]
    @UserID UNIQUEIDENTIFIER = N'ea596efb-5eb1-4648-a219-089d2a4d310c',
    @project_code NVARCHAR(50) = NULL,
    @periods_oid NVARCHAR(50) = NULL,
    @clientId NVARCHAR(50) = NULL,
    @ProjectCd NVARCHAR(10) = '04',
    @ToDate NVARCHAR(10) = N'31/10/2025',
    @IsCalculated BIT = 0,
    @filter NVARCHAR(100) = N'B-2906',
    @gridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 20,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    declare @Total		bigint
    declare @GridKey	nvarchar(100) = 'view_service_expected_page'
    DECLARE @ToDt DATETIME;
    DECLARE @ToDtVehicle DATETIME;
    
    IF(@periods_oid IS NOT NULL)
        SET @GridKey = 'view_service_expected_page_new';
    
    IF(@periods_oid IS NOT NULL AND TRIM(@periods_oid) <> '')
    BEGIN
        SELECT @ToDate = FORMAT(end_date, 'dd/MM/yyyy')
        FROM mas_billing_periods WHERE oid = @periods_oid;
        SET @ProjectCd = @project_code;
    END
    
    SET @ToDate = ISNULL(@ToDate, CONVERT(NVARCHAR(10), GETDATE(), 103));
    SET @ToDt = CONVERT(DATETIME, @ToDate, 103);
    SET @ToDtVehicle = DATEADD(MONTH, 1, @ToDt);

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;
    
    SELECT @Total = COUNT(b.ApartmentId)
    FROM
        MAS_Apartments b        
        LEFT JOIN dbo.UserInfo u  ON u.loginName = b.UserLogin
        LEFT JOIN dbo.MAS_Customers d ON u.CustId = d.CustId
        LEFT JOIN MAS_Service_ReceiveEntry r 
                  ON r.ApartmentId = b.ApartmentId
                  AND r.IsPayed = 0
                  AND DAY(r.ToDt) = DAY(CONVERT(DATETIME, @ToDate, 103))
                  AND MONTH(r.ToDt) = MONTH(CONVERT(DATETIME, @ToDate, 103))
                  AND YEAR(r.ToDt) = YEAR(CONVERT(DATETIME, @ToDate, 103))
    WHERE
        b.IsReceived = 1
        AND b.isFeeStart = 1
        AND(b.DebitAmt != 0
            OR b.DebitAmt IS NOT NULL
            OR EXISTS(SELECT (CardVehicleId)
                      FROM MAS_CardVehicle v
                      WHERE
                          v.StartTime = @ToDtVehicle
                          AND (v.lastReceivable IS NULL OR v.lastReceivable = @ToDtVehicle)
                          AND v.ApartmentId = b.ApartmentId)
            OR EXISTS(SELECT ([TrackingId])
                      FROM [MAS_Service_Living_Tracking] t
                      WHERE IsCalculate = 1
                            AND ToDt = @ToDt
                            AND t.IsReceivable = 0
                            AND t.ApartmentId = b.ApartmentId
                            AND t.Amount != 0)
            OR (ISNULL(b.lastReceived, b.FreeToDt) = @ToDt))
        AND(@filter = '' OR b.RoomCode LIKE '%' + @filter + '%')
        AND (@ProjectCd ='-1' or b.projectCd = @ProjectCd) 
        AND r.isExpected = 1
        AND(r.ToDt = @ToDt) and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
        AND (@periods_oid IS NULL OR r.periods_oid = @periods_oid)

    --root	
    select
        recordsTotal = @Total
        ,recordsFiltered = @Total
        ,gridKey = @GridKey
        ,valid = 1
        
    --grid config
    IF @Offset = 0
        BEGIN
            SELECT *
            FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
            ORDER BY [ordinal];
        END;
    --
    SELECT b.[ApartmentId],
           b.[RoomCode],
           b.[Cif_No],
           CONVERT(NVARCHAR(10), b.[ReceiveDt], 103) AS [ReceiveDate],
           r.ReceiveId,
--            d.FullName,
           h.FullName,
           b.WaterwayArea,
           CONVERT(NVARCHAR(10), r.ToDt, 103) AS ToDate,
           CONVERT(NVARCHAR(10), r.[ExpireDate], 103) AS [ExpireDate],
           r.CommonFee,
           r.VehicleAmt,
           r.LivingAmt,
           livingElectricAmt = (SELECT TOP 1 SUM(a.TotalAmt)
                            FROM
                                [MAS_Service_Receivable] a
                                JOIN MAS_Service_Living_Tracking b ON a.srcId = b.TrackingId
                                JOIN MAS_Apartment_Service_Living c ON b.LivingId = c.LivingId
                                JOIN MAS_LivingTypes d ON c.LivingTypeId = d.LivingTypeId
                            WHERE
                                a.ReceiveId = r.ReceiveId
                                AND a.ServiceTypeId = 3),

           livingWaterAmt = (SELECT TOP 1 SUM(a.TotalAmt)
                            FROM
                                [MAS_Service_Receivable] a
                                JOIN MAS_Service_Living_Tracking b ON a.srcId = b.TrackingId
                                JOIN MAS_Apartment_Service_Living c ON b.LivingId = c.LivingId
                                JOIN MAS_LivingTypes d ON c.LivingTypeId = d.LivingTypeId
                            WHERE
                                a.ReceiveId = r.ReceiveId
                                AND a.ServiceTypeId = 4),
           r.ExtendAmt,
           r.TotalAmt,
           r.DebitAmt AS DebitAmt,
           ISNULL(r.isExpected, 0) AS isExpected,
           CONVERT(NVARCHAR(10), ISNULL(b.lastReceived, b.FeeStart), 103) AS AccrualLastDt,
           AccrualStatus = CASE
                               WHEN r.ToDt IS NULL THEN N'<span class="bg-warning noti-number ml5">Chưa tính</span>'
                               ELSE N'<span class="bg-success noti-number ml5">' + FORMAT(r.ToDt, 'MM/yyyy') + '</span>'
                           END,
          ItemStatusCode = itemStatus.StatusCode,
          ItemStatusName = CASE
                              WHEN itemStatus.StatusCode = 0 THEN N'<span class="bg-secondary noti-number ml5">Khởi tạo</span>'
                              WHEN itemStatus.StatusCode = 1 THEN N'<span class="bg-success noti-number ml5">Đã phát hành</span>'
                              WHEN itemStatus.StatusCode = 2 THEN N'<span class="bg-primary noti-number ml5">Đã thanh toán</span>'
                              WHEN itemStatus.StatusCode = 3 THEN N'<span class="bg-info noti-number ml5">Thanh toán một phần</span>'
                           END,
          r.IsBill,
          r.[IsDebt],
          r.[IsPayed],
          r.IsPush,
          r.BillUrl,
          r.BillViewUrl,
          r.PaidAmt,
          PayedDate = FORMAT(r.PayedDt, 'dd/MM/yyyy hh:mm:ss'),
          RemainAmt = r.TotalAmt - ISNULL(r.PaidAmt, 0),
          [ReceiptNos] = STUFF((SELECT ',' + [ReceiptNo]
                                 FROM MAS_Service_Receipts mr
                                 WHERE mr.ReceiveId = r.ReceiveId
                                 FOR XML PATH('')), 1, 1, '' )
    FROM
        MAS_Apartments b
        LEFT JOIN UserInfo u  ON b.UserLogin = u.loginName
        LEFT JOIN MAS_Customers d ON u.CustId = d.CustId
        OUTER APPLY (SELECT TOp(1) t1.*
                      FROM
                          MAS_Customers t1
                          join MAS_Apartment_Member b1 on t1.CustId = b1.CustId 
                          left join MAS_Customer_Relation d1 on b1.RelationId = d1.RelationId
                      WHERE b1.ApartmentId = b.ApartmentId and b1.RelationId = 0) h
        LEFT JOIN MAS_Service_ReceiveEntry r ON r.ApartmentId = b.ApartmentId
               --AND r.IsPayed = 0 -- Lỗi hóa đơn bị x2 nếu đã thanh toán rồi
               AND DAY(r.ToDt) = DAY(CONVERT(DATETIME, @ToDate, 103))
               AND MONTH(r.ToDt) = MONTH(CONVERT(DATETIME, @ToDate, 103))
               AND YEAR(r.ToDt) = YEAR(CONVERT(DATETIME, @ToDate, 103))
        OUTER APPLY (SELECT TOP 1 slt.Amount FROM MAS_Service_Living_Tracking slt WHERE slt.ApartmentId = r.ApartmentId AND slt.ToDt = CONVERT(DATE,r.ToDt,103) ORDER BY slt.ToDt DESC) x
        OUTER APPLY(SELECT StatusCode = CASE
                                          WHEN r.IsBill = 1 AND r.IsPayed <> 1 AND (r.PaidAmt IS NULL OR r.PaidAmt <= 0) THEN 1 -- Đã phát hành
                                          WHEN r.IsBill = 1 AND r.IsPayed = 1 THEN 2 -- Đã thanh toán
                                          WHEN r.TotalAmt > 0 AND r.PaidAmt > 0 AND r.TotalAmt > r.PaidAmt THEN 3 -- Thanh toán 1 phần
                                          ELSE 0 -- Khởi tạo
                                       END) itemStatus
    WHERE
        b.IsReceived = 1
        AND b.isFeeStart = 1
        AND(@filter = '' OR b.RoomCode LIKE '%' + @filter + '%')
        AND (@ProjectCd ='-1' or b.projectCd = @ProjectCd) 
        AND r.isExpected = 1
        AND(r.ToDt = @ToDt)
        and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
        AND (@periods_oid IS NULL OR r.periods_oid = @periods_oid)
    ORDER BY r.ToDt DESC, r.SysDate 
	OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_expected_get ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '@UserID ' + cast(@UserID as varchar(50));
    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Expectables', 'Get', @SessionID, @AddlInfo;
END CATCH;