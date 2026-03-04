CREATE PROCEDURE [dbo].[sp_res_service_living_meter_field]
    @userId UNIQUEIDENTIFIER = NULL,
    @project_code NVARCHAR(40) = NULL,
    @periods_oid NVARCHAR(50) = NULL,
    @LivingId INT = NULL,
    @TrackingId INT = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN',
    @MeterSerial NVARCHAR(30) = NULL,
    @FromDate NVARCHAR(10) = NULL,
    @ToDate NVARCHAR(10) = NULL,
    @FromNum INT = NULL,
    @ToNum INT = NULL,
    @TotalNum int = NULL
AS
BEGIN TRY
    
    IF(@periods_oid IS NOT NULL AND (@TrackingId IS NULL OR @TrackingId <= 0))
    BEGIN
        SELECT TOP 1
--             @FromDate = ISNULL(@FromDate, a.start_date),
            @ToDate = ISNULL(@ToDate, a.end_date)
        FROM mas_billing_periods a
        WHERE oid = @periods_oid
    END
    
    
    -- Check IsBill to Disable UI
    DECLARE @BlockEdit BIT = 0;
    IF @LivingId IS NOT NULL
    BEGIN
        DECLARE @ChkApartmentId INT;
        SELECT @ChkApartmentId = ApartmentId FROM MAS_Apartment_Service_Living WHERE LivingId = @LivingId;
        
        DECLARE @ChkMonth INT;
        DECLARE @ChkYear INT;

        IF @ToDate IS NOT NULL 
        BEGIN
             SET @ChkMonth = MONTH(CONVERT(DATETIME, @ToDate, 103));
             SET @ChkYear = YEAR(CONVERT(DATETIME, @ToDate, 103));
        END
        ELSE IF @TrackingId > 0
        BEGIN
             SELECT @ChkMonth = MONTH(ToDt), @ChkYear = YEAR(ToDt) FROM MAS_Service_Living_Tracking WHERE TrackingId = @TrackingId;
        END
        ELSE IF @periods_oid IS NOT NULL
        BEGIN
             SELECT @ChkMonth = MONTH(end_date), @ChkYear = YEAR(end_date) FROM mas_billing_periods WHERE oid = @periods_oid;
        END

        IF @ChkMonth IS NOT NULL AND EXISTS (
            SELECT 1 FROM MAS_Service_ReceiveEntry 
            WHERE ApartmentId = @ChkApartmentId 
            AND MONTH(ToDt) = @ChkMonth 
            AND YEAR(ToDt) = @ChkYear 
            AND IsBill = 1
        )
        BEGIN
            SET @BlockEdit = 1;
        END
    END

    --begin
    --1 thong tin chung
    SELECT @LivingId LivingId,@TrackingId TrackingId,[tableKey] = 'service_living';
    --2- cac group
    SELECT 1 [group_cd],
           N'Thông tin chung' [group_name];
    --3 tung o trong group
    IF @LivingId IS NOT NULL
       AND EXISTS
    (
        SELECT 1
        FROM dbo.MAS_Apartment_Service_Living
        where LivingId = @LivingId
    )
	BEGIN
	    SELECT s.[id],
           s.[table_name],
           s.[field_name],
           s.[view_type],
           s.[data_type],
           s.[ordinal],
           s.[columnLabel],
           s.[group_cd],
           CASE [data_type] 
              WHEN 'nvarchar' THEN CONVERT(NVARCHAR(350),
                  CASE [field_name] 
                      WHEN 'MeterSerial' THEN a.MeterSeri
                      WHEN 'periods_oid' THEN @periods_oid
                  END)
              WHEN 'date' THEN CONVERT(NVARCHAR(50), 
                  CASE [field_name] 
                      WHEN 'FromDate' THEN ISNULL(@FromDate, CONVERT(NVARCHAR(10), ISNULL(c.FromDt, a.MeterLastDt), 103))
                      WHEN 'ToDate' THEN ISNULL(@ToDate, convert(nvarchar(10), ISNULL(@ToDate, c.ToDt), 103))
                      ELSE NULL
                  END)
              WHEN 'int' THEN CONVERT(NVARCHAR(50),
                  CASE [field_name] 
                      WHEN 'LivingId' THEN @LivingId
                      WHEN 'TrackingId' THEN @TrackingId
                      WHEN 'FromNum' THEN IIF(@FromNum IS NOT NULL, @FromNum, CAST(isnull(c.[FromNum],a.MeterLastNum) AS VARCHAR(50)))
                      WHEN 'ToNum' THEN IIF(@ToNum IS NOT NULL, @ToNum, CAST(c.ToNum AS VARCHAR(50)))
                      WHEN 'TotalNum' THEN IIF(@FromNum IS NOT NULL AND @ToNum IS NOT NULL, @ToNum - @FromNum, c.TotalNum)
                      ELSE s.columnDefault
                END)
           END AS columnValue,
           [columnClass],
           [columnType],
           [columnObject],
           [isSpecial],
           [isRequire],
           CASE WHEN @BlockEdit = 1 THEN 1 ELSE [isDisable] END AS [isDisable],
           [isVisiable],
           NULL AS [IsEmpty],
           ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
           , s.[columnDisplay]
           , s.[isIgnore]
    --,case when @action = 'edit' then 1 else 0 end as isChange
    FROM fn_config_form_gets('service_living', @acceptLanguage) s,
        MAS_Apartment_Service_Living a
        left join (select * from MAS_Service_Living_Tracking WHERE TrackingId = @TrackingId) c on a.LivingId = c.LivingId
    WHERE a.LivingId = @LivingId
    ORDER BY s.ordinal;
	END
	else
    BEGIN
        SELECT [id],
               [table_name],
               [field_name],
               [view_type],
               [data_type],
               [ordinal],
               [columnLabel],
               group_cd,
               a.columnDefault AS columnValue,
               [columnClass],
               [columnType],
               [columnObject],
               [isSpecial],
               [isRequire],
               [isDisable],
               a.[isVisiable],
               --,[IsEmpty]
               ISNULL(a.columnTooltip, a.[columnLabel]) AS columnTooltip
               , a.[columnDisplay]
               , a.[isIgnore]
        FROM fn_config_form_gets('service_living', @acceptLanguage) a
        ORDER BY a.ordinal;
    END
    
    
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_living_meter_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'service living',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;