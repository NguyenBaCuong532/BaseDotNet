
CREATE   PROCEDURE [dbo].[sp_res_partner_vehicle_page]
    @userId     UNIQUEIDENTIFIER,
    @clientId   NVARCHAR(50)  = NULL,
    @ProjectCd  NVARCHAR(40)  = '01',

    @partnerId  BIGINT,             
    @status     INT = -1,            
    @filter     NVARCHAR(100) = '',  

    @gridWidth  INT = 0,
    @Offset     INT = 0,
    @PageSize   INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @Total BIGINT = 0;
    DECLARE @GridKey NVARCHAR(100) = N'view_partner_vehicle_page_v2';

    SET @Offset   = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @filter   = ISNULL(@filter, N'');

    IF @PageSize <= 0 SET @PageSize = 10;
    IF @Offset < 0    SET @Offset = 0;

    /* ================= TOTAL ================= */
    SELECT @Total = COUNT(1)
    FROM dbo.MAS_PartnerVehiclePage v
    WHERE (@ProjectCd = N'-1' OR v.ProjectCd = @ProjectCd)
      AND v.PartnerId = @partnerId
      AND (@status = -1 OR v.Status = @status)
      AND (
            @filter = N''
            OR v.CardCode      LIKE N'%' + @filter + N'%'
            OR v.PartnerName   LIKE N'%' + @filter + N'%'
            OR v.OwnerName     LIKE N'%' + @filter + N'%'
            OR v.LicensePlate  LIKE N'%' + @filter + N'%'
          );

    /* ================= ROOT ================= */
    SELECT recordsTotal = @Total, recordsFiltered = @Total, gridKey = @GridKey, valid = 1;

    /* ================= CONFIG ================= */
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM dbo.fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY ordinal;
    END

    /* ================= LIST ================= */
    SELECT
        v.VehicleId,

        CardCode    = v.CardCode,
        PartnerName = v.PartnerName,
        OwnerName   = v.OwnerName,

        VehicleType = v.VehicleType,
        VehicleTypeName =
            CASE v.VehicleType
                WHEN 1 THEN N'Ô tô'
                WHEN 2 THEN N'Xe máy'
                WHEN 3 THEN N'Xe đạp'
                WHEN 4 THEN N'Xe máy điện'
                WHEN 5 THEN N'Xe đạp điện'
                ELSE N'-'
            END,

        LicensePlate = v.LicensePlate,

        StartDate    = CONVERT(NVARCHAR(10), v.StartDate, 103),

        Status       = v.Status,
        StatusName =
            CASE v.Status
                WHEN 1 THEN N'<span class="bg-info noti-number ml5">Khởi tạo</span>'
                WHEN 2 THEN N'<span class="bg-success noti-number ml5">Hoạt động</span>'
                WHEN 3 THEN N'<span class="bg-warning noti-number ml5">Quá hạn</span>'
                WHEN 4 THEN N'<span class="bg-danger noti-number ml5">Khóa thẻ</span>'
                WHEN 5 THEN N'<span class="bg-secondary noti-number ml5">Hủy</span>'
                ELSE N'<span class="bg-dark noti-number ml5">-</span>'
            END,

        CreateDate = CONVERT(NVARCHAR(10), v.Create_dt, 103),
        CreateBy   = v.CreateBy

    FROM dbo.MAS_PartnerVehiclePage v
    WHERE (@ProjectCd = N'-1' OR v.ProjectCd = @ProjectCd)
      AND v.PartnerId = @partnerId
      AND (@status = -1 OR v.Status = @status)
      AND (
            @filter = N''
            OR v.CardCode      LIKE N'%' + @filter + N'%'
            OR v.PartnerName   LIKE N'%' + @filter + N'%'
            OR v.OwnerName     LIKE N'%' + @filter + N'%'
            OR v.LicensePlate  LIKE N'%' + @filter + N'%'
          )
    ORDER BY v.Create_dt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    SELECT recordsTotal = 0, recordsFiltered = 0, gridKey = N'view_partner_vehicle_page_v2', valid = 0;
END CATCH