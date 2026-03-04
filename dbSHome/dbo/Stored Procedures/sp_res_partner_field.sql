CREATE PROCEDURE [dbo].[sp_res_partner_field]
    @userid UNIQUEIDENTIFIER = NULL,
    @oid UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @group_key NVARCHAR(50) = N'res_partner_tabs';
    DECLARE @table_key NVARCHAR(50) = N'MAS_CardPartner';
    DECLARE @id BIGINT = NULL;

    SELECT TOP 1 @id = partner_id
    FROM dbo.MAS_CardPartner
    WHERE oid = @oid;

    IF @id IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.MAS_CardPartner WHERE partner_id = @id)
    BEGIN
        SELECT
            [oid]           = @oid,
            [id]            = @id,
            tableKey        = @table_key,
            groupKey        = @group_key,
            partner_cd      = p.partner_cd,
            partner_name    = p.partner_name,
            projectCd       = p.projectCd,
            partner_type_id = p.partner_type_id
        FROM dbo.MAS_CardPartner p
        WHERE p.partner_id = @id;
    END
    ELSE
    BEGIN
        SELECT
            [oid]           = @oid,
            [id]            = NULL,
            tableKey        = @table_key,
            groupKey        = @group_key,
            partner_cd      = NULL,
            partner_name    = NULL,
            projectCd       = NULL,
            partner_type_id = NULL;
    END

    SELECT *
    FROM dbo.fn_get_field_group_lang(@group_key, @acceptLanguage)
    ORDER BY intOrder;

    IF @id IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.MAS_CardPartner WHERE partner_id = @id)
    BEGIN
        ;WITH ins AS
        (
            SELECT TOP 1 *
            FROM dbo.MAS_CardPartnerInsurance
            WHERE partner_id = @id
            ORDER BY create_dt DESC
        ),
        bld AS
        (
            SELECT TOP 1 *
            FROM dbo.MAS_CardPartnerBuilding
            WHERE partner_id = @id
            ORDER BY create_dt DESC
        )
        SELECT
            s.id,
            s.table_name,
            s.field_name,
            s.view_type,
            s.data_type,
            s.ordinal,
            s.columnLabel,
            s.group_cd,
            ISNULL(
                CASE s.field_name
                    WHEN 'partner_id'            THEN CONVERT(NVARCHAR(50), p.partner_id)
                    WHEN 'oid'                   THEN CONVERT(NVARCHAR(50), p.oid)
                    WHEN 'projectCd'             THEN p.projectCd
                    WHEN 'partner_cd'            THEN p.partner_cd
                    WHEN 'partner_name'          THEN p.partner_name
                    WHEN 'partner_type_id'       THEN CONVERT(NVARCHAR(50), p.partner_type_id)

                    WHEN 'tax_code'              THEN p.tax_code
                    WHEN 'company_phone'         THEN p.company_phone
                    WHEN 'company_email'         THEN p.company_email
                    WHEN 'address'               THEN p.[address]
                    WHEN 'website'               THEN p.website

                    WHEN 'license_no'            THEN p.license_no
                    WHEN 'issue_dt'              THEN CONVERT(NVARCHAR(10), p.issue_dt, 23)
                    WHEN 'issue_place'           THEN p.issue_place

                    WHEN 'legal_rep_name'        THEN p.legal_rep_name
                    WHEN 'legal_rep_title'       THEN p.legal_rep_title
                    WHEN 'legal_rep_cccd'        THEN p.legal_rep_cccd
                    WHEN 'legal_rep_issue_dt'    THEN CONVERT(NVARCHAR(10), p.legal_rep_issue_dt, 23)
                    WHEN 'legal_rep_issue_place' THEN p.legal_rep_issue_place

                    WHEN 'pic_name'              THEN p.pic_name
                    WHEN 'contact_phone'         THEN p.contact_phone
                    WHEN 'contact_email'         THEN p.contact_email

                    WHEN 'contract_start_dt'     THEN CONVERT(NVARCHAR(10), p.contract_start_dt, 23)
                    WHEN 'contract_end_dt'       THEN CONVERT(NVARCHAR(10), p.contract_end_dt, 23)

                    WHEN 'attachments'           THEN CONVERT(NVARCHAR(50), p.attachments)

                    WHEN 'insurance_provider_name' THEN ins.provider_name
                    WHEN 'insurance_policy_number' THEN ins.policy_number
                    WHEN 'insurance_start_date'    THEN CONVERT(NVARCHAR(10), ins.start_date, 23)
                    WHEN 'insurance_end_date'      THEN CONVERT(NVARCHAR(10), ins.end_date, 23)
                    WHEN 'insurance_coverage_scope' THEN ins.coverage_scope

                    WHEN 'building_id'                 THEN CONVERT(NVARCHAR(50), bld.building_id)
                    WHEN 'building_contract_start_date' THEN CONVERT(NVARCHAR(10), bld.contract_start_date, 23)
                    WHEN 'building_contract_end_date'   THEN CONVERT(NVARCHAR(10), bld.contract_end_date, 23)
                    WHEN 'building_monthly_cost'        THEN CONVERT(NVARCHAR(50), bld.monthly_cost)
                    WHEN 'building_service_scope'       THEN bld.service_scope
                END,
                s.columnDefault
            ) AS columnValue,
            s.columnClass,
            s.columnType,
            columnObject = CASE
                WHEN s.field_name = 'attachments' AND p.attachments IS NOT NULL
                    THEN CONCAT(s.columnObject, CONVERT(NVARCHAR(50), p.attachments))
                ELSE s.columnObject
            END,
            s.isSpecial,
            s.isRequire,
            s.isDisable,
            s.isVisiable,
            CAST(0 AS BIT) AS isEmpty,
            ISNULL(s.columnTooltip, s.columnLabel) AS columnTooltip
            , s.columnDisplay
            , s.isIgnore
        FROM fn_config_form_gets(@table_key, @acceptLanguage) s
        INNER JOIN dbo.MAS_CardPartner p
            ON p.partner_id = @id
        LEFT JOIN ins ON 1 = 1
        LEFT JOIN bld ON 1 = 1
        ORDER BY s.group_cd, s.ordinal;
    END
    ELSE
    BEGIN
        SELECT
            s.id,
            s.table_name,
            s.field_name,
            s.view_type,
            s.data_type,
            s.ordinal,
            s.columnLabel,
            s.group_cd,
            ISNULL(
                CASE s.field_name
                    WHEN 'oid'               THEN CONVERT(NVARCHAR(50), @oid)
                    WHEN 'contract_start_dt' THEN CONVERT(NVARCHAR(10), GETDATE(), 23)
                    WHEN 'contract_end_dt'   THEN CONVERT(NVARCHAR(10), GETDATE(), 23)
                END,
                s.columnDefault
            ) AS columnValue,
            s.columnClass,
            s.columnType,
            s.columnObject,
            s.isSpecial,
            s.isRequire,
            s.isDisable,
            s.isVisiable,
            CAST(0 AS BIT) AS isEmpty,
            ISNULL(s.columnTooltip, s.columnLabel) AS columnTooltip
            , s.columnDisplay
            , s.isIgnore
        FROM fn_config_form_gets(@table_key, @acceptLanguage) s
        ORDER BY s.group_cd, s.ordinal;
    END
