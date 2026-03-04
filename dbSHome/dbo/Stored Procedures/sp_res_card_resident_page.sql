CREATE PROCEDURE [dbo].[sp_res_card_resident_page] 
	  @UserId UNIQUEIDENTIFIER
    , @clientId NVARCHAR(50) = null
    , @projectCd NVARCHAR(50)
    , @filter NVARCHAR(30)
    , @apartmentId NVARCHAR(30) = NULL
    , @apartOid UNIQUEIDENTIFIER = NULL
    , @cardOid UNIQUEIDENTIFIER = NULL
    , @Statuses INT = NULL
    , @vehicle INT = NULL
    , @isVehicle INT = - 1
    , @gridWidth			int				= 0
    , @Offset INT = 0
    , @PageSize INT = 10
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    IF @apartOid IS NOT NULL
        SET @apartmentId = CONVERT(NVARCHAR(30), (SELECT ApartmentId FROM MAS_Apartments WHERE oid = @apartOid));

	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_resident_card_page'

    IF @filter = ''
        SET @filter = NULL

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    --SET @RoomCd = ISNULL(@RoomCd, '');
    SET @isVehicle = ISNULL(@isVehicle, - 1);
	--DECLARE @temp NVARCHAR(500)

    IF @PageSize = 0
        SET @PageSize = 10;

    IF @Offset < 0
        SET @Offset = 0;

	--Bảng tạm để lọc nhiều kq
		SET NOCOUNT ON;
		DROP TABLE IF EXISTS #kw;
		CREATE TABLE #kw (kw NVARCHAR(4000) NOT NULL);

		INSERT INTO #kw(kw)
		SELECT TRIM(value)
		FROM STRING_SPLIT(@filter, ',')
		WHERE TRIM(value) <> '';
	---

	SELECT @Total = COUNT(a.CardId)
    FROM MAS_Apartments c
    JOIN [MAS_Cards] a
        ON a.ApartmentId = c.ApartmentId
    LEFT JOIN MAS_Customers b ON a.CustId = b.CustId
    WHERE (@ProjectCd ='-1' or c.projectCd = @ProjectCd) 
		and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
	AND a.CardTypeId <= 3
        AND (
            (
                @Statuses IS NULL
                OR @Statuses = - 1
                )
            OR a.Card_St = @Statuses
            )
        AND (
            (@isVehicle = - 1)
            OR (
                @isVehicle = 0
                AND NOT EXISTS (
                    SELECT CardVehicleId
                    FROM MAS_CardVehicle
                    WHERE CardId = a.CardId
                        AND [Status] < 3
                    )
                )
            OR (
                @isVehicle = 1
                AND EXISTS (
                    SELECT CardVehicleId
                    FROM MAS_CardVehicle
                    WHERE CardId = a.CardId
                        AND [Status] < 3
                    )
                )
            )
        AND (
            @apartmentId is null
            OR a.ApartmentId = @apartmentId
            )
        AND (
			@filter IS NULL
			OR EXISTS (
				SELECT 1
				FROM #kw k
				WHERE a.CardCd LIKE k.kw + '%'
				)
			)
	--root	
	select recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1
	IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
    END;

-- Lấy danh sách dự án được phân quyền bên trang cấu hình config
	
    --1
    SELECT [CardCd]
        , CONVERT(NVARCHAR(10), a.[IssueDate], 103) [IssueDate]
        , CONVERT(NVARCHAR(10), a.[ExpireDate], 103) [ExpireDate]
        , a.CustId AS CifNo
        , a.CustId
        , a.[CardTypeId]
        , pp.CardTypeImg AS [ImageUrl]
        , b.FullName
        , s.[StatusNameLable] as StatusName
        , a.Card_St AS [Status]
        , c.RoomCode
        , a.ApartmentId
        , cb.Card_Hex AS cardHex
        , CASE 
            WHEN COUNT(vh.CardVehicleId) > 0
                THEN 1
            ELSE 0
            END AS IsVehicle
        , CASE 
            WHEN COUNT(vh.CardVehicleId) > 0
                THEN 'Có'
            ELSE 'Không'
            END AS IsVehicleName
        , p.projectName
    FROM [MAS_Cards] a
    JOIN [MAS_Apartments] c ON a.ApartmentId = c.ApartmentId
	JOIN MAS_Projects p ON c.projectCd = p.projectCd
    JOIN MAS_CardBase cb ON a.CardCd = cb.Code
    JOIN MAS_Customers b ON a.CustId = b.CustId
    JOIN MAS_CardStatus s ON a.Card_St = s.StatusId
    JOIN MAS_CardTypes pp ON a.[CardTypeId] = pp.[CardTypeId]
    LEFT JOIN MAS_CardVehicle vh ON a.CardId = vh.CardId AND vh.[Status] < 3
    WHERE (@ProjectCd ='-1' or c.projectCd = @ProjectCd) 
			and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
		AND a.CardTypeId <= 3
        AND (
            (
                @Statuses IS NULL
                OR @Statuses = - 1
                )
            OR a.Card_St = @Statuses
            )
        AND (
            (@isVehicle = - 1)
            OR (
                @isVehicle = 0
                AND NOT EXISTS (
                    SELECT CardVehicleId
                    FROM MAS_CardVehicle
                    WHERE CardId = a.CardId
                        AND [Status] < 3
                    )
                )
            OR (
                @isVehicle = 1
                AND EXISTS (
                    SELECT CardVehicleId
                    FROM MAS_CardVehicle
                    WHERE CardId = a.CardId
                        AND [Status] < 3
                    )
                )
            )
        AND (
            @apartmentId is null
            OR a.ApartmentId = @apartmentId
            )
        AND (
			@filter IS NULL
			OR EXISTS (
				SELECT 1
				FROM #kw k
				WHERE a.CardCd LIKE k.kw + '%'
				)
			)
    GROUP BY [CardCd]
        , CONVERT(NVARCHAR(10), a.[IssueDate], 103)
        , CONVERT(NVARCHAR(10), a.[ExpireDate], 103)
        , a.CustId
        , a.CustId
        , a.[CardTypeId]
        , pp.CardTypeImg
        , b.FullName
        , s.[StatusNameLable] 
        , a.Card_St
        , c.RoomCode
        , a.ApartmentId
        , cb.Card_Hex
        , p.projectName
    ORDER BY c.RoomCode
        , a.[CardCd] OFFSET @Offset ROWS

    FETCH NEXT @PageSize ROWS ONLY;
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_resident_card_get ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'Register card'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;