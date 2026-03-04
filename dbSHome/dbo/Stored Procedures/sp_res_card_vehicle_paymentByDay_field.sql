
CREATE PROCEDURE [dbo].[sp_res_card_vehicle_paymentByDay_field] 
    @UserID UNIQUEIDENTIFIER = NULL,
    @ProjectCd NVARCHAR(10),
    @cardVehicleId NVARCHAR(100),
    @startDate NVARCHAR(10),
    @endDate NVARCHAR(10),
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'vehicle_paymentByDay';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT @cardVehicleId [@cardVehicleId]
        , tableKey = @tableKey,
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
    DECLARE @ToDt DATETIME

    SET @ToDt = convert(DATETIME, @endDate, 103)

    SELECT s.id
        , s.[table_name]
        , s.[field_name]
        , s.[view_type]
        , s.[data_type]
        , s.[ordinal]
        , s.[columnLabel]
        , s.[group_cd]
        , columnValue = CASE s.[data_type]
            WHEN 'nvarchar'
                THEN CONVERT(NVARCHAR(350), CASE s.[field_name]
                            WHEN 'CustId'
                                THEN a.CustId
                            WHEN 'Remart'
                                THEN c.remart
                            WHEN 'CustName'
                                THEN b.FullName
                            END)
            WHEN 'datetime'
                THEN CONVERT(NVARCHAR(50), CASE s.[field_name]
                            WHEN 'EndDate'
                                THEN convert(NVARCHAR(10), @ToDt, 103)
                            WHEN 'ExtraTime'
                                THEN convert(NVARCHAR(10), c.StartDate, 103)
                            WHEN 'StartDate'
                                THEN convert(NVARCHAR(10), c.StartDate, 103)
                            END)
            WHEN 'decimal'
                THEN CAST(CASE s.[field_name]
                            WHEN 'Quantity'
                                THEN c.Quantity
                            WHEN 'Price'
                                THEN c.Price
                            WHEN 'Amount'
                                THEN c.Amount
                            END AS NVARCHAR(100))
            WHEN 'int'
                THEN CONVERT(NVARCHAR(50), CASE s.[field_name]
                            WHEN 'CardVehicleId'
                                THEN (CAST(a.CardVehicleId AS VARCHAR(50)))
                            WHEN 'VehNum'
                                THEN (CAST(c.VehNum AS VARCHAR(50)))
                            END)
            END
        , s.[columnClass]
        , s.[columnType]
        , s.[columnObject]
        , s.[isSpecial]
        , s.[isRequire]
        , s.[isDisable]
        , s.[IsVisiable]
        , s.[isEmpty]
        , columnTooltip = ISNULL(s.columnTooltip, s.[columnLabel])
        , s.[columnDisplay]
        , s.[isIgnore]
    FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) s
    CROSS JOIN [dbo].[MAS_CardVehicle] a
    JOIN MAS_Customers b
        ON a.CustId = b.CustId
    JOIN [dbo].[fn_Hom_Vehicle_Payday_Get](@CardVehicleId, @ToDt) c
        ON a.CardVehicleId = c.CardVehicleId
    WHERE a.CardVehicleId = @cardVehicleId
        AND (
            a.[monthlyType] = 1
            OR a.[monthlyType] = 2
            )
        AND (s.IsVisiable = 1 OR s.isRequire = 1)
    ORDER BY s.ordinal
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_vehicle_paymentByDay_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'vehicle_paymentByDay'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;