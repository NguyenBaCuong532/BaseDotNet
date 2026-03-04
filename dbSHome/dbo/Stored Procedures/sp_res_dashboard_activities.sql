
CREATE PROCEDURE [dbo].[sp_res_dashboard_activities]
    @ProjectCd NVARCHAR(30),
    @Limit INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RecentDate DATETIME2 = DATEADD(DAY, -30, GETDATE());
    
    SELECT TOP (@Limit)
        AuditID AS Id,
        ChangedAt AS ActivityTime,
        FORMAT(ChangedAt, 'HH:mm') AS Time,
        FORMAT(ChangedAt, 'dd/MM/yyyy') AS Date,
        CASE ActionType
            WHEN 'INSERT' THEN 
                CASE TableName
                    WHEN 'MAS_Apartments' THEN N'Thêm căn hộ'
                    WHEN 'MAS_Cards' THEN N'Gán thẻ'
                    WHEN 'MAS_CardVehicle' THEN N'Đăng ký xe mới'
                    WHEN 'MAS_CardPartner' THEN N'Thêm đối tác'
                    ELSE N'Thêm mới ' + TableName
                END
            WHEN 'UPDATE' THEN 
                CASE TableName
                    WHEN 'MAS_Apartments' THEN N'Cập nhật căn hộ'
                    WHEN 'MAS_Cards' THEN 
                        CASE WHEN CHARINDEX('Card_St', ISNULL(NewValue, '')) > 0 
                             THEN N'Vô hiệu hóa thẻ' ELSE N'Cập nhật thẻ' END
                    WHEN 'MAS_CardVehicle' THEN N'Cập nhật xe'
                    ELSE N'Cập nhật ' + TableName
                END
            WHEN 'DELETE' THEN N'Xóa ' + TableName
            ELSE ActionType
        END AS Action,
        ISNULL(LoginName, N'System') AS [User],
        CASE TableName
            WHEN 'MAS_Apartments' THEN ISNULL(JSON_VALUE(NewValue, '$.RoomCode'), N'Căn hộ')
            WHEN 'MAS_Cards' THEN ISNULL(N'Thẻ ' + JSON_VALUE(NewValue, '$.CardCd'), N'Card')
            WHEN 'MAS_CardVehicle' THEN ISNULL(CONCAT(JSON_VALUE(NewValue, '$.VehicleNo'), ' (', JSON_VALUE(NewValue, '$.VehicleName'), ')'), N'Vehicle')
            WHEN 'MAS_CardPartner' THEN ISNULL(JSON_VALUE(NewValue, '$.partner_name'), N'Partner')
            ELSE TableName
        END AS Target,
        CASE 
            WHEN TableName = 'MAS_Apartments' THEN 'apartment'
            WHEN TableName = 'MAS_Cards' THEN 'card'
            WHEN TableName = 'MAS_CardVehicle' THEN 'vehicle'
            WHEN TableName = 'MAS_CardPartner' THEN 'partner'
            ELSE 'other'
        END AS Type
    FROM Audit WITH (NOLOCK)
    WHERE TableName IN ('MAS_Apartments', 'MAS_Cards', 'MAS_CardVehicle', 'MAS_CardPartner')
      AND ActionType IN ('INSERT', 'UPDATE', 'DELETE')
      AND ChangedAt >= @RecentDate
    ORDER BY ChangedAt DESC;
END