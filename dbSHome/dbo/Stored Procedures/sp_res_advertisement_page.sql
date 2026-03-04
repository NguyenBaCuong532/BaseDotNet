CREATE PROCEDURE [dbo].[sp_res_advertisement_page]
    @clientId NVARCHAR(50) = NULL,
    @userId NVARCHAR(50) = NULL,
    @title NVARCHAR(200) = NULL,
    @company_name NVARCHAR(200) = NULL,
    @is_active BIT = NULL,
    @start_date DATETIME = NULL,
    @end_date DATETIME = NULL,
    @position INT = NULL,
    @offset INT = 0,
    @pagesize INT = 20,
    @filter NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.id,
        a.title,
        a.description,
        a.image_url,
        a.link_url,
        a.position,
        a.priority,
        a.start_date,
        a.end_date,
        a.is_active,
        a.company_name,
        a.company_contact,
        a.company_phone,
        a.company_email,
        a.click_count,
        a.view_count,
        a.is_deleted,
        a.app_st,
        a.created_dt,
        a.created_by,
        a.updated_dt,
        a.updated_by
    FROM advertisement_info a
    WHERE a.is_deleted = 0
        AND (@title IS NULL OR a.title LIKE '%' + @title + '%')
        AND (@company_name IS NULL OR a.company_name LIKE '%' + @company_name + '%')
        AND (@is_active IS NULL OR a.is_active = @is_active)
        AND (@start_date IS NULL OR a.start_date >= @start_date)
        AND (@end_date IS NULL OR a.end_date <= @end_date)
        AND (@position IS NULL OR a.position = @position)
        AND (@filter IS NULL OR (
            a.title LIKE '%' + @filter + '%' OR
            a.company_name LIKE '%' + @filter + '%'
        ))
    ORDER BY a.created_dt DESC
    OFFSET @offset ROWS
    FETCH NEXT @pagesize ROWS ONLY;
END
GO