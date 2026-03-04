CREATE PROCEDURE [dbo].[sp_res_service_living_meter_calculator_field2]
    @project_code NVARCHAR(50) = NULL,
    @periods_oid NVARCHAR(50) = NULL,
    @TrackingId INT = 197170,
    @UserId UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'service_living_calculator2';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT @TrackingId TrackingId,
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
 --   IF @TrackingId IS NOT NULL
 --      AND EXISTS
 --   (
 --       SELECT 1
 --       FROM dbo.MAS_Service_Living_Tracking
 --       where TrackingId = @TrackingId
 --   )
	--BEGIN
	--    SELECT [table_name],
 --          [field_name],
 --          [view_type],
 --          [data_type],
 --          [ordinal],
 --          [columnLabel],
 --          [group_cd],
 --          CASE [data_type] 
	--			  WHEN 'nvarchar' THEN CONVERT(NVARCHAR(350), CASE [field_name] 
	--					WHEN 'ProjectCd' THEN a.MeterSeri
	--					END) 
	--			  WHEN 'date' THEN CONVERT(NVARCHAR(50), CASE [field_name] 
	--				  WHEN 'FromDate' THEN convert(nvarchar(10),a.MeterLastDt,103)
	--				  WHEN 'ToDate' THEN convert(nvarchar(10),c.ToDt,103)
	--				  END)
	--			 --WHEN 'uniqueidentifier' THEN CONVERT(NVARCHAR(350), CASE [field_name] 
	--				--		WHEN 'DrugStore' THEN (CAST(DrugStore AS VARCHAR(50))) 
							
	--				--  END)
	--			--WHEN 'decimal' THEN CAST(CASE [field_name] 
	--			--		WHEN 'Quantity' THEN c.Quantity
	--			--		WHEN 'Price' THEN c.Price
	--			--		WHEN 'Amount' THEN c.Amount
	--			--		END  AS NVARCHAR(100))

	--			--WHEN 'numeric' THEN CAST(CASE [field_name] 
	--			--		WHEN 'Cost' THEN Cost
	--			--		END  AS NVARCHAR(100))
	--			WHEN 'int' THEN CONVERT(NVARCHAR(50), CASE [field_name] 
	--						WHEN 'FromNum' THEN (CAST(isnull(c.[FromNum],a.MeterLastNum) AS VARCHAR(50))) 
	--						WHEN 'ToNum' THEN (CAST(c.ToNum AS VARCHAR(50))) 
	--						--WHEN 'TotalNum' THEN '0'
	--						--WHEN 'TotalNum' THEN (CAST(0 AS VARCHAR(50))) 
	--						ELSE s.columnDefault
	--				  END)
	--			--WHEN 'bit' THEN CONVERT(NVARCHAR(50), CASE [field_name] 
	--			--			WHEN 'isVehicleNone' THEN (CAST(CASE WHEN isVehicleNone = 1 THEN 'true' ELSE 'false' END  AS VARCHAR(50))) 
	--			--			END)
				
	--			END AS columnValue,
 --          [columnClass],
 --          [columnType],
 --          [columnObject],
 --          [isSpecial],
 --          [isRequire],
 --          [isDisable],
 --          [isVisiable],
 --          NULL AS [IsEmpty],
 --          ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
 --   --,case when @action = 'edit' then 1 else 0 end as isChange
 --   FROM sys_config_form s,
 --       MAS_Apartment_Service_Living a
 --       left join (select * from MAS_Service_Living_Tracking WHERE TrackingId = @TrackingId) c on a.LivingId = c.LivingId
 --   WHERE a.LivingId = @LivingId
 --   AND s.table_name = 'service_living'
 --   ORDER BY ordinal;
	--END
	--else
    BEGIN
        SELECT a.id,
               columnValue = CASE a.[data_type]
                                    WHEN 'nvarchar' THEN CONVERT(NVARCHAR(MAX), 
                                        CASE a.[field_name]
                                            WHEN 'periods_oid' THEN @periods_oid
                                        END)
                                    WHEN 'int' THEN CONVERT(NVARCHAR(MAX), 
                                        CASE a.[field_name]
                                            WHEN 'PeriodMonth' THEN MONTH(b.reference_date)
                                            WHEN 'PeriodYear' THEN YEAR(b.reference_date)
                                        END)
                                END,
               a.[table_name],
               a.[field_name],
               a.[view_type],
               a.[data_type],
               a.[ordinal],
               a.[columnLabel],
               a.[group_cd],
               a.[columnClass],
               a.[columnType],
               a.[columnObject],
               a.[isSpecial],
               a.[isRequire],
               [isDisable] = IIF(@periods_oid IS NOT NULL, 1, a.[isDisable]),
               a.[IsVisiable],
               a.[isEmpty],
               columnTooltip = ISNULL(a.columnTooltip, a.[columnLabel]),
               a.[columnDisplay],
               a.[isIgnore]
        FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
        OUTER APPLY(SELECT TOP 1 * FROM mas_billing_periods WHERE oid = @periods_oid) b
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
    SET @ErrorMsg = 'sp_res_service_living_meter_calculator_field2' + ERROR_MESSAGE();
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