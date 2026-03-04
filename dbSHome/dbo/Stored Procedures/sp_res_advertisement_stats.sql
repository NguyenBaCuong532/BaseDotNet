CREATE PROCEDURE [dbo].[sp_res_advertisement_stats]
    @from_date DATETIME = NULL,
    @to_date DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.id as AdvertisementId,
        a.title as Title,
        a.view_count as ViewCount,
        a.click_count as ClickCount,
        CASE
            WHEN a.view_count > 0 THEN CAST(a.click_count AS FLOAT) / a.view_count * 100
            ELSE 0
        END as ClickThroughRate,
        (SELECT MAX(created_dt) FROM advertisement_analytics WHERE advertisement_id = a.id AND action = 'View') as LastViewed,
        (SELECT MAX(created_dt) FROM advertisement_analytics WHERE advertisement_id = a.id AND action = 'Click') as LastClicked
    FROM advertisement_info a
    WHERE a.is_deleted = 0
        AND (@from_date IS NULL OR a.created_dt >= @from_date)
        AND (@to_date IS NULL OR a.created_dt <= @to_date)
    ORDER BY a.view_count DESC, a.click_count DESC;
END
GO