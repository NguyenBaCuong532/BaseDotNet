
CREATE   PROCEDURE [dbo].[sp_res_partner_vehicle_detail_fields]
    @UserId UNIQUEIDENTIFIER = NULL,
    @id     BIGINT = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;
    SET @id = ISNULL(@id, 0);

   
    SELECT TOP (1)
       
        p.partner_id              AS [id],
        p.partner_cd              AS partner_cd,
        p.partner_name            AS partner_name,
        p.partner_type_id         AS partner_type_id,
        pt.type_name              AS partner_type_name,
        p.tax_code                AS tax_code,
        p.company_phone           AS company_phone,
        p.company_email           AS company_email,
        CONVERT(NVARCHAR(50), p.contract_start_dt, 103) AS contract_start_dt,
        CONVERT(NVARCHAR(50), p.contract_end_dt,   103) AS contract_end_dt,

     
        v.VehicleId               AS vehicle_id,
        v.CardCode                AS card_code,
        v.LicensePlate            AS license_plate,
        v.VehicleType             AS vehicle_type,
        CASE v.VehicleType
            WHEN 1 THEN N'Ô tô'
            WHEN 2 THEN N'Xe máy'
            WHEN 3 THEN N'Xe đạp'
            WHEN 4 THEN N'Xe máy điện'
            WHEN 5 THEN N'Xe đạp điện'
            ELSE N'-'
        END                       AS vehicle_type_name,
        v.OwnerName               AS owner_name,
        CONVERT(NVARCHAR(50), v.StartDate, 103) AS start_date,
        v.Status                  AS [status],
        CASE v.Status
            WHEN 1 THEN N'Khởi tạo'
            WHEN 2 THEN N'Hoạt động'
            WHEN 3 THEN N'Quá hạn'
            WHEN 4 THEN N'Khóa thẻ'
            WHEN 5 THEN N'Hủy'
            ELSE N'-'
        END                       AS status_name
    FROM dbo.MAS_PartnerVehiclePage v
    LEFT JOIN dbo.MAS_CardPartner p   ON p.partner_id = v.PartnerId
    LEFT JOIN dbo.MAS_PartnerType pt ON pt.partner_type_id = p.partner_type_id
    WHERE v.VehicleId = @id;

    SELECT 1 AS group_cd, N'Thông tin xe' AS group_name
    UNION ALL
    SELECT 2 AS group_cd, N'Tệp đính kèm' AS group_name;

  
    SELECT
        v.VehicleId AS [id],
        a.table_name,
        a.field_name,
        a.view_type,
        a.data_type,
        a.ordinal,
        a.columnLabel,
        a.group_cd,

        columnValue =
            ISNULL(
                CASE a.data_type
                    WHEN 'nvarchar' THEN CONVERT(NVARCHAR(MAX),
                        CASE a.field_name
                            WHEN 'CardCode'     THEN v.CardCode
                            WHEN 'PartnerName'  THEN v.PartnerName
                            WHEN 'OwnerName'    THEN v.OwnerName
                            WHEN 'LicensePlate' THEN v.LicensePlate
                            WHEN 'Brand'        THEN v.Brand
                            WHEN 'Color'        THEN v.Color
                            WHEN 'AttachFile'   THEN v.AttachFile
                            ELSE NULL
                        END
                    )

                    WHEN 'int' THEN CONVERT(NVARCHAR(100),
                        CASE a.field_name
                            WHEN 'VehicleType' THEN v.VehicleType
                            WHEN 'Status'      THEN v.Status
                            ELSE NULL
                        END
                    )

                    WHEN 'date' THEN CONVERT(NVARCHAR(50),
                        CASE a.field_name
                            WHEN 'StartDate' THEN v.StartDate
                            ELSE NULL
                        END, 103
                    )

                    ELSE NULL
                END,
            a.columnDefault),

        a.columnClass,
        a.columnType,

        columnObject =
            CASE
                WHEN a.field_name = 'AttachFile'
                    THEN CONCAT(ISNULL(a.columnObject, N''), ISNULL(v.AttachFile, N''))
                ELSE a.columnObject
            END,

        a.isSpecial,
        a.isRequire,
        a.isDisable,
        a.IsVisiable,
        ISNULL(a.columnTooltip, a.columnLabel) AS columnTooltip
    FROM dbo.fn_config_form_gets(N'partner_vehicle_detail', @AcceptLanguage) a
    JOIN dbo.MAS_PartnerVehiclePage v ON v.VehicleId = @id
    WHERE a.table_name = N'partner_vehicle_detail'
      AND ISNULL(a.is_active, 1) = 1
      AND ISNULL(a.IsVisiable, 1) = 1
    ORDER BY a.group_cd, a.ordinal;

END TRY
BEGIN CATCH
   
    SELECT TOP 0
        CAST(NULL AS BIGINT) AS [id],
        CAST(NULL AS NVARCHAR(50)) AS partner_cd,
        CAST(NULL AS NVARCHAR(255)) AS partner_name,
        CAST(NULL AS INT) AS partner_type_id,
        CAST(NULL AS NVARCHAR(255)) AS partner_type_name,
        CAST(NULL AS NVARCHAR(50)) AS tax_code,
        CAST(NULL AS NVARCHAR(50)) AS company_phone,
        CAST(NULL AS NVARCHAR(100)) AS company_email,
        CAST(NULL AS NVARCHAR(50)) AS contract_start_dt,
        CAST(NULL AS NVARCHAR(50)) AS contract_end_dt,
        CAST(NULL AS BIGINT) AS vehicle_id,
        CAST(NULL AS NVARCHAR(50)) AS card_code,
        CAST(NULL AS NVARCHAR(20)) AS license_plate,
        CAST(NULL AS INT) AS vehicle_type,
        CAST(NULL AS NVARCHAR(50)) AS vehicle_type_name,
        CAST(NULL AS NVARCHAR(100)) AS owner_name,
        CAST(NULL AS NVARCHAR(50)) AS start_date,
        CAST(NULL AS INT) AS [status],
        CAST(NULL AS NVARCHAR(50)) AS status_name;

    SELECT 1 AS group_cd, N'Thông tin xe' AS group_name;

    SELECT TOP 0
        CAST(NULL AS BIGINT) AS [id],
        CAST(NULL AS NVARCHAR(100)) AS table_name,
        CAST(NULL AS NVARCHAR(100)) AS field_name,
        CAST(NULL AS NVARCHAR(50)) AS view_type,
        CAST(NULL AS NVARCHAR(50)) AS data_type,
        CAST(NULL AS INT) AS ordinal,
        CAST(NULL AS NVARCHAR(255)) AS columnLabel,
        CAST(NULL AS INT) AS group_cd,
        CAST(NULL AS NVARCHAR(MAX)) AS columnValue,
        CAST(NULL AS NVARCHAR(100)) AS columnClass,
        CAST(NULL AS NVARCHAR(100)) AS columnType,
        CAST(NULL AS NVARCHAR(MAX)) AS columnObject,
        CAST(NULL AS BIT) AS isSpecial,
        CAST(NULL AS BIT) AS isRequire,
        CAST(NULL AS BIT) AS isDisable,
        CAST(NULL AS BIT) AS IsVisiable,
        CAST(NULL AS NVARCHAR(255)) AS columnTooltip;
END CATCH