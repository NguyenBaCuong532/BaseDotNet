CREATE PROCEDURE [dbo].[sp_res_card_partner_page]
    @UserId UNIQUEIDENTIFIER
    , @clientId NVARCHAR(50) = null
    , @projectCd NVARCHAR(50)
    , @filter NVARCHAR(30)
    , @gridWidth INT = 0
    , @Offset INT = 0
    , @PageSize INT = 10
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
 --   , @Total INT OUT
 --   , @TotalFiltered INT OUT
	--, @GridKey NVARCHAR(100) OUT
AS
BEGIN TRY
    declare @Total		bigint
    declare @GridKey	nvarchar(100) = 'view_Card_Partner_Page'

    SET @projectCd = isnull(@projectCd, '')

    SET @Offset = isnull(@Offset, 0)
    SET @PageSize = isnull(@PageSize, 10)
    SET @Total = isnull(@Total, 0)
    SET @filter = isnull(@filter, '')

    IF @PageSize <= 0
        SET @PageSize = 10

    IF @Offset < 0
        SET @Offset = 0

    SELECT @Total = count(a.partner_id)
    FROM
        MAS_CardPartner a
        JOIN MAS_Projects p ON a.ProjectCd = p.projectCd
    WHERE
        (partner_name LIKE '%' + @filter + '%')
        and exists(select 1 from UserProject x where x.projectCd = a.projectCd and x.userId = @userId)
        AND (TRIM(@projectCd) = '' OR p.projectCd = @projectCd)

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
    --SET @TotalFiltered = @Total

    --1
    SELECT
        a.partner_id
        , a.partner_cd
        , a.partner_name
        , a.projectCd
        , p.projectName
        , a.create_dt
        , a.create_by
        , a.update_dt
        , a.update_by
    FROM
        [dbo].MAS_CardPartner a
        JOIN MAS_Projects p ON a.ProjectCd = p.projectCd
    WHERE
        (partner_name LIKE '%' + @filter + '%')
        and exists(select 1 from UserProject x where x.projectCd = a.projectCd and x.userId = @userId)
        AND (TRIM(@projectCd) = '' OR p.projectCd = @projectCd)
    ORDER BY a.partner_name offset @Offset rows
    FETCH NEXT @PageSize rows ONLY
        --2
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_card_partner_page ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'CardPartner'
        , 'GET'
        , @SessionID
        , @AddlInfo
END CATCH