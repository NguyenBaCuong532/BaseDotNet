CREATE   PROCEDURE [dbo].[sp_res_apartment_service_cut_history_page]
    @userId UNIQUEIDENTIFIER,
    @filter NVARCHAR(30) = NULL,
    @ApartmentId INT,
    @gridWidth int = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    declare @Total		bigint
    declare @GridKey	nvarchar(100) = 'view_apartment_service_cut_history_page'

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

    if @ApartmentId is null or @ApartmentId = 0
    set @ApartmentId = (
        SELECT top 1 c.ApartmentId
        FROM UserInfo a inner join MAS_Apartments c on a.loginName = c.UserLogin
        WHERE a.UserId = @UserID
    )

    IF @PageSize = 0 SET @PageSize = 10;
    IF @Offset < 0 SET @Offset = 0;

    SELECT @Total = COUNT(1)
    FROM MAS_Service_Cut_History a
        JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
    WHERE a.ApartmentId = @ApartmentId

    --root	
    select recordsTotal = @Total
          ,recordsFiltered = @Total
          ,gridKey = @GridKey
          ,valid = 1
          
    --grid config
    IF @Offset = 0
        SELECT * FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage) ORDER BY [ordinal];

    -- Data
    SELECT
        a.*,
        cd1.par_desc CutType,
        CONVERT(VARCHAR(10), CutStartDate, 103) + ' ' + LEFT(CONVERT(VARCHAR(8), CutStartDate, 108), 5) AS CutStartDate ,
        CONVERT(VARCHAR(10), CutEndDate, 103) + ' ' + LEFT(CONVERT(VARCHAR(8), CutEndDate, 108), 5) AS CutEndDate        
    FROM MAS_Service_Cut_History a
        JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
		LEFT JOIN dbo.sys_config_data cd1 ON cd1.key_1 ='cut_type' and a.CutType = cd1.value2
    WHERE a.ApartmentId = @ApartmentId
    ORDER BY a.SysDate OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_service_cut_history_page' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_service_cut_history',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;