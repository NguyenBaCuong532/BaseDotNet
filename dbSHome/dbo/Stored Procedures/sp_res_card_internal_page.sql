

CREATE procedure [dbo].[sp_res_card_internal_page]
    @UserId            UNIQUEIDENTIFIER,
    @orgid             uniqueidentifier = null,
    @filter            nvarchar(30) = null,
    @status				int = null,
    @projectCd			nvarchar(50) = null,
    @GridWidth         int = 0,
    @Offset            int = 0,
    @PageSize          int = 10,
    @acceptLanguage    NVARCHAR(50) = N'vi-VN'
    --@Total             int out,
    --@TotalFiltered     int out,
    --@GridKey           nvarchar(100) out
AS
BEGIN TRY
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_hrm_employees_card_page';

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = RTRIM(LTRIM(ISNULL(@filter, '')));
    SET @status = ISNULL(@status, -1);

    IF @PageSize <= 0 SET @PageSize = 10;
    IF @Offset < 0 SET @Offset = 0;
    

    SELECT @Total = COUNT(hc.CardId)
    FROM MAS_Cards hc 
		INNER JOIN mas_employee e ON e.CustId = hc.CustId AND hc.CardTypeId <> 1
    WHERE (@filter = '' OR hc.CardCd LIKE '%' + @filter + '%' OR e.Phone LIKE @filter + '%' OR e.fullName LIKE '%' + @filter + '%' OR e.code LIKE '%' + @filter + '%')

    --root	
	select recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1

    IF @Offset = 0
    BEGIN
        SELECT * FROM dbo.fn_config_list_gets_lang(@GridKey, @GridWidth, @acceptLanguage);
    END

    SELECT hc.[cardCd]
        , CONVERT(NVARCHAR(10), hc.[IssueDate], 103) [issueDate]
        , [statusName] = s.StatusNameLable
        , hc.Card_St AS [status]
        , e.fullName
        , hc.isClose 
        , closeDate = FORMAT(hc.CloseDate, 'dd/MM/yyyy hh:mm:ss tt')
        , e.phone
        , e.email
        , positionTypeName
        , hc.cardName
        , hc.custId
        , departmentName
        --, COUNT(vh.CustId) AS countVehicle
        , created_by = Users.fullName
        , orgName 
        , workplaceName = p.projectName
        , CONVERT(NVARCHAR(10), hc.ExpireDate, 103) [ExpireDate]
        , e.empId
    FROM mas_Cards hc 
	JOIN MAS_CardStatus s ON hc.Card_St = s.StatusId
    INNER JOIN mas_employee e ON e.CustId = hc.CustId AND hc.CardTypeId <> 1
    LEFT JOIN Users ON Users.userId = hc.created_by
    LEFT JOIN MAS_Projects p ON hc.ProjectCd = p.projectCd
    WHERE (@filter = '' OR hc.CardCd LIKE '%' + @filter + '%' OR e.Phone LIKE @filter + '%' OR e.fullName LIKE '%' + @filter + '%' OR e.code LIKE '%' + @filter + '%')
		ORDER BY CardCd
			OFFSET @Offset ROWS
			FETCH NEXT @PageSize ROWS ONLY

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_internal_page ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_res_card_internal_page', 'GET', @SessionID, @AddlInfo;
END CATCH;