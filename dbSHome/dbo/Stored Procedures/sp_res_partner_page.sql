CREATE PROCEDURE [dbo].[sp_res_partner_page]
    @UserId UNIQUEIDENTIFIER,
    @clientId NVARCHAR(50) = NULL,
    @projectCd NVARCHAR(50),
    @filter NVARCHAR(30),
    @status INT = NULL,            
    @gridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @Total BIGINT;
    DECLARE @GridKey NVARCHAR(100) = 'view_Partner_Page';

    SET @projectCd = ISNULL(@projectCd, '');
    SET @Offset    = ISNULL(@Offset, 0);
    SET @PageSize  = ISNULL(@PageSize, 10);
    SET @filter    = ISNULL(@filter, '');
    SET @status    = ISNULL(@status, 0);

    IF @PageSize <= 0 SET @PageSize = 10;
    IF @Offset < 0 SET @Offset = 0;

    SELECT @Total = COUNT(a.partner_id)
    FROM dbo.MAS_CardPartner a
    JOIN dbo.MAS_Projects p ON a.ProjectCd = p.projectCd
    LEFT JOIN dbo.MAS_PartnerType t ON a.partner_type_id = t.partner_type_id
    WHERE
        (a.partner_name LIKE '%' + @filter + '%'
         OR a.partner_cd LIKE '%' + @filter + '%'
         OR ISNULL(t.type_name,'') LIKE '%' + @filter + '%')
        AND EXISTS (
            SELECT 1 FROM dbo.UserProject x
            WHERE x.projectCd = a.projectCd AND x.userId = @userId
        )
        AND (TRIM(@projectCd) = '' OR p.projectCd = @projectCd)
        AND (@status = 0 OR a.status = @status);

   
    SELECT
        recordsTotal = @Total,
        recordsFiltered = @Total,
        gridKey = @GridKey,
        valid = 1;

    
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
    END

   
    SELECT
        a.partner_id,
        a.partner_cd,
        a.partner_name,
        partner_type_name = t.type_name,
        pic_name = a.pic_name,

        phone = COALESCE(NULLIF(a.company_phone,''), NULLIF(a.contact_phone,'')),
        email = COALESCE(NULLIF(a.company_email,''), NULLIF(a.contact_email,'')),

        a.create_dt,

        status_id = a.status,
        status_name =
            CASE a.status
                WHEN 1 THEN N'Đang hoạt động'
                WHEN 2 THEN N'Tạm dừng'
                WHEN 3 THEN N'Ngừng hợp tác'
                ELSE N'Không xác định'
            END
    FROM dbo.MAS_CardPartner a
    JOIN dbo.MAS_Projects p ON a.ProjectCd = p.projectCd
    LEFT JOIN dbo.MAS_PartnerType t ON a.partner_type_id = t.partner_type_id
    WHERE
        (a.partner_name LIKE '%' + @filter + '%'
         OR a.partner_cd LIKE '%' + @filter + '%'
         OR ISNULL(t.type_name,'') LIKE '%' + @filter + '%')
        AND EXISTS (
            SELECT 1 FROM dbo.UserProject x
            WHERE x.projectCd = a.projectCd AND x.userId = @userId
        )
        AND (TRIM(@projectCd) = '' OR p.projectCd = @projectCd)
        AND (@status = 0 OR a.status = @status)
    ORDER BY a.partner_name
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_partner_page ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Partner', 'GET', @SessionID, @AddlInfo;
END CATCH