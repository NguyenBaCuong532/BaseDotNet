

-- =============================================
-- Author: duongpx
-- Create date: 2025-09-18 09:14:34
-- Description: Lấy thông tin fields cho form MAS_Apartment_Member
-- Output: 5 result sets (Info, Groups, Data, HouseholdHead, ApartmentInfo)
-- =============================================
CREATE   procedure [dbo].[sp_app_apartment_member_field]
    @userId uniqueidentifier = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN',
    @oid UNIQUEIDENTIFIER = NULL,       -- Oid bản ghi member (MAS_Apartment_Member)
    @apartId INT = NULL,                -- Backward compatible (ApartmentId)
    @apartOid UNIQUEIDENTIFIER = NULL   -- Ưu tiên (apartment oid)
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @tableKey NVARCHAR(100) = N'MAS_Apartment_Member';
    DECLARE @groupKey NVARCHAR(200) = N'common_group_app';

    DECLARE @ApartmentId INT;
    IF @apartId IS NOT NULL
        SET @ApartmentId = @apartId;
    ELSE IF @apartOid IS NOT NULL
        SELECT @ApartmentId = ApartmentId FROM MAS_Apartments WHERE oid = @apartOid;
    ELSE
        SET @ApartmentId = ([dbo].[fn_get_apartment_main](dbo.fn_get_customerid(@UserId)));

    -- =========================
    -- RESULT 3: DATA
    -- =========================
    DROP TABLE IF EXISTS #tempIn;
    CREATE TABLE #tempIn (
        ApartmentId INT,
        main_st INT,
        Oid UNIQUEIDENTIFIER,
        FullName NVARCHAR(200),
        member_st INT,
        householdHead NVARCHAR(200),
        RelationId INT NULL,
        Birthday DATETIME NULL,
        sex BIT NULL,
        Phone NVARCHAR(50),
        Email NVARCHAR(100),
        AvatarUrl NVARCHAR(500),
        Auth_St INT,
        value1 NVARCHAR(100),
        [Status] INT,
        [StatusName] NVARCHAR(100)
    );

    IF @oid IS NOT NULL
    BEGIN
        INSERT INTO #tempIn (
            ApartmentId, main_st, Oid, FullName, member_st, householdHead,
            RelationId, Birthday, sex, Phone, Email, AvatarUrl, Auth_St,
            value1, [Status], [StatusName]
        )
        SELECT 
              b.ApartmentId
            , b.main_st 
            , b.Oid
            , c.FullName
            , b.member_st
            , u.FullName AS householdHead
            , cr.RelationId
            , c.Birthday
            , u.sex
            , c.Phone
            , c.Email
            , c.AvatarUrl
            , c.Auth_St
            , sy.value1
            , b.member_st
            , sy.key_1
        FROM MAS_Apartment_Member b
        LEFT JOIN MAS_Apartments ap ON b.ApartmentId = ap.ApartmentId 
        LEFT JOIN UserInfo u ON ap.UserLogin = u.loginName
        LEFT JOIN MAS_Customers c ON c.CustId = b.CustId
        LEFT JOIN MAS_Customer_Relation cr ON cr.RelationId = b.RelationId
        LEFT JOIN sys_config_data sy ON sy.key_1 = 'member_st' AND sy.value2 = ISNULL(b.member_st, 1)
        WHERE b.Oid = @oid;
    END
    ELSE
    BEGIN
        -- Record mới theo căn hộ đã xác định
        SET @oid = NEWID();
        INSERT INTO #tempIn (
            ApartmentId, main_st, Oid, FullName, member_st, householdHead,
            RelationId, Birthday, sex, Phone, Email, AvatarUrl, Auth_St,
            value1, [Status], [StatusName]
        )
        SELECT 
              @ApartmentId
            , 0
            , @oid
            , N''
            , 1
            , N''
            , NULL
            , NULL
            , NULL
            , N''
            , N''
            , N''
            , 0
            , N''
            , 1
            , N'';
    END

    -- =========================
    -- RESULT 1: INFO
    -- =========================
    IF @oid IS NULL
    BEGIN
        SELECT NEWID() AS Oid, @tableKey AS tableKey, @groupKey AS groupKey, 1 AS [statusId], N'Chưa xác định' AS [statusName];
    END
    ELSE IF EXISTS (SELECT 1 FROM MAS_Apartment_Member WHERE Oid = @oid)
    BEGIN
        SELECT 
              b.Oid
            , @tableKey AS tableKey
            , @groupKey AS groupKey
            , ISNULL(b.member_st, 1) AS [statusId]
            , ISNULL(sy.value1, N'Chưa xác định') AS [statusName]
        FROM MAS_Apartment_Member b
        LEFT JOIN MAS_Customers c ON c.CustId = b.CustId
        LEFT JOIN sys_config_data sy ON sy.key_1 = 'member_st' AND sy.value2 = ISNULL(b.member_st, 1)
        WHERE b.Oid = @oid;
    END
    ELSE
    BEGIN
        SELECT @oid AS Oid, @tableKey AS tableKey, @groupKey AS groupKey, 1 AS [statusId], N'Chưa xác định' AS [statusName];
    END

    -- =========================
    -- RESULT 2: GROUPS
    -- =========================
    SELECT * FROM dbo.fn_get_field_group_lang(@groupKey, @acceptLanguage) ORDER BY intOrder;

    -- =========================
    -- RESULT 3: DATA (map columnValue)
    -- =========================
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
            CASE a.[data_type]
                WHEN 'nvarchar' THEN CONVERT(NVARCHAR(451),
                    CASE a.[field_name]
                        WHEN 'fullName'      THEN b.FullName
                        WHEN 'householdHead' THEN b.householdHead
                        WHEN 'phone'         THEN b.Phone
                        WHEN 'email'         THEN b.Email
                        WHEN 'avatarUrl'     THEN b.AvatarUrl
                    END)
                WHEN 'datetime' THEN
                    CASE a.[field_name]
                        WHEN 'Birthday' THEN FORMAT(b.Birthday, 'dd/MM/yyyy')
                    END
                WHEN 'bit' THEN CONVERT(NVARCHAR(150),
                    CASE a.[field_name]
                        WHEN 'sex' THEN CASE WHEN b.[sex] = 1 THEN 'true' WHEN b.[sex] = 0 THEN 'false' ELSE '' END
                        WHEN 'isCheck' THEN CASE WHEN b.Auth_St = 1 THEN 'true' WHEN b.Auth_St = 0 THEN 'false' ELSE '' END
                    END)
                WHEN 'int' THEN CONVERT(NVARCHAR(50),
                    CASE a.[field_name]
                        WHEN 'relationName' THEN b.RelationId
                        WHEN 'ApartmentId'  THEN b.[ApartmentId]
                    END)
            END
        , a.columnDefault)
        , a.columnClass
        , a.columnType
        , CASE WHEN a.columnType = 'file'
               THEN ISNULL(a.columnObject, '') + ISNULL(CAST(b.AvatarUrl AS NVARCHAR(50)), '')
               ELSE a.columnObject
          END AS columnObject
        , a.isSpecial
        , a.isRequire
        , a.isDisable
        , a.IsVisiable
        , a.isEmpty
        , columnTooltip = ISNULL(a.columnTooltip, a.columnLabel)
        , a.columnDisplay
        , a.isIgnore
    FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
    CROSS JOIN #tempIn b
    --WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
    ORDER BY a.ordinal;

    -- =========================
    -- RESULT 4: HOUSEHOLD HEAD (KHÔNG dùng @oid)
    -- =========================
    IF OBJECT_ID('tempdb..#household') IS NOT NULL DROP TABLE #household;
    CREATE TABLE #household (
        Oid UNIQUEIDENTIFIER NULL,
        fullName NVARCHAR(200) NULL,
        relationName NVARCHAR(50) NULL,
        isMain BIT NULL,
        avatarUrl NVARCHAR(500) NULL
    );

    -- Ưu tiên thành viên RelationId = 0; nếu không có thì theo chủ căn ap.UserLogin
    INSERT INTO #household (Oid, fullName, relationName, isMain, avatarUrl)
    SELECT TOP 1 
          a.Oid
        , c.FullName
        , N'Chủ hộ'
        , ap.isMain
        , ISNULL(u.AvatarUrl, u.AvatarUrl)
    FROM MAS_Apartment_Member a
    JOIN MAS_Customers  c  ON c.CustId       = a.CustId
    JOIN MAS_Apartments ap ON ap.ApartmentId = a.ApartmentId
    JOIN UserInfo u ON u.loginName = ap.UserLogin
    WHERE a.ApartmentId = @ApartmentId
      AND a.RelationId = 0
    ORDER BY a.Oid;

    IF NOT EXISTS (SELECT 1 FROM #household)
    BEGIN
        INSERT INTO #household (Oid, fullName, relationName, isMain, avatarUrl)
        SELECT TOP 1 
              NULL
            , u.FullName
            , N'Chủ hộ'
            , CAST(0 AS BIT)
            , u.AvatarUrl
        FROM MAS_Apartments ap
        JOIN UserInfo u ON u.loginName = ap.UserLogin
        WHERE ap.ApartmentId = @ApartmentId;
    END

    SELECT TOP 1 Oid, fullName, relationName, isMain, avatarUrl
    FROM #household;

    -- =========================
    -- RESULT 5: APARTMENT INFO
    -- =========================
    SELECT 
          @ApartmentId AS apartmentId
        , p.ProjectName AS projectName
        , bu.BuildingName AS buildingName
        , ISNULL(ef.FloorNumber, ap.Floor) AS floor
        , ap.RoomCode AS apartment
        , p.projectCd AS projectCd
        , bu.BuildingCd AS buildingCd
        , N'Căn ' + ap.RoomCode + N' • Tầng ' + CAST(ISNULL(ef.FloorNumber, ap.Floor) AS NVARCHAR(50)) + N' • ' + bu.BuildingName AS roomCode
        , p.address AS address
    FROM MAS_Apartments ap
    LEFT JOIN MAS_Projects  p  ON p.oid = ap.tenant_oid
    LEFT JOIN MAS_Buildings bu ON ap.buildingOid = bu.oid
    LEFT JOIN MAS_Elevator_Floor ef ON ap.floorOid = ef.oid
    WHERE (@ApartmentId IS NOT NULL AND ap.ApartmentId = @ApartmentId) OR (@apartOid IS NOT NULL AND ap.oid = @apartOid);

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = N'sp_app_apartment_member_fields ' + ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Apartment_Member', N'GET', @SessionID, @AddlInfo;
END CATCH