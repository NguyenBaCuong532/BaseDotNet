
CREATE   PROCEDURE [dbo].[sp_res_card_vehicle_page] 
      @UserId UNIQUEIDENTIFIER
    , @clientId NVARCHAR(50) = null
    , @ProjectCd NVARCHAR(30)
    , @filter NVARCHAR(30)
    , @Status INT = NULL
    , @VehicleTypeId INT = - 1
    , @PartnerId INT = - 1
    , @dateFilter INT = 0
    , @endDate NVARCHAR(20) = NULL
    , @gridWidth INT = 0
    , @Offset INT = 0
    , @PageSize INT = 10
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
 
AS
BEGIN TRY
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_card_vehicle_page'

    SET @Offset = isnull(@Offset, 0)
    SET @PageSize = isnull(@PageSize, 10)
    SET @Total = isnull(@Total, 0)
    SET @filter = isnull(@filter, '')
    SET @Status = isnull(@Status, - 1)
    SET @VehicleTypeId = isnull(@VehicleTypeId, - 1)
    SET @Status = ISNULL(@Status, -1)
    SET @PartnerId = ISNULL(@PartnerId, -1)
	--set		@GridKey				= 'view_card_vehicle_page'

    IF @PageSize <= 0
    BEGIN
        SET @PageSize = 10
    END
	DECLARE @tbIsUse TABLE (Id [Int] NULL)

    IF @Status IS NULL
        OR @Status = - 1
        INSERT INTO @tbIsUse (Id)
        SELECT [StatusId]
        FROM [MAS_VehicleStatus]
    ELSE
    BEGIN
        INSERT INTO @tbIsUse (Id)
        SELECT @Status
    END

    SELECT @Total = count(b.CardId)
    FROM MAS_CardVehicle b
    --JOIN @tbCats ca ON ca.categoryCd = b.ProjectCd
    JOIN MAS_Customers c ON b.CustId = c.CustId
    JOIN MAS_VehicleTypes d ON b.VehicleTypeId = d.VehicleTypeId
    JOIN MAS_VehicleStatus s ON b.[Status] = s.StatusId
    JOIN MAS_Projects p ON b.ProjectCd = p.ProjectCd
    LEFT JOIN [dbo].[MAS_Cards] a ON b.CardId = a.CardId
    LEFT JOIN Users mkr ON b.Mkr_Id = mkr.UserId
    LEFT JOIN Users aut ON b.Auth_id = aut.UserId
    WHERE b.[monthlyType] = 2
	AND (@ProjectCd ='-1' or b.projectCd = @ProjectCd) 
    and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
    AND (
        @VehicleTypeId = - 1
        OR b.VehicleTypeId = @VehicleTypeId
        )
    AND (
        b.VehicleNo LIKE '%' + @filter + '%'
        OR c.Phone LIKE '%' + @filter + '%'
        OR c.FullName LIKE '%' + @filter + '%'
        OR a.CardCd LIKE '%' + @filter + '%'
        )
    AND CASE 
        WHEN b.[Status] = 1
            AND dateadd(day, 1, b.EndTime) < getdate()
            THEN 2
        ELSE b.[Status]
        END IN (
        SELECT Id
        FROM @tbIsUse
        )
    AND (
        @dateFilter = 0
        OR b.EndTime <= convert(DATETIME, @endDate, 103)
        )
    AND (
        @PartnerId = - 1
        OR EXISTS (
            SELECT 1
            FROM MAS_Cards
            WHERE cardid = b.CardId
                AND partner_id = @PartnerId
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
        FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
        ORDER BY [ordinal];
    END

    

    --1
    SELECT b.CardVehicleId
        , convert(NVARCHAR(10), a.[IssueDate], 103) [IssueDate]
        , c.FullName
        , b.VehicleNo
        , b.VehicleName
        , c.Phone
        , convert(NVARCHAR(10), dateadd(day, 1, b.EndTime), 103) AS StartTimeRen
        , convert(NVARCHAR(10), b.StartTime, 103) AS StartTime
        , convert(NVARCHAR(10), b.EndTime, 103) AS EndTime
        , a.CardName AS CardTypeName
        , a.CardCd
        , b.CustId
        , d.VehicleTypeName
        , CASE 
            WHEN b.[Status] = 1
                AND dateadd(day, 1, b.EndTime) < getdate()
                THEN 2
            ELSE b.[Status]
            END AS [Status]
        , CASE 
            WHEN b.[Status] < 3
                AND dateadd(day, 1, b.EndTime) < getdate()
                THEN N'Quá hạn TT'
            ELSE s.StatusName
            END AS StatusName
        , CASE 
            WHEN b.[Status] < 2
                THEN 0
            ELSE 1
            END AS IsLock
        , b.AssignDate
        , b.VehicleTypeId
        , isnull(p.ProjectName, N'Tất cả các dự án') AS ProjectName
        , isnull(mkr.loginName, '') + '/' + isnull(aut.loginName, '') AS CreateByName
		,cp.partner_name
    FROM MAS_CardVehicle b
    --JOIN @tbCats ca ON ca.categoryCd = b.ProjectCd
    JOIN MAS_Customers c ON b.CustId = c.CustId
    JOIN MAS_VehicleTypes d ON b.VehicleTypeId = d.VehicleTypeId
    JOIN MAS_VehicleStatus s ON b.[Status] = s.StatusId
    JOIN MAS_Projects p ON b.ProjectCd = p.ProjectCd
    LEFT JOIN [dbo].[MAS_Cards] a ON b.CardId = a.CardId
	LEFT JOIN MAS_CardPartner cp ON a.partner_id = cp.partner_id
	LEFT JOIN dbo.Users mkr ON b.Mkr_Id = mkr.UserId
    LEFT JOIN dbo.Users aut ON b.Auth_id = aut.UserId

    WHERE b.[monthlyType] = 2
		AND (@ProjectCd ='-1' or b.projectCd = @ProjectCd) 
		and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
        AND (
            @VehicleTypeId = - 1
            OR b.VehicleTypeId = @VehicleTypeId
            )
        AND (
            b.VehicleNo LIKE '%' + @filter + '%'
            OR c.Phone LIKE '%' + @filter + '%'
            OR c.FullName LIKE '%' + @filter + '%'
            OR a.CardCd LIKE '%' + @filter + '%'
            )
        AND CASE 
            WHEN b.[Status] = 1
                AND dateadd(day, 1, b.EndTime) < getdate()
                THEN 2
            ELSE b.[Status]
            END IN (
            SELECT Id
            FROM @tbIsUse
            )
        AND (
            @dateFilter = 0
            OR b.EndTime <= convert(DATETIME, @endDate, 103)
            )
        AND (
            @PartnerId = - 1
            OR EXISTS (
                SELECT 1
                FROM MAS_Cards
                WHERE cardid = b.CardId
                    AND partner_id = @PartnerId
                )
            )
    ORDER BY b.AssignDate DESC offset @Offset rows

    FETCH NEXT @PageSize rows ONLY
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_card_vehicle_page ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'CardVehicle'
        , 'GET'
        , @SessionID
        , @AddlInfo
END CATCH