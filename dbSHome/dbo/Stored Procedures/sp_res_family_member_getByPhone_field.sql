
CREATE PROCEDURE [dbo].[sp_res_family_member_getByPhone_field] 
	@filter	nvarchar(50) = NULL,
	@ApartmentId	nvarchar(50) = NULL,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
	SET NOCOUNT ON;

	-- Khai báo biến
	DECLARE @tableKey NVARCHAR(100) = N'MAS_Apartment_Family_Member';
	DECLARE @groupKey NVARCHAR(200) = N'common_group';

	-- =============================================
	-- RESULT SET 1: INFO - Thông tin cơ bản
	-- =============================================
	SELECT tableKey = @tableKey
		, groupKey = @groupKey;

	-- =============================================
	-- RESULT SET 2: GROUPS - Nhóm field
	-- =============================================
	SELECT *
	FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
	ORDER BY intOrder;

	-- =============================================
	-- RESULT SET 3: DATA - Dữ liệu field với columnValue động
	-- =============================================
	-- Lấy ra từng ô trong group
	IF EXISTS (SELECT TOP 1 a.CustId 
		FROM MAS_Customers a 
		WHERE Phone LIKE @filter 
		ORDER BY sysDate)
	BEGIN
		SELECT s.id
			, s.[table_name]
			, s.[field_name]
			, s.[view_type]
			, s.[data_type]
			, s.[ordinal]
			, s.[columnLabel]
			, s.[group_cd]
			, columnValue = ISNULL(CASE s.[field_name]
					WHEN 'ApartmentId'
						THEN @ApartmentId
					WHEN 'avatarUrl'
						THEN b.AvatarUrl
					WHEN 'birthday'
						THEN CONVERT(NVARCHAR(10), b.birthday, 103)
					WHEN 'cifNo'
						THEN b.Cif_No
					WHEN 'countryCd'
						THEN b.CountryCd
					WHEN 'custId'
						THEN b.CustId
					WHEN 'email'
						THEN b.Email
					WHEN 'fullName'
						THEN b.[FullName]
					WHEN 'isForeign'
						THEN CONVERT(NVARCHAR(500), b.IsForeign)
					WHEN 'isNotification'
						THEN '1'
					WHEN 'isSex'
						THEN CONVERT(NVARCHAR(500), b.IsSex)
					WHEN 'phone'
						THEN b.Phone
					WHEN 'relationId'
						THEN '-1'
				END, s.[columnDefault])
			, s.[columnClass]
			, s.[columnType]
			, s.[columnObject]
			, s.[isSpecial]
			, s.[isRequire]
			, s.[isDisable]
			, s.[IsVisiable]
			, s.[isEmpty]
			, columnTooltip = ISNULL(s.columnTooltip, s.[columnLabel])
			, s.[columnDisplay]
			, s.[isIgnore]
		FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) s
		CROSS JOIN (SELECT TOP(1) * FROM dbo.MAS_Customers c WHERE Phone LIKE @filter) b
		WHERE (s.IsVisiable = 1 OR s.isRequire = 1)
		ORDER BY s.ordinal;
	END
	ELSE
	BEGIN
		SELECT s.id
			, s.[table_name]
			, s.[field_name]
			, s.[view_type]
			, s.[data_type]
			, s.[ordinal]
			, s.[columnLabel]
			, s.[group_cd]
			, columnValue = CASE 
				WHEN s.field_name = 'birthday'
					THEN CONVERT(NVARCHAR(10), GETDATE(), 103)
				WHEN s.field_name = 'isForeign'
					THEN 'false'
				WHEN s.field_name = 'relationId'
					THEN '-1'
				WHEN s.field_name = 'isNotification'
					THEN '0'
				ELSE
					s.columnDefault
			END
			, s.[columnClass]
			, s.[columnType]
			, s.[columnObject]
			, s.[isSpecial]
			, s.[isRequire]
			, s.[isDisable]
			, s.[IsVisiable]
			, s.[isEmpty]
			, columnTooltip = ISNULL(s.columnTooltip, s.[columnLabel])
			, s.[columnDisplay]
			, s.[isIgnore]
		FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) s
		WHERE (s.IsVisiable = 1 OR s.isRequire = 1)
		ORDER BY s.ordinal;
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