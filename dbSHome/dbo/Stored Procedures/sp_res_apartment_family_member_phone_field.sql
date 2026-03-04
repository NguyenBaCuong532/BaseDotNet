
CREATE   procedure [dbo].[sp_res_apartment_family_member_phone_field] 
    @UserId uniqueidentifier = NULL,
	@filter	nvarchar(50) = NULL,
	@ApartmentId	nvarchar(50) = NULL,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY

    DECLARE @group_key VARCHAR(50) = 'common_group'
    DECLARE @table_key VARCHAR(50) = 'MAS_Apartment_Family_Member'

    SELECT tableKey = @table_key
        , groupKey = @group_key;

    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
    ORDER BY intOrder;

    -- Lấy ra từng ô trong group
    IF EXISTS (select top 1 a.CustId 
		FROM MAS_Customers a 
		  WHERE Phone like @filter 
			--or (Pass_No like @filter and Pass_No is not null)
		  order by sysDate )
    BEGIN
        SELECT [table_name]
            , [field_name]
            , [view_type]
            , [data_type]
            , [ordinal]
            , [columnLabel]
            , [group_cd]
            , ISNULL(CASE [field_name]
                    WHEN 'ApartmentId'
                        --THEN LOWER(CONVERT(NVARCHAR(500), b.[ApartmentId]))
						THEN @ApartmentId
                    WHEN 'avatarUrl'
                        THEN b.AvatarUrl
                    WHEN 'birthday'
                        THEN convert(NVARCHAR(10), b.birthday, 103)
                    WHEN 'cifNo'
                        THEN b.Cif_No
                    WHEN 'countryCd'
                        THEN b.CountryCd
                    WHEN 'custId'
                        THEN b.CustId
                    WHEN 'email'
                        THEN b.Email
                    WHEN 'fullName'
                        THEN b.FullName
                   WHEN 'isNotification'
						THEN CASE WHEN ISNULL(m.isNotification, 0) = 1 THEN N'1' ELSE N'0' END  
                   WHEN 'isForeign'
						THEN CASE WHEN ISNULL(b.IsForeign, 0) = 1 THEN N'1' ELSE N'0' END
                        --THEN 'true'
                    WHEN 'isSex'
                        THEN CONVERT(NVARCHAR(500), b.IsSex)
						--THEN (CAST(CASE WHEN b.isSex = 1 THEN 'true' ELSE 'false' END  AS VARCHAR(50)))
                    WHEN 'phone'
                        THEN b.Phone
                   WHEN 'relationId'
						THEN CONVERT(NVARCHAR(500), m.RelationId)
					WHEN 'effectiveDate'
						THEN CONVERT(NVARCHAR(10), ISNULL(m.approveDt, m.RegDt), 103)
					WHEN 'effectiveDateEnd'
						THEN CONVERT(NVARCHAR(10), hist.ApproveDtEnd, 103)
					WHEN 'householdHead'
						THEN (

							SELECT TOP 1 c.FullName

							FROM MAS_Apartments ma

							JOIN UserInfo mu ON ma.UserLogin = mu.loginName

							JOIN MAS_Customers c ON c.CustId = mu.CustId

							WHERE @ApartmentId IS NOT NULL AND ISNUMERIC(@ApartmentId) = 1 AND ma.ApartmentId = CAST(@ApartmentId AS INT)

						)

					WHEN 'note'
						THEN hist.Note

                    END, [columnDefault]) AS columnValue
            , [columnClass]
            , [columnType]
            , [columnObject]
            , [isSpecial]
            , [isRequire]
            , [isDisable]
            , [isVisiable]
            , NULL AS [IsEmpty]
            , ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
        --,case when @action = 'edit' then 1 else 0 end as isChange
        FROM dbo.fn_config_form_gets('MAS_Apartment_Family_Member', @acceptLanguage) s
         JOIN (SELECT TOP(1) * FROM dbo.MAS_Customers c WHERE Phone like @filter) b ON 1=1
         LEFT JOIN MAS_Apartment_Member m ON b.CustId = m.CustId 
            AND (@ApartmentId IS NOT NULL AND ISNUMERIC(@ApartmentId) = 1 AND m.ApartmentId = CAST(@ApartmentId AS INT))
         OUTER APPLY (
             SELECT TOP 1 h.Note, h.ApproveDtEnd
             FROM MAS_Apartment_HostChange_History h WITH (NOLOCK)
             WHERE h.ApartmentId = CASE WHEN @ApartmentId IS NOT NULL AND ISNUMERIC(@ApartmentId) = 1 THEN CAST(@ApartmentId AS INT) ELSE m.ApartmentId END
               AND h.CustId = b.CustId
             ORDER BY h.ApproveDt DESC, h.PerformedAt DESC, h.HistoryId DESC
         ) hist
    ORDER BY ordinal;
    END
    ELSE
    BEGIN
        SELECT [table_name]
            , [field_name]
            , [view_type]
            , [data_type]
            , [ordinal]
            , [columnLabel]
            , [group_cd]
            , CASE 
			WHEN s.field_name = 'birthday'
			THEN convert(NVARCHAR(10), GETDATE(), 103)
			WHEN s.field_name = 'isForeign'
			THEN 'false'
			WHEN s.field_name = 'relationId'
			THEN '-1'
			WHEN s.field_name = 'isNotification'
			THEN '0'
					WHEN s.field_name = 'ApartmentId' 
						THEN CONVERT(NVARCHAR(50), @ApartmentId)
					WHEN s.field_name = 'householdHead' 
						THEN (
							SELECT TOP 1 CONVERT(NVARCHAR(500), c.FullName)
							FROM MAS_Apartments ma
							JOIN UserInfo mu ON ma.UserLogin = mu.loginName
							JOIN MAS_Customers c ON c.CustId = mu.CustId
							WHERE ma.ApartmentId = @ApartmentId
						)
					WHEN s.field_name = 'effectiveDate'
						THEN CONVERT(NVARCHAR(50),GETDATE(),103)
			ELSE s.columnDefault
			END AS columnValue
            , [columnClass]
            , [columnType]
            , [columnObject]
            , [isSpecial]
            , [isRequire]
            , [isDisable]
            , [isVisiable]
            , NULL AS [IsEmpty]
            , ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
        FROM dbo.fn_config_form_gets('MAS_Apartment_Family_Member', @acceptLanguage) s
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
    SET @ErrorMsg = 'sp_res_family_member_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Apartment_Family_Member'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;