CREATE PROCEDURE [dbo].[sp_res_partner_staff_page]
    @userId     UNIQUEIDENTIFIER,
    @clientId   NVARCHAR(50)  = NULL,
    @ProjectCd  NVARCHAR(40)  = '01',

    @partnerId  BIGINT,             -- BẮT BUỘC
    @staffType  INT = -1,           -- optional
    @status     INT = -1,           -- optional
    @filter     NVARCHAR(100) = '', -- keyword

    @gridWidth  INT = 0,
    @Offset     INT = 0,
    @PageSize   INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @Total BIGINT;
    DECLARE @GridKey NVARCHAR(100) = 'view_partner_staff_page';

    SET @Offset   = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @filter   = ISNULL(@filter, '');

    IF @PageSize = 0 SET @PageSize = 10;
    IF @Offset < 0  SET @Offset = 0;

    -- total
    SELECT @Total = COUNT(1)
    FROM dbo.MAS_CardPartnerStaff s
    WHERE (@ProjectCd = '-1' OR s.ProjectCd = @ProjectCd)
      AND s.PartnerId = @partnerId
      AND (@status    = -1 OR s.Status    = @status)
      AND (@staffType = -1 OR s.StaffType = @staffType)
      AND (
            @filter = ''
            OR s.StaffCode LIKE '%' + @filter + '%'
            OR s.FullName  LIKE '%' + @filter + '%'
            OR s.CardCode  LIKE '%' + @filter + '%'
          );

    -- root
    SELECT recordsTotal = @Total, recordsFiltered = @Total, gridKey = @GridKey, valid = 1;

    -- config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
    END

    -- list
    SELECT
        s.StaffId,
        PartnerId  = s.PartnerId,
        ProjectCd  = s.ProjectCd,
        StaffCode  = s.StaffCode,
        FullName   = s.FullName,
        Department = s.Department,
        JobTitle   = s.JobTitle,
        StaffType  = s.StaffType,
        Phone      = s.Phone,
        IdNo       = s.IdNo,
        CardCode   = ISNULL(NULLIF(s.CardCode,''), N'-'),
        CreateDate = CONVERT(NVARCHAR(10), s.Create_dt, 103),
        Status     = s.Status,
        StatusName =
            CASE ISNULL(s.Status, 0)
                WHEN 1 THEN N'<span class="bg-success noti-number ml5">Đang hoạt động</span>'
                WHEN 2 THEN N'<span class="bg-warning noti-number ml5">Tạm dừng</span>'
                WHEN 3 THEN N'<span class="bg-secondary noti-number ml5">Nghỉ việc</span>'
                ELSE N'<span class="bg-dark noti-number ml5">-</span>'
            END
    FROM dbo.MAS_CardPartnerStaff s
    WHERE (@ProjectCd = '-1' OR s.ProjectCd = @ProjectCd)
      AND s.PartnerId = @partnerId
      AND (@status    = -1 OR s.Status    = @status)
      AND (@staffType = -1 OR s.StaffType = @staffType)
      AND (
            @filter = ''
            OR s.StaffCode LIKE '%' + @filter + '%'
            OR s.FullName  LIKE '%' + @filter + '%'
            OR s.CardCode  LIKE '%' + @filter + '%'
          )
    ORDER BY s.Create_dt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    SELECT recordsTotal = 0, recordsFiltered = 0, gridKey = 'view_partner_staff_page', valid = 0;
END CATCH