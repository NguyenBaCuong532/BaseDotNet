
CREATE PROCEDURE [dbo].[sp_res_apartment_household_page]
    @userId UNIQUEIDENTIFIER,
    @filter NVARCHAR(30) = NULL,
	@ApartmentId INT ,

    @Offset INT = 0,
    @PageSize INT = 10,
 --   @Total INT = 0 OUT,
 --   @TotalFiltered INT = 0 OUT,
	--@GridKey		nvarchar(100) out
	@gridWidth				int = 0,
    @acceptLanguage			NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_apartment_household_page'

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

	if @ApartmentId is null or @ApartmentId = 0
		set @ApartmentId = (SELECT top 1 c.ApartmentId FROM UserInfo a 
		inner join MAS_Apartments c on a.loginName = c.UserLogin 
		 WHERE a.UserId = @UserID)

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    SELECT @Total = COUNT(a.CustId )
	  FROM [MAS_Customers] a 
		left join [MAS_Customer_Household] b ON a.CustId = b.CustId
		join MAS_Apartment_Member c on a.CustId = c.CustId 
		left join MAS_Customer_Relation d on c.RelationId = d.RelationId 
	WHERE EXISTS(SELECT [ApartmentId] FROM MAS_Apartment_Member WHERE CustId = a.CustId AND ApartmentId = @ApartmentId)
		and c.ApartmentId = @ApartmentId


    --root	
	select recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1
    --grid config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];

    END;
    -- Data
    SELECT a.CustId 
		  ,a.[FullName]
		  ,case when a.[IsSex] = 1 then N'Nam' else N'Nữ' end as SexName
		  ,convert(nvarchar(10),a.birthday,103) as birthday
		  ,a.[Phone]
		  ,a.[Email]
		  ,a.[IsHost]
		  ,c.[ApartmentId]
		  ,a.[AvatarUrl]
		  ,isnull(a.IsForeign,0) as IsForeign
		  
		  ,isnull(b.[IsResident],0) IsResident
		  , CASE WHEN isnull(b.[IsResident],0) = 1 
		  THEN N'<i class="pi pi-check text-blue-500 font-bold"></i>'
		  ELSE N'<i class="pi pi-times text-red-500 font-bold"></i>'
		  END AS IsResidentName
		  ,b.[ResAdd1]
		  ,b.[ContactAdd1]
		  ,b.[Pass_No] as PassNo
		  ,convert(nvarchar(10),b.[Pass_I_Dt],103) as PassDate 
		  ,b.[Pass_I_Plc] as PassPlace
		  ,d.RelationName
	  FROM [MAS_Customers] a 
		left join [MAS_Customer_Household] b ON a.CustId = b.CustId
		join MAS_Apartment_Member c on a.CustId = c.CustId 
		left join MAS_Customer_Relation d on c.RelationId = d.RelationId 
	WHERE EXISTS(SELECT [ApartmentId] FROM MAS_Apartment_Member WHERE CustId = a.CustId AND ApartmentId = @ApartmentId)
		and c.ApartmentId = @ApartmentId
    ORDER BY [IsHost] desc, b.sysDate desc OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_household_page' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_household',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;