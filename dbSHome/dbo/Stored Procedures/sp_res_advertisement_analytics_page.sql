CREATE PROCEDURE [dbo].[sp_res_advertisement_analytics_page]
    @clientId NVARCHAR(50) = NULL,
    @userId NVARCHAR(50) = NULL,
    @advertisement_id UNIQUEIDENTIFIER = NULL,
    @action NVARCHAR(20) = NULL,
    @from_date DATETIME = NULL,
    @to_date DATETIME = NULL,
    @device_type NVARCHAR(50) = NULL,
    @platform NVARCHAR(50) = NULL,
    @offset INT = 0,
    @pagesize INT = 20,
    @filter NVARCHAR(MAX) = NULL
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
    WHERE (@advertisement_id IS NULL OR aa.advertisement_id = @advertisement_id)
        AND (@action IS NULL OR aa.action = @action)
        AND (@from_date IS NULL OR aa.created_dt >= @from_date)
        AND (@to_date IS NULL OR aa.created_dt <= @to_date)
        AND (@device_type IS NULL OR aa.device_type = @device_type)
        AND (@platform IS NULL OR aa.platform = @platform)
        AND (@filter IS NULL OR (
            a.title LIKE '%' + @filter + '%' OR
            a.company_name LIKE '%' + @filter + '%' OR
            aa.action LIKE '%' + @filter + '%'
        ))
    ORDER BY aa.created_dt DESC
    OFFSET @offset ROWS
    FETCH NEXT @pagesize ROWS ONLY;
END
GO