-- =============================================
-- Author:      ThanhMT
-- Create date: 07/11/2025
-- Description: Dự thu các căn hộ trước khi xuất hóa đơn - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_receive_entry_page]
    @UserId UNIQUEIDENTIFIER = null,
    @project_code NVARCHAR(50) = NULL,
    @RevenuePeriodId UNIQUEIDENTIFIER = null,
    @ClientId nvarchar(50) = null,
    @Filter nvarchar(150) = NULL,
    @GridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @AcceptLanguage nvarchar(50) = 'vi-VN'
AS
BEGIN TRY
--     SET @project_code = '02';
    DECLARE @ViewGrid NVARCHAR(100) = 'config_sp_res_service_receive_entry_page';--sys_config_list
    SET @OffSet = ISNULL(@OffSet, 0);
    SET @PageSize = ISNULL(@PageSize, 20);
    SET @Filter = ISNULL(@Filter, '');

    SELECT
        b.[ApartmentId],
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
        AccrualStatus = IIF(r.ToDt IS NULL,
                            N'<span class="bg-warning noti-number ml5">Chưa tính</span>',
                            N'<span class="bg-success noti-number ml5">' + FORMAT(r.ToDt, 'MM/yyyy') + '</span>'),
        r.ToDt,
        r.SysDate
    INTO #MAS_Service_ReceiveEntry
    FROM
        MAS_Apartments b
        LEFT JOIN UserInfo u  ON b.UserLogin = u.loginName
        LEFT JOIN MAS_Customers d ON u.CustId = d.CustId
        LEFT JOIN MAS_Service_ReceiveEntry r ON r.ApartmentId = b.ApartmentId
        OUTER APPLY (SELECT TOP 1 slt.Amount FROM MAS_Service_Living_Tracking slt WHERE slt.ApartmentId = r.ApartmentId AND slt.ToDt = CONVERT(DATE,r.ToDt,103) ORDER BY slt.ToDt DESC) x
    WHERE
        b.IsReceived = 1
        --AND (@RevenuePeriodId IS NULL OR r.revenue_period_id = @RevenuePeriodId)
        AND b.isFeeStart = 1
        AND(@filter = '' OR b.RoomCode LIKE '%' + @filter + '%')
        AND (@project_code ='-1' or b.projectCd = @project_code) 
        and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @project_code)
    ORDER BY r.ToDt DESC, r.SysDate 

    SELECT *
    INTO #MAS_Service_ReceiveEntry_page
    FROM #MAS_Service_ReceiveEntry
    ORDER BY ToDt DESC, SysDate 
	OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

    SELECT
        RecordsTotal = (SELECT COUNT(*) FROM #MAS_Service_ReceiveEntry),
        RecordsFiltered = (SELECT COUNT(*) FROM #MAS_Service_ReceiveEntry_page),
        GridKey = @ViewGrid
	
    SELECT*FROM dbo.fn_config_list_gets_lang(@ViewGrid, @gridWidth, @AcceptLanguage) ORDER BY ordinal;
	
    SELECT * FROM #MAS_Service_ReceiveEntry_page

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH