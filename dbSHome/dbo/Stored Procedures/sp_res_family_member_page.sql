
CREATE PROCEDURE [dbo].[sp_res_family_member_page]
    @userId UNIQUEIDENTIFIER,
    @filter NVARCHAR(30) = NULL,
	@ApartmentId INT = NULL, -- Backward compatible
	@Oid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID)
    @Offset INT = 0,
    @PageSize INT = 10,
    @Total INT = 0 OUT,
    @TotalFiltered INT = 0 OUT,
	@GridKey		nvarchar(200) out,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- =============================================
    -- LẤY TENANT_OID TỪ USERS
    -- =============================================
    DECLARE @tenantOid UNIQUEIDENTIFIER = NULL;
    
    IF @userId IS NOT NULL
    BEGIN
        SELECT @tenantOid = tenant_oid
        FROM Users
        WHERE userId = @userId;
        
        -- Kiểm tra user có tenant_oid không
        IF @tenantOid IS NULL
        BEGIN
            SET @Total = 0;
            SET @TotalFiltered = 0;
            SET @GridKey = 'view_apartment_family_member_page';
            RETURN;
        END
    END

    -- =============================================
    -- XÁC ĐỊNH ACTUAL APARTMENT ID TỪ OID HOẶC APARTMENTID
    -- =============================================
    DECLARE @ActualApartmentId INT = NULL;
    
    IF @Oid IS NOT NULL
    BEGIN
        SELECT @ActualApartmentId = a.ApartmentId
        FROM MAS_Apartments a
        WHERE a.oid = @Oid
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END
    ELSE IF @ApartmentId IS NOT NULL
    BEGIN
        SELECT @ActualApartmentId = a.ApartmentId
        FROM MAS_Apartments a
        WHERE a.ApartmentId = @ApartmentId
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END

    -- Nếu không tìm thấy căn hộ, trả về rỗng
    IF @ActualApartmentId IS NULL
    BEGIN
        SET @Total = 0;
        SET @TotalFiltered = 0;
        SET @GridKey = 'view_apartment_family_member_page';
        RETURN;
    END

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');
	set		@GridKey				= 'view_apartment_family_member_page'

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    SELECT @Total = COUNT(CustId)
    FROM (SELECT a.CustId 
	  FROM [MAS_Customers] a 
		join MAS_Apartment_Member b on a.CustId = b.CustId 
		join MAS_Apartments ap on b.ApartmentId = ap.ApartmentId
			left join MAS_Customer_Relation d on b.RelationId = d.RelationId
			left join [COR_Countries] g on a.CountryCd = g.CountryCd 
			-- WHERE b.ApartmentId = 6120 AND b.[member_st] = 0
	  WHERE b.ApartmentId = @ActualApartmentId 
	    AND (@tenantOid IS NULL OR ap.tenant_oid = @tenantOid)
		 --and b.[member_st] = 1
	  --ORDER BY a.sysDate
		UNION ALL
	SELECT a.CustId 
	  FROM UserInfo a 
		join MAS_Apartment_Reg b on a.UserId = b.userId 
		join MAS_Apartments p on b.RoomCode = p.RoomCode 
			left join MAS_Customer_Relation d on b.RelationId = d.RelationId
			--WHERE p.ApartmentId = 6120
	  WHERE 
	  p.ApartmentId = @ActualApartmentId 
	    AND (@tenantOid IS NULL OR p.tenant_oid = @tenantOid)
		and 
		b.reg_st = 0
		and not exists(select * from MAS_Apartment_Member am 
		join MAS_Customers cc on am.CustId = cc.CustId 
		where am.ApartmentId = p.ApartmentId and am.CustId = a.custId and am.memberUserId = b.userId)) #temp


    SET @TotalFiltered = @Total;

    IF @PageSize < 0
    BEGIN
        SET @PageSize = 10;
    END;
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang('view_apartment_family_member_page', 0, @acceptLanguage)
        ORDER BY [ordinal];

    END;
    
	SELECT a.CustId 
		  ,a.[FullName]
		  ,a.[IsSex]
		  ,case when a.[IsSex] = 1 then N'Nam' else N'Nữ' end as SexName
		  ,convert(nvarchar(10),a.birthday,103) as birthday
		  ,a.[Phone]
		  ,a.[Email]
		  ,CASE	when exists(
				SELECT ma.ApartmentId from MAS_Apartments ma JOIN dbo.MAS_Apartment_Member me ON ma.ApartmentId=me.ApartmentId
				JOIN UserInfo mu on me.CustId=mu.CustId
				WHERE mu.CustId = a.CustId and ma.ApartmentId = b.ApartmentId) 
			THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' 
			ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' 
			END as [isAppName]
		  ,b.[ApartmentId]
		  --,isnull(p.CurrPoint,0) as [CurrentPoint]
		  ,case when b.RelationId = 0 then 1 else 0 end as [IsHost]
			,case when  b.RelationId = 0 then '<i class="pi pi-check text-blue-500 font-bold"></i>' else '<i class="pi pi-times text-red-500 font-bold"></i>' end as [IsHostName]
		  ,a.[AvatarUrl]
		  ,isnull(a.IsForeign,0) as IsForeign
		  ,CASE WHEN isnull(a.IsForeign,0) = 1
			THEN '<i class="pi pi-check text-blue-500 font-bold"></i>'
			ELSE
             '<i class="pi pi-times text-red-500 font-bold"></i>'
			 END AS IsForeignName
		  ,isnull(b.member_St,1) as [Status]
		  ,case when isnull(b.member_St,1) = 0 then N'Chờ phê duyệt' else N'Đã phê duyệt' end as StatusName
		  ,convert(nvarchar(10),a.Auth_Dt,103) as AuthDate
		  --,a.CustId
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 1) as FaceRecogUrl1
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 2) as FaceRecogUrl2
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 3) as FaceRecogUrl3
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 4) as FaceRecogUrl4
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 5) as FaceRecogUrl5
		  ,b.RelationId
		  ,isnull(d.RelationName,N'Khác') as RelationName
		  ,b.memberUserId
		  ,b.isNotification
		  ,case when b.memberUserId is not null or exists(select userid from UserInfo mu 
				where mu.CustId = a.CustId and mu.userType = 2) then 1 else 0 end as isApp
		  ,a.CountryCd
		  ,g.CountryName
	  FROM MAS_Customers a 
		join MAS_Apartment_Member b on a.CustId = b.CustId 
		join MAS_Apartments ap on b.ApartmentId = ap.ApartmentId
			left join MAS_Customer_Relation d on b.RelationId = d.RelationId
			left join [COR_Countries] g on a.CountryCd = g.CountryCd 
			-- WHERE b.ApartmentId = 6120 AND b.[member_st] = 0
	  WHERE b.ApartmentId = @ActualApartmentId 
	    AND (@tenantOid IS NULL OR ap.tenant_oid = @tenantOid)
		 --and b.[member_st] = 1
	  --ORDER BY a.sysDate
		UNION ALL
	SELECT a.CustId 
		  ,a.[FullName]
		  ,a.[Sex] as [IsSex]
		  ,case when a.[Sex] = 1 then N'Nam' else N'Nữ' end as SexName
		  ,convert(nvarchar(10),a.birthday,103) as birthday
		  ,a.[Phone]
		  ,a.[Email]
		   ,CASE	when exists(
				SELECT ma.ApartmentId from MAS_Apartments ma JOIN dbo.MAS_Apartment_Member me ON ma.ApartmentId=me.ApartmentId
				JOIN UserInfo mu on me.CustId=mu.CustId
				WHERE mu.CustId = a.CustId and ma.ApartmentId = p.ApartmentId) 
			THEN '<i class="pi pi-check text-blue-500 font-bold"></i>' 
			ELSE '<i class="pi pi-times text-red-500 font-bold"></i>' 
			END as [isAppName]
		  ,p.[ApartmentId]
		  ,case when b.RelationId = 0 then 1 else 0 end as [IsHost]
		,case when  b.RelationId = 0 then '<i class="pi pi-check text-blue-500 font-bold"></i>' else '<i class="pi pi-times text-red-500 font-bold"></i>' end as [IsHostName]
		  --,isnull(p.CurrPoint,0) as [CurrentPoint]
		  ,a.[AvatarUrl]
		  ,case when a.res_Cntry = 'VN' or a.res_Cntry is null then 0 else 1 end as IsForeign
		  ,CASE WHEN (a.res_Cntry = 'VN')
			THEN '<i class="pi pi-check text-blue-500 font-bold"></i>'
			ELSE
             '<i class="pi pi-times text-red-500 font-bold"></i>'
			 END AS IsForeignName
		  ,0 as [Status]
		  , N'Chờ phê duyệt' as StatusName
		  ,null as AuthDate
		  --,a.CustId
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 1) as FaceRecogUrl1
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 2) as FaceRecogUrl2
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 3) as FaceRecogUrl3
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 4) as FaceRecogUrl4
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 5) as FaceRecogUrl5
		  ,b.RelationId
		  ,isnull(d.RelationName,N'Khác') as RelationName
		  ,b.userId
		  ,0 as isNotification
		  ,case when b.userid is not null then 1 else 0 end as isApp
		  ,'VN' as countryCd
		  ,N'Việt Nam' as CountryName
	  FROM UserInfo a 
		join MAS_Apartment_Reg b on a.UserId = b.userId 
		join MAS_Apartments p on b.RoomCode = p.RoomCode 
			left join MAS_Customer_Relation d on b.RelationId = d.RelationId
			--WHERE p.ApartmentId = 6120
	  WHERE 
	  p.ApartmentId = @ActualApartmentId 
	    AND (@tenantOid IS NULL OR p.tenant_oid = @tenantOid)
		and 
		b.reg_st = 0
		and not exists(select * from MAS_Apartment_Member am join MAS_Customers cc on am.CustId = cc.CustId where am.ApartmentId = p.ApartmentId and am.CustId = a.custId 
		--AND am.userId = b.userId  duongvt
		)
	  --ORDER BY a.sysDate	


END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_family_member_page' + ERROR_MESSAGE();
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