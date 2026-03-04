CREATE PROCEDURE [dbo].[sp_res_advertisement_analytics_by_action]
    @advertisement_id UNIQUEIDENTIFIER,
    @from_date DATETIME = NULL,
    @to_date DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        action,
        COUNT(*) as count
    FROM advertisement_analytics
    WHERE advertisement_id = @advertisement_id
        AND (@from_date IS NULL OR created_dt >= @from_date)
        AND (@to_date IS NULL OR created_dt <= @to_date)
    GROUP BY action
    ORDER BY count DESC;
END
GO