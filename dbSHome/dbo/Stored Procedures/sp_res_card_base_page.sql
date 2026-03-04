CREATE PROCEDURE [dbo].[sp_res_card_base_page]
      @UserId        UNIQUEIDENTIFIER 
    , @project_code  NVARCHAR(50) = NULL
    , @clientId      NVARCHAR(50) = NULL
    , @filter        NVARCHAR(30) = NULL
    , @Status        INT          = NULL      -- -1: bỏ lọc; 0/1: lọc theo IsUsed
    , @gridWidth     INT          = 0
    , @Offset        INT          = 0
    , @PageSize      INT          = 10
    , @startNum       BIGINT      = 0
    , @endNum         BIGINT      = 0
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    SET @startNum = ISNULL(@startNum, 0);
    SET @endNum  = ISNULL(@endNum , 0);
    -- 
    IF @startNum > @endNum
    BEGIN
        SET @startNum = 0
        SET @endNum = 0
    END
--
    DECLARE @Total   BIGINT;
    DECLARE @GridKey NVARCHAR(100) = N'view_card_base_page';
	
    --Tạo bảng tạm cho start - End 
		SET NOCOUNT ON;
		DROP TABLE IF EXISTS #ct;
		CREATE TABLE #ct (ct NVARCHAR(4000) NOT NULL);
		INSERT INTO #ct(ct)
		SELECT TOP (@endNum - @startNum + 1)
		ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 + @startNum
		FROM master..spt_values a
		CROSS JOIN master..spt_values b;
	--


    --Tạo bảng tạm cho filter
		SET NOCOUNT ON;
		DROP TABLE IF EXISTS #ft;
		CREATE TABLE #ft (ft NVARCHAR(4000) NOT NULL);

		INSERT INTO #ft(ft)
		SELECT TRIM([part])
		FROM SplitString(@filter, ',')
		WHERE TRIM([part]) <> '';
	--


    -- Chuẩn hoá tham số
    SET @Offset   = ISNULL(@Offset, 0);
    SET @PageSize = CASE WHEN ISNULL(@PageSize, 10) <= 0 THEN 10 ELSE @PageSize END;
    SET @filter   = ISNULL(@filter, N'');
    SET @Status   = ISNULL(@Status, -1);

    /* ==================== Tổng bản ghi ==================== */

    IF @startNum = 0 AND @endNum = 0
		BEGIN
        SELECT @Total = COUNT_BIG(1)
        FROM
            dbo.MAS_CardBase AS a WITH (READUNCOMMITTED)   -- tương đương NOLOCK, có thể bỏ nếu cần tính nhất quán
            LEFT JOIN dbo.UserProject AS up ON up.projectCd = a.ProjectCode AND up.userId    = @UserId
            LEFT JOIN MAS_Cards cs on a.Code = cs.CardCd
            LEFT JOIN MAS_CardTypes c on ISNULL(a.[Type], cs.CardTypeId) = c.CardTypeId
            LEFT JOIN MAS_Projects pu on pu.projectCd = ISNULL(cs.ProjectCd, a.ProjectCode)
        WHERE --a.ProjectCode = @project_code 
            (@project_code is null
                                  OR ((a.ProjectCode IS NOT NULL AND a.ProjectCode = @project_code) OR (cs.ProjectCd IS NOT NULL AND cs.ProjectCd = @project_code))
                                  OR (a.ProjectCode IS NULL AND cs.ProjectCd IS NULL))
            AND (@filter = N''
                OR a.Code LIKE N'%'+@filter+'%'
                OR a.Card_Num LIKE N'%'+@filter+'%'
                OR a.Code LIKE N'%'+@filter+'%'
                OR EXISTS (SELECT 1 FROM #ft f WHERE a.LotNumber LIKE f.ft + '%'))
            AND (@Status = -1 OR (@Status = 1 AND cs.CardId IS NOT NULL) OR (@Status = 0 AND cs.CardId IS NULL AND a.IsUsed <> 1))
    END
    ELSE
		BEGIN
        SELECT @Total = COUNT_BIG(1)
        FROM
            dbo.MAS_CardBase AS a WITH (READUNCOMMITTED)   -- tương đương NOLOCK, có thể bỏ nếu cần tính nhất quán
            LEFT JOIN dbo.UserProject AS up ON up.projectCd = a.ProjectCode AND up.userId    = @UserId
            LEFT JOIN MAS_Cards cs on a.Code = cs.CardCd
            LEFT JOIN MAS_CardTypes c on ISNULL(a.[Type], cs.CardTypeId) = c.CardTypeId
            LEFT JOIN MAS_Projects pu on pu.projectCd = ISNULL(cs.ProjectCd, a.ProjectCode)
        WHERE --a.ProjectCode = @project_code 
            (@project_code is null
                                  OR ((a.ProjectCode IS NOT NULL AND a.ProjectCode = @project_code) OR (cs.ProjectCd IS NOT NULL AND cs.ProjectCd = @project_code))
                                  OR (a.ProjectCode IS NULL AND cs.ProjectCd IS NULL))
            AND (@filter = N''
                OR a.Code LIKE N'%'+@filter+'%'
                OR a.Card_Num LIKE N'%'+@filter+'%'
                OR a.Code LIKE N'%'+@filter+'%'
                OR EXISTS (SELECT 1 FROM #ft f WHERE a.LotNumber LIKE f.ft + '%'))
--             AND (@Status = -1 OR a.IsUsed = @Status)
            AND (@Status = -1 OR (@Status = 1 AND cs.CardId IS NOT NULL) OR (@Status = 0 AND cs.CardId IS NULL AND a.IsUsed <> 1))
            AND EXISTS (SELECT 1 FROM #ct c WHERE TRY_CAST(a.Code AS BIGINT) = TRY_CAST(c.ct AS BIGINT))
        OPTION (RECOMPILE);
		END
    

    /* ==================== Root result ==================== */
    SELECT
        recordsTotal    = @Total,
        recordsFiltered = @Total,
        gridKey         = @GridKey,
        valid           = 1;

    /* ==================== Grid config (trang đầu) ==================== */
    IF (@Offset = 0)
    BEGIN
        SELECT *
        FROM dbo.fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
        ORDER BY [ordinal];
    END

    /* ==================== Listing phân trang ==================== */
    IF @startNum = 0 AND @endNum = 0
        SELECT
            cs.CardId,
            cs.ProjectCd,
            cs.IsDaily,
            a.Guid_Cd,
            a.Card_Num,
            a.Card_Hex,
            a.Code,
            IsUsed = IIF(cs.CardId IS NOT NULL OR cs.IsDaily = 1, 1, a.IsUsed),
            a.projectCode,
            ProjectCode = ISNULL(cs.ProjectCd, a.ProjectCode),
            CASE
                WHEN pu.projectName is null Then N'Thẻ chưa được cấp dự án'
                Else pu.projectName
            END as projectName,
              CardTypeName = IIF(cs.IsDaily = 1, N'Thẻ lượt', c.CardTypeName),
              a.LotNumber,
              SysDate = CONVERT(varchar(10), a.SysDate, 103) + N' ' + CONVERT(varchar(8), a.SysDate, 108) -- dd/MM/yyyy HH:mm:ss
        FROM
            dbo.MAS_CardBase AS a
            LEFT JOIN dbo.UserProject AS up ON up.projectCd = a.ProjectCode AND up.userId    = @UserId
            LEFT JOIN MAS_Projects p on p.projectCd = a.ProjectCode
            LEFT JOIN MAS_Cards cs on a.Code = cs.CardCd
            LEFT JOIN MAS_CardTypes c on ISNULL(a.[Type], cs.CardTypeId) = c.CardTypeId
            LEFT JOIN MAS_Projects pu on pu.projectCd = ISNULL(cs.ProjectCd, a.ProjectCode)
        WHERE --a.ProjectCode = @project_code 
            (@project_code is null
                                  OR ((a.ProjectCode IS NOT NULL AND a.ProjectCode = @project_code) OR (cs.ProjectCd IS NOT NULL AND cs.ProjectCd = @project_code))
                                  OR (a.ProjectCode IS NULL AND cs.ProjectCd IS NULL))
            AND (@filter = N''
                OR a.Code LIKE N'%'+@filter+'%'
                OR a.Card_Num LIKE N'%'+@filter+'%'
                OR a.Code LIKE N'%'+@filter+'%'
                OR EXISTS (SELECT 1 FROM #ft f WHERE a.LotNumber LIKE f.ft + '%'))
            AND (@Status = -1 OR (@Status = 1 AND (cs.CardId IS NOT NULL OR a.IsUsed = 1)) OR (@Status = 0 AND cs.CardId IS NULL AND a.IsUsed <> 1))
        ORDER BY a.Code asc
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY
        OPTION (RECOMPILE);

    ELSE
        SELECT
            cs.CardId,
            a.Guid_Cd,
            a.Card_Num,
            a.Card_Hex,
            a.Code,
--             a.IsUsed,
            IsUsed = IIF(cs.CardId IS NOT NULL AND cs.IsDaily = 1, 1, a.IsUsed),
            a.projectCode,
            --p.projectName
            CASE
                WHEN pu.projectName is null Then N'Thẻ chưa được cấp dự án'
                Else pu.projectName
            END as projectName,
            --a.[Type],
--             CASE 
--                 WHEN @status = 1 THEN (SELECT TOP 1 								
--                                           CASE 
--                                               WHEN LTRIM(RTRIM(CardTypeName)) = N'Thẻ S-Service' THEN N'Thẻ nội bộ'
--                                               WHEN LTRIM(RTRIM(CardTypeName)) = N'Thẻ khác' THEN N'Thẻ khách'
--                                               WHEN LTRIM(RTRIM(CardTypeName)) = N'Thẻ gửi xe' THEN N'Thẻ lượt'
--                                               WHEN LTRIM(RTRIM(CardTypeName)) = N'Thẻ khách hàng thân thiết' THEN N'Thông tin ẩn'	
--                                               ELSE CardTypeName
--                                           END
--                                       FROM MAS_Cards cs
--                                       JOIN MAS_CardTypes ct on cs.CardTypeId = ct.CardTypeId
--                                       WHERE CardCd = a.Code)
--                 WHEN LTRIM(RTRIM(c.CardTypeName)) = N'Thẻ S-Service' THEN N'Thẻ nội bộ'
--                 WHEN LTRIM(RTRIM(c.CardTypeName)) = N'Thẻ khác' THEN N'Thẻ khách'
--                 WHEN LTRIM(RTRIM(c.CardTypeName)) = N'Thẻ gửi xe' THEN N'Thẻ lượt'
--                 WHEN LTRIM(RTRIM(c.CardTypeName)) = N'Thẻ khách hàng thân thiết' THEN N'Thông tin ẩn'
--                 ELSE c.CardTypeName
--             END AS CardTypeName,
            CardTypeName = IIF(cs.IsDaily = 1, N'Thẻ lượt', c.CardTypeName),
            a.LotNumber,
            SysDate = CONVERT(varchar(10), a.SysDate, 103) + N' ' + CONVERT(varchar(8), a.SysDate, 108) -- dd/MM/yyyy HH:mm:ss
        FROM
            dbo.MAS_CardBase AS a WITH (READUNCOMMITTED)
            LEFT JOIN dbo.UserProject AS up ON up.projectCd = a.ProjectCode AND up.userId = @UserId
            LEFT JOIN MAS_Projects p on p.projectCd = a.ProjectCode
            LEFT JOIN MAS_Cards cs on a.Code = cs.CardCd
            LEFT JOIN MAS_CardTypes c on ISNULL(a.[Type], cs.CardTypeId) = c.CardTypeId
            LEFT JOIN MAS_Projects pu on pu.projectCd = ISNULL(cs.ProjectCd, a.ProjectCode)
        WHERE --a.ProjectCode = @project_code 
            (@project_code is null
                                  OR ((a.ProjectCode IS NOT NULL AND a.ProjectCode = @project_code) OR (cs.ProjectCd IS NOT NULL AND cs.ProjectCd = @project_code))
                                  OR (a.ProjectCode IS NULL AND cs.ProjectCd IS NULL))
            AND (@filter = N''
                OR a.Code LIKE N'%'+@filter+'%'
                OR a.Card_Num LIKE N'%'+@filter+'%'
                OR a.Code LIKE N'%'+@filter+'%'
                OR EXISTS (SELECT 1 FROM #ft f WHERE a.LotNumber LIKE f.ft + '%'))
--             AND (@Status = -1 OR a.IsUsed = @Status)
            AND (@Status = -1 OR (@Status = 1 AND cs.CardId IS NOT NULL) OR (@Status = 0 AND cs.CardId IS NULL AND a.IsUsed <> 1))
            AND EXISTS (SELECT 1 FROM #ct c WHERE TRY_CAST(a.Code AS BIGINT) = TRY_CAST(c.ct AS BIGINT))
        ORDER BY a.Code asc
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY
        OPTION (RECOMPILE);

END TRY
BEGIN CATCH
    DECLARE @ErrorNum  INT,
            @ErrorMsg  VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo  VARCHAR(MAX);

    SET @ErrorNum  = ERROR_NUMBER();
    SET @ErrorMsg  = 'sp_res_card_base_page ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo  = ' ';

    EXEC dbo.utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Mas_CardBase', 'GET', @SessionID, @AddlInfo;
END CATCH