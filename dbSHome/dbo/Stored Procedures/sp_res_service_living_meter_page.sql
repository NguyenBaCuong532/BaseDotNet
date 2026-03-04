--exec sp_res_service_living_meter_get 'ac943cfd-1216-476c-b240-8cb9facad4a9','swagger_development','01',1,'',7,2023,100,0,10,100,100
CREATE PROCEDURE [dbo].[sp_res_service_living_meter_page]
    @UserId UNIQUEIDENTIFIER = NULL,
    @clientId NVARCHAR(50) = null,
    @project_code NVARCHAR(40) = NULL,
    @periods_oid NVARCHAR(40) = NULL,
    @ProjectCd NVARCHAR(40) = NULL,
    @livingType INT = 1,
    @filter NVARCHAR(30) = NULL,
    @month INT = NULL,
    @year INT = NULL,
    @gridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    declare @Total bigint
    declare @GridKey nvarchar(100) = 'view_service_living_page'
    DECLARE @tbService TABLE(id [INT] NULL);
    DECLARE @ToDt DATETIME;

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    IF(@project_code IS NOT NULL AND @ProjectCd IS NULL)
        SET @ProjectCd = @project_code;
    
    SET @year = ISNULL(@year, (SELECT MAX(PeriodYear) FROM MAS_Service_Living_Tracking));
    SET @month = ISNULL(@month, 0); --(select max(PeriodMonth) from TRS_LivingService where PeriodYear = @year))

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;
		    
    IF(@periods_oid IS NOT NULL)
    BEGIN
        SELECT TOP 1
            @month = MONTH(end_date),
            @year = YEAR(end_date)
        FROM mas_billing_periods WHERE oid = @periods_oid
    END

    IF @month > 0
    BEGIN
        SELECT @Total = COUNT(a.LivingId)
        FROM
            MAS_Apartment_Service_Living a
            INNER JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
            LEFT JOIN(SELECT * FROM MAS_Service_Living_Tracking WHERE PeriodMonth = @month AND PeriodYear = @year) c ON a.LivingId = c.LivingId
        WHERE
            a.LivingTypeId = @livingType
            AND (@filter IS NULL OR b.RoomCode LIKE '%' + @filter + '%')
            AND (@ProjectCd ='-1' or b.projectCd = @ProjectCd) 
            and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
		
        --root
        select recordsTotal = @Total
            ,recordsFiltered = @Total
            ,gridKey = @GridKey
            ,valid = 1
          
        --grid config
        IF @Offset = 0
            SELECT * FROM [dbo].[fn_config_list_gets_lang](@GridKey, @gridWidth, @acceptLanguage) ORDER BY ordinal;

        --1 profile
        SELECT
            c.TrackingId,
            b.projectCd,
            a.[ApartmentId],
            b.RoomCode,
            d.FullName,
            ISNULL(c.[PeriodMonth], @month) AS PeriodMonth,
            ISNULL(c.[PeriodYear], @year) AS PeriodYear,
            CONVERT(NVARCHAR(20), ISNULL(c.[FromDt], a.MeterLastDt), 103) AS fromDate,
            CONVERT(NVARCHAR(20), c.[ToDt], 103) AS toDate,
            lt.LivingTypeName,
            ISNULL(c.[FromNum], a.MeterLastNum) AS [FromNum],
            c.[ToNum],
            c.TotalNum,
            CASE 
                WHEN ISNULL(pe.vat, pw.vat) = 0 THEN c.[Amount] 
                ELSE CAST(c.Amount / (1 + ISNULL(pe.vat, pw.vat) / 100.0) AS DECIMAL(18,2))
            END AS AmountBeforeVAT,
            c.[Amount],		   
            c.InputType,
            c.InputId,
            a.MeterSeri AS MeterSerial,
            ISNULL(c.IsCalculate, 0) AS IsCalculate,
--             ISNULL(c.IsBill, 0) AS IsBill,
            ISNULL(r.IsBill, 0) AS IsBill,
            ISNULL(c.IsReceivable, 0) AS IsReceivable,
            a.LivingId,
            a.LivingTypeId,
