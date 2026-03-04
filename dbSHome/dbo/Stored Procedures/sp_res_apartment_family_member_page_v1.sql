CREATE PROCEDURE [dbo].[sp_res_apartment_family_member_page_v1]
    @userId UNIQUEIDENTIFIER,
    @filter NVARCHAR(30) = NULL,
	@clientId nvarchar(50) = null,
	@ApartmentId INT,
	@gridWidth int = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
	@MemberType NVARCHAR(20) = 'Current', -- 'All', 'Current', 'Old'
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
	SET NOCOUNT ON;
	
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_apartment_family_member_page'
	DECLARE @TotalCurrent BIGINT = 0,
	        @TotalPending BIGINT = 0,
	        @TotalOld BIGINT = 0;

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');
	SET @MemberType = ISNULL(@MemberType, 'Current');

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    -- Tạo temp table chứa tất cả CustId cần thiết TRƯỚC để chỉ load images cho những CustId này
    IF OBJECT_ID('tempdb..#RequiredCustIds') IS NOT NULL DROP TABLE #RequiredCustIds;
    CREATE TABLE #RequiredCustIds (CustId NVARCHAR(50) PRIMARY KEY);
    
    -- Lấy danh sách CustId cần thiết
    IF @MemberType IN ('Current')
    BEGIN
        INSERT INTO #RequiredCustIds (CustId)
        SELECT DISTINCT a.CustId 
        FROM [MAS_Customers] a WITH (NOLOCK)
        JOIN MAS_Apartment_Member b WITH (NOLOCK) ON a.CustId = b.CustId 
        WHERE b.ApartmentId = @ApartmentId 
        AND (b.leaveId = 0 OR b.leaveId IS NULL)
        AND (@filter = '' OR a.FullName LIKE N'%' + @filter + N'%');
        
        INSERT INTO #RequiredCustIds (CustId)
        SELECT DISTINCT ISNULL(a.CustId, '')
        FROM UserInfo a WITH (NOLOCK)
        JOIN MAS_Apartment_Reg b WITH (NOLOCK) ON a.UserId = b.userId 
        JOIN MAS_Apartments p WITH (NOLOCK) ON b.RoomCode = p.RoomCode 
        WHERE p.ApartmentId = @ApartmentId 
        AND b.reg_st = 0
        AND NOT EXISTS (
            SELECT 1 FROM MAS_Apartment_Member am WITH (NOLOCK)
            WHERE am.ApartmentId = p.ApartmentId 
            AND am.CustId = a.custId 
            AND am.memberUserId = b.userId
        )
        AND (@filter = '' OR a.FullName LIKE N'%' + @filter + N'%')
        AND NOT EXISTS (SELECT 1 FROM #RequiredCustIds WHERE CustId = a.CustId);
    END
    
    IF @MemberType IN ('Old')
    BEGIN
        INSERT INTO #RequiredCustIds (CustId)
        SELECT DISTINCT a.CustId 
        FROM [MAS_Customers] a WITH (NOLOCK)
        JOIN MAS_Apartment_Member b WITH (NOLOCK) ON a.CustId = b.CustId 
        WHERE b.ApartmentId = @ApartmentId 
        AND b.leaveId = 1
        AND (@filter = '' OR a.FullName LIKE N'%' + @filter + N'%')
        AND NOT EXISTS (SELECT 1 FROM #RequiredCustIds WHERE CustId = a.CustId);
    END

    -- CHỈ load images cho những CustId đã được xác định (tối ưu lớn)
    IF OBJECT_ID('tempdb..#CustomerImages') IS NOT NULL DROP TABLE #CustomerImages;
    
    SELECT ci.CustId, 
           MAX(CASE WHEN ci.Imagetype = 1 THEN ci.imageUrl END) as FaceRecogUrl1,
           MAX(CASE WHEN ci.Imagetype = 2 THEN ci.imageUrl END) as FaceRecogUrl2,
           MAX(CASE WHEN ci.Imagetype = 3 THEN ci.imageUrl END) as FaceRecogUrl3,
           MAX(CASE WHEN ci.Imagetype = 4 THEN ci.imageUrl END) as FaceRecogUrl4,
           MAX(CASE WHEN ci.Imagetype = 5 THEN ci.imageUrl END) as FaceRecogUrl5
    INTO #CustomerImages
    FROM [MAS_Customer_Image] ci WITH (NOLOCK)
    INNER JOIN #RequiredCustIds r ON r.CustId = ci.CustId
    WHERE ci.Imagetype IN (1,2,3,4,5)
    GROUP BY ci.CustId;
    
    CREATE CLUSTERED INDEX IX_CustomerImages_CustId ON #CustomerImages(CustId);

    -- Đếm tổng - tách riêng để tối ưu
    IF @MemberType IN ('Current')
    BEGIN
        SELECT @TotalCurrent = COUNT(1)
        FROM MAS_Customers a WITH (NOLOCK)
        JOIN MAS_Apartment_Member b WITH (NOLOCK) ON a.CustId = b.CustId
        WHERE b.ApartmentId = @ApartmentId
          AND (b.leaveId = 0 OR b.leaveId IS NULL)
          AND (@filter = '' OR a.FullName LIKE N'%' + @filter + N'%');

        SELECT @TotalPending = COUNT(1)
        FROM UserInfo a WITH (NOLOCK)
        JOIN MAS_Apartment_Reg b WITH (NOLOCK) ON a.UserId = b.userId
        JOIN MAS_Apartments p WITH (NOLOCK) ON b.RoomCode = p.RoomCode
        WHERE p.ApartmentId = @ApartmentId
          AND b.reg_st = 0
          AND (@filter = '' OR a.FullName LIKE N'%' + @filter + N'%');
    END

    IF @MemberType IN ('Old')
    BEGIN
        SELECT @TotalOld = COUNT(1)
        FROM MAS_Customers a WITH (NOLOCK)
        JOIN MAS_Apartment_Member b WITH (NOLOCK) ON a.CustId = b.CustId
        WHERE b.ApartmentId = @ApartmentId
          AND b.leaveId = 1
          AND (@filter = '' OR a.FullName LIKE N'%' + @filter + N'%');
    END

    IF @MemberType = 'Current'
    BEGIN
        SET @Total = @TotalCurrent + @TotalPending;
    END
    ELSE IF @MemberType = 'Old'
    BEGIN
        SET @Total = @TotalOld;
    END
    ELSE -- All
    BEGIN
        SET @Total = @TotalCurrent + @TotalPending + @TotalOld;
    END

    --root	
	SELECT recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1
    
    --grid config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
    END;
    
    -- Data - Tách riêng theo MemberType để tối ưu
    IF @MemberType = 'Current'
    BEGIN
        -- Tạo temp table cho app users
        IF OBJECT_ID('tempdb..#AppUsersCurrent') IS NOT NULL DROP TABLE #AppUsersCurrent;
        SELECT DISTINCT mu.CustId
        INTO #AppUsersCurrent
        FROM MAS_Apartments ma WITH (NOLOCK)
        JOIN dbo.MAS_Apartment_Member me WITH (NOLOCK) ON ma.ApartmentId=me.ApartmentId
        JOIN UserInfo mu WITH (NOLOCK) ON me.CustId=mu.CustId
        WHERE ma.ApartmentId = @ApartmentId;
        CREATE CLUSTERED INDEX IX_AppUsersCurrent ON #AppUsersCurrent(CustId);
        
        IF OBJECT_ID('tempdb..#UserType2Current') IS NOT NULL DROP TABLE #UserType2Current;
        SELECT DISTINCT u.CustId
        INTO #UserType2Current
        FROM UserInfo u WITH (NOLOCK)
        INNER JOIN #RequiredCustIds r ON r.CustId = u.CustId
        WHERE u.userType = 2;
        CREATE CLUSTERED INDEX IX_UserType2Current ON #UserType2Current(CustId);
        
        SELECT * FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY CustId ORDER BY IsCurrent DESC, EffectiveDate DESC) AS rn
            FROM (
            SELECT a.CustId 
                  ,a.[FullName]
                  ,a.[IsSex]
                  ,case when a.[IsSex] = 1 then N'Nam' else N'Nữ' end as SexName
                  ,convert(nvarchar(10),a.birthday,103) as birthday
                  ,a.[Phone]
                  ,a.[Email]
                  ,CASE WHEN  b.memberUserId IS NOT NULL THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' 
                    ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' 
                    END as [isAppName]
                  ,b.[ApartmentId]
                  ,case when b.RelationId = 0 then 1 else 0 end as [IsHost]
                  ,case when b.RelationId = 0 then '<i class="pi pi-check text-blue-500 font-bold"></i>' else '<i class="pi pi-times text-red-500 font-bold"></i>' end as [IsHostName]
                  ,a.[AvatarUrl]
                  ,isnull(a.IsForeign,0) as IsForeign
                  ,CASE WHEN isnull(a.IsForeign,0) = 1 THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' END AS IsForeignName
                  ,ISNULL(b.member_St, 0) as [Status]
                  ,case when ISNULL(b.member_St, 0) = 0 then N'Chờ phê duyệt' else N'Đã phê duyệt' end as StatusName
                  ,convert(nvarchar(10),a.Auth_Dt,103) as AuthDate
                  ,ISNULL(img.FaceRecogUrl1, '') as FaceRecogUrl1
                  ,ISNULL(img.FaceRecogUrl2, '') as FaceRecogUrl2
                  ,ISNULL(img.FaceRecogUrl3, '') as FaceRecogUrl3
                  ,ISNULL(img.FaceRecogUrl4, '') as FaceRecogUrl4
                  ,ISNULL(img.FaceRecogUrl5, '') as FaceRecogUrl5
                  ,b.RelationId
                  ,isnull(d.RelationName,N'Khác') as RelationName
                  ,b.memberUserId userId
                  ,b.isNotification
                  ,case when b.memberUserId is not null OR ut2.CustId IS NOT NULL then 1 else 0 end as isApp
                  ,a.CountryCd
                  ,g.CountryName
                  ,ISNULL(CurrentHost.FullName, '') as HostName
                  ,convert(nvarchar(10), ISNULL(b.approveDt, b.RegDt), 103) as EffectiveDate
                  ,CONVERT(nvarchar(10), hist.ApproveDtEnd, 103) as EffectiveTo
              ,ISNULL(hist.Note, '') as Note
                  ,N'Hiện tại' as MemberTypeName
                  ,1 as IsCurrent
              FROM MAS_Customers a WITH (NOLOCK)
                JOIN MAS_Apartment_Member b WITH (NOLOCK) ON a.CustId = b.CustId 
                LEFT JOIN MAS_Customer_Relation d WITH (NOLOCK) ON b.RelationId = d.RelationId
                LEFT JOIN [COR_Countries] g WITH (NOLOCK) ON a.CountryCd = g.CountryCd
                LEFT JOIN #CustomerImages img ON img.CustId = a.CustId
                LEFT JOIN #AppUsersCurrent au ON au.CustId = a.CustId
                LEFT JOIN #UserType2Current ut2 ON ut2.CustId = a.CustId
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
                FROM MAS_Apartment_HostChange_History h WITH (NOLOCK)
                WHERE h.ApartmentId = b.ApartmentId
                  AND h.CustId = a.CustId
                ORDER BY 
                    CASE WHEN ISNULL(h.RelationId, 14) = 0 AND ISNULL(h.LeaveId, 0) = 0 THEN 0 ELSE 1 END,
                    ISNULL(h.ApproveDt, h.PerformedAt) DESC,
                    h.PerformedAt DESC,
                    h.HistoryId DESC
            ) hist
              WHERE b.ApartmentId = @ApartmentId 
              AND (b.leaveId = 0 OR b.leaveId IS NULL)
              AND (@filter = '' OR a.FullName LIKE N'%' + @filter + N'%')
              
            UNION ALL
            
            SELECT a.CustId 
                  ,a.[FullName]
                  ,a.[Sex] as [IsSex]
                  ,case when a.[Sex] = 1 then N'Nam' else N'Nữ' end as SexName
                  ,convert(nvarchar(10),a.birthday,103) as birthday
                  ,a.[Phone]
                  ,a.[Email]
                  ,CASE WHEN  b.userid IS NOT NULL THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' 
                    ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' 
                    END as [isAppName]
                  ,p.[ApartmentId]
                  ,case when b.RelationId = 0 then 1 else 0 end as [IsHost]
                  ,case when b.RelationId = 0 then '<i class="pi pi-check text-blue-500 font-bold"></i>' else '<i class="pi pi-times text-red-500 font-bold"></i>' end as [IsHostName]
                  ,a.[AvatarUrl]
                  ,case when a.res_Cntry = 'VN' or a.res_Cntry is null then 0 else 1 end as IsForeign
                  ,CASE WHEN (a.res_Cntry = 'VN') THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' END AS IsForeignName
                  ,ISNULL(am_pending.member_St, 0) as [Status]
                  ,case when ISNULL(am_pending.member_St, 0) = 0 then N'Chờ phê duyệt' else N'Đã phê duyệt' end as StatusName
                  ,null as AuthDate
                  ,ISNULL(img.FaceRecogUrl1, '') as FaceRecogUrl1
                  ,ISNULL(img.FaceRecogUrl2, '') as FaceRecogUrl2
                  ,ISNULL(img.FaceRecogUrl3, '') as FaceRecogUrl3
                  ,ISNULL(img.FaceRecogUrl4, '') as FaceRecogUrl4
                  ,ISNULL(img.FaceRecogUrl5, '') as FaceRecogUrl5
                  ,b.RelationId
                  ,isnull(d.RelationName,N'Khác') as RelationName
                  ,b.userId
                  ,0 as isNotification
                  ,case when b.userid is not null then 1 else 0 end as isApp
                  ,'VN' as countryCd
                  ,N'Việt Nam' as CountryName
                  ,ISNULL(CurrentHost.FullName, '') as HostName
                  ,null as EffectiveDate
                  ,NULL as EffectiveTo
                  ,NULL as Note
                  ,N'Chờ duyệt' as MemberTypeName
                  ,1 as IsCurrent
              FROM UserInfo a WITH (NOLOCK)
             JOIN MAS_Apartment_Reg b WITH (NOLOCK) ON a.UserId = b.userId 
                JOIN MAS_Apartments p WITH (NOLOCK) ON b.RoomCode = p.RoomCode 
                LEFT JOIN MAS_Customer_Relation d WITH (NOLOCK) ON b.RelationId = d.RelationId
                LEFT JOIN #CustomerImages img ON img.CustId = a.CustId
                LEFT JOIN #AppUsersCurrent au ON au.CustId = a.CustId
                LEFT JOIN MAS_Apartment_Member am_pending WITH (NOLOCK) ON am_pending.ApartmentId = p.ApartmentId AND am_pending.CustId = a.CustId
                OUTER APPLY (
                    SELECT TOP 1 ch.FullName
                    FROM MAS_Apartment_Member hostMem WITH (NOLOCK)
                    JOIN MAS_Customers ch WITH (NOLOCK) ON ch.CustId = hostMem.CustId
                    WHERE hostMem.ApartmentId = p.ApartmentId
                      AND hostMem.RelationId = 0
                    ORDER BY ISNULL(hostMem.approveDt, hostMem.RegDt) DESC
                ) CurrentHost
              WHERE p.ApartmentId = @ApartmentId 
                AND b.reg_st = 0
                AND (@filter = '' OR a.FullName LIKE N'%' + @filter + N'%')
                AND NOT EXISTS (
                    SELECT 1 FROM MAS_Apartment_Member am WITH (NOLOCK)
                    WHERE am.ApartmentId = p.ApartmentId 
                    AND am.CustId = a.CustId
                )
        ) AS AllMembers
        ) AS RankedMembers
        WHERE rn = 1
        ORDER BY IsCurrent DESC, EffectiveDate DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
        
        DROP TABLE #AppUsersCurrent;
        DROP TABLE #UserType2Current;
    END
    ELSE IF @MemberType = 'Old'
    BEGIN
        SELECT *
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY HistoryId ORDER BY PerformedAt DESC, EffectiveDate DESC) AS rn
            FROM (
                SELECT 
                      h.HistoryId
                      ,h.CustId as CustId
                      ,c.[FullName]
                      ,c.[IsSex]
                      ,case when c.[IsSex] = 1 then N'Nam' else N'Nữ' end as SexName
                      ,convert(nvarchar(10), c.birthday, 103) as birthday
                      ,c.[Phone]
                      ,c.[Email]
                      ,CASE WHEN c.[Phone] IS NOT NULL THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' 
                    ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' 
                    END as [isAppName]
                      ,h.ApartmentId
                      ,CASE WHEN ISNULL(h.RelationId, ISNULL(b.RelationId, 0)) = 0 THEN 1 ELSE 0 END as [IsHost]
                      ,CASE WHEN ISNULL(h.RelationId, ISNULL(b.RelationId, 0)) = 0 
                            THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' 
                            ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' 
                       END as [IsHostName]
                      ,c.[AvatarUrl]
                      ,ISNULL(h.IsForeign, c.IsForeign) as IsForeign
                      ,CASE WHEN ISNULL(h.IsForeign, c.IsForeign) = 1 THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' END AS IsForeignName
                      ,ISNULL(b.member_St, 1) as [Status]
                      ,case when ISNULL(b.member_St, 1) = 0 then N'Chờ phê duyệt' else N'Đã phê duyệt' end as StatusName
                      ,null as AuthDate
                      ,ISNULL(img.FaceRecogUrl1, '') as FaceRecogUrl1
                      ,ISNULL(img.FaceRecogUrl2, '') as FaceRecogUrl2
                      ,ISNULL(img.FaceRecogUrl3, '') as FaceRecogUrl3
                      ,ISNULL(img.FaceRecogUrl4, '') as FaceRecogUrl4
                      ,ISNULL(img.FaceRecogUrl5, '') as FaceRecogUrl5
                      ,ISNULL(h.RelationId, ISNULL(b.RelationId, 0)) as RelationId
                      ,isnull(d.RelationName,N'Khác') as RelationName
                      ,b.memberUserId as userId
                      ,ISNULL(b.isNotification, 0) as isNotification
                      ,case when b.memberUserId is not null then 1 else 0 end as isApp
                      ,c.CountryCd
                      ,g.CountryName
                      ,ISNULL(LatestHost.FullName, '') as HostName
                      ,CONVERT(nvarchar(10), ISNULL(h.ApproveDt, ISNULL(b.approveDt, b.RegDt)), 103) as EffectiveDate
                      ,CONVERT(nvarchar(10), h.ApproveDtEnd, 103) as EffectiveTo
                      ,h.Note as Note
                      ,N'Đã rời đi' as MemberTypeName
                      ,0 as IsCurrent
                      ,h.PerformedAt
                FROM MAS_Apartment_HostChange_History h WITH (NOLOCK)
                INNER JOIN MAS_Customers c WITH (NOLOCK) ON h.CustId = c.CustId
                LEFT JOIN MAS_Apartment_Member b WITH (NOLOCK) ON b.CustId = h.CustId AND b.ApartmentId = h.ApartmentId
                LEFT JOIN MAS_Customer_Relation d WITH (NOLOCK) ON d.RelationId = ISNULL(h.RelationId, ISNULL(b.RelationId, 0))
                LEFT JOIN [COR_Countries] g WITH (NOLOCK) ON g.CountryCd = c.CountryCd
                LEFT JOIN #CustomerImages img ON img.CustId = h.CustId
                OUTER APPLY (
                    SELECT TOP 1 hc.FullName
                    FROM MAS_Apartment_HostChange_History hh WITH (NOLOCK)
                    INNER JOIN MAS_Customers hc WITH (NOLOCK) ON hh.NewCustId = hc.CustId
                    WHERE hh.ApartmentId = h.ApartmentId
                      AND hh.PerformedAt <= h.PerformedAt
                      AND (ISNULL(hh.RelationId, 0) = 0)
                    ORDER BY hh.PerformedAt DESC
                ) LatestHost
                WHERE h.ApartmentId = @ApartmentId
                  AND h.CustId IS NOT NULL
                  AND (@filter = '' OR c.FullName LIKE N'%' + @filter + N'%')
            ) AS RankedOldMembers
        ) AS OldMembers
        WHERE rn = 1
        ORDER BY PerformedAt DESC, EffectiveDate DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END
    ELSE -- All - Tối ưu bằng cách tạo temp tables riêng cho từng loại
    BEGIN
        -- Tạo temp table cho thành viên hiện tại
        IF OBJECT_ID('tempdb..#CurrentMembers') IS NOT NULL DROP TABLE #CurrentMembers;
        
        -- Tạo temp table cho app users
        IF OBJECT_ID('tempdb..#AppUsers') IS NOT NULL DROP TABLE #AppUsers;
        SELECT DISTINCT mu.CustId
        INTO #AppUsers
        FROM MAS_Apartments ma WITH (NOLOCK)
        JOIN dbo.MAS_Apartment_Member me WITH (NOLOCK) ON ma.ApartmentId=me.ApartmentId
        JOIN UserInfo mu WITH (NOLOCK) ON me.CustId=mu.CustId
        WHERE ma.ApartmentId = @ApartmentId;
        CREATE CLUSTERED INDEX IX_AppUsers ON #AppUsers(CustId);
        
        IF OBJECT_ID('tempdb..#UserType2') IS NOT NULL DROP TABLE #UserType2;
        SELECT DISTINCT u.CustId
        INTO #UserType2
        FROM UserInfo u WITH (NOLOCK)
        INNER JOIN #RequiredCustIds r ON r.CustId = u.CustId
        WHERE u.userType = 2;
        CREATE CLUSTERED INDEX IX_UserType2 ON #UserType2(CustId);
        
        -- Lấy tất cả - sử dụng temp tables đã tạo
        SELECT * FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY CustId ORDER BY IsCurrent DESC, EffectiveDate DESC) AS rn
            FROM (
            -- Thành viên hiện tại
            SELECT a.CustId 
                  ,a.[FullName]
                  ,a.[IsSex]
                  ,case when a.[IsSex] = 1 then N'Nam' else N'Nữ' end as SexName
                  ,convert(nvarchar(10),a.birthday,103) as birthday
                  ,a.[Phone]
                  ,a.[Email]
                  ,CASE WHEN b.memberUserId IS NOT NULL THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' 
                    ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' 
                    END as [isAppName]
                  ,b.[ApartmentId]
                  ,case when b.RelationId = 0 then 1 else 0 end as [IsHost]
                  ,case when b.RelationId = 0 then '<i class="pi pi-check text-blue-500 font-bold"></i>' else '<i class="pi pi-times text-red-500 font-bold"></i>' end as [IsHostName]
                  ,a.[AvatarUrl]
                  ,isnull(a.IsForeign,0) as IsForeign
                  ,CASE WHEN isnull(a.IsForeign,0) = 1 THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' END AS IsForeignName
                  ,ISNULL(b.member_St, 0) as [Status]
                  ,case when ISNULL(b.member_St, 0) = 0 then N'Chờ phê duyệt' else N'Đã phê duyệt' end as StatusName
                  ,convert(nvarchar(10),a.Auth_Dt,103) as AuthDate
                  ,ISNULL(img.FaceRecogUrl1, '') as FaceRecogUrl1
                  ,ISNULL(img.FaceRecogUrl2, '') as FaceRecogUrl2
                  ,ISNULL(img.FaceRecogUrl3, '') as FaceRecogUrl3
                  ,ISNULL(img.FaceRecogUrl4, '') as FaceRecogUrl4
                  ,ISNULL(img.FaceRecogUrl5, '') as FaceRecogUrl5
                  ,b.RelationId
                  ,isnull(d.RelationName,N'Khác') as RelationName
                  ,b.memberUserId userId
                  ,b.isNotification
                  ,case when b.memberUserId is not null OR ut2.CustId IS NOT NULL then 1 else 0 end as isApp
                  ,a.CountryCd
                  ,g.CountryName
                  ,ISNULL(CurrentHost.FullName, '') as HostName
                  ,convert(nvarchar(10), ISNULL(b.approveDt, b.RegDt), 103) as EffectiveDate
                  ,CONVERT(nvarchar(10), hist.ApproveDtEnd, 103) as EffectiveTo
              ,ISNULL(hist.Note, '') as Note
                  ,N'Hiện tại' as MemberTypeName
                  ,1 as IsCurrent
              FROM MAS_Customers a WITH (NOLOCK)
                JOIN MAS_Apartment_Member b WITH (NOLOCK) ON a.CustId = b.CustId 
                LEFT JOIN MAS_Customer_Relation d WITH (NOLOCK) ON b.RelationId = d.RelationId
                LEFT JOIN [COR_Countries] g WITH (NOLOCK) ON a.CountryCd = g.CountryCd
                LEFT JOIN #CustomerImages img ON img.CustId = a.CustId
                LEFT JOIN #AppUsers au ON au.CustId = a.CustId
                LEFT JOIN #UserType2 ut2 ON ut2.CustId = a.CustId
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
                FROM MAS_Apartment_HostChange_History h WITH (NOLOCK)
                WHERE h.ApartmentId = b.ApartmentId
                  AND h.CustId = a.CustId
                ORDER BY h.PerformedAt DESC, h.HistoryId DESC
            ) hist
              WHERE b.ApartmentId = @ApartmentId 
              AND (b.leaveId = 0 OR b.leaveId IS NULL)
              AND (@filter = '' OR a.FullName LIKE N'%' + @filter + N'%')
              
            UNION ALL
            
            -- Thành viên chờ duyệt
            SELECT a.CustId 
                  ,a.[FullName]
                  ,a.[Sex] as [IsSex]
                  ,case when a.[Sex] = 1 then N'Nam' else N'Nữ' end as SexName
                  ,convert(nvarchar(10),a.birthday,103) as birthday
                  ,a.[Phone]
                  ,a.[Email]
                  ,CASE WHEN  b.userid IS NOT NULL THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' 
                    ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' 
                    END as [isAppName]
                  ,p.[ApartmentId]
                  ,case when b.RelationId = 0 then 1 else 0 end as [IsHost]
                  ,case when b.RelationId = 0 then '<i class="pi pi-check text-blue-500 font-bold"></i>' else '<i class="pi pi-times text-red-500 font-bold"></i>' end as [IsHostName]
                  ,a.[AvatarUrl]
                  ,case when a.res_Cntry = 'VN' or a.res_Cntry is null then 0 else 1 end as IsForeign
                  ,CASE WHEN (a.res_Cntry = 'VN') THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' END AS IsForeignName
                  ,ISNULL(am_pending_all.member_St, 0) as [Status]
                  ,case when ISNULL(am_pending_all.member_St, 0) = 0 then N'Chờ phê duyệt' else N'Đã phê duyệt' end as StatusName
                  ,null as AuthDate
                  ,ISNULL(img.FaceRecogUrl1, '') as FaceRecogUrl1
                  ,ISNULL(img.FaceRecogUrl2, '') as FaceRecogUrl2
                  ,ISNULL(img.FaceRecogUrl3, '') as FaceRecogUrl3
                  ,ISNULL(img.FaceRecogUrl4, '') as FaceRecogUrl4
                  ,ISNULL(img.FaceRecogUrl5, '') as FaceRecogUrl5
                  ,b.RelationId
                  ,isnull(d.RelationName,N'Khác') as RelationName
                  ,b.userId
                  ,0 as isNotification
                  ,case when b.userid is not null then 1 else 0 end as isApp
                  ,'VN' as countryCd
                  ,N'Việt Nam' as CountryName
                  ,ISNULL(CurrentHost.FullName, '') as HostName
                  ,null as EffectiveDate
                  ,NULL as EffectiveTo
                  ,NULL as Note
                  ,N'Chờ duyệt' as MemberTypeName
                  ,1 as IsCurrent
              FROM UserInfo a WITH (NOLOCK)
             JOIN MAS_Apartment_Reg b WITH (NOLOCK) ON a.UserId = b.userId 
                JOIN MAS_Apartments p WITH (NOLOCK) ON b.RoomCode = p.RoomCode 
                LEFT JOIN MAS_Customer_Relation d WITH (NOLOCK) ON b.RelationId = d.RelationId
                LEFT JOIN #CustomerImages img ON img.CustId = a.CustId
                LEFT JOIN #AppUsers au ON au.CustId = a.CustId
                LEFT JOIN MAS_Apartment_Member am_pending_all WITH (NOLOCK) ON am_pending_all.ApartmentId = p.ApartmentId AND am_pending_all.CustId = a.CustId
                OUTER APPLY (
                    SELECT TOP 1 ch.FullName
                    FROM MAS_Apartment_Member hostMem WITH (NOLOCK)
                    JOIN MAS_Customers ch WITH (NOLOCK) ON ch.CustId = hostMem.CustId
                    WHERE hostMem.ApartmentId = p.ApartmentId
                      AND hostMem.RelationId = 0
                    ORDER BY ISNULL(hostMem.approveDt, hostMem.RegDt) DESC
                ) CurrentHost
              WHERE p.ApartmentId = @ApartmentId 
                AND b.reg_st = 0
                AND (@filter = '' OR a.FullName LIKE N'%' + @filter + N'%')
                AND NOT EXISTS (
                    SELECT 1 FROM MAS_Apartment_Member am WITH (NOLOCK)
                    WHERE am.ApartmentId = p.ApartmentId 
                    AND am.CustId = a.CustId
                )
                
            UNION ALL
            
            -- Thành viên cũ
            SELECT 
                  c.CustId
                  ,c.[FullName]
                  ,c.[IsSex]
                  ,case when c.[IsSex] = 1 then N'Nam' else N'Nữ' end as SexName
                  ,convert(nvarchar(10),c.birthday,103) as birthday
                  ,c.[Phone]
                  ,c.[Email]
                  ,CASE WHEN c.[Phone] IS NOT NULL THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' 
                    ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' 
                    END as [isAppName]
                  ,b.[ApartmentId]
                  ,case when b.RelationId = 0 then 1 else 0 end as [IsHost]
                  ,case when b.RelationId = 0 then '<i class="pi pi-check text-blue-500 font-bold"></i>' else '<i class="pi pi-times text-red-500 font-bold"></i>' end as [IsHostName]
                  ,c.[AvatarUrl]
                  ,isnull(c.IsForeign,0) as IsForeign
                  ,CASE WHEN isnull(c.IsForeign,0) = 1 THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' END AS IsForeignName
                  ,ISNULL(b.member_St, 1) as [Status]
                  ,case when ISNULL(b.member_St, 1) = 0 then N'Chờ phê duyệt' else N'Đã phê duyệt' end as StatusName
                  ,null as AuthDate
                  ,ISNULL(img.FaceRecogUrl1, '') as FaceRecogUrl1
                  ,ISNULL(img.FaceRecogUrl2, '') as FaceRecogUrl2
                  ,ISNULL(img.FaceRecogUrl3, '') as FaceRecogUrl3
                  ,ISNULL(img.FaceRecogUrl4, '') as FaceRecogUrl4
                  ,ISNULL(img.FaceRecogUrl5, '') as FaceRecogUrl5
                  ,b.RelationId
                  ,isnull(d.RelationName,N'Khác') as RelationName
                  ,b.memberUserId as userId
                  ,b.isNotification
                  ,case when b.memberUserId is not null then 1 else 0 end as isApp
                  ,c.CountryCd
                  ,g.CountryName
                  ,CONVERT(nvarchar(10), ISNULL(b.approveDt, b.RegDt), 103) as EffectiveDate
                  ,CONVERT(nvarchar(10), histOld.ApproveDtEnd, 103) as EffectiveTo
              ,ISNULL(histOld.Note, '') as Note
                  ,N'Đã rời đi' as MemberTypeName
                  ,0 as IsCurrent
              FROM MAS_Customers c WITH (NOLOCK)
              INNER JOIN MAS_Apartment_Member b WITH (NOLOCK) ON c.CustId = b.CustId
              LEFT JOIN MAS_Customer_Relation d WITH (NOLOCK) ON d.RelationId = b.RelationId
              LEFT JOIN [COR_Countries] g WITH (NOLOCK) ON g.CountryCd = c.CountryCd
              LEFT JOIN #CustomerImages img ON img.CustId = c.CustId
          OUTER APPLY (
              SELECT TOP 1 h.Note, h.ApproveDtEnd
              FROM MAS_Apartment_HostChange_History h WITH (NOLOCK)
              WHERE h.ApartmentId = b.ApartmentId
                AND h.CustId = c.CustId
              ORDER BY h.PerformedAt DESC, h.HistoryId DESC
          ) histOld
              WHERE b.ApartmentId = @ApartmentId
              AND b.leaveId = 1
              AND (@filter = '' OR c.FullName LIKE N'%' + @filter + N'%')
            ) AS AllMembers
        ) AS RankedAll
        WHERE rn = 1
        ORDER BY IsCurrent DESC, EffectiveDate DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
        
        -- Cleanup temp tables
        DROP TABLE #AppUsers;
        DROP TABLE #UserType2;
    END
    
    DROP TABLE #CustomerImages;
    DROP TABLE #RequiredCustIds;

END TRY
BEGIN CATCH
    IF OBJECT_ID('tempdb..#CustomerImages') IS NOT NULL DROP TABLE #CustomerImages;
    IF OBJECT_ID('tempdb..#AppUsers') IS NOT NULL DROP TABLE #AppUsers;
    IF OBJECT_ID('tempdb..#UserType2') IS NOT NULL DROP TABLE #UserType2;
    IF OBJECT_ID('tempdb..#RequiredCustIds') IS NOT NULL DROP TABLE #RequiredCustIds;
    
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_family_member_page' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'FamilyMember',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;