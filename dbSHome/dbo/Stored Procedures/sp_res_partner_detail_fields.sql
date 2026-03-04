
CREATE PROCEDURE [dbo].[sp_res_partner_detail_fields]
    @UserId UNIQUEIDENTIFIER = NULL,
    @id BIGINT = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    SET @id = ISNULL(@id, 0);

    /* 1) HEADER (resultset #1) */
    SELECT TOP (1)
        p.partner_id        AS [id],
        p.partner_cd,
        p.partner_name,
        p.partner_type_id,
        pt.type_name        AS partner_type_name,
        p.tax_code,
        p.company_phone,
        p.company_email,
        CONVERT(NVARCHAR(50), p.contract_start_dt, 103) AS contract_start_dt,
        CONVERT(NVARCHAR(50), p.contract_end_dt,   103) AS contract_end_dt
    FROM dbo.MAS_CardPartner p
    LEFT JOIN dbo.MAS_PartnerType pt ON p.partner_type_id = pt.partner_type_id
    WHERE p.partner_id = @id;

    /* 2) GROUPS (resultset #2) */
    SELECT 1 AS group_cd, N'Thông tin chung'   AS group_name
    UNION ALL
    SELECT 2 AS group_cd, N'Thông tin liên hệ' AS group_name;

    /* 3) FIELDS (resultset #3) */
    SELECT
        a.[id] AS id,
        a.[table_name],
        a.[field_name],
        a.[view_type],
        a.[data_type],
        a.[ordinal],
        a.[columnLabel],
        a.[group_cd],

        ISNULL(
            CASE a.[data_type]
                WHEN 'nvarchar' THEN CONVERT(NVARCHAR(MAX),
                    CASE a.[field_name]
                        -- group 1
                        WHEN 'partner_cd'        THEN p.partner_cd
                        WHEN 'partner_name'      THEN p.partner_name
                        WHEN 'tax_code'          THEN p.tax_code
                        WHEN 'license_no'        THEN p.license_no
                        WHEN 'issue_place'       THEN p.issue_place
                        WHEN 'address'           THEN p.[address]
                        WHEN 'company_phone'     THEN p.company_phone
                        WHEN 'company_email'     THEN p.company_email
                        WHEN 'website'           THEN p.website

                        -- group 2
                        WHEN 'legal_rep_name'        THEN p.legal_rep_name
                        WHEN 'legal_rep_title'       THEN p.legal_rep_title
                        WHEN 'legal_rep_cccd'        THEN p.legal_rep_cccd
                        WHEN 'legal_rep_issue_place' THEN p.legal_rep_issue_place
                        WHEN 'pic_name'              THEN p.pic_name
                        WHEN 'contact_phone'         THEN p.contact_phone
                        WHEN 'contact_email'         THEN p.contact_email
                        ELSE NULL
                    END
                )

                WHEN 'int' THEN CONVERT(NVARCHAR(100),
                    CASE a.[field_name]
                        WHEN 'partner_type_id' THEN p.partner_type_id
                        WHEN 'status'          THEN p.[status]
                        ELSE NULL
                    END
                )

                WHEN 'date' THEN CONVERT(NVARCHAR(50),
                    CASE a.[field_name]
                        WHEN 'issue_dt'           THEN p.issue_dt
                        WHEN 'contract_start_dt'  THEN p.contract_start_dt
                        WHEN 'contract_end_dt'    THEN p.contract_end_dt
                        WHEN 'legal_rep_issue_dt' THEN p.legal_rep_issue_dt
                        ELSE NULL
                    END, 103
                )

                WHEN 'uniqueidentifier' THEN CONVERT(NVARCHAR(50),
                    CASE a.[field_name]
                        WHEN 'oid' THEN p.oid
                        ELSE NULL
                    END
                )

                ELSE CONVERT(NVARCHAR(50),
                    CASE a.[field_name]
                        WHEN 'projectCd' THEN p.projectCd
                        ELSE NULL
                    END
                )
            END,
        a.[columnDefault]) AS columnValue,

        a.[columnClass],
        a.[columnType],
        a.[columnObject],
        a.[isSpecial],
        a.[isRequire],
        a.[isDisable],
        a.[IsVisiable],
        ISNULL(a.columnTooltip, a.[columnLabel]) AS columnTooltip
    FROM dbo.fn_config_form_gets('partner_detail', @AcceptLanguage) a
    JOIN dbo.MAS_CardPartner p ON p.partner_id = @id
    WHERE a.table_name = 'partner_detail'
      AND ISNULL(a.is_active, 1) = 1
      AND ISNULL(a.IsVisiable, 1) = 1
    ORDER BY a.group_cd, a.ordinal;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum  INT,
            @ErrorMsg  VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo  VARCHAR(MAX);

    SET @ErrorNum  = ERROR_NUMBER();
    SET @ErrorMsg  = 'sp_res_partner_detail_fields ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo  = '@id=' + CONVERT(VARCHAR(20), ISNULL(@id, 0));

    EXEC utl_Insert_ErrorLog
        @ErrorNum, @ErrorMsg, @ErrorProc,
        'MAS_CardPartner', 'GET', @SessionID, @AddlInfo;
END CATCH;