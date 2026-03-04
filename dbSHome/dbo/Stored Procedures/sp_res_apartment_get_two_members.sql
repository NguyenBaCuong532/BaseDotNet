
CREATE   procedure [dbo].[sp_res_apartment_get_two_members]
    @userId UNIQUEIDENTIFIER,
    @ApartmentId INT,
    @CustIds NVARCHAR(MAX) = NULL,
    @filter NVARCHAR(100) = NULL, 
    @clientId NVARCHAR(50) = NULL, 
    @gridWidth INT = NULL, 
    @Offset INT = NULL, 
    @PageSize INT = NULL,
    @total BIGINT = NULL OUTPUT,
    @totalFiltered BIGINT = NULL OUTPUT,
    @gridKey NVARCHAR(100) = NULL OUTPUT,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    
    -- Parse danh sách CustId nếu có
    DECLARE @CustTable TABLE (CustId NVARCHAR(450) PRIMARY KEY);
    IF @CustIds IS NOT NULL AND LEN(LTRIM(RTRIM(@CustIds))) > 0
    BEGIN
        -- Loại bỏ các ký tự thừa và parse
        SET @CustIds = LTRIM(RTRIM(@CustIds));
        -- Loại bỏ dấu phẩy ở đầu và cuối nếu có
        IF LEFT(@CustIds, 1) = ',' SET @CustIds = RIGHT(@CustIds, LEN(@CustIds) - 1);
        IF RIGHT(@CustIds, 1) = ',' SET @CustIds = LEFT(@CustIds, LEN(@CustIds) - 1);
        
        -- Sử dụng XML parsing thay vì STRING_SPLIT để đảm bảo parse chính xác
        DECLARE @xml XML = CAST('<r><![CDATA[' + REPLACE(@CustIds, ',', ']]></r><r><![CDATA[') + ']]></r>' AS XML);
        
        INSERT INTO @CustTable (CustId)
        SELECT DISTINCT LTRIM(RTRIM(Parsed.value)) AS CustId
        FROM (
            SELECT T.c.value('.', 'NVARCHAR(MAX)') AS value
            FROM @xml.nodes('/r') T(c)
        ) AS Parsed
        WHERE LTRIM(RTRIM(Parsed.value)) <> '' 
            AND LTRIM(RTRIM(Parsed.value)) IS NOT NULL;
        
        -- Debug: In số lượng CustId đã parse
        DECLARE @CountCustId INT = 0;
        SELECT @CountCustId = COUNT(*) FROM @CustTable;
        
        -- Debug: In từng CustId đã parse
        DECLARE @DebugCustId NVARCHAR(450);
        DECLARE @DebugCursor CURSOR;
        SET @DebugCursor = CURSOR FOR SELECT CustId FROM @CustTable;
        OPEN @DebugCursor;
        FETCH NEXT FROM @DebugCursor INTO @DebugCustId;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            FETCH NEXT FROM @DebugCursor INTO @DebugCustId;
        END
        CLOSE @DebugCursor;
        DEALLOCATE @DebugCursor;
    END
 
    -- Khai báo biến cho root record

    DECLARE @GridKeyLocal NVARCHAR(100) = ISNULL(@gridKey, 'view_merge_member_info');
    SET @gridKey = @GridKeyLocal;
    SET @total = ISNULL(@total, 0);
    SET @totalFiltered = ISNULL(@totalFiltered, 0);
    
    -- Tạo temp table để lưu kết quả
    CREATE TABLE #DataResult (
        FieldName NVARCHAR(200),
        [name] NVARCHAR(500),
        [value] BIT,
        [name1] NVARCHAR(500),
        [value1] BIT
    );
    
    -- Lấy 2 thành viên theo điều kiện
    IF EXISTS(SELECT 1 FROM @CustTable)
    BEGIN
        ;WITH MemberCte AS
        (
            SELECT 
                ROW_NUMBER() OVER (
                    ORDER BY CASE WHEN b.RelationId = 0 THEN 0 ELSE 1 END,
                             b.RegDt DESC
                ) AS rn,
                a.[FullName],
                a.CustId,
                ISNULL(a.IsSex, 0) AS IsSex,
                CASE WHEN ISNULL(a.IsSex, 0) = 1 THEN N'Nam' ELSE N'Nữ' END AS SexName,
                CONVERT(NVARCHAR(10), a.birthday, 103) AS Birthday,
                a.[Phone],
                a.[Email],
                ISNULL(d.RelationName, N'Khác') AS RelationName,
                CONVERT(NVARCHAR(10), ISNULL(b.approveDt, b.RegDt), 103) AS StartDate,
                CASE 
                    WHEN b.memberUserId IS NOT NULL
                         OR EXISTS (
                            SELECT 1 
                            FROM UserInfo mu 
                            WHERE mu.CustId = a.CustId 
                                  AND mu.userType = 2
                         )
                    THEN 1 ELSE 0 
                END AS IsApp,
                CASE 
                    WHEN a.CountryCd = 'VN' OR a.CountryCd IS NULL THEN 0 
                    ELSE 1 
                END AS IsForeign
            FROM MAS_Customers a WITH (NOLOCK)
            INNER JOIN MAS_Apartment_Member b WITH (NOLOCK) ON a.CustId = b.CustId
            INNER JOIN @CustTable c ON c.CustId = a.CustId
            LEFT JOIN MAS_Customer_Relation d WITH (NOLOCK) ON b.RelationId = d.RelationId
            WHERE b.ApartmentId = @ApartmentId
        )
        , MemberPair AS
        (
            SELECT 
                m1.*,
                m2.FullName AS FullName2,
                m2.CustId AS CustId2,
                m2.IsSex AS IsSex2,
                m2.SexName AS SexName2,
                m2.Birthday AS Birthday2,
                m2.Phone AS Phone2,
                m2.Email AS Email2,
                m2.RelationName AS RelationName2,
                m2.StartDate AS StartDate2,
                m2.IsApp AS IsApp2,
                m2.IsForeign AS IsForeign2
            FROM MemberCte m1
            LEFT JOIN MemberCte m2 ON m2.rn = 2
            WHERE m1.rn = 1
        )
        , DataResult AS
        (
            SELECT 
                -- Họ tên
                N'Họ tên' AS FieldName,
                p.FullName AS [name],
                p.FullName2 AS [name1]
            FROM MemberPair p
            
            UNION ALL
            
            SELECT 
                -- Giới tính
                N'Giới tính' AS FieldName,
                p.SexName AS [name],
                p.SexName2 AS [name1]
            FROM MemberPair p
            
            UNION ALL
            
            SELECT 
                -- Ngày sinh
                N'Ngày sinh' AS FieldName,
                p.Birthday AS [name],
                p.Birthday2 AS [name1]
            FROM MemberPair p
            
            UNION ALL
            
            SELECT 
                -- Số điện thoại
                N'Số điện thoại' AS FieldName,
                ISNULL(p.Phone,'1') AS [name],
                ISNULL(p.Phone2,'') AS [name1]
            FROM MemberPair p
            
            UNION ALL
            
            SELECT 
                -- Email
                N'Email' AS FieldName,
                p.Email AS [name],
                p.Email2 AS [name1]
            FROM MemberPair p
            
            UNION ALL
            
            SELECT 
                -- Quan hệ với chủ hộ
                N'Quan hệ với chủ hộ' AS FieldName,
                p.RelationName AS [name],
                p.RelationName2 AS [name1]
            FROM MemberPair p
            
            UNION ALL
            
            SELECT 
                -- Ngày bắt đầu cư trú
                N'Ngày bắt đầu cư trú' AS FieldName,
                p.StartDate AS [name],
                p.StartDate2 AS [name1]
            FROM MemberPair p
            
            UNION ALL
            
            SELECT 
                -- Tài khoản app liên kết
                N'Tài khoản app liên kết' AS FieldName,
                CASE WHEN p.IsApp = 1 THEN N'Đã liên kết' ELSE N'Chưa liên kết' END AS [name],
                CASE WHEN ISNULL(p.IsApp2, 0) = 1 THEN N'Đã liên kết' ELSE N'Chưa liên kết' END AS [name1]
            FROM MemberPair p
            
            UNION ALL
            
            SELECT 
                -- Người nước ngoài (radio true/false)
                N'Người nước ngoài' AS FieldName,
                CASE WHEN p.IsForeign = 1 THEN N'Người nước ngoài' ELSE N'Trong nước' END AS [name],
                CASE WHEN ISNULL(p.IsForeign2, 0) = 1 THEN N'Người nước ngoài' ELSE N'Trong nước' END AS [name1]
            FROM MemberPair p
        )
        INSERT INTO #DataResult (FieldName, [name], [value], [name1], [value1])
        SELECT 
            N'Họ tên' AS FieldName,
            ISNULL(p.FullName,'') AS [name],
            CAST(0 AS BIT) AS [value],
            ISNULL(p.FullName2,'') AS [name1],
            CAST(1 AS BIT) AS [value1]
        FROM MemberPair p
        
        UNION ALL
        
        SELECT 
            N'Giới tính' AS FieldName,
            ISNULL(p.SexName,'') AS [name],
            CAST(0 AS BIT) AS [value],
            ISNULL(p.SexName2,'') AS [name1],
            CAST(1 AS BIT) AS [value1]
        FROM MemberPair p
        
        UNION ALL
        
        SELECT 
            N'Ngày sinh' AS FieldName,
            ISNULL( p.Birthday,'') AS [name],
            CAST(0 AS BIT) AS [value],
            ISNULL(p.Birthday2,'') AS [name1],
            CAST(1 AS BIT) AS [value1]
        FROM MemberPair p
        
        UNION ALL
        
        SELECT 
            N'Số điện thoại' AS FieldName,
            isnull(p.Phone,'') AS [name],
            CAST(0 AS BIT) AS [value],
            isnull(p.Phone2,'') AS [name1],
            CAST(1 AS BIT) AS [value1]
        FROM MemberPair p
        
        UNION ALL
        
        SELECT 
            N'Email' AS FieldName,
            isnull(p.Email,'') AS [name],
            CAST(0 AS BIT) AS [value],
            isnull(p.Email2,'') AS [name1],
            CAST(1 AS BIT) AS [value1]
        FROM MemberPair p
        
        UNION ALL
        
        SELECT 
            N'Quan hệ với chủ hộ' AS FieldName,
            ISNULL(p.RelationName,'') AS [name],
            CAST(0 AS BIT) AS [value],
            ISNULL(p.RelationName2,'') AS [name1],
            CAST(1 AS BIT) AS [value1]
        FROM MemberPair p
        
        UNION ALL
        
        SELECT 
            N'Ngày bắt đầu cư trú' AS FieldName,
            ISNULL(p.StartDate,'') AS [name],
            CAST(0 AS BIT) AS [value],
            ISNULL(p.StartDate2,'') AS [name1],
            CAST(1 AS BIT) AS [value1]
        FROM MemberPair p
        
        UNION ALL
        
        SELECT 
            N'Tài khoản app liên kết' AS FieldName,
            CASE WHEN ISNULL(p.IsApp,0) = 1 THEN N'Đã liên kết' ELSE N'Chưa liên kết' END AS [name],
            CAST(1 AS BIT) AS [value],
            CASE WHEN ISNULL(p.IsApp2, 0) = 1 THEN N'Đã liên kết' ELSE N'Chưa liên kết' END AS [name1],
            CAST(0 AS BIT) AS [value1]
        FROM MemberPair p
        
        UNION ALL
        
        SELECT 
            N'Người nước ngoài' AS FieldName,
            CASE WHEN ISNULL(p.IsForeign,0) = 1 THEN N'Người nước ngoài' ELSE N'Trong nước' END AS [name],
            CAST(1 AS BIT) AS [value],
            CASE WHEN ISNULL(p.IsForeign2, 0) = 1 THEN N'Người nước ngoài' ELSE N'Trong nước' END AS [name1],
            CAST(0 AS BIT) AS [value1]
        FROM MemberPair p;
    END
   
    
    -- Tính tổng số records
    SELECT @Total = COUNT(*) FROM #DataResult;
    SET @total = ISNULL(@Total, 0);
    SET @totalFiltered = ISNULL(@Total, 0);
    
    -- Lấy CustId1 và CustId2 từ @CustTable
    DECLARE @CustId1 NVARCHAR(450) = NULL;
    DECLARE @CustId2 NVARCHAR(450) = NULL;
    
    IF EXISTS (SELECT 1 FROM @CustTable)
    BEGIN
        -- Lấy CustId đầu tiên
        SELECT TOP 1 @CustId1 = CustId FROM @CustTable ORDER BY CustId;
        
        -- Lấy CustId thứ hai (nếu có)
        SELECT TOP 1 @CustId2 = CustId 
        FROM (
            SELECT CustId, ROW_NUMBER() OVER (ORDER BY CustId) AS rn
            FROM @CustTable
        ) AS t
        WHERE rn = 2;
    END
    
    -- Root record - luôn trả về, kể cả khi không có data
    SELECT
        recordsTotal = ISNULL(@Total, 0),
        recordsFiltered = ISNULL(@Total, 0),
        gridKey = @GridKeyLocal,
        valid = 1,
        CustId1 = @CustId1,
        CustId2 = @CustId2;
    
    -- Grid config
    SELECT *
    FROM [dbo].fn_config_list_gets_lang(@GridKeyLocal, 0, @acceptLanguage)
    ORDER BY [ordinal];
    
    -- Data list
    SELECT 
        FieldName,
        [name],
        [value],
        [name1],
        [value1]
    FROM #DataResult;
    
    -- Cleanup
    DROP TABLE #DataResult;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = N', @ApartmentId: ' + ISNULL(CAST(@ApartmentId AS NVARCHAR(50)), N'NULL');
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Apartment_Member', N'GET_TWO_MEMBERS', @SessionID, @AddlInfo;
    
    -- Trả về lỗi
    THROW;
END CATCH;