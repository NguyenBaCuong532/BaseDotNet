
CREATE PROCEDURE [dbo].[sp_res_card_vehicle_field] 
     @CardVehicleId INT = NULL,
     @cardVehicleOid UNIQUEIDENTIFIER = NULL,
     @UserId UNIQUEIDENTIFIER,
     @AcceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;
    IF @cardVehicleOid IS NOT NULL
        SET @CardVehicleId = (SELECT CardVehicleId FROM MAS_CardVehicle WHERE oid = @cardVehicleOid);

    DECLARE @DomainUrl NVARCHAR(200) = 'https://cdn.sunshinegroup.vn/media/';
    DECLARE @group_key NVARCHAR(50) = 'common_group';
    DECLARE @table_key NVARCHAR(50) = 'apartment_vehicle_card';
    DECLARE @authName  NVARCHAR(50) = (SELECT fullName FROM dbo.Users WHERE userId = @UserId);

    -- RS0: key
    SELECT CardVehicleId = @CardVehicleId, tableKey = @table_key, groupKey = @group_key;

    -- RS1: group
    SELECT * FROM [dbo].[fn_get_field_group_lang](@group_key, @AcceptLanguage) ORDER BY intOrder;

    IF EXISTS (SELECT 1 FROM dbo.MAS_CardVehicle WHERE CardVehicleId = @CardVehicleId)
    BEGIN
        SELECT 
            s.[table_name],
            s.[field_name],
            s.[view_type],
            s.[data_type],
            s.[ordinal],
            s.[columnLabel],
            s.[group_cd],

            columnValue =
                CASE 
                    WHEN s.field_name IN ('ImageUrl','ImageUrl2','ImageUrl3','ImageUrl4','ImageUrl5') THEN
                        CASE s.field_name
                            WHEN 'ImageUrl' THEN
                                CASE
                                    WHEN NULLIF(LTRIM(RTRIM(a.ImageUrl)), '') IS NULL THEN NULL
                                    WHEN LTRIM(RTRIM(a.ImageUrl)) IN (@DomainUrl, '/media/', 'media/') THEN NULL
                                    WHEN a.ImageUrl LIKE 'http%' THEN a.ImageUrl
                                    ELSE @DomainUrl + a.ImageUrl
                                END
                            WHEN 'ImageUrl2' THEN
                                CASE
                                    WHEN NULLIF(LTRIM(RTRIM(a.ImageUrl2)), '') IS NULL THEN NULL
                                    WHEN LTRIM(RTRIM(a.ImageUrl2)) IN (@DomainUrl, '/media/', 'media/') THEN NULL
                                    WHEN a.ImageUrl2 LIKE 'http%' THEN a.ImageUrl2
                                    ELSE @DomainUrl + a.ImageUrl2
                                END
                            WHEN 'ImageUrl3' THEN
                                CASE
                                    WHEN NULLIF(LTRIM(RTRIM(a.ImageUrl3)), '') IS NULL THEN NULL
                                    WHEN LTRIM(RTRIM(a.ImageUrl3)) IN (@DomainUrl, '/media/', 'media/') THEN NULL
                                    WHEN a.ImageUrl3 LIKE 'http%' THEN a.ImageUrl3
                                    ELSE @DomainUrl + a.ImageUrl3
                                END
                            WHEN 'ImageUrl4' THEN
                                CASE
                                    WHEN NULLIF(LTRIM(RTRIM(a.ImageUrl4)), '') IS NULL THEN NULL
                                    WHEN LTRIM(RTRIM(a.ImageUrl4)) IN (@DomainUrl, '/media/', 'media/') THEN NULL
                                    WHEN a.ImageUrl4 LIKE 'http%' THEN a.ImageUrl4
                                    ELSE @DomainUrl + a.ImageUrl4
                                END
                            WHEN 'ImageUrl5' THEN
                                CASE
                                    WHEN NULLIF(LTRIM(RTRIM(a.ImageUrl5)), '') IS NULL THEN NULL
                                    WHEN LTRIM(RTRIM(a.ImageUrl5)) IN (@DomainUrl, '/media/', 'media/') THEN NULL
                                    WHEN a.ImageUrl5 LIKE 'http%' THEN a.ImageUrl5
                                    ELSE @DomainUrl + a.ImageUrl5
                                END
                        END
                    ELSE
                        ISNULL(
                            CASE s.field_name
                                WHEN 'CardVehicleId' THEN CONVERT(NVARCHAR(500), a.CardVehicleId)
                                WHEN 'VehicleNo' THEN a.VehicleNo
                                WHEN 'VehicleName' THEN a.VehicleName
                                WHEN 'VehicleTypeID' THEN CONVERT(NVARCHAR(10), a.VehicleTypeId)
                                WHEN 'VehicleTypeName' THEN CONVERT(NVARCHAR(500), e.VehicleTypeName)
                                WHEN 'AssignDate' THEN CONVERT(NVARCHAR(20), a.[AssignDate], 103)
                                WHEN 'StartTime' THEN CONVERT(NVARCHAR(10), a.[StartTime], 103)
                                WHEN 'EndTime' THEN CONVERT(NVARCHAR(10), a.[EndTime], 103)
                                WHEN 'ServiceId' THEN CONVERT(NVARCHAR(500), a.ServiceId)
                                WHEN 'ServiceName' THEN N'Vé tháng - ' + e.VehicleTypeName
                                WHEN 'Status' THEN CONVERT(NVARCHAR(500), a.[Status])
                                WHEN 'VehicleStatusName' THEN mv.StatusName
                                WHEN 'CardCd' THEN d.CardCd
                                WHEN 'AuthName' THEN u.fullName
                                WHEN 'AuthDate' THEN CONVERT(NVARCHAR(20), a.Auth_Dt, 103)
                                WHEN 'ProjectCd' THEN CONVERT(NVARCHAR(500), d.ProjectCd)
                                WHEN 'VehicleColor' THEN a.VehicleColor
                                WHEN 'DueDate' THEN CONVERT(NVARCHAR(500), a.DueDate, 103)
                                WHEN 'RadioButton' THEN CONVERT(NVARCHAR(500), CASE WHEN a.IsMonthlyScripts = 1 THEN 'true' ELSE 'false' END)
                                WHEN 'RadioButton1' THEN CONVERT(NVARCHAR(500), CASE WHEN a.IsMonthlyScripts = 1 THEN 'false' ELSE 'true' END)
                            END,
                            s.columnDefault
                        )
                END,

            s.[columnClass],
            s.[columnType],
            s.[columnObject],
            s.[isSpecial],
            s.[isRequire],
            [isDisable] = CASE s.field_name WHEN 'DueDate' THEN IIF(a.IsMonthlyScripts = 1, 'true', 'false') ELSE s.[isDisable] END,
            s.[isVisiable],
            [IsEmpty] = NULL,
            columnTooltip = ISNULL(s.columnTooltip, s.[columnLabel])
            , s.[columnDisplay]
            , s.[isIgnore]
        FROM fn_config_form_gets(@table_key, @AcceptLanguage) s
        LEFT JOIN dbo.MAS_CardVehicle a 
               ON a.CardVehicleId = @CardVehicleId
        INNER JOIN MAS_Cards d 
               ON a.CardId = d.CardId
        LEFT JOIN MAS_VehicleTypes e 
               ON a.VehicleTypeId = e.VehicleTypeId
        LEFT JOIN Users u 
               ON u.userId = a.Auth_id
        LEFT JOIN MAS_VehicleStatus mv 
               ON a.STATUS = mv.StatusId
        ORDER BY s.ordinal;
    END
    ELSE
    BEGIN
        SELECT 
            a.[id],
            a.[table_name],
            a.[field_name],
            a.[view_type],
            a.[data_type],
            a.[ordinal],
            a.[columnLabel],
            a.[group_cd],
            columnValue = ISNULL(
                CASE a.[field_name]
                    WHEN 'AuthDate' THEN CONVERT(NVARCHAR(20), GETDATE(), 103)
                    WHEN 'StartTime' THEN CONVERT(NVARCHAR(10), GETDATE(), 103)
                    WHEN 'AuthName' THEN @authName
                END,
                a.[columnDefault]
            ),
            a.[columnClass],
            a.[columnType],
            a.[columnObject],
            a.[isSpecial],
            a.[isRequire],
            a.[isDisable],
            a.[isVisiable],
            columnTooltip = ISNULL(a.columnTooltip, a.[columnLabel])
            , a.[columnDisplay]
            , a.[isIgnore]
        FROM fn_config_form_gets(@table_key, @AcceptLanguage) a
        ORDER BY a.ordinal;
    END
END TRY
BEGIN CATCH 
    SELECT ERROR_MESSAGE() AS [messages];
END CATCH;