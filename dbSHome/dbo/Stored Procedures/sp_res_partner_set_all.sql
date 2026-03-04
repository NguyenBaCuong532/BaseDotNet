CREATE PROCEDURE dbo.sp_res_partner_set_all
  @userID UNIQUEIDENTIFIER,
  @payload NVARCHAR(MAX)
AS
BEGIN TRY
  SET NOCOUNT ON;
  BEGIN TRAN;

  DECLARE @partner_id_raw INT = TRY_CONVERT(INT, JSON_VALUE(@payload,'$.partnerId'));
  DECLARE @partner_id INT = NULL;

  -- ✅ FIX: partnerId <= 0 coi như NULL (INSERT)
  IF @partner_id_raw IS NOT NULL AND @partner_id_raw > 0
      SET @partner_id = @partner_id_raw;

  DECLARE @projectCd NVARCHAR(20) = JSON_VALUE(@payload,'$.projectCd');
  DECLARE @partner_cd NVARCHAR(50) = JSON_VALUE(@payload,'$.partnerCd');
  DECLARE @partner_name NVARCHAR(100) = JSON_VALUE(@payload,'$.companyName');
  DECLARE @partner_type_id INT = TRY_CONVERT(INT, JSON_VALUE(@payload,'$.serviceTypeId'));

  -- ===== VALIDATE =====
  IF ISNULL(@partner_cd,'') = '' OR ISNULL(@partner_name,'') = ''
  BEGIN
    ROLLBACK;
    SELECT 0 valid, N'Thiếu mã đối tác hoặc tên công ty' messages, NULL partner_id;
    RETURN;
  END

  IF NOT EXISTS (SELECT 1 FROM MAS_Projects WHERE projectCd=@projectCd)
  BEGIN
    ROLLBACK;
    SELECT 0 valid, N'Chưa chọn dự án!' messages, NULL partner_id;
    RETURN;
  END

  IF @partner_type_id IS NULL
     OR NOT EXISTS (SELECT 1 FROM MAS_PartnerType WHERE partner_type_id=@partner_type_id AND is_active=1)
  BEGIN
    ROLLBACK;
    SELECT 0 valid, N'Loại dịch vụ không hợp lệ!' messages, NULL partner_id;
    RETURN;
  END

  -- ===== MAP FIELD =====
  DECLARE @tax_code NVARCHAR(50) = JSON_VALUE(@payload,'$.taxCode');
  DECLARE @address NVARCHAR(500) = JSON_VALUE(@payload,'$.companyAddress');
  DECLARE @company_phone NVARCHAR(30) = JSON_VALUE(@payload,'$.companyPhone');
  DECLARE @company_email NVARCHAR(100) = JSON_VALUE(@payload,'$.companyEmail');
  DECLARE @website NVARCHAR(200) = JSON_VALUE(@payload,'$.website');

  DECLARE @legal_rep_name NVARCHAR(100) = JSON_VALUE(@payload,'$.representative.fullName');
  DECLARE @legal_rep_title NVARCHAR(100) = JSON_VALUE(@payload,'$.representative.title');
  DECLARE @legal_rep_cccd NVARCHAR(30) = JSON_VALUE(@payload,'$.representative.cccd');
  DECLARE @legal_rep_issue_dt DATE = TRY_CONVERT(DATE, JSON_VALUE(@payload,'$.representative.issueDate'));
  DECLARE @legal_rep_issue_place NVARCHAR(100) = JSON_VALUE(@payload,'$.representative.issuePlace');

  DECLARE @pic_name NVARCHAR(100) = JSON_VALUE(@payload,'$.contactPerson.fullName');
  DECLARE @contact_phone NVARCHAR(30) = JSON_VALUE(@payload,'$.contactPerson.phone');
  DECLARE @contact_email NVARCHAR(100) = JSON_VALUE(@payload,'$.contactPerson.email');

  DECLARE @contract_start_dt DATE = TRY_CONVERT(DATE, JSON_VALUE(@payload,'$.contractStartDate'));
  DECLARE @contract_end_dt DATE = TRY_CONVERT(DATE, JSON_VALUE(@payload,'$.contractEndDate'));

  -- ===== UPDATE =====
  IF @partner_id IS NOT NULL
  BEGIN
    UPDATE dbo.MAS_CardPartner
    SET partner_cd=@partner_cd,
        partner_name=@partner_name,
        projectCd=@projectCd,
        partner_type_id=@partner_type_id,
        tax_code=@tax_code,
        [address]=@address,
        company_phone=@company_phone,
        company_email=@company_email,
        website=@website,
        legal_rep_name=@legal_rep_name,
        legal_rep_title=@legal_rep_title,
        legal_rep_cccd=@legal_rep_cccd,
        legal_rep_issue_dt=@legal_rep_issue_dt,
        legal_rep_issue_place=@legal_rep_issue_place,
        pic_name=@pic_name,
        contact_phone=@contact_phone,
        contact_email=@contact_email,
        contract_start_dt=@contract_start_dt,
        contract_end_dt=@contract_end_dt,
        update_dt=GETDATE(),
        update_by=@userID
    WHERE partner_id=@partner_id;

    IF @@ROWCOUNT = 0
    BEGIN
      ROLLBACK;
      SELECT 0 valid, N'Không tìm thấy partner để cập nhật' messages, NULL partner_id;
      RETURN;
    END
  END
  ELSE
  BEGIN
    INSERT dbo.MAS_CardPartner(
      partner_cd, partner_name, projectCd, partner_type_id,
      tax_code, [address], company_phone, company_email, website,
      legal_rep_name, legal_rep_title, legal_rep_cccd, legal_rep_issue_dt, legal_rep_issue_place,
      pic_name, contact_phone, contact_email,
      contract_start_dt, contract_end_dt,
      create_dt, create_by, status
    )
    VALUES(
      @partner_cd, @partner_name, @projectCd, @partner_type_id,
      @tax_code, @address, @company_phone, @company_email, @website,
      @legal_rep_name, @legal_rep_title, @legal_rep_cccd, @legal_rep_issue_dt, @legal_rep_issue_place,
      @pic_name, @contact_phone, @contact_email,
      @contract_start_dt, @contract_end_dt,
      GETDATE(), @userID, 1
    );

    SET @partner_id = SCOPE_IDENTITY();
  END

  COMMIT;

  SELECT 1 valid, N'Thành công' messages, @partner_id partner_id;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT 0 valid, ERROR_MESSAGE() messages, NULL partner_id;
END CATCH