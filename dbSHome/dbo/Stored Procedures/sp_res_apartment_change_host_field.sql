
CREATE PROCEDURE [dbo].[sp_res_apartment_change_host_field]
    @CustId NVARCHAR(450),
    @ApartmentId INT,
	@acceptLanguage nvarchar(50) = N'vi-VN',
	 @UserID NVARCHAR(450),
    @isForeign INT = 0
     

AS
BEGIN TRY
    if OBJECT_ID('tempdb..#ApartmentInfo') is not null
			drop table #ApartmentInfo

    select a.* 
    into #ApartmentInfo
    from (
        SELECT a.CustId 
              ,a.[FullName]
              ,b.[ApartmentId]
              ,a.Phone
              ,a.Email
              ,a.Birthday
              ,a.IsSex
              ,a.IsForeign
              ,a.CountryCd
              ,g.CountryName
              ,b.isNotification
              ,b.RelationId
              ,ISNULL(d.RelationName, N'Khác') AS RelationName
              ,b.approveDt
              ,b.RegDt
        FROM [MAS_Customers] a 
            join MAS_Apartment_Member b on a.CustId = b.CustId 
            left join MAS_Customer_Relation d on b.RelationId = d.RelationId
            left join [dbo].[COR_Countries] g on a.CountryCd = g.CountryCd 

        WHERE b.ApartmentId = @ApartmentId AND a.CustId = @CustId
    UNION ALL
        SELECT  r.CustId 
              ,a.[FullName]
              ,p.[ApartmentId]
              ,r.Phone
              ,NULL AS Email
              ,NULL AS Birthday
              ,NULL AS IsSex
              ,NULL AS IsForeign
              ,NULL AS CountryCd
              ,NULL AS CountryName
              ,CAST(NULL AS bit) AS isNotification
              ,b.RelationId
              ,ISNULL(d.RelationName, N'Khác') AS RelationName
              ,NULL AS approveDt
              ,NULL AS RegDt
        FROM UserInfo a 
            join MAS_Apartment_Reg b on a.UserId = b.userId 
            join MAS_Apartments p on b.RoomCode = p.RoomCode 
            join UserInfo r on b.UserId = r.UserId 
            left join MAS_Customer_Relation d on b.RelationId = d.RelationId
        WHERE p.ApartmentId = @ApartmentId AND a.CustId = @CustId 
          and b.reg_st = 0
          and not exists(select 1 
                           from MAS_Apartment_Member am join MAS_Customers cc on am.CustId = cc.CustId 
                           where am.ApartmentId = p.ApartmentId and am.CustId = a.custId and am.memberUserId = b.userId)
    ) a


    --
    IF @ApartmentId IS NOT NULL
       AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.MAS_Apartments
        WHERE ApartmentId = @ApartmentId
    )
        SET @ApartmentId = NULL;
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'MAS_Apartment_Change_Host';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        ApartmentId = @ApartmentId,
        CustId = @CustId,
        tableKey = @tableKey, 
        groupKey = @groupKey;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
    ORDER BY intOrder;
    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu field với columnValue động
    -- =============================================
    
    -- Sử dụng temp table #ApartmentInfo đã tạo ở trên
    SELECT
          a.id
        , a.table_name
        , a.field_name
        , a.view_type
        , a.data_type
        , a.ordinal
        , a.columnLabel
        , a.group_cd
        , columnValue = ISNULL(
            CASE a.field_name
                WHEN 'ApartmentId' THEN LOWER(CONVERT(NVARCHAR(500), b.[ApartmentId]))
                WHEN 'contractDate' THEN CONVERT(NVARCHAR(10), ISNULL(b.approveDt, b.RegDt), 103)
                WHEN 'contractRemark' THEN ''
                WHEN 'custId' THEN b.CustId
                WHEN 'fullnameChangeHost' THEN b.[FullName]
                WHEN 'userLogin' THEN b.Phone
                WHEN 'fullName' THEN b.[FullName]
                WHEN 'phone' THEN b.Phone
                WHEN 'birthday' THEN CONVERT(NVARCHAR(10), b.Birthday, 103)
                WHEN 'email' THEN b.Email
                WHEN 'isNotification' THEN CASE WHEN ISNULL(b.isNotification, 0) = 1 THEN N'1' ELSE N'0' END
                WHEN 'isSex' THEN CASE WHEN ISNULL(b.IsSex, 0) = 1 THEN N'1' ELSE N'0' END
                WHEN 'relationId' THEN CONVERT(NVARCHAR(50), b.RelationId)
                WHEN 'relationName' THEN b.RelationName
                WHEN 'isForeign' THEN CASE WHEN ISNULL(b.IsForeign, 0) = 1 THEN N'1' ELSE N'0' END
                WHEN 'countryCd' THEN b.CountryCd
                WHEN 'countryName' THEN b.CountryName
            END,
            a.columnDefault
        )
        , a.columnClass
        , a.columnType
        , a.columnObject
        , a.isSpecial
        , a.isRequire
        , a.isDisable
        , a.IsVisiable
        , a.isEmpty
        , columnTooltip = ISNULL(a.columnTooltip, a.columnLabel)
        , a.columnDisplay
        , a.isIgnore
    FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
    CROSS JOIN #ApartmentInfo b
    WHERE b.ApartmentId = @ApartmentId
      AND a.table_name = @tableKey
      AND (a.IsVisiable = 1 OR a.isRequire = 1)
    ORDER BY a.ordinal;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_change_host_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'Apartment_Change_Host',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;