
CREATE PROCEDURE [dbo].[sp_res_partner_card_page]
    @userId     UNIQUEIDENTIFIER,
    @clientId   NVARCHAR(50)  = NULL,
    @ProjectCd  NVARCHAR(40)  = '01',

    @partnerId  BIGINT,              -- BẮT BUỘC
    @status     INT = -1,            -- optional
    @filter     NVARCHAR(100) = '',  -- keyword

    @gridWidth  INT = 0,
    @Offset     INT = 0,
    @PageSize   INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @Total BIGINT;
    DECLARE @GridKey NVARCHAR(100) = 'view_partner_card_page';

    SET @Offset   = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @filter   = ISNULL(@filter, '');

    IF @PageSize = 0 SET @PageSize = 10;
    IF @Offset < 0  SET @Offset = 0;

    /* ================= TOTAL ================= */
    SELECT @Total = COUNT(1)
    FROM dbo.MAS_PartnerCard c
    WHERE (@ProjectCd = '-1' OR c.ProjectCd = @ProjectCd)
      AND c.PartnerId = @partnerId
      AND (@status = -1 OR c.Status = @status)
      AND (
            @filter = ''
            OR c.CardCode     LIKE '%' + @filter + '%'
            OR c.PartnerName  LIKE '%' + @filter + '%'
            OR c.CardOwner    LIKE '%' + @filter + '%'
          );

    /* ================= ROOT ================= */
    SELECT
        recordsTotal    = @Total,
        recordsFiltered = @Total,
        gridKey         = @GridKey,
        valid           = 1;

    /* ================= CONFIG ================= */
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM dbo.fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY ordinal;
    END

    /* ================= LIST ================= */
    SELECT
        c.CardId,
        c.ProjectCd,
        c.PartnerId,

        CardCode    = c.CardCode,
        IssueDate   = CASE WHEN c.IssueDate IS NULL THEN N'-'
                           ELSE CONVERT(NVARCHAR(10), c.IssueDate, 103) END,

        PartnerName = c.PartnerName,
        CardOwner   = c.CardOwner,

        Status      = c.Status,
        StatusName  =
            CASE c.Status
                WHEN 1 THEN N'<span class="bg-success noti-number ml5">Hoạt động</span>'
                WHEN 2 THEN N'<span class="bg-warning noti-number ml5">Khóa</span>'
                WHEN 3 THEN N'<span class="bg-secondary noti-number ml5">Hủy</span>'
                ELSE N'<span class="bg-dark noti-number ml5">-</span>'
            END,

        IsParking   = c.IsParking,
        ParkingName = CASE WHEN c.IsParking = 1 THEN N'Có đăng ký gửi xe'
                           ELSE N'Không đăng ký gửi xe' END,

        CreateDate  = CONVERT(NVARCHAR(10), c.Create_dt, 103)

    FROM dbo.MAS_PartnerCard c
    WHERE (@ProjectCd = '-1' OR c.ProjectCd = @ProjectCd)
      AND c.PartnerId = @partnerId
      AND (@status = -1 OR c.Status = @status)
      AND (
            @filter = ''
            OR c.CardCode     LIKE '%' + @filter + '%'
            OR c.PartnerName  LIKE '%' + @filter + '%'
            OR c.CardOwner    LIKE '%' + @filter + '%'
          )
    ORDER BY c.Create_dt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    SELECT recordsTotal = 0, recordsFiltered = 0, gridKey = 'view_partner_card_page', valid = 0;
END CATCH