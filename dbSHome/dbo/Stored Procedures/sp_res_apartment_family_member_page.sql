CREATE PROCEDURE [dbo].[sp_res_apartment_family_member_page]
    @userId UNIQUEIDENTIFIER,
    @filter NVARCHAR(30) = NULL,
	@clientId NVARCHAR(50) = NULL,
	@ApartmentId INT,
	@gridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @MemberType Nvarchar(30) = null,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @Total   BIGINT = 0;
    DECLARE @GridKey NVARCHAR(100) = 'view_apartment_family_member_page';

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = CASE WHEN ISNULL(@PageSize, 0) > 0 THEN @PageSize ELSE 10 END;
    SET @filter = ISNULL(@filter, '');

    IF @PageSize = 0 SET @PageSize = 10;
    IF @Offset  < 0 SET @Offset  = 0;

    ----------------------------------------------------------------
    -- Total
    ----------------------------------------------------------------
    SELECT @Total = COUNT(1)
    FROM MAS_Customers a WITH (NOLOCK)
    JOIN MAS_Apartment_Member b WITH (NOLOCK) ON a.CustId = b.CustId
    WHERE b.ApartmentId = @ApartmentId
      AND (@filter = '' OR a.FullName LIKE N'%' + @filter + N'%');

    -- Result 1: root
    SELECT  recordsTotal   = @Total,
            recordsFiltered= @Total,
            gridKey        = @GridKey,
            valid          = 1;

    ----------------------------------------------------------------
    -- Result 2: grid config
    ----------------------------------------------------------------
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
        ORDER BY [ordinal];
    END;

    ----------------------------------------------------------------
    -- Result 3: Data
    ----------------------------------------------------------------

    -- Ảnh khuôn mặt theo CustId
    IF OBJECT_ID('tempdb..#CustomerImages') IS NOT NULL DROP TABLE #CustomerImages;

    SELECT  ci.CustId,
            MAX(CASE WHEN ci.Imagetype = 1 THEN ci.imageUrl END) AS FaceRecogUrl1,
            MAX(CASE WHEN ci.Imagetype = 2 THEN ci.imageUrl END) AS FaceRecogUrl2,
            MAX(CASE WHEN ci.Imagetype = 3 THEN ci.imageUrl END) AS FaceRecogUrl3,
            MAX(CASE WHEN ci.Imagetype = 4 THEN ci.imageUrl END) AS FaceRecogUrl4,
            MAX(CASE WHEN ci.Imagetype = 5 THEN ci.imageUrl END) AS FaceRecogUrl5
    INTO #CustomerImages
    FROM [MAS_Customer_Image] ci WITH (NOLOCK)
    JOIN MAS_Apartment_Member b WITH (NOLOCK)
         ON b.CustId = ci.CustId AND b.ApartmentId = @ApartmentId
    WHERE ci.Imagetype IN (1,2,3,4,5)
    GROUP BY ci.CustId;

    -- UserType2: tài khoản app
    IF OBJECT_ID('tempdb..#UserType2') IS NOT NULL DROP TABLE #UserType2;

    SELECT DISTINCT u.CustId
    INTO #UserType2
    FROM UserInfo u WITH (NOLOCK)
    JOIN MAS_Apartment_Member b WITH (NOLOCK)
         ON b.CustId = u.CustId AND b.ApartmentId = @ApartmentId
    WHERE u.userType = 2;

    -- Data
    SELECT  a.CustId,
            a.[FullName],
            a.[IsSex],
            CASE WHEN a.[IsSex] = 1 THEN N'Nam'
                 WHEN a.[IsSex] = 0 THEN N'Nữ'
                 ELSE N'' END AS SexName,
            CONVERT(NVARCHAR(10), a.birthday, 103) AS birthday,
            a.[Phone],
            a.[Email],
            CASE WHEN b.memberUserId IS NOT NULL
                 THEN '<i class="pi pi-check text-blue-500 font-bold"></i>'
                 ELSE '<i class="pi pi-times text-red-500 font-bold"></i>'
            END AS [isAppName],
            b.[ApartmentId],
            CASE WHEN b.RelationId = 0 THEN 1 ELSE 0 END AS [IsHost],
            CASE WHEN b.RelationId = 0
                 THEN '<i class="pi pi-check text-blue-500 font-bold"></i>'
                 ELSE '<i class="pi pi-times text-red-500 font-bold"></i>'
            END AS [IsHostName],
            a.[AvatarUrl],
            ISNULL(a.IsForeign, 0) AS IsForeign,
            CASE WHEN ISNULL(a.IsForeign, 0) = 1
                 THEN '<i class="pi pi-check text-blue-500 font-bold"></i>'
                 ELSE '<i class="pi pi-times text-red-500 font-bold"></i>'
            END AS IsForeignName,
            ISNULL(b.member_St, 0) AS [Status],
            CASE WHEN ISNULL(b.member_St, 0) = 0 THEN N'Chờ phê duyệt'
                 ELSE N'Đã phê duyệt'
            END AS StatusName,
            CONVERT(NVARCHAR(10), a.Auth_Dt, 103) AS AuthDate,
            ISNULL(img.FaceRecogUrl1, '') AS FaceRecogUrl1,
            ISNULL(img.FaceRecogUrl2, '') AS FaceRecogUrl2,
            ISNULL(img.FaceRecogUrl3, '') AS FaceRecogUrl3,
            ISNULL(img.FaceRecogUrl4, '') AS FaceRecogUrl4,
            ISNULL(img.FaceRecogUrl5, '') AS FaceRecogUrl5,
            b.RelationId,
            ISNULL(d.RelationName, N'Khác') AS RelationName,
            b.memberUserId AS userId,
            b.isNotification,
            CASE WHEN b.memberUserId IS NOT NULL OR ut2.CustId IS NOT NULL
                 THEN 1 ELSE 0 END AS isApp,
            a.CountryCd,
            g.CountryName,
            ISNULL(CurrentHost.FullName, '') AS HostName,
            CONVERT(NVARCHAR(10), ISNULL(b.approveDt, b.RegDt), 103) AS EffectiveDate,
            CONVERT(NVARCHAR(10), hist.ApproveDtEnd, 103) AS EffectiveTo,
            ISNULL(hist.Note, '') AS Note,
            1 AS IsCurrent
    FROM MAS_Customers a WITH (NOLOCK)
    JOIN MAS_Apartment_Member b WITH (NOLOCK)
         ON a.CustId = b.CustId AND b.ApartmentId = @ApartmentId
    LEFT JOIN MAS_Customer_Relation d WITH (NOLOCK)
         ON b.RelationId = d.RelationId
    LEFT JOIN [COR_Countries] g WITH (NOLOCK)
         ON a.CountryCd = g.CountryCd
    LEFT JOIN #CustomerImages img
         ON img.CustId = a.CustId
    LEFT JOIN #UserType2 ut2
         ON ut2.CustId = a.CustId
    OUTER APPLY (
        SELECT TOP 1 ch.FullName
        FROM MAS_Apartment_Member hostMem WITH (NOLOCK)
        JOIN MAS_Customers ch WITH (NOLOCK) ON ch.CustId = hostMem.CustId
        WHERE hostMem.ApartmentId = b.ApartmentId
          AND hostMem.RelationId = 0
        ORDER BY ISNULL(hostMem.approveDt, hostMem.RegDt) DESC
    ) CurrentHost
    OUTER APPLY (
        SELECT TOP 1 h.Note, h.ApproveDtEnd
        FROM MAS_Apartment_Member_H h WITH (NOLOCK)
        WHERE h.ApartmentId = b.ApartmentId
          AND h.CustId = a.CustId
        ORDER BY
            CASE WHEN ISNULL(h.RelationId, 14) = 0 THEN 0 ELSE 1 END,
            ISNULL(h.ApproveDt, h.PerformedAt) DESC,
            h.PerformedAt DESC,
            h.Oid DESC
    ) hist
    WHERE (@filter = '' OR a.FullName LIKE N'%' + @filter + N'%')
    ORDER BY IsCurrent DESC, EffectiveDate DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

    -- Cleanup temp tables
    IF OBJECT_ID('tempdb..#UserType2') IS NOT NULL DROP TABLE #UserType2;
    IF OBJECT_ID('tempdb..#CustomerImages') IS NOT NULL DROP TABLE #CustomerImages;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum  INT,
            @ErrorMsg  VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo  VARCHAR(MAX);

    SET @ErrorNum  = ERROR_NUMBER();
    SET @ErrorMsg  = 'sp_res_apartment_family_member_page ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo  = '';

    EXEC utl_ErrorLog_Set @ErrorNum,@ErrorMsg,@ErrorProc,'FamilyMember','GET', @SessionID,@AddlInfo;
END CATCH;