END TRY
BEGIN CATCH
    DECLARE @ErrorNum  INT = ERROR_NUMBER(),
            @ErrorMsg  NVARCHAR(4000) = N'sp_res_partner_field: ' + ERROR_MESSAGE(),
            @ErrorProc NVARCHAR(200) = ERROR_PROCEDURE(),
            @SessionID INT,
            @AddlInfo  NVARCHAR(MAX) = N'';

    EXEC utl_errorlog_set
          @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , N'MAS_CardPartner'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;

    SELECT [oid]=@oid, [id]=@id, tableKey=N'MAS_CardPartner', groupKey=N'res_partner_tabs';

    SELECT *
    FROM dbo.fn_get_field_group_lang(N'res_partner_tabs', @acceptLanguage)
    ORDER BY intOrder;

    SELECT TOP 0
        table_name      = CAST(NULL AS NVARCHAR(50)),
        field_name      = CAST(NULL AS NVARCHAR(50)),
        view_type       = CAST(NULL AS NVARCHAR(50)),
        data_type       = CAST(NULL AS NVARCHAR(50)),
        ordinal         = CAST(NULL AS INT),
        columnLabel     = CAST(NULL AS NVARCHAR(200)),
        group_cd        = CAST(NULL AS INT),
        columnValue     = CAST(NULL AS NVARCHAR(MAX)),
        columnClass     = CAST(NULL AS NVARCHAR(50)),
        columnType      = CAST(NULL AS NVARCHAR(50)),
        columnObject    = CAST(NULL AS NVARCHAR(500)),
        isSpecial       = CAST(NULL AS BIT),
        isRequire       = CAST(NULL AS BIT),
        isDisable       = CAST(NULL AS BIT),
        isVisiable      = CAST(NULL AS BIT),
        isEmpty         = CAST(0 AS BIT),
        columnTooltip   = CAST(NULL AS NVARCHAR(500));
END CATCH