CREATE PROCEDURE [dbo].[sp_res_service_expected_page]
    @UserID UNIQUEIDENTIFIER = N'ea596efb-5eb1-4648-a219-089d2a4d310c',
    @clientId NVARCHAR(50) = NULL,
    @ProjectCd NVARCHAR(10) = '03',
    @ToDate NVARCHAR(10) = N'30/09/2025',
    @IsCalculated BIT = 0,
    @filter NVARCHAR(100) = N'R3-2909',
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
		AND(r.ToDt = @ToDt)
        and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)

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
           d.FullName,
           b.WaterwayArea,
           CONVERT(NVARCHAR(10), r.ToDt, 103) AS ToDate,
           CONVERT(NVARCHAR(10), r.[ExpireDate], 103) AS [ExpireDate],
           r.CommonFee,
           r.VehicleAmt,
           r.LivingAmt,
           livingElectricAmt =--ISNULL(x.Amount * 1.08, 0),
							(SELECT TOP 1 ROUND(Amount * 1.08, 0)
                                 FROM MAS_Service_Receivable
                                 WHERE
                                     ReceiveId = r.ReceiveId
                                     AND ServiceObject LIKE N'%Điện sinh hoạt%'),
           livingWaterAmt = (SELECT TOP 1 ROUND(Amount * 1.15, 0)
                             FROM MAS_Service_Receivable
                             WHERE
                                  ReceiveId = r.ReceiveId
                                  AND ServiceObject LIKE N'%Nước sinh hoạt%'),
           r.ExtendAmt,
           r.TotalAmt,
           r.DebitAmt AS DebitAmt,
           ISNULL(r.isExpected, 0) AS isExpected,
           CONVERT(NVARCHAR(10), ISNULL(b.lastReceived, b.FeeStart), 103) AS AccrualLastDt,
           AccrualStatus = CASE
                               WHEN r.ToDt IS NULL THEN N'<span class="bg-warning noti-number ml5">Chưa tính</span>'
                               ELSE N'<span class="bg-success noti-number ml5">' + FORMAT(r.ToDt, 'MM/yyyy') + '</span>'
                           END
    FROM
        MAS_Apartments b
        LEFT JOIN UserInfo u  ON b.UserLogin = u.loginName
        LEFT JOIN MAS_Customers d ON u.CustId = d.CustId
        LEFT JOIN MAS_Service_ReceiveEntry r ON r.ApartmentId = b.ApartmentId
               AND r.IsPayed = 0
               AND DAY(r.ToDt) = DAY(CONVERT(DATETIME, @ToDate, 103))
               AND MONTH(r.ToDt) = MONTH(CONVERT(DATETIME, @ToDate, 103))
               AND YEAR(r.ToDt) = YEAR(CONVERT(DATETIME, @ToDate, 103))
		OUTER APPLY (
			SELECT TOP 1 slt.Amount
			FROM MAS_Service_Living_Tracking slt
			WHERE slt.ApartmentId = r.ApartmentId
			  AND slt.ToDt = CONVERT(DATE,r.ToDt,103)
			ORDER BY slt.ToDt DESC
		) x
    WHERE
        b.IsReceived = 1
        AND b.isFeeStart = 1
        AND(@filter = '' OR b.RoomCode LIKE '%' + @filter + '%')
        AND (@ProjectCd ='-1' or b.projectCd = @ProjectCd) 
		AND(r.ToDt = @ToDt)
        and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
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