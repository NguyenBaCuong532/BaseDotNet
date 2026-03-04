
CREATE PROCEDURE [dbo].[sp_res_resident_vehicle_page]
    @UserId UNIQUEIDENTIFIER,
    @clientId NVARCHAR(50) = null,
    @ProjectCd NVARCHAR(30),
    @filter NVARCHAR(30),
    @Statuses INT = NULL,
    @VehicleTypeId INT = -1,
    @DateFilter INT = 0,
    @EndDate NVARCHAR(20) = NULL,
	@gridWidth			int				= 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
 --   @Total INT = 0 OUT,
 --   @TotalFiltered INT = 0 OUT,
	--@GridKey		nvarchar(200) out,
AS
BEGIN TRY
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_resident_vehicle_page'

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');
    SET @ProjectCd = ISNULL(@ProjectCd, '');
    SET @VehicleTypeId = ISNULL(@VehicleTypeId, -1);

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;
		
    select	 @Total	= count(a.CardVehicleId)
			FROM MAS_CardVehicle AS a 
				JOIN MAS_Apartments AS e ON a.ApartmentId = e.ApartmentId 
				--join @tbCats t on e.projectCd = t.categoryCd 
                JOIN MAS_Customers AS c ON a.CustId = c.CustId 
				left JOIN MAS_Cards AS b ON a.CardId = b.CardId 
				--left join MAS_CardVehicle_H ah on a.CardVehicleId = ah.CardVehicleId
			WHERE (@VehicleTypeId = -1 or a.VehicleTypeId = @VehicleTypeId)
				and ((@Statuses is null or @Statuses = -1) or case when a.[Status] = 1 and dateadd(day,1,a.EndTime) < getdate() then 2 else a.[Status] end = @Statuses) --in (select Id from @tbIsUse)
				and ((b.CardTypeId = 1 or b.CardTypeId = 3))
				AND (@ProjectCd ='-1' or e.projectCd = @ProjectCd) 
			    and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
				and (@filter = '' or CardCd =  @filter or e.RoomCode =  @filter
					or c.Phone =  @filter or b.CardCd like '%' + @filter + '%' 
					or a.VehicleNo like '%' + @filter + '%')
				and (@DateFilter = 0 or a.EndTime <= convert(datetime,@EndDate,103))

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
    
	SELECT   a.CardVehicleId
				,a.AssignDate
				,a.VehicleNo
				,a.VehicleTypeId
				,a.VehicleName
				,convert(nvarchar(10),dateadd(day,1,a.EndTime),103) as StartTimeRen
				,convert(nvarchar(10),a.StartTime,103) as StartTime
				,convert(nvarchar(10),a.EndTime,103) as EndTime
				,b.CardCd
				,c.FullName
				,c.Phone
				,e.RoomCode
				,g.VehicleTypeName
				,case when a.[Status] = 1 and dateadd(day,1,a.EndTime) < getdate() then 2 else a.[Status] end as [Status]
				,case when a.[Status] = 1 and dateadd(day,1,a.EndTime) < getdate() then N'<span class="bg-dark noti-number ml5">Quá hạn</span>' 
					ELSE s.StatusNameLable
				END as StatusName
				,case when a.[Status] < 2 then 0 else 1 end as IsLock
				,k.CardTypeName 
				,isnull(mkr.loginName,'') + '/'+isnull(aut.loginName,'')  as CreateByName
				--,isnull(mkt.UserLogin,'') + '/[' + convert(nvarchar(20),format(ah.SaveDate,'dd/MM/yyyy')) + ']' as DeleteBy 
			FROM  MAS_CardVehicle AS a 
				JOIN MAS_Apartments AS e ON a.ApartmentId = e.ApartmentId 
				--join @tbCats t on e.projectCd = t.categoryCd 
				join MAS_VehicleStatus s on a.[Status] = s.StatusId
				JOIN MAS_Customers AS c ON a.CustId = c.CustId 
				JOIN MAS_VehicleTypes g ON a.VehicleTypeId = g.VehicleTypeId
                left JOIN MAS_Cards AS b ON a.CardId = b.CardId 
				LEFT JOIN [MAS_CardTypes] k On b.CardTypeId = k.CardTypeId
				left join dbo.Users mkr on a.Mkr_Id = mkr.UserId
				LEFT JOIN dbo.Users aut ON a.Auth_id = aut.userId
			WHERE (@VehicleTypeId = -1 or a.VehicleTypeId = @VehicleTypeId)
				and ((@Statuses is null or @Statuses = -1 ) or case when a.[Status] = 1 and dateadd(day,1,a.EndTime) < getdate() then 2 else a.[Status] end = @Statuses) --in (select Id from @tbIsUse)
				and ((b.CardTypeId = 1 or b.CardTypeId = 3))
				and (@filter = '' or CardCd =  @filter or e.RoomCode =  @filter
					or c.Phone =  @filter or b.CardCd like '%' + @filter + '%' 
					or a.VehicleNo like '%' + @filter + '%')
				AND (@ProjectCd ='-1' or e.projectCd = @ProjectCd) 
				and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
				and (@DateFilter = 0 or a.EndTime <= convert(datetime,@EndDate,103))
		ORDER BY [CardCd] offset @Offset rows	
			fetch next @PageSize rows only
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_resident_vehicle_get' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'resident_vehicle',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;