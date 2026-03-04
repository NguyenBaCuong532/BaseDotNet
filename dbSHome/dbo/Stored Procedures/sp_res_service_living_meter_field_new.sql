CREATE PROCEDURE [dbo].[sp_res_service_living_meter_field_new]
    @userId UNIQUEIDENTIFIER = NULL,
	@LivingId INT,
	@TrackingId INT,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'service_living';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT @LivingId LivingId,
        @TrackingId TrackingId,
        tableKey = @tableKey,
        groupKey = @groupKey;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
    ORDER BY intOrder;

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu field với columnValue động
    -- =============================================
    IF @LivingId IS NOT NULL
       AND EXISTS
    (
        SELECT 1
        FROM dbo.MAS_Apartment_Service_Living
        where LivingId = @LivingId
    )
	BEGIN
	    SELECT s.id,
           s.[table_name],
           s.[field_name],
           s.[view_type],
           s.[data_type],
           s.[ordinal],
           s.[columnLabel],
           s.[group_cd],
           columnValue = CASE s.[data_type] 
				  WHEN 'nvarchar' THEN CONVERT(NVARCHAR(350), CASE s.[field_name] 
						WHEN 'MeterSerial' THEN a.MeterSeri
						END) 
				  WHEN 'date' THEN CONVERT(NVARCHAR(50), CASE s.[field_name] 
					  WHEN 'FromDate' THEN convert(nvarchar(10),a.MeterLastDt,103)
					  WHEN 'ToDate' THEN convert(nvarchar(10),c.ToDt,103)
					  END)
				WHEN 'int' THEN CONVERT(NVARCHAR(50), CASE s.[field_name] 
							WHEN 'FromNum' THEN (CAST(isnull(c.[FromNum],a.MeterLastNum) AS VARCHAR(50))) 
							WHEN 'ToNum' THEN (CAST(c.ToNum AS VARCHAR(50))) 
							WHEN 'TotalNum' THEN c.TotalNum
							ELSE s.columnDefault
					  END)
				END,
           s.[columnClass],
           s.[columnType],
           s.[columnObject],
           s.[isSpecial],
           s.[isRequire],
           s.[isDisable],
           s.[IsVisiable],
           s.[isEmpty],
           columnTooltip = ISNULL(s.columnTooltip, s.[columnLabel]),
           s.[columnDisplay],
           s.[isIgnore]
    FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) s
    CROSS JOIN MAS_Apartment_Service_Living a
    LEFT JOIN (SELECT * FROM MAS_Service_Living_Tracking WHERE TrackingId = @TrackingId) c ON a.LivingId = c.LivingId
    WHERE a.LivingId = @LivingId
      AND (s.IsVisiable = 1 OR s.isRequire = 1)
    ORDER BY s.ordinal;
	END
	ELSE
    BEGIN
        SELECT a.id,
               a.[table_name],
               a.[field_name],
               a.[view_type],
               a.[data_type],
               a.[ordinal],
               a.[columnLabel],
               a.[group_cd],
               columnValue = a.columnDefault,
               a.[columnClass],
               a.[columnType],
               a.[columnObject],
               a.[isSpecial],
               a.[isRequire],
               a.[isDisable],
               a.[IsVisiable],
               a.[isEmpty],
               columnTooltip = ISNULL(a.columnTooltip, a.[columnLabel]),
               a.[columnDisplay],
               a.[isIgnore]
        FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
        WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
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