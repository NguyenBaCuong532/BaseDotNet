
-- =============================================
-- Author: duongpx
-- Create date: 2025-09-18 09:14:34
-- Description: Grid phân trang cho bảng MAS_Apartment_Member
-- Updated: Added apartment information to result set; Added household avatarUrl
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_apartment_member_page]
      @userId         UNIQUEIDENTIFIER    = NULL
    , @filter         NVARCHAR(30)     = NULL
    , @Offset         INT              = 0
    , @PageSize       INT              = 10
    , @gridWidth      INT              = 0
    , @acceptLanguage NVARCHAR(50)     = N'vi-VN'
    , @ApartmentId    INT              = NULL   -- Backward compatible
    , @apartOid       UNIQUEIDENTIFIER = NULL   -- Ưu tiên (GUID)
    , @CustId         UNIQUEIDENTIFIER = NULL
    , @action         NVARCHAR(20)     = N'list'      -- 'list' | 'reg'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @GridKey NVARCHAR(100) = N'view_app_apartment_member_page';
    SET @Offset   = ISNULL(@Offset, 0);
    SET @PageSize = CASE WHEN ISNULL(@PageSize, 0) > 0 THEN @PageSize ELSE 10 END;
    SET @filter   = ISNULL(@filter,  N'');
    SET @action   = LOWER(ISNULL(@action, N'list'));

    DECLARE @isList BIT = CASE WHEN @action = N'list' THEN 1 ELSE 0 END;

    IF @apartOid IS NOT NULL AND @ApartmentId IS NULL
        SELECT @ApartmentId = ApartmentId FROM MAS_Apartments WHERE oid = @apartOid;
    IF @ApartmentId IS NULL
    BEGIN
        SET @ApartmentId = ([dbo].[fn_get_apartment_main](dbo.fn_get_customerid(@userId)));
        SET @CustId = (dbo.fn_get_customerid(@userId));
    END

    -- Drop temp tables if exist
    IF OBJECT_ID('tempdb..#all') IS NOT NULL DROP TABLE #all;
    IF OBJECT_ID('tempdb..#household') IS NOT NULL DROP TABLE #household;

    -- Tạo temp table #all với cấu trúc đầy đủ
    CREATE TABLE #all (
        Oid UNIQUEIDENTIFIER,
        ApartmentId INT,
        FullName NVARCHAR(200),
        RoomCode NVARCHAR(50),
        RelationName NVARCHAR(50),
        member_st INT,
        statusName NVARCHAR(100),
        receive_dt DATETIME
    );

    -- Populate #all based on condition
    IF EXISTS (SELECT 1 FROM MAS_Apartment_Member am WHERE (am.apartOid = @apartOid OR (am.apartOid IS NULL AND am.ApartmentId = @ApartmentId))
      AND am.CustId      = @CustId
      AND am.RelationId  = 0    )     -- chủ hộ
    BEGIN
        INSERT INTO #all (Oid, ApartmentId, FullName, RoomCode, RelationName, member_st, statusName, receive_dt)
        SELECT
            a.Oid,
            a.ApartmentId,
            c.FullName,
            ap.RoomCode,
            cr.RelationName,
            sy.value2 AS member_st,
            sy.value1 AS statusName,
            a.RegDt AS receive_dt
        FROM MAS_Apartment_Member a
        JOIN MAS_Apartments ap ON (ap.oid = a.apartOid OR (a.apartOid IS NULL AND ap.ApartmentId = a.ApartmentId))
        JOIN MAS_Customers c ON c.CustId = a.CustId
        LEFT JOIN sys_config_data sy ON sy.key_1 = 'member_st' AND sy.value2 = ISNULL(a.member_st, 1)
        LEFT JOIN MAS_Customer_Relation cr ON cr.RelationId = a.RelationId
        WHERE (a.apartOid = @apartOid OR (a.apartOid IS NULL AND a.ApartmentId = @ApartmentId))
            AND (@filter = N'' OR c.FullName LIKE N'%' + @filter + N'%');
    END
    ELSE 
    BEGIN
    --ko pải chủ hộ
        INSERT INTO #all (Oid, ApartmentId, FullName, RoomCode, RelationName, member_st, statusName, receive_dt)
        SELECT
            a.Oid,
            a.ApartmentId,
            c.FullName,
            ap.RoomCode,
            cr.RelationName,
            sy.value2 AS member_st,
            sy.value1 AS statusName,
            a.RegDt AS receive_dt
        FROM MAS_Apartment_Member a
        JOIN MAS_Apartments ap ON (ap.oid = a.apartOid OR (a.apartOid IS NULL AND ap.ApartmentId = a.ApartmentId))
        JOIN MAS_Customers c ON c.CustId = a.CustId
        LEFT JOIN sys_config_data sy ON sy.key_1 = 'member_st' AND sy.value2 = ISNULL(a.member_st, 1)
        LEFT JOIN MAS_Customer_Relation cr ON cr.RelationId = a.RelationId
        WHERE (a.apartOid = @apartOid OR (a.apartOid IS NULL AND a.ApartmentId = @ApartmentId))
        AND (a.memberUserId = @userId)
            AND (@filter = N'' OR c.FullName LIKE N'%' + @filter + N'%');
    END

    -- Tạo bảng tạm hộ gia đình có đủ cột (thêm avatarUrl)
    CREATE TABLE #household (
        Oid UNIQUEIDENTIFIER NULL,
        fullName NVARCHAR(200) NULL,
        relationName NVARCHAR(50) NULL,
        isMain BIT NULL,
        avatarUrl NVARCHAR(500) NULL
    );

    -- Ưu tiên: thành viên có RelationName = 'Chủ hộ' và lấy avatar theo chủ căn
    INSERT INTO #household (Oid, fullName, relationName, isMain, avatarUrl)
    SELECT TOP 1 
          a.Oid
        , c.FullName
        , N'Chủ hộ'
        , ap.isMain
        , ISNULL(u.AvatarUrl, u.AvatarUrl)
    FROM MAS_Apartment_Member a
    JOIN MAS_Customers  c  ON c.CustId       = a.CustId
    JOIN MAS_Apartments ap ON (ap.oid = a.apartOid OR (a.apartOid IS NULL AND ap.ApartmentId = a.ApartmentId))
    JOIN UserInfo u ON u.loginName = ap.UserLogin
    WHERE (a.apartOid = @apartOid OR (a.apartOid IS NULL AND a.ApartmentId = @ApartmentId))
      AND a.RelationId = 0
    ORDER BY a.Oid;

    -- Fallback: không có "Chủ hộ" → dùng chủ căn (ap.UserLogin)
    --IF NOT EXISTS (SELECT 1 FROM #household)
    --BEGIN
    --    INSERT INTO #household (Oid, fullName, relationName, isMain, avatarUrl)
    --    SELECT
    --           NULL,                -- không có Oid thành viên cho chủ căn
    --           u.FullName,
    --           N'Chủ hộ',
    --           CAST(0 AS bit),
    --           u.AvatarUrl
    --    FROM #all a
    --    JOIN MAS_Apartments ap ON ap.ApartmentId = a.ApartmentId
    --    JOIN MAS_Apartment_Member am ON am.ApartmentId = ap.ApartmentId
    --    JOIN UserInfo u ON u.loginName = ap.UserLogin
    --    JOIN MAS_Customers c ON u.CustId = c.CustId
    --    WHERE am.RelationId = 0 and a.ApartmentId=@ApartmentId;
    --END

    -- Đếm 1 lần
    DECLARE @Total BIGINT;
    SELECT @Total = COUNT(1)
    FROM #all d
    WHERE ( @isList = 1 AND d.member_st = 1)
       OR ( @isList = 0 AND d.member_st IN (0,2))
      AND ISNULL(d.RelationName, N'') <> N'Chủ hộ';

    -- RESULT 1: metadata + household (có thể thêm avatarUrl nếu cần)
    SELECT  recordsTotal    = @Total,
            recordsFiltered = @Total,
            gridKey         = @GridKey,
            valid           = 1,
            householdhead_Oid          = h.Oid,
            householdhead_fullName     = h.fullName,
            householdhead_relationName = h.relationName,
            householdhead_isMain       = h.isMain,
            householdhead_avatarUrl    = h.avatarUrl  -- Bật nếu muốn trả ở result 1
    FROM #household h
    UNION ALL
    SELECT  @Total, @Total, @GridKey, 1, NULL, NULL, NULL, NULL, NULL
    WHERE NOT EXISTS (SELECT 1 FROM #household);

    -- RESULT 2: header
    IF @Offset = 0
    BEGIN
        SELECT * FROM dbo.fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage) ORDER BY ordinal;
    END

    -- RESULT 3: data theo tab
    IF @isList = 1
    BEGIN
        SELECT  d.Oid,
                d.FullName    AS fullName,
                d.RoomCode    AS roomCode,
                d.RelationName AS relationName,
                CONVERT(varchar(10), d.receive_dt, 103) AS regDt,
                d.ApartmentId
        FROM #all d
        WHERE d.member_st = 1 AND ISNULL(d.RelationName, N'') <> N'Chủ hộ'
        ORDER BY CASE WHEN d.RelationName = N'Chủ hộ' THEN 0 ELSE 1 END, d.FullName
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
    END
    ELSE
    BEGIN
        SELECT  d.Oid,
                d.FullName    AS fullName,
                d.RoomCode    AS roomCode,
                d.RelationName AS relationName,
                CONVERT(NVARCHAR(100), d.statusName) as statusName,
                CONVERT(varchar(16), d.receive_dt, 103) AS regDt,
                d.ApartmentId
        FROM #all d
        WHERE d.member_st IN (0,2) AND ISNULL(d.RelationName, N'') <> N'Chủ hộ'
        ORDER BY d.FullName
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
    END

    -- RESULT 4: householdhead (trả avatarUrl để Dapper map vào HouseholdHead.avatarUrl)
    SELECT TOP 1 Oid, fullName, relationName, isMain, avatarUrl
    FROM #household;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'@Userid: ' + ISNULL(CAST(@userId AS VARCHAR(50)), N'NULL') 
                  + N', @filter: ' + ISNULL(@filter, N'NULL');
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 
                          N'MAS_Apartment_Member', N'Page', 
                          @SessionID, @AddlInfo;
    
    SELECT 0 AS valid, N'Lỗi: ' + ERROR_MESSAGE() AS [messages];
END CATCH