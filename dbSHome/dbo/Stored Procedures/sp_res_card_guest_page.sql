CREATE PROCEDURE [dbo].[sp_res_card_guest_page]
      @UserId UNIQUEIDENTIFIER
    , @clientId NVARCHAR(50) = null
    , @projectCd NVARCHAR(50)
    , @partner_id INT = - 1
    , @filter NVARCHAR(50) = NULL
    , @Statuses INT = NULL
    , @gridWidth          int = 0
    , @Offset INT = 0
    , @PageSize INT = 10
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_card_guest_page'
    SET @Offset = isnull(@Offset, 0)
    SET @PageSize = isnull(@PageSize, 10)
    SET @Total = isnull(@Total, 0)
    SET @filter = isnull(@filter, '')
    SET @Statuses = isnull(@Statuses, - 1)
    SET @projectCd = ISNULL(@projectCd, '')

    IF @PageSize = 0
        SET @PageSize = 10
    

    SELECT @Total = count(a.CardId)
    FROM
        [MAS_Cards] a
        JOIN MAS_Customers c ON a.CustId = c.CustId
    WHERE
        (TRIM(@ProjectCd) = '' or a.projectCd = @ProjectCd) 
        and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
        AND a.IsGuest = 1
        AND (@Statuses = - 1 OR Card_St = @Statuses)
        AND (@partner_id = - 1 OR a.partner_id = @partner_id)
        AND (CardCd LIKE '%' + @filter + '%' OR c.Phone LIKE '%' + @filter + '%' OR c.FullName LIKE '%' + @filter + '%')

    --root	
	select
      recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1
      
	--grid config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
    END
    --1
    SELECT
    distinct
        a.[cardCd]
        , a.cardId
        , format(a.[IssueDate], 'dd/MM/yyyy hh:mm:ss') AS [issueDate]
        , format(a.[ExpireDate], 'dd/MM/yyyy hh:mm:ss') AS [expireDate]
        , s.[StatusName]
        , a.Card_St AS [status]
        , c.FullName AS custName
        , a.isClose
        , a.closeDate
        , c.Phone AS custPhone
        , c.email
        , a.cardName
        , a.CustId
        , CASE 
            WHEN EXISTS (
                    SELECT CardId
                    FROM MAS_CardVehicle
                    WHERE cardid = a.CardId
                    )
                THEN 1
            ELSE 0
          END isVehicle
        , p.projectName
        , a.projectCd
        , d.partner_name
        , a.partner_id
    FROM
        [dbo].[MAS_Cards] a
        CROSS APPLY (
            SELECT LTRIM(RTRIM(part)) AS projectId 
            FROM SplitString(a.projectCd, ',')
        ) x
        JOIN MAS_Customers c ON a.CustId = c.CustId
        JOIN MAS_CardStatus s ON a.Card_St = s.StatusId
        JOIN MAS_Projects p ON p.projectCd = x.projectId -- sửa ở đây --a.ProjectCd = p.projectCd
        LEFT JOIN MAS_CardPartner d ON a.partner_id = d.partner_id
    WHERE
        (TRIM(@ProjectCd) = '' OR x.projectId = @ProjectCd)
        and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
        AND a.IsGuest = 1
        AND (@Statuses = - 1 OR Card_St = @Statuses)
        AND (@partner_id = - 1 OR a.partner_id = @partner_id)
        AND (CardCd LIKE '%' + @filter + '%' OR c.Phone LIKE '%' + @filter + '%' OR c.FullName LIKE '%' + @filter + '%')
    ORDER BY a.CardCd offset @Offset rows

    FETCH NEXT @PageSize rows ONLY
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_card_guest_page ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'CardGuest'
        , 'GET'
        , @SessionID
        , @AddlInfo
END CATCH