
CREATE PROCEDURE [dbo].[sp_res_dashboard_feedback]
    @ProjectCd NVARCHAR(30),
    @Limit INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    ;WITH ProjectApartmentIds AS (
        SELECT a.ApartmentId, a.RoomCode
        FROM MAS_Apartments a WITH (NOLOCK)
        LEFT JOIN MAS_Buildings b WITH (NOLOCK) ON a.buildingOid = b.oid
        WHERE b.ProjectCd = @ProjectCd
    )
    SELECT TOP (@Limit)
        f.FeedbackId AS Id,
        f.InputDate AS FeedbackTime,
        FORMAT(f.InputDate, 'HH:mm') AS Time,
        FORMAT(f.InputDate, 'dd/MM/yyyy') AS Date,
        ISNULL(u.FullName, N'Cư dân') AS Sender,
        ISNULL(CONCAT(N'Căn ', pa.RoomCode, N' - Tầng ', ef.FloorNumber, N' - ', b.BuildingName), N'N/A') AS Apartment,
        CASE WHEN LEN(f.Comment) > 100 
             THEN LEFT(f.Comment, 100) + '...' 
             ELSE f.Comment END AS Content,
        CASE f.Status
            WHEN 0 THEN 'pending'
            WHEN 1 THEN 'processing'
            WHEN 2 THEN 'resolved'
            ELSE 'pending'
        END AS Status,
        CASE f.FeedbackId % 5
            WHEN 0 THEN '#0091FF'
            WHEN 1 THEN '#8B5CF6'
            WHEN 2 THEN '#10B981'
            WHEN 3 THEN '#F76808'
            ELSE '#EC4899'
        END AS AvatarColor,
        CAST(NULL AS NVARCHAR(500)) AS AvatarUrl
    FROM MAS_Feedbacks f WITH (NOLOCK)
    LEFT JOIN UserInfo u ON u.userId = f.userId
    INNER JOIN ProjectApartmentIds pa ON f.ApartmentId = pa.ApartmentId
    LEFT JOIN MAS_Apartments a ON pa.ApartmentId = a.ApartmentId
    LEFT JOIN MAS_Buildings b WITH (NOLOCK) ON a.buildingOid = b.oid
    LEFT JOIN MAS_Elevator_Floor ef WITH (NOLOCK) ON a.floorOid = ef.oid
    --LEFT JOIN MAS_Apartment_Member am WITH (NOLOCK) ON pa.ApartmentId = am.ApartmentId-- AND am.isDefault = 1
    --LEFT JOIN MAS_Customer_Household m WITH (NOLOCK) ON am.CustId = m.CustId
    ORDER BY f.InputDate DESC;
END