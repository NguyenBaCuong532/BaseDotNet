CREATE PROCEDURE [dbo].[sp_res_apartment_merge_member_field_draft]
    @userId UNIQUEIDENTIFIER = NULL,
    @ApartmentId INT = NULL,
    @custId NVARCHAR(MAX) = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN',
    @birthDay1 NVARCHAR(250) = NULL,
    @birthDay2 NVARCHAR(250) = NULL,
    @email1 NVARCHAR(450) = NULL,
    @email2 NVARCHAR(450) = NULL,
    @fullName INT = 0,
    @fullName2 INT = 0,
    @isSex1 INT = 0,
    @isSex2 INT = 0,
    @phone1 NVARCHAR(450) = NULL,
    @phone2 NVARCHAR(450) = NULL,
    @relationId1 INT = 0,
    @relationId2 INT = 0,
    @fullNameOld INT = 0
AS
BEGIN TRY
    --1 thong tin chung
    SELECT convert(nvarchar(50),@ApartmentId) id,[tableKey] = 'MAS_Apartment_Family_Member_List';
    --2- cac group
    select * from DBO.fn_get_field_group_lang('common_group', @acceptLanguage)
		   order by intOrder
	--
    --3 tung o trong group
    -- Lấy thông tin từ database nếu có @custId (giống như sp_res_apartment_get_apartmentid_by_custid)
    DECLARE @CustId1 NVARCHAR(450) = NULL;
    DECLARE @CustId2 NVARCHAR(450) = NULL;
    DECLARE @FullName1DB NVARCHAR(200) = NULL;
    DECLARE @FullName2DB NVARCHAR(200) = NULL;
    DECLARE @IsSex1DB BIT = NULL;
    DECLARE @IsSex2DB BIT = NULL;
    DECLARE @Birthday1DB DATETIME = NULL;
    DECLARE @Birthday2DB DATETIME = NULL;
    DECLARE @Phone1DB NVARCHAR(50) = NULL;
    DECLARE @Phone2DB NVARCHAR(50) = NULL;
    DECLARE @Email1DB NVARCHAR(150) = NULL;
    DECLARE @Email2DB NVARCHAR(150) = NULL;
    DECLARE @RelationId1DB INT = NULL;
    DECLARE @RelationId2DB INT = NULL;
    -- Lấy giá trị custId từ columnTooltip nếu parameter là NULL (để dùng cho việc parse và lấy thông tin)
    DECLARE @custIdFromTooltip NVARCHAR(MAX) = NULL;
    IF (@custId IS NULL OR LEN(LTRIM(RTRIM(@custId))) = 0)
    BEGIN
        SELECT @custIdFromTooltip = columnTooltip
        FROM fn_config_form_gets('MAS_Apartment_Family_Member_List', @acceptLanguage)
        WHERE field_name = 'custId';
    END
    ELSE
    BEGIN
        SET @custIdFromTooltip = @custId;
    END
    -- Parse custId để lấy thông tin từ database (dùng @custIdFromTooltip)
    IF @custIdFromTooltip IS NOT NULL AND LEN(LTRIM(RTRIM(@custIdFromTooltip))) > 0
    BEGIN
        -- Loại bỏ dấu phẩy ở đầu và cuối nếu có
        SET @custIdFromTooltip = LTRIM(RTRIM(@custIdFromTooltip));
        IF LEFT(@custIdFromTooltip, 1) = ',' SET @custIdFromTooltip = RIGHT(@custIdFromTooltip, LEN(@custIdFromTooltip) - 1);
        IF RIGHT(@custIdFromTooltip, 1) = ',' SET @custIdFromTooltip = LEFT(@custIdFromTooltip, LEN(@custIdFromTooltip) - 1);
        DECLARE @xml XML = CAST('<r><![CDATA[' + REPLACE(@custIdFromTooltip, ',', ']]></r><r><![CDATA[') + ']]></r>' AS XML);
        -- Tạo temp table để chứa danh sách CustId
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
        -- Lấy giá trị từ #CustIdList
        IF EXISTS (SELECT 1 FROM #CustIdList)
        BEGIN
            SELECT TOP 1 
                @CustId1 = CustId, 
                @FullName1DB = FullName,
                @IsSex1DB = IsSex,
                @Birthday1DB = Birthday,
                @Phone1DB = Phone,
                @Email1DB = Email,
                @RelationId1DB = RelationId
            FROM #CustIdList
            WHERE Seq = 1;
            SELECT TOP 1 
                @CustId2 = CustId, 
                @FullName2DB = FullName,
                @IsSex2DB = IsSex,
                @Birthday2DB = Birthday,
                @Phone2DB = Phone,
                @Email2DB = Email,
                @RelationId2DB = RelationId
            FROM #CustIdList
            WHERE Seq = 2;
        END
    END


    DECLARE @fullNameValue  INT = ISNULL(@fullName, 0);
    DECLARE @fullName2Value INT = ISNULL(@fullName2, 0);

IF (@fullName <> 1 AND @fullName2 <> 1)
BEGIN
    SET @fullNameValue = 1
    SET @fullNameOld = 1;
        PRINT '1 fullName: ' + CAST(@fullNameValue AS NVARCHAR(10)) + ', fullName2: ' + CAST(@fullName2Value AS NVARCHAR(10));

END
ELSE IF (@fullName = 1 AND @fullName2 = 1)
BEGIN
    IF(CAST(@fullNameOld AS NVARCHAR(10)) = 1)
    BEGIN
        SET @fullNameValue = 0
        SET @fullName2Value = 1
        SET @fullNameOld = 0

        PRINT '2 fullName: ' + CAST(@fullNameValue AS NVARCHAR(10)) + ', fullName2: ' + CAST(@fullName2Value AS NVARCHAR(10));
    END
    ELSE IF(CAST(@fullNameOld AS NVARCHAR(10)) = 0)
    BEGIN
        SET @fullNameValue = 1
        SET @fullName2Value = 0
        SET @fullNameOld = 1

        PRINT '2 fullName: ' + CAST(@fullNameValue AS NVARCHAR(10)) + ', fullName2: ' + CAST(@fullName2Value AS NVARCHAR(10));
    END


    ELSE
    BEGIN
        SET @fullNameOld = 1
        SET @fullNameValue = 1
        SET @fullName2Value = 0
    END
END
else if (@fullName = 1)
BEGIN
        SET @fullNameOld = 1
        SET @fullNameValue = 1
        SET @fullName2Value = 0
        PRINT '1 fullName: ' + CAST(@fullNameValue AS NVARCHAR(10)) + ', fullName2: ' + CAST(@fullName2Value AS NVARCHAR(10));
    END


    SELECT s.id,
			s.[table_name]
			, s.[field_name]
			, s.[view_type]
			, s.[data_type]
			, s.[ordinal]
			, s.[columnLabel]
			, s.[group_cd]
			, CASE [data_type] 
              WHEN 'nvarchar' THEN convert(nvarchar(350), CASE [field_name]			
					WHEN 'email1'
						THEN ISNULL(@email1, @Email1DB)
					WHEN 'email2'
						THEN ISNULL(@email2, @Email2DB)
					WHEN 'phone1'
						THEN ISNULL(@phone1, @Phone1DB)
					WHEN 'phone2'
						THEN ISNULL(@phone2, @Phone2DB)
					WHEN 'fullName'
						THEN @FullName1DB
					WHEN 'fullName2'
						THEN @FullName2DB
					WHEN 'custId'
						THEN ISNULL(@custId, (SELECT columnTooltip FROM fn_config_form_gets('MAS_Apartment_Family_Member_List', @acceptLanguage) WHERE field_name = 'custId'))
					WHEN 'memberFirst'
						THEN @CustId1
					WHEN 'memberSc'
						THEN @CustId2
						END)
				WHEN 'int' THEN convert(nvarchar(350), CASE [field_name] 
				    WHEN 'ApartmentId' THEN  CONVERT(NVARCHAR(500), @ApartmentId)
					WHEN 'isSex1'
						THEN CASE 
							WHEN @isSex1 IS NOT NULL AND @isSex1 != 0 
								THEN CASE WHEN @isSex1 = 1 THEN N'1' ELSE N'0' END 
							ELSE CASE WHEN ISNULL(@IsSex1DB, 0) = 1 THEN N'1' ELSE N'0' END 
						END
					WHEN 'isSex2'
						THEN CASE 
							WHEN @isSex2 IS NOT NULL AND @isSex2 != 0 
								THEN CASE WHEN @isSex2 = 1 THEN N'1' ELSE N'0' END 
							ELSE CASE WHEN ISNULL(@IsSex2DB, 0) = 1 THEN N'1' ELSE N'0' END 
						END
					WHEN 'relationId1'
						THEN CONVERT(NVARCHAR(500), ISNULL(@relationId1, ISNULL(@RelationId1DB, 0)))
					WHEN 'relationId2'
						THEN CONVERT(NVARCHAR(500), ISNULL(@relationId2, ISNULL(@RelationId2DB, 0)))
              END)
			  WHEN 'date' THEN convert(nvarchar(50), CASE [field_name] 
               WHEN 'birthDay1'
					THEN ISNULL(CONVERT(NVARCHAR(50), @birthDay1, 103), CASE WHEN @Birthday1DB IS NOT NULL THEN CONVERT(NVARCHAR(50), @Birthday1DB, 103) ELSE NULL END)
				WHEN 'birthDay2'
					THEN ISNULL(CONVERT(NVARCHAR(50), @birthDay2, 103), CASE WHEN @Birthday2DB IS NOT NULL THEN CONVERT(NVARCHAR(50), @Birthday2DB, 103) ELSE NULL END)
              END)
				WHEN 'bit' THEN convert(nvarchar(350), CASE [field_name] 
					WHEN 'fullName'
						THEN CASE WHEN ISNULL(@fullNameValue, 0) = 1 THEN N'true' ELSE N'false' END
					WHEN 'fullName2'
						THEN CASE WHEN ISNULL(@fullName2Value, 0) = 1 THEN N'true' ELSE N'false' END
                    WHEN 'fullNameOld'
						THEN CASE WHEN ISNULL(@fullNameOld, 0) = 1 THEN N'true' ELSE N'false' END
              END)
				ELSE ISNULL(s.[columnDefault], NULL)
					END  
            as columnValue
			, [columnClass]
			, [columnType]
			, CASE 
				WHEN s.[field_name] = 'memberFirst' 
				THEN REPLACE(REPLACE(s.[columnObject], 'apartmentId=', 'apartmentId=' + ISNULL(CAST(@ApartmentId AS NVARCHAR(50)), '')), 'custIds=', 'custIds=' + ISNULL(CAST(ISNULL(@custId, @custIdFromTooltip) AS NVARCHAR(MAX)), ''))
				WHEN s.[field_name] = 'memberSc' 
				THEN REPLACE(REPLACE(s.[columnObject], 'apartmentId=', 'apartmentId=' + ISNULL(CAST(@ApartmentId AS NVARCHAR(50)), '')), 'custIds=', 'custIds=' + ISNULL(CAST(ISNULL(@custId, @custIdFromTooltip) AS NVARCHAR(MAX)), ''))
				ELSE s.[columnObject]
			END AS [columnObject]
			, [isSpecial]
			, [isRequire]
			, [isDisable]
			, [isVisiable]
			, NULL AS [IsEmpty]
			, ISNULL(
				CASE s.[field_name]
					WHEN 'ApartmentId'
						THEN LOWER(CONVERT(NVARCHAR(500), @ApartmentId))
					WHEN 'custId'
						THEN ISNULL(@custId, (SELECT columnTooltip FROM fn_config_form_gets('MAS_Apartment_Family_Member_List', @acceptLanguage) WHERE field_name = 'custId'))
					WHEN 'memberFirst'
						THEN @CustId1
					WHEN 'memberSc'
						THEN @CustId2
					WHEN 'fullName'
						THEN @FullName1DB
					WHEN 'fullName2'
						THEN @FullName2DB
					WHEN 'isSex1'
						THEN CONVERT(NVARCHAR(10), ISNULL(@IsSex1DB, 0))
					WHEN 'isSex2'
						THEN CONVERT(NVARCHAR(10), ISNULL(@IsSex2DB, 0))
					WHEN 'birthDay1'
						THEN CASE WHEN @Birthday1DB IS NOT NULL THEN CONVERT(NVARCHAR(10), @Birthday1DB, 103) ELSE NULL END
					WHEN 'birthDay2'
						THEN CASE WHEN @Birthday2DB IS NOT NULL THEN CONVERT(NVARCHAR(10), @Birthday2DB, 103) ELSE NULL END
					WHEN 'phone1'
						THEN @Phone1DB
					WHEN 'phone2'
						THEN @Phone2DB
					WHEN 'email1'
						THEN @Email1DB
					WHEN 'email2'
						THEN @Email2DB
					WHEN 'relationId1'
						THEN CONVERT(NVARCHAR(10), ISNULL(@RelationId1DB, 0))
					WHEN 'relationId2'
						THEN CONVERT(NVARCHAR(10), ISNULL(@RelationId2DB, 0))
					ELSE NULL
				END,
				ISNULL(s.columnTooltip, s.[columnLabel])
			) AS columnTooltip
			, s.columnDisplay
			, s.isIgnore
    FROM fn_config_form_gets('MAS_Apartment_Family_Member_List', @acceptLanguage) s
    --WHERE s.isVisiable = 1
    ORDER BY ordinal;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_merge_member_field_draft' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = N'@ApartmentId: ' + ISNULL(CAST(@ApartmentId AS NVARCHAR(50)), N'NULL') + N', @fullName: ' + ISNULL(CAST(@fullName AS NVARCHAR(10)), N'NULL') + N', @fullName2: ' + ISNULL(CAST(@fullName2 AS NVARCHAR(10)), N'NULL');
    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'MAS_Apartment_Family_Member_List',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;