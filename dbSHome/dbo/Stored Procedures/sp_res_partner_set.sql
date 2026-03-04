CREATE PROCEDURE [dbo].[sp_res_partner_set]
(
    @userID UNIQUEIDENTIFIER,
    @oid UNIQUEIDENTIFIER = NULL,
    @partner_id INT = NULL,
    @projectCd NVARCHAR(20),
    @partner_name NVARCHAR(100),
    @partner_cd NVARCHAR(50),
    @partner_type_id INT = NULL,
    @status INT = NULL,
    @tax_code NVARCHAR(50) = NULL,
    @company_phone NVARCHAR(50) = NULL,
    @company_email NVARCHAR(100) = NULL,
    @address NVARCHAR(255) = NULL,
    @website NVARCHAR(255) = NULL,

    @license_no NVARCHAR(100) = NULL,
    @issue_dt DATE = NULL,
    @issue_place NVARCHAR(255) = NULL,

    @legal_rep_name NVARCHAR(100) = NULL,
    @legal_rep_title NVARCHAR(100) = NULL,
    @legal_rep_cccd NVARCHAR(50) = NULL,
    @legal_rep_issue_dt DATE = NULL,
    @legal_rep_issue_place NVARCHAR(255) = NULL,

    @pic_name NVARCHAR(100) = NULL,
    @contact_phone NVARCHAR(50) = NULL,
    @contact_email NVARCHAR(100) = NULL,
    @contract_start_dt DATE = NULL,
    @contract_end_dt DATE = NULL,

    @attachments UNIQUEIDENTIFIER = NULL,

    @insurance_provider_name NVARCHAR(255) = NULL,
    @insurance_policy_number NVARCHAR(100) = NULL,
    @insurance_start_date DATE = NULL,
    @insurance_end_date DATE = NULL,
    @insurance_coverage_scope NVARCHAR(500) = NULL,

    @building_id INT = NULL,
    @building_contract_start_date DATE = NULL,
    @building_contract_end_date DATE = NULL,
    @building_monthly_cost DECIMAL(18,2) = NULL,
    @building_service_scope NVARCHAR(500) = NULL
)
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @pid INT;
    DECLARE @is_insert BIT = 0;

    SET @partner_id = ISNULL(@partner_id, 0);
    SET @status = COALESCE(@status, 1);

    IF @oid IS NULL SET @oid = NEWID();

    IF @status NOT IN (1,2,3)
    BEGIN
        SELECT CAST(0 AS BIT) AS valid, N'Trạng thái không hợp lệ!' AS [messages];
        RETURN;
    END

    IF NULLIF(LTRIM(RTRIM(@partner_name)), '') IS NULL
    BEGIN
        SELECT CAST(0 AS BIT) AS valid, N'Phải nhập thông tin tên' AS [messages];
        RETURN;
    END

    IF NULLIF(LTRIM(RTRIM(@projectCd)), '') IS NULL
    BEGIN
        SELECT CAST(0 AS BIT) AS valid, N'Chưa chọn dự án!' AS [messages];
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.MAS_Projects WHERE projectCd = @projectCd)
    BEGIN
        SELECT CAST(0 AS BIT) AS valid, N'Chưa chọn dự án!' AS [messages];
        RETURN;
    END

    IF NULLIF(LTRIM(RTRIM(@partner_cd)), '') IS NULL
    BEGIN
        SELECT CAST(0 AS BIT) AS valid, N'Mã đối tác là bắt buộc' AS [messages];
        RETURN;
    END

    IF @partner_type_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM dbo.MAS_PartnerType WHERE partner_type_id = @partner_type_id AND is_active = 1)
    BEGIN
        SELECT CAST(0 AS BIT) AS valid, N'Loại đối tác không hợp lệ!' AS [messages];
        RETURN;
    END

    BEGIN TRAN;

    IF @partner_id > 0
        SELECT TOP 1 @pid = partner_id FROM dbo.MAS_CardPartner WHERE partner_id = @partner_id;
    ELSE
        SELECT TOP 1 @pid = partner_id FROM dbo.MAS_CardPartner WHERE oid = @oid;

    IF @pid IS NULL SET @is_insert = 1;

    IF @is_insert = 1
    BEGIN
        INSERT INTO dbo.MAS_CardPartner
        (
            oid,
            partner_cd, partner_name, projectCd, partner_type_id,
            partner_status_id, status,
            tax_code, company_phone, company_email, [address], website,
            license_no, issue_dt, issue_place,
            legal_rep_name, legal_rep_title, legal_rep_cccd, legal_rep_issue_dt, legal_rep_issue_place,
            pic_name, contact_phone, contact_email,
            contract_start_dt, contract_end_dt,
            attachments,
            create_dt, create_by
        )
        VALUES
        (
            @oid,
            @partner_cd, @partner_name, @projectCd, @partner_type_id,
            @status, @status,
            @tax_code, @company_phone, @company_email, @address, @website,
            @license_no, @issue_dt, @issue_place,
            @legal_rep_name, @legal_rep_title, @legal_rep_cccd, @legal_rep_issue_dt, @legal_rep_issue_place,
            @pic_name, @contact_phone, @contact_email,
            @contract_start_dt, @contract_end_dt,
            @attachments,
            GETDATE(), @userID
        );

        SET @pid = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.MAS_CardPartner
        SET
            partner_cd = @partner_cd,
            partner_name = @partner_name,
            projectCd = @projectCd,
            partner_type_id = @partner_type_id,
            partner_status_id = @status,
            status = @status,
            tax_code = @tax_code,
            company_phone = @company_phone,
            company_email = @company_email,
            [address] = @address,
            website = @website,
            license_no = @license_no,
            issue_dt = @issue_dt,
            issue_place = @issue_place,
            legal_rep_name = @legal_rep_name,
            legal_rep_title = @legal_rep_title,
            legal_rep_cccd = @legal_rep_cccd,
            legal_rep_issue_dt = @legal_rep_issue_dt,
            legal_rep_issue_place = @legal_rep_issue_place,
            pic_name = @pic_name,
            contact_phone = @contact_phone,
            contact_email = @contact_email,
            contract_start_dt = @contract_start_dt,
            contract_end_dt = @contract_end_dt,
            attachments = @attachments,
            update_dt = GETDATE(),
            update_by = @userID
        WHERE partner_id = @pid;
    END

    DELETE FROM dbo.MAS_CardPartnerInsurance WHERE partner_id = @pid;

    IF NULLIF(LTRIM(RTRIM(ISNULL(@insurance_provider_name,''))), '') IS NOT NULL
       OR NULLIF(LTRIM(RTRIM(ISNULL(@insurance_policy_number,''))), '') IS NOT NULL
       OR @insurance_start_date IS NOT NULL
       OR @insurance_end_date IS NOT NULL
       OR NULLIF(LTRIM(RTRIM(ISNULL(@insurance_coverage_scope,''))), '') IS NOT NULL
    BEGIN
        INSERT INTO dbo.MAS_CardPartnerInsurance
            (partner_id, provider_name, policy_number, start_date, end_date, coverage_scope, create_dt, create_by)
        VALUES
            (@pid, @insurance_provider_name, @insurance_policy_number, @insurance_start_date, @insurance_end_date, @insurance_coverage_scope, GETDATE(), @userID);
    END

    DELETE FROM dbo.MAS_CardPartnerBuilding WHERE partner_id = @pid;

    IF @building_id IS NOT NULL
    BEGIN
        INSERT INTO dbo.MAS_CardPartnerBuilding
            (partner_id, building_id, contract_start_date, contract_end_date, monthly_cost, service_scope, create_dt, create_by)
        VALUES
            (@pid, @building_id, @building_contract_start_date, @building_contract_end_date, @building_monthly_cost, @building_service_scope, GETDATE(), @userID);
    END

    DELETE FROM dbo.MAS_CardPartnerFile WHERE partner_id = @pid;

    IF @attachments IS NOT NULL
    BEGIN
        INSERT INTO dbo.MAS_CardPartnerFile
            (partner_id, file_id, file_name, content_type, file_size, note, create_dt, create_by)
        SELECT
            @pid,
            m.Oid,
            m.file_name,
            CASE LOWER(m.file_type)
                WHEN '.png' THEN 'image/png'
                WHEN '.jpg' THEN 'image/jpeg'
                WHEN '.jpeg' THEN 'image/jpeg'
                WHEN '.gif' THEN 'image/gif'
                WHEN '.pdf' THEN 'application/pdf'
                WHEN '.doc' THEN 'application/msword'
                WHEN '.docx' THEN 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
                WHEN '.xls' THEN 'application/vnd.ms-excel'
                WHEN '.xlsx' THEN 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                ELSE 'application/octet-stream'
            END,
            ISNULL(CONVERT(BIGINT, m.file_size), 0),
            m.meta_note,
            GETDATE(),
            @userID
        FROM dbo.meta_info m
        WHERE m.sourceOid = @attachments OR m.Oid = @attachments;
    END

    COMMIT;

    SELECT CAST(1 AS BIT) AS valid, N'Success' AS [messages], @pid AS partner_id, @oid AS oid;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;

    SELECT
        CAST(0 AS BIT) AS valid,
        CONCAT(N'ERR ', ERROR_NUMBER(), N' | LINE ', ERROR_LINE(), N' | ', ERROR_MESSAGE()) AS [messages];
END CATCH