--             isExpected = 1
            ISNULL(r.isExpected, 0) AS isExpected
        FROM
            MAS_Apartment_Service_Living a
            INNER JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
            OUTER APPLY(SELECT TOP 1 * FROM MAS_Service_ReceiveEntry r WHERE r.ApartmentId = b.ApartmentId AND ((@periods_oid IS NULL AND 1 <> 1) OR periods_oid = @periods_oid)) r
            LEFT JOIN (SELECT * FROM MAS_Service_Living_Tracking WHERE PeriodMonth = @month AND PeriodYear = @year) c ON a.LivingId = c.LivingId
            LEFT JOIN UserInfo cc  ON cc.loginName = b.UserLogin              
            LEFT JOIN MAS_Customers d ON cc.CustId = d.CustId               
            LEFT JOIN [MAS_LivingTypes] lt  ON a.LivingTypeId = lt.LivingTypeId
            OUTER APPLY (SELECT top 1 vat from par_electric WHERE @livingType = 1 AND project_code = @ProjectCd) pe
            OUTER APPLY (SELECT top 1 vat from par_electric WHERE @livingType = 2 AND project_code = @ProjectCd) pw
        WHERE
            a.LivingTypeId = @livingType
            AND (@filter IS NULL OR b.RoomCode LIKE '%' + @filter + '%')
            AND (@ProjectCd ='-1' or b.projectCd = @ProjectCd) 
            and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
        ORDER BY RoomCode DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END;
    ELSE
    BEGIN
        SELECT @Total = COUNT(a.LivingId)
        FROM
            MAS_Apartment_Service_Living a
            INNER JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
            LEFT JOIN (SELECT * FROM MAS_Service_Living_Tracking WHERE PeriodYear = @year) c ON a.LivingId = c.LivingId
        WHERE
            (@filter = '' OR b.RoomCode LIKE '%' + @filter + '%')
            AND a.LivingTypeId = @livingType
            AND (@ProjectCd ='-1' or b.projectCd = @ProjectCd) 
            and exists(select 1 from UserProject x where x.projectCd = b.projectCd and x.userId = @userId)
		
        --root	
        select
            recordsTotal = @Total
            ,recordsFiltered = @Total
            ,gridKey = @GridKey
            ,valid = 1
            
        --grid config
        IF @Offset = 0
            SELECT * FROM [dbo].[fn_config_list_gets_lang](@GridKey, @gridWidth, @acceptLanguage) ORDER BY ordinal;

        --1 profile
        SELECT
            c.TrackingId,
            b.projectCd,
            a.[ApartmentId],
            b.RoomCode AS RoomCd,
            d.FullName,
            ISNULL(c.[PeriodMonth], @month) AS PeriodMonth,
            ISNULL(c.[PeriodYear], @year) AS PeriodYear,
            CONVERT(NVARCHAR(20), ISNULL(c.[FromDt], a.MeterLastDt), 103) AS fromDate,
            CONVERT(NVARCHAR(20), c.[ToDt], 103) AS toDate,
            lt.LivingTypeName,
            ISNULL(c.[FromNum], a.MeterLastNum) AS [FromNum],
            c.[ToNum],
            c.TotalNum,
            CASE 
                WHEN ISNULL(pe.vat, pw.vat) = 0 THEN c.[Amount] 
                ELSE CAST(c.Amount / (1 + ISNULL(pe.vat, pw.vat) / 100.0) AS DECIMAL(18,2))
            END AS AmountBeforeVAT,
            c.[Amount],
            c.InputType,
            c.InputId,
            a.MeterSeri AS MeterSerial,
            ISNULL(c.IsCalculate, 0) AS IsCalculate,
--             ISNULL(c.IsBill, 0) AS IsBill,
            ISNULL(r.IsBill, 0) AS IsBill,
            ISNULL(c.IsReceivable, 0) AS IsReceivable,
            a.LivingId
        FROM
            MAS_Apartment_Service_Living a
            INNER JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
            OUTER APPLY(SELECT TOP 1 * FROM MAS_Service_ReceiveEntry r WHERE r.ApartmentId = b.ApartmentId AND ((@periods_oid IS NULL AND 1 <> 1) OR periods_oid = @periods_oid)) r
            LEFT JOIN(SELECT * FROM MAS_Service_Living_Tracking WHERE PeriodYear = @year) c ON a.LivingId = c.LivingId
            LEFT JOIN UserInfo cc ON cc.loginName = b.UserLogin
            LEFT JOIN MAS_Customers d ON cc.CustId = d.CustId
            LEFT JOIN [MAS_LivingTypes] lt ON a.LivingTypeId = lt.LivingTypeId
            OUTER APPLY (SELECT top 1 vat from par_electric WHERE @livingType = 1 AND project_code = @ProjectCd) pe
            OUTER APPLY (SELECT top 1 vat from par_electric WHERE @livingType = 2 AND project_code = @ProjectCd) pw
        WHERE
            (@filter = '' OR b.RoomCode LIKE '%' + @filter + '%')
            AND a.LivingTypeId = @livingType
            AND (@ProjectCd ='-1' or b.projectCd = @ProjectCd) 
            and exists(select 1 from UserProject x where x.projectCd = b.projectCd and x.userId = @userId)			
        ORDER BY RoomCode DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_living_meter_get ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';
    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServiceLiving', 'GET', @SessionID, @AddlInfo;
END CATCH;