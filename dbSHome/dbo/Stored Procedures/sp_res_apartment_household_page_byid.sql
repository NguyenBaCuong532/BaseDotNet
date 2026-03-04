CREATE PROCEDURE [dbo].[sp_res_apartment_household_page_byid]
    @userId UNIQUEIDENTIFIER,
	@clientId nvarchar(50) = null,
    @filter NVARCHAR(30) = NULL,
	@ApartmentId INT = NULL, -- Backward compatible
	@Oid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID) của MAS_Apartments
	@gridWidth int = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_apartment_household_page'
    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

	DECLARE @tenantOid UNIQUEIDENTIFIER = NULL;
	IF @userId IS NOT NULL
	BEGIN
		SELECT @tenantOid = tenant_oid FROM Users WHERE userId = @userId;
	END

	DECLARE @ActualApartmentId INT = NULL;
	DECLARE @ActualApartOid UNIQUEIDENTIFIER = NULL;

	-- Resolve @ActualApartmentId and @ActualApartOid
	IF @Oid IS NOT NULL
	BEGIN
		SELECT @ActualApartmentId = ApartmentId, @ActualApartOid = oid
		FROM MAS_Apartments
		WHERE oid = @Oid AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
	END
	ELSE IF @ApartmentId IS NOT NULL
	BEGIN
		SELECT @ActualApartmentId = ApartmentId, @ActualApartOid = oid
		FROM MAS_Apartments
		WHERE ApartmentId = @ApartmentId AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
	END

	IF @ActualApartmentId IS NULL OR @ActualApartmentId = 0
	BEGIN
		-- Try to get from UserInfo
		SELECT TOP 1 @ActualApartmentId = c.ApartmentId, @ActualApartOid = c.oid
		FROM UserInfo a 
		INNER JOIN MAS_Apartments c ON a.loginName = c.UserLogin 
		WHERE a.UserId = @userId
		  AND (@tenantOid IS NULL OR c.tenant_oid = @tenantOid);
	END

	IF @ActualApartmentId IS NULL
	BEGIN
		SELECT recordsTotal = 0, recordsFiltered = 0, gridKey = @GridKey, valid = 1;
		SELECT * FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage) ORDER BY [ordinal];
		SELECT NULL WHERE 1 = 0; -- Empty data set
		RETURN;
	END

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    SELECT @Total = COUNT(DISTINCT a.CustId)
	  FROM [MAS_Customers] a 
		OUTER APPLY (
			SELECT TOP (1) *
			FROM dbo.MAS_Customer_Household b
			WHERE b.CustId = a.CustId
			ORDER BY b.sysDate DESC, b.Pass_I_Dt DESC
		) b
		join MAS_Apartment_Member c on a.CustId = c.CustId 
		join MAS_Apartments ap on c.ApartmentId = ap.ApartmentId
		left join MAS_Customer_Relation d on c.RelationId = d.RelationId 
	WHERE EXISTS(SELECT [ApartmentId] FROM MAS_Apartment_Member WHERE CustId = a.CustId AND ApartmentId = @ActualApartmentId)
		and c.ApartmentId = @ActualApartmentId
		AND (@tenantOid IS NULL OR ap.tenant_oid = @tenantOid)


    --root	
	select recordsTotal = @Total
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
    -- Data
    SELECT a.CustId 
		  ,a.[FullName]
		  ,case when a.[IsSex] = 1 then N'Nam' else N'Nữ' end as SexName
		  ,convert(nvarchar(10),a.birthday,103) as birthday
		  ,a.[Phone]
		  ,a.[Email]
		  ,a.[IsHost]
		  ,c.[ApartmentId]
		  ,ap.oid as apartOid
		  ,a.[AvatarUrl]
		  ,isnull(a.IsForeign,0) as IsForeign
		  
		  ,isnull(b.[IsResident],0) IsResident
		  , CASE WHEN isnull(b.[IsResident],0) = 1 
		  THEN N'<i class="pi pi-check text-blue-500 font-bold"></i>'
		  ELSE N'<i class="pi pi-times text-red-500 font-bold"></i>'
		  END AS IsResidentName
		  ,b.[ResAdd1]
		  ,b.[ContactAdd1]
		  ,b.[Pass_No] as PassNo
		  ,convert(nvarchar(10),b.[Pass_I_Dt],103) as PassDate 
		  ,b.[Pass_I_Plc] as PassPlace
		  ,d.RelationName
	  FROM [MAS_Customers] a 
		OUTER APPLY (
			SELECT TOP (1) *
			FROM dbo.MAS_Customer_Household b
			WHERE b.CustId = a.CustId
			ORDER BY b.sysDate DESC, b.Pass_I_Dt DESC
		) b
		join MAS_Apartment_Member c on a.CustId = c.CustId
		join MAS_Apartments ap on c.ApartmentId = ap.ApartmentId
		left join MAS_Customer_Relation d on c.RelationId = d.RelationId 
	WHERE EXISTS(SELECT [ApartmentId] FROM MAS_Apartment_Member WHERE CustId = a.CustId AND ApartmentId = @ActualApartmentId)
		and c.ApartmentId = @ActualApartmentId
		AND (@tenantOid IS NULL OR ap.tenant_oid = @tenantOid)
    ORDER BY [IsHost] desc, b.sysDate desc OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_household_get' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_household',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;