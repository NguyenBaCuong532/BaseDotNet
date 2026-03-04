CREATE PROCEDURE [dbo].[sp_res_card_family_page]
    @userId UNIQUEIDENTIFIER = NULL,
    @clientId nvarchar(50) = null,
    @filter NVARCHAR(30) = NULL,
    @ApartmentId INT = NULL,
    @apartOid UNIQUEIDENTIFIER = NULL,
    @gridWidth int = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @HostUrl NVARCHAR(150) = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
 --   @Total INT = 0 OUT,
 --   @TotalFiltered INT = 0 OUT,
	--@GridKey		nvarchar(100) out
AS
BEGIN TRY
    IF @apartOid IS NOT NULL
        SET @ApartmentId = (SELECT ApartmentId FROM MAS_Apartments WHERE oid = @apartOid);

	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_apartment_family_card_page'

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');
	--set		@GridKey				= 'view_apartment_family_card_page'

	if @ApartmentId is null or @ApartmentId = 0
		set @ApartmentId = (SELECT top 1 c.ApartmentId 
		FROM UserInfo a inner join MAS_Apartments c on a.loginName = c.UserLogin 
		 WHERE a.UserId = @UserID)

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    SELECT @Total = COUNT(a.[CardCd])
	  FROM  [MAS_Apartments] c
		join [MAS_Cards] a  on a.ApartmentId = c.ApartmentId
		left join MAS_Customers b On a.CustId = b.CustId 
		join MAS_CardStatus s on a.Card_St = s.StatusId
		join MAS_CardTypes pp on a.[CardTypeId] = pp.[CardTypeId]
		left join MAS_CardVehicle vh on a.CardId = vh.CardId --and vh.[Status] < 3
		left join MAS_Points p on b.CustId = p.CustId		
	  WHERE c.ApartmentId = @ApartmentId

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
    SELECT a.[CardCd]
		  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
		  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
		  ,a.CustId as CifNo
		  ,a.[CardTypeId]
		  ,pp.CardTypeName
		  ,isnull(p.CurrPoint,0) as [CurrentPoint]
		  ,[ImageUrl] = IIF(pp.CardTypeImg LIKE N'http%', pp.CardTypeImg, CONCAT(@HostUrl, pp.CardTypeImg))
		  ,b.FullName
		  ,a.Card_St as [Status]
		  ,s.StatusNameLable
		  --,case a.Card_St when 0 then N'Đang hoạt động' when 1 then N'Hết hiệu lực' when 2 then N'Đã báo mất thẻ' else N'Khóa thẻ' end [StatusName]
		  --,case Card_St when 0 then N'Đang hoạt động' when 1 then N'Hết hiệu lực' when 2 then N'Đã báo mất thẻ' else N'Khóa thẻ' end as [Status]
		  ,c.ApartmentId
		  ,b.CustId
		  --,p.CurrPoint as CurrentPoint
		  ,case when count(vh.CardVehicleId) > 0 then 1 else 0 end as IsVehicle
		  ,case when count(vh.CardVehicleId) > 0 then N'<i class="pi pi-check text-blue-500 font-bold"></i>'
		  ELSE N'<i class="pi pi-times text-red-500 font-bold"></i>' 
		  END as IsVehicleName
	  FROM 
        [MAS_Apartments] c
        join [MAS_Cards] a  on a.ApartmentId = c.ApartmentId
        left join MAS_Customers b On a.CustId = b.CustId 
        join MAS_CardStatus s on a.Card_St = s.StatusId
        join MAS_CardTypes pp on a.[CardTypeId] = pp.[CardTypeId]
        left join MAS_CardVehicle vh on a.CardId = vh.CardId --and vh.[Status] < 3
        left join MAS_Points p on b.CustId = p.CustId		
	  WHERE c.ApartmentId = @ApartmentId
	  group by
			   [CardCd]
			  ,convert(nvarchar(10),a.[IssueDate],103) 
			  ,convert(nvarchar(10),a.[ExpireDate],103) 
			  ,a.CustId 
			  ,a.CustId
			  ,a.[CardTypeId]
			  ,p.CurrPoint
			  ,pp.CardTypeImg 
			  ,b.FullName
			  ,s.[StatusNameLable]
			  ,Card_St 
			  ,c.RoomCode
			  ,a.ApartmentId
			  ,s.StatusNameLable 
			  ,pp.CardTypeName
			  ,c.ApartmentId
			  ,b.CustId
    ORDER BY a.CardCd OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_family_card_get' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_family_card',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;