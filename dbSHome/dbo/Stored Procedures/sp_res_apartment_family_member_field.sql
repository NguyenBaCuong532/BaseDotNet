CREATE PROCEDURE [dbo].[sp_res_apartment_family_member_field]
     @CustId NVARCHAR(450) = NULL
    , @ApartmentId INT = NULL -- Backward compatible
    , @Oid UNIQUEIDENTIFIER = NULL -- Ưu tiên sử dụng (GUID)
    , @UserId UNIQUEIDENTIFIER = NULL
    , @AcceptLanguage nvarchar(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- =============================================
    -- LẤY TENANT_OID TỪ USERS
    -- =============================================
    DECLARE @tenantOid UNIQUEIDENTIFIER = NULL;
    
    IF @UserId IS NOT NULL
    BEGIN
        SELECT @tenantOid = tenant_oid
        FROM Users
        WHERE userId = @UserId;
        
        -- Kiểm tra user có tenant_oid không
        IF @tenantOid IS NULL
        BEGIN
            SELECT 
                ApartmentId = NULL,
                apartOid = NULL,
                tableKey = N'MAS_Apartment_Family_Member',
                groupKey = N'common_group';
            RETURN;
        END
    END

    -- =============================================
    -- XÁC ĐỊNH ACTUAL APARTMENT ID TỪ OID HOẶC APARTMENTID
    -- =============================================
    DECLARE @ActualApartmentId INT = NULL;
    DECLARE @ActualOid UNIQUEIDENTIFIER = NULL;
    
    IF @Oid IS NOT NULL
    BEGIN
        SELECT @ActualApartmentId = a.ApartmentId, @ActualOid = a.oid
        FROM MAS_Apartments a
        WHERE a.oid = @Oid
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END
    ELSE IF @ApartmentId IS NOT NULL
    BEGIN
        SELECT @ActualApartmentId = a.ApartmentId, @ActualOid = a.oid
        FROM MAS_Apartments a
        WHERE a.ApartmentId = @ApartmentId
          AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
    END

    -- Nếu không tìm thấy căn hộ, trả về rỗng
    IF @ActualApartmentId IS NULL
    BEGIN
        SELECT 
            ApartmentId = NULL,
            apartOid = NULL,
            tableKey = N'MAS_Apartment_Family_Member',
            groupKey = N'common_group';
        RETURN;
    END

    DECLARE @group_key VARCHAR(50) = 'common_group'
    DECLARE @table_key VARCHAR(50) = 'MAS_Apartment_Family_Member'

    SELECT @ActualApartmentId [ApartmentId]
        , @ActualOid [apartOid]
        , tableKey = @table_key
        , groupKey = @group_key;

    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@group_key, @AcceptLanguage)
    ORDER BY intOrder;

    -- Lấy ra từng ô trong group
    IF EXISTS (
            SELECT 1
            FROM dbo.MAS_Customers
            WHERE CustId = @CustId
            )
    BEGIN
        SELECT s.id
			, s.[table_name]
			, [field_name]
			, [view_type]
			, [data_type]
			, [ordinal]
			, [columnLabel]
			, [group_cd]
			, ISNULL(CASE [field_name]
					WHEN 'ApartmentId'
						THEN LOWER(CONVERT(NVARCHAR(500), b.[ApartmentId]))
					WHEN 'avatarUrl'
						THEN b.AvatarUrl
					WHEN 'birthday'
						THEN b.birthday
					WHEN 'cifNo'
						THEN NULL
					WHEN 'countryCd'
						THEN b.CountryCd
					WHEN 'custId'
						THEN b.CustId
					WHEN 'email'
						THEN b.Email
					WHEN 'fullName'
						THEN b.[FullName]
					WHEN 'isForeign'
						THEN CASE WHEN ISNULL(b.IsForeign, 0) = 1 THEN N'1' ELSE N'0' END
					WHEN 'isNotification'
						THEN CASE WHEN ISNULL(b.isNotification, 0) = 1 THEN N'1' ELSE N'0' END
					WHEN 'isSex'
						THEN CASE WHEN ISNULL(b.IsSex, 0) = 1 THEN N'1' ELSE N'0' END
					WHEN 'phone'
						THEN b.Phone
					WHEN 'relationId'
						THEN CONVERT(NVARCHAR(500), b.RelationId)
					WHEN 'effectiveDate'
						THEN CONVERT(NVARCHAR(10), ISNULL(b.approveDt, b.RegDt), 103)
					WHEN 'effectiveDateEnd'
						THEN CONVERT(NVARCHAR(10),b.HistoryApproveDtEnd, 103)
					WHEN 'householdHead'
						THEN b.HouseholdHead
					WHEN 'note'
						THEN b.HistoryNote
					END, 
					[columnDefault]) AS columnValue
			, [columnClass]
			, [columnType]
			, [columnObject]
			, [isSpecial]
			, [isRequire]
			, [isDisable]
			, [isVisiable] = CASE
							WHEN b.IsForeign = 1 AND field_name IN('countryCd')
							THEN 1 
							WHEN b.IsForeign = 0 AND field_name IN('countryCd')
							THEN 0
							ELSE [s].[isVisiable] END
			, NULL AS [IsEmpty]
			, ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
			, s.columnDisplay
			, s.[isIgnore]
		FROM dbo.fn_config_form_gets('MAS_Apartment_Family_Member', @AcceptLanguage) s
		JOIN (
			SELECT a.CustId
				, a.[FullName]
				, a.[IsSex]
				, CASE 
					WHEN a.[IsSex] = 1
						THEN N'Nam'
					ELSE N'Nữ'
					END AS SexName
				, CONVERT(NVARCHAR(10), a.birthday, 103) AS birthday
				, a.[Phone]
				, a.[Email]
				, CASE 
					WHEN EXISTS (
							SELECT ApartmentId
							FROM MAS_Apartments ma
							JOIN UserInfo mu
								ON ma.UserLogin = mu.loginName
							WHERE mu.CustId = a.CustId
								AND ma.ApartmentId = b.ApartmentId
							)
						THEN 1
					ELSE 0
					END AS [IsHost]
				, b.[ApartmentId]
				, a.[AvatarUrl]
				, ISNULL(a.IsForeign, 0) AS IsForeign
				, ISNULL(b.member_St, 1) AS [Status]
				, CASE 
					WHEN ISNULL(b.member_St, 1) = 0
						THEN N'Chờ phê duyệt'
					ELSE N'Đã phê duyệt'
					END AS StatusName
				, CONVERT(NVARCHAR(10), a.Auth_Dt, 103) AS AuthDate
				, (
					SELECT TOP 1 [imageUrl]
					FROM [MAS_Customer_Image]
					WHERE CustId = a.CustId
						AND Imagetype = 1
					) AS FaceRecogUrl1
				, (
					SELECT TOP 1 [imageUrl]
					FROM [MAS_Customer_Image]
					WHERE CustId = a.CustId
						AND Imagetype = 2
					) AS FaceRecogUrl2
				, (
					SELECT TOP 1 [imageUrl]
					FROM [MAS_Customer_Image]
					WHERE CustId = a.CustId
						AND Imagetype = 3
					) AS FaceRecogUrl3
				, (
					SELECT TOP 1 [imageUrl]
					FROM [MAS_Customer_Image]
					WHERE CustId = a.CustId
						AND Imagetype = 4
					) AS FaceRecogUrl4
				, (
					SELECT TOP 1 [imageUrl]
					FROM [MAS_Customer_Image]
					WHERE CustId = a.CustId
						AND Imagetype = 5
					) AS FaceRecogUrl5
				, b.RelationId
				, ISNULL(d.RelationName, N'Khác') AS RelationName
				, b.memberUserId userId
				, b.isNotification
				, CASE 
					WHEN b.memberUserId IS NOT NULL
						OR EXISTS (
							SELECT userid
							FROM UserInfo mu
							WHERE mu.CustId = a.CustId
								AND mu.userType = 2
							)
						THEN 1
					ELSE 0
					END AS isApp
				, a.CountryCd
				, g.CountryName
				, b.approveDt
				, b.RegDt
				, hist.ApproveDtEnd AS HistoryApproveDtEnd
				, hist.Note AS HistoryNote
				, (
					SELECT TOP 1 c.FullName
					FROM MAS_Apartments ma
					JOIN UserInfo mu ON ma.UserLogin = mu.loginName
					JOIN MAS_Customers c ON c.CustId = mu.CustId
					WHERE ma.ApartmentId = b.ApartmentId
				) AS HouseholdHead
			FROM [MAS_Customers] a
			JOIN MAS_Apartment_Member b
				ON a.CustId = b.CustId
			JOIN MAS_Apartments ap
				ON b.ApartmentId = ap.ApartmentId
			LEFT JOIN MAS_Customer_Relation d
				ON b.RelationId = d.RelationId
			LEFT JOIN [COR_Countries] g
				ON a.CountryCd = g.CountryCd
			OUTER APPLY (
				SELECT TOP 1 h.Note
					, h.ApproveDtEnd
				FROM MAS_Apartment_Member_H h WITH (NOLOCK)
				WHERE h.ApartmentId = b.ApartmentId
					AND h.CustId = a.CustId
				ORDER BY h.PerformedAt DESC, h.Oid DESC
			) hist
			WHERE b.ApartmentId = @ActualApartmentId
				AND a.CustId = @CustId
				AND (@tenantOid IS NULL OR ap.tenant_oid = @tenantOid)

			UNION ALL

			SELECT r.CustId
				, a.[FullName]
				, a.[Sex] AS [IsSex]
				, CASE 
					WHEN a.[Sex] = 1
						THEN N'Nam'
					ELSE N'Nữ'
					END AS SexName
				, CONVERT(NVARCHAR(10), a.birthday, 103) AS birthday
				, a.[Phone]
				, a.[Email]
				, 0 AS [IsHost]
				, p.[ApartmentId]
				, a.[AvatarUrl]
				, CASE 
					WHEN a.res_Cntry = 'VN' OR a.res_Cntry IS NULL THEN 0 
					ELSE 1 
				END AS IsForeign
				, 0 AS [Status]
				, N'Chờ phê duyệt' AS StatusName
				, NULL AS AuthDate
				, (
					SELECT TOP 1 [imageUrl]
					FROM [MAS_Customer_Image]
					WHERE CustId = a.CustId
						AND Imagetype = 1
					) AS FaceRecogUrl1
				, (
					SELECT TOP 1 [imageUrl]
					FROM [MAS_Customer_Image]
					WHERE CustId = a.CustId
						AND Imagetype = 2
					) AS FaceRecogUrl2
				, (
					SELECT TOP 1 [imageUrl]
					FROM [MAS_Customer_Image]
					WHERE CustId = a.CustId
						AND Imagetype = 3
					) AS FaceRecogUrl3
				, (
					SELECT TOP 1 [imageUrl]
					FROM [MAS_Customer_Image]
					WHERE CustId = a.CustId
						AND Imagetype = 4
					) AS FaceRecogUrl4
				, (
					SELECT TOP 1 [imageUrl]
					FROM [MAS_Customer_Image]
					WHERE CustId = a.CustId
						AND Imagetype = 5
					) AS FaceRecogUrl5
				, b.RelationId
				, ISNULL(d.RelationName, N'Khác') AS RelationName
				, b.userId
				, 0 AS isNotification
				, CASE 
					WHEN b.userid IS NOT NULL
						THEN 1
					ELSE 0
					END AS isApp
				, 'VN' AS countryCd
				, N'Việt Nam' AS CountryName
				, NULL AS approveDt
				, NULL AS RegDt
			
				, hist.ApproveDtEnd AS HistoryApproveDtEnd
				, hist.Note AS HistoryNote
				, (
					SELECT TOP 1 c.FullName
					FROM MAS_Apartments ma
					JOIN UserInfo mu ON ma.UserLogin = mu.loginName
					JOIN MAS_Customers c ON c.CustId = mu.CustId
					WHERE ma.ApartmentId = p.ApartmentId
				) AS HouseholdHead
			FROM UserInfo a
			JOIN MAS_Apartment_Reg b
				ON a.UserId = b.userId
			JOIN MAS_Apartments p
				ON b.RoomCode = p.RoomCode
			JOIN UserInfo r
				ON b.UserId = r.UserId
			LEFT JOIN MAS_Customer_Relation d
				ON b.RelationId = d.RelationId
			OUTER APPLY (
				SELECT TOP 1 h.Note
					, h.ApproveDtEnd
				FROM MAS_Apartment_Member_H h WITH (NOLOCK)
				WHERE h.ApartmentId = p.ApartmentId
					AND h.CustId = a.CustId
				ORDER BY h.PerformedAt DESC, h.Oid DESC
			) hist
			WHERE p.ApartmentId = @ActualApartmentId
				--AND (@tenantOid IS NULL OR p.tenant_oid = @tenantOid)
				AND a.CustId = @CustId
				AND b.reg_st = 0
				AND NOT EXISTS (
					SELECT *
					FROM MAS_Apartment_Member am
					JOIN MAS_Customers cc
						ON am.CustId = cc.CustId
					WHERE am.ApartmentId = p.ApartmentId
						AND am.CustId = a.custId
						AND am.memberUserId = b.userId
					)
		) b
			ON b.ApartmentId = @ActualApartmentId
		ORDER BY ordinal;
    END
    ELSE
    BEGIN
        SELECT s.id
			, s.[table_name]
            , [field_name]
            , [view_type]
            , [data_type]
            , [ordinal]
            , [columnLabel]
            , [group_cd]
            , CASE 
					WHEN s.field_name = 'ApartmentId' 
						THEN CONVERT(NVARCHAR(50), @ActualApartmentId)
					WHEN s.field_name = 'apartOid'
						THEN LOWER(CONVERT(NVARCHAR(100), @ActualOid))
					WHEN s.field_name = 'householdHead' 
						THEN (
							SELECT TOP 1 CONVERT(NVARCHAR(500), c.FullName)
							FROM MAS_Apartments ma
							JOIN UserInfo mu ON ma.UserLogin = mu.loginName
							JOIN MAS_Customers c ON c.CustId = mu.CustId
							WHERE ma.ApartmentId = @ActualApartmentId
								--AND (@tenantOid IS NULL OR ma.tenant_oid = @tenantOid)
						)
					WHEN s.field_name = 'EffectiveDate' 
						THEN CONVERT(NVARCHAR(10), getdate(), 103)
			ELSE s.columnDefault
			END AS columnValue
            , [columnClass]
            , [columnType]
            , [columnObject]
            , [isSpecial]
            , [isRequire]
            , [isDisable]
            , [isVisiable]
            , s.[IsEmpty]
			, s.columnDisplay
            , ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
        	,s.[isIgnore]
        FROM dbo.fn_config_form_gets('MAS_Apartment_Family_Member', @AcceptLanguage) s
        ORDER BY ordinal;
    END
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_family_member_field ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Apartment_Family_Member'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;