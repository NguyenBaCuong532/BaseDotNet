CREATE PROCEDURE [dbo].[sp_res_advertisement_info]
    @id UNIQUEIDENTIFIER
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
    WHERE a.id = @id
        AND a.is_deleted = 0;
END
GO