CREATE PROCEDURE [dbo].[sp_res_vehicle_cancel_info]
     @CardVehicleId INT = NULL,
	 @UserId UNIQUEIDENTIFIER = NULL,
	 @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @tableKey NVARCHAR(100) = N'apartment_vehicle_card';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    SELECT CardVehicleId = @CardVehicleId
        , tableKey = @tableKey
        , groupKey = @groupKey;

    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
    ORDER BY intOrder;

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu field với columnValue động
    -- =============================================
    IF EXISTS (
            SELECT 1
            FROM dbo.MAS_CardVehicle
            WHERE CardVehicleId = @CardVehicleId
            )
    BEGIN
        SELECT s.id
            , s.[table_name]
            , s.[field_name]
            , s.[view_type]
            , s.[data_type]
            , s.[ordinal]
            , s.[columnLabel]
            , s.[group_cd]
            , columnValue = ISNULL(CASE s.[field_name]
                    WHEN 'CardVehicleId'
                        THEN CONVERT(NVARCHAR(500), a.CardVehicleId)
                    WHEN 'AssignDate'
                        THEN CONVERT(NVARCHAR(20), a.[AssignDate], 103)
                    WHEN 'VehicleNo'
                        THEN a.VehicleNo
                    WHEN 'VehicleTypeID'
                        THEN CONVERT(NVARCHAR(10), a.VehicleTypeId)
                    WHEN 'VehicleTypeName'
                        THEN CONVERT(NVARCHAR(500), e.VehicleTypeName)
                    WHEN 'VehicleName'
                        THEN a.VehicleName
                    WHEN 'StartTime'
                        THEN CONVERT(NVARCHAR(10), a.[StartTime], 103)
                    WHEN 'EndTime'
                        THEN CONVERT(NVARCHAR(10), a.[EndTime], 103)
                    WHEN 'ServiceId'
                        THEN CONVERT(NVARCHAR(500), a.ServiceId)
                    WHEN 'ServiceName'
                        THEN N'Vé tháng - ' + e.VehicleTypeName
                    WHEN 'Status'
                        THEN CONVERT(NVARCHAR(500), a.[Status])
                    WHEN 'VehicleStatusName'
                        THEN mv.StatusName
                    WHEN 'CardCd'
                        THEN d.CardCd
					WHEN 'AuthName'
						THEN u.fullName
					WHEN 'AuthDate'
						THEN CONVERT(NVARCHAR(20), a.Auth_Dt, 103)
                    END, s.[columnDefault])
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
        INNER JOIN [MAS_Cards] d
            ON a.CardId = d.CardId
        LEFT JOIN MAS_VehicleTypes e
            ON a.VehicleTypeId = e.VehicleTypeId
		LEFT JOIN Users u
			ON u.userId = a.Auth_id
        LEFT JOIN MAS_VehicleStatus mv
            ON a.STATUS = mv.StatusId
        WHERE a.CardVehicleId = @CardVehicleId
          AND (s.IsVisiable = 1 OR s.isRequire = 1)
        ORDER BY s.ordinal;
    END;
    ELSE
    BEGIN
        SELECT a.id
            , a.[table_name]
            , a.[field_name]
            , a.[view_type]
            , a.[data_type]
            , a.[ordinal]
            , a.[columnLabel]
            , a.[group_cd]
            , columnValue = IIF(a.field_name = 'startTime', CONVERT(NVARCHAR(10), GETDATE(), 103), a.columnDefault)
            , a.[columnClass]
            , a.[columnType]
            , a.[columnObject]
            , a.[isSpecial]
            , a.[isRequire]
            , a.[isDisable]
            , a.[IsVisiable]
            , a.[isEmpty]
            , columnTooltip = ISNULL(a.columnTooltip, a.[columnLabel])
            , a.[columnDisplay]
            , a.[isIgnore]
        FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
        WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
        ORDER BY a.ordinal;
    END;
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_vehicle_card_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'apartment_vehicle_card'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;