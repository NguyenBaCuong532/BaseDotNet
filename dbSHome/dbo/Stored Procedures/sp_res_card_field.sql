
CREATE PROCEDURE [dbo].[sp_res_card_field] 
    @userId UNIQUEIDENTIFIER = NULL,
    @RoomCd NVARCHAR(450) = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @group_key VARCHAR(50) = 'common_group';
    DECLARE @table_key VARCHAR(50) = 'card';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        RoomCd = @RoomCd,
        tableKey = @table_key,
        groupKey = @group_key;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
    ORDER BY intOrder;

    --3 tung o trong group
    --IF @RoomCd IS NOT NULL
    --   AND EXISTS
    --(
    --    SELECT 1
    --    FROM dbo.MAS_Apartments
    --    where RoomCode = @RoomCd
    --)
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
    --					WHEN 'CustId' THEN a.CustId
    --					WHEN 'CustPhone' THEN a.CustPhone
    --					WHEN 'ContractNo' THEN a.ContractNo
    --					WHEN 'MeterSerial' THEN a.MeterSeri
    --					WHEN 'DeliverName' THEN a.DeliverName
    --					WHEN 'ProviderCd' THEN a.ProviderCd
    --					WHEN 'Note' THEN a.Note
    --					WHEN 'EmployeeCd' THEN a.EmployeeCd
    --					END) 
    --			  WHEN 'date' THEN CONVERT(NVARCHAR(50), CASE [field_name] 
    --				  WHEN 'ContractDate' THEN convert(nvarchar(10),a.ContractDt,103)
    --				  WHEN 'StartDate' THEN convert(nvarchar(10),a.MeterDate,103)
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
    --						WHEN 'ApartmentId' THEN (CAST(a.ApartmentId AS VARCHAR(50))) 
    --						WHEN 'MeterNumber' THEN (CAST(a.MeterNum AS VARCHAR(50))) 
    --						WHEN 'LivingType' THEN (CAST(a.LivingTypeId AS VARCHAR(50))) 
    --						WHEN 'LivingId' THEN (CAST(a.LivingId AS VARCHAR(50))) 
    --						WHEN 'NumPersonWater' THEN (CAST(a.NumPersonWater AS VARCHAR(50))) 
    --						--WHEN 'VehiclePayId' THEN (CAST(VehiclePayId AS VARCHAR(50))) 
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
    --       --JOIN MAS_Apartments b
    --       --    ON a.ApartmentId = b.ApartmentId
    --       --JOIN MAS_LivingTypes c
    --       --    ON a.LivingTypeId = c.LivingTypeId
    --       --LEFT JOIN MAS_ServiceProvider d 
    --       --    ON a.ProviderCd = d.ProviderCd
    --   WHERE a.LivingId = @LivingId
    --   AND s.table_name = 'apartment_service_living'
    --   ORDER BY ordinal;
    --END
    --else
    BEGIN
        SELECT 
            a.id
            , a.table_name
            , a.field_name
            , a.view_type
            , a.data_type
            , a.ordinal
            , a.columnLabel
            , a.group_cd
            , a.columnDefault AS columnValue
            , a.columnClass
            , a.columnType
            , a.columnObject
            , a.isSpecial
            , a.isRequire
            , a.isDisable
            , a.IsVisiable
            , a.isEmpty
            , columnTooltip = ISNULL(a.columnTooltip, a.columnLabel)
            , a.columnDisplay
            , a.isIgnore
        FROM dbo.fn_config_form_gets(@table_key, @acceptLanguage) a
        WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
        ORDER BY a.ordinal;
    END
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'apartment_vehicle'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;