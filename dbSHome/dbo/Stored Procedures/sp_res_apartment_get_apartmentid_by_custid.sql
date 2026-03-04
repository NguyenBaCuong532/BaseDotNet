CREATE PROCEDURE [dbo].[sp_res_apartment_get_apartmentid_by_custid]
    @CustIds NVARCHAR(MAX) = NULL  -- Danh sách CustId cách nhau bởi dấu phẩy
    , @ApartmentId INT = NULL
    , @UserId uniqueidentifier = NULL
    , @AcceptLanguage nvarchar(50) = N'vi-VN'
AS
BEGIN TRY
    IF @ApartmentId IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM dbo.MAS_Apartments
            WHERE ApartmentId = @ApartmentId
            )
        SET @ApartmentId = NULL;
    DECLARE @group_key VARCHAR(50) = 'common_group'
    DECLARE @table_key VARCHAR(50) = 'MAS_Apartment_Family_Member_List'
    SELECT @ApartmentId [ApartmentId]
        , tableKey = @table_key
        , groupKey = @group_key;
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@group_key, @AcceptLanguage)
    ORDER BY intOrder;
    -- Tạo temp table để chứa danh sách CustId (chỉ lấy 2 đầu tiên) - lấy đầy đủ thông tin thành viên
    IF OBJECT_ID('tempdb..#CustIdList') IS NOT NULL DROP TABLE #CustIdList;
    CREATE TABLE #CustIdList (
        CustId NVARCHAR(450), 
        Seq INT, 
        FullName NVARCHAR(200),
        IsSex BIT,
        Birthday DATETIME,
        Phone NVARCHAR(50),
        Email NVARCHAR(150),
        RelationId INT
    );
    -- Parse CustIds từ string (phân tách bằng dấu phẩy) và chỉ lấy 2 đầu tiên
    IF @CustIds IS NOT NULL AND LEN(LTRIM(RTRIM(@CustIds))) > 0
    BEGIN
        -- Loại bỏ dấu phẩy ở đầu và cuối nếu có
        SET @CustIds = LTRIM(RTRIM(@CustIds));
        IF LEFT(@CustIds, 1) = ',' SET @CustIds = RIGHT(@CustIds, LEN(@CustIds) - 1);
        IF RIGHT(@CustIds, 1) = ',' SET @CustIds = LEFT(@CustIds, LEN(@CustIds) - 1);
        DECLARE @xml XML = CAST('<r><![CDATA[' + REPLACE(@CustIds, ',', ']]></r><r><![CDATA[') + ']]></r>' AS XML);
        -- Lấy đầy đủ thông tin từ MAS_Customers và MAS_Apartment_Member
        INSERT INTO #CustIdList (CustId, Seq, FullName, IsSex, Birthday, Phone, Email, RelationId)
        SELECT TOP 2 
            LTRIM(RTRIM(Parsed.value)) AS CustId,
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Seq,
            ISNULL(c.FullName, '') AS FullName,
            c.IsSex,
            c.Birthday,
            c.Phone,
            c.Email,
            ISNULL(am.RelationId, 0) AS RelationId
        FROM (
            SELECT T.c.value('.', 'NVARCHAR(MAX)') AS value
            FROM @xml.nodes('/r') T(c)
        ) AS Parsed
        LEFT JOIN MAS_Customers c WITH (NOLOCK) ON c.CustId = LTRIM(RTRIM(Parsed.value))
        LEFT JOIN MAS_Apartment_Member am WITH (NOLOCK) ON am.CustId = LTRIM(RTRIM(Parsed.value)) 
            AND (@ApartmentId IS NULL OR am.ApartmentId = @ApartmentId)
        WHERE LTRIM(RTRIM(Parsed.value)) <> '' AND LTRIM(RTRIM(Parsed.value)) IS NOT NULL;
    END
    -- Debug: Kiểm tra số lượng record trong #CustIdList
    DECLARE @CountCustId INT = 0;
    SELECT @CountCustId = COUNT(*) FROM #CustIdList;
    PRINT 'Count in #CustIdList: ' + CAST(@CountCustId AS NVARCHAR(10));
    -- Lấy giá trị từ #CustIdList (nếu có)
    DECLARE @CustId1 NVARCHAR(450) = NULL;
    DECLARE @CustId2 NVARCHAR(450) = NULL;
    DECLARE @FullName1 NVARCHAR(200) = NULL;
    DECLARE @FullName2 NVARCHAR(200) = NULL;
    DECLARE @IsSex1 BIT = NULL;
    DECLARE @IsSex2 BIT = NULL;
    DECLARE @Birthday1 DATETIME = NULL;
    DECLARE @Birthday2 DATETIME = NULL;
    DECLARE @Phone1 NVARCHAR(50) = NULL;
    DECLARE @Phone2 NVARCHAR(50) = NULL;
    DECLARE @Email1 NVARCHAR(150) = NULL;
    DECLARE @Email2 NVARCHAR(150) = NULL;
    DECLARE @RelationId1 INT = NULL;
    DECLARE @RelationId2 INT = NULL;
    IF EXISTS (SELECT 1 FROM #CustIdList)
    BEGIN
        PRINT 'Found data in #CustIdList';
        SELECT TOP 1 
            @CustId1 = CustId, 
            @FullName1 = FullName,
            @IsSex1 = IsSex,
            @Birthday1 = Birthday,
            @Phone1 = Phone,
            @Email1 = Email,
            @RelationId1 = RelationId
        FROM #CustIdList
        WHERE Seq = 1;
        SELECT TOP 1 
            @CustId2 = CustId, 
            @FullName2 = FullName,
            @IsSex2 = IsSex,
            @Birthday2 = Birthday,
            @Phone2 = Phone,
            @Email2 = Email,
            @RelationId2 = RelationId
        FROM #CustIdList
        WHERE Seq = 2;
        PRINT 'CustId1: ' + ISNULL(@CustId1, 'NULL');
        PRINT 'CustId2: ' + ISNULL(@CustId2, 'NULL');
    END
    ELSE
    BEGIN
        PRINT 'No data in #CustIdList';
    END
    -- Lấy ra từng ô trong group cho tối đa 2 thành viên
    -- Luôn trả về kết quả từ sys_config_form, không phụ thuộc vào #CustIdList
    SELECT s.[table_name]
        , s.[field_name]
        , s.[view_type]
        , s.[data_type]
        , s.[ordinal]
        , s.[columnLabel]
        , s.[group_cd]
        , CASE s.[data_type]
            WHEN 'bit' THEN 
                CASE s.[field_name]
                    WHEN 'fullName'
                        THEN s.[columnDefault] 
                    WHEN 'fullName2'
                        THEN s.[columnDefault] 
                    ELSE s.[columnDefault]
                END
            WHEN 'nvarchar' THEN
                CASE 
                    WHEN s.[field_name] = 'custId'
                        THEN ISNULL(@CustIds, s.[columnDefault])
                    ELSE s.[columnDefault]
                END
            ELSE s.[columnDefault]
        END AS columnValue
        , s.[columnClass]
        , s.[columnType]
        , CASE 
            WHEN s.[field_name] = 'memberFirst' 
            THEN REPLACE(REPLACE(s.[columnObject], 'apartmentId=', 'apartmentId=' + ISNULL(CAST(@ApartmentId AS NVARCHAR(50)), '')), 'custIds=', 'custIds=' + ISNULL(CAST(@CustIds AS NVARCHAR(MAX)), ''))
            WHEN s.[field_name] = 'memberSc' 
            THEN REPLACE(REPLACE(s.[columnObject], 'apartmentId=', 'apartmentId=' + ISNULL(CAST(@ApartmentId AS NVARCHAR(50)), '')), 'custIds=', 'custIds=' + ISNULL(CAST(@CustIds AS NVARCHAR(MAX)), ''))
            ELSE s.[columnObject]
        END AS [columnObject]
        , s.[isSpecial]
        , s.[isRequire]
        , s.[isDisable]
        , s.[isVisiable]
        , NULL AS [IsEmpty]
        , ISNULL(
            CASE s.[field_name]
                WHEN 'ApartmentId'
                    THEN LOWER(CONVERT(NVARCHAR(500), @ApartmentId))
                WHEN 'custId'
                    THEN @CustIds -- trả lại đúng chuỗi CustIds CSV (2 CustId trong 1 field)
                WHEN 'memberFirst'
                    THEN @CustId1
                WHEN 'memberSc'
                    THEN @CustId2
                WHEN 'fullName'
                    THEN @FullName1 -- Thông tin thành viên đầu tiên
                WHEN 'fullName1'
                    THEN @FullName1
                WHEN 'fullName2'
                    THEN @FullName2
                WHEN 'isSex'
                    THEN CONVERT(NVARCHAR(10), ISNULL(@IsSex1, 0))
                WHEN 'isSex1'
                    THEN CONVERT(NVARCHAR(10), ISNULL(@IsSex1, 0))
                WHEN 'isSex2'
                    THEN CONVERT(NVARCHAR(10), ISNULL(@IsSex2, 0))
                WHEN 'birthDay'
                    THEN CASE WHEN @Birthday1 IS NOT NULL THEN CONVERT(NVARCHAR(10), @Birthday1, 103) ELSE NULL END
                WHEN 'birthDay1'
                    THEN CASE WHEN @Birthday1 IS NOT NULL THEN CONVERT(NVARCHAR(10), @Birthday1, 103) ELSE NULL END
                WHEN 'birthDay2'
                    THEN CASE WHEN @Birthday2 IS NOT NULL THEN CONVERT(NVARCHAR(10), @Birthday2, 103) ELSE NULL END
                WHEN 'phone'
                    THEN @Phone1 -- Thông tin thành viên đầu tiên
                WHEN 'phone1'
                    THEN @Phone1
                WHEN 'phone2'
                    THEN @Phone2
                WHEN 'email'
                    THEN @Email1 -- Thông tin thành viên đầu tiên
                WHEN 'email1'
                    THEN @Email1
                WHEN 'email2'
                    THEN @Email2
                WHEN 'relationId'
                    THEN CONVERT(NVARCHAR(10), ISNULL(@RelationId1, 0))
                WHEN 'relationId1'
                    THEN CONVERT(NVARCHAR(10), ISNULL(@RelationId1, 0))
                WHEN 'relationId2'
                    THEN CONVERT(NVARCHAR(10), ISNULL(@RelationId2, 0))
                ELSE NULL
            END,
            ISNULL(s.columnTooltip, s.[columnLabel])
        ) AS columnTooltip
    FROM dbo.fn_config_form_gets(@table_key, @AcceptLanguage) s
    ORDER BY s.ordinal;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_get_apartmentid_by_custid' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = N'@CustIds: ' + ISNULL(@CustIds, N'NULL') + N', @ApartmentId: ' + ISNULL(CAST(@ApartmentId AS NVARCHAR(50)), N'NULL');
    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Apartment_Family_Member_List'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;