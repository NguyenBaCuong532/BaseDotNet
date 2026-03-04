CREATE PROCEDURE [dbo].[sp_res_advertisement_analytics_info]
    @id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        aa.id,
        aa.advertisement_id,
        aa.customer_id,
        aa.session_id,
        aa.action,
        aa.ip_address,
        aa.user_agent,
        aa.device_type,
        aa.platform,
        aa.apartment_id,
        aa.building_id,
        aa.app_st,
        aa.created_dt,
        aa.created_by,
        aa.updated_dt,
        aa.updated_by,
        -- Include advertisement info
        a.title as advertisement_title,
        a.company_name as advertisement_company
    FROM advertisement_analytics aa
        LEFT JOIN advertisement_info a ON aa.advertisement_id = a.id
    WHERE aa.id = @id;
END
GO