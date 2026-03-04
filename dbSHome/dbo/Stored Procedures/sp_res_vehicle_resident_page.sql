CREATE   PROCEDURE [dbo].[sp_res_vehicle_resident_page]
    @UserId UNIQUEIDENTIFIER,
    @clientId NVARCHAR(50) = null,
    @projectCd NVARCHAR(30) = null,
    @cardCd NVARCHAR(30) = null,
    @filter NVARCHAR(30) = null,
    @Statuses INT = NULL,
    @VehicleTypeId INT = -1,
    @IsFilterDate INT = 0,
    @EndDate NVARCHAR(20) = NULL,
    @gridWidth			int				= 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    declare @Total		bigint
    declare @GridKey	nvarchar(100) = 'view_resident_vehicle_page'

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');
    SET @projectCd = ISNULL(@projectCd, '');
    SET @VehicleTypeId = ISNULL(@VehicleTypeId, -1);
    
    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;
		
    select	 @Total	= count(a.CardVehicleId)
    FROM
        MAS_CardVehicle AS a 
        JOIN MAS_Apartments AS e ON a.ApartmentId = e.ApartmentId 
        --join @tbCats t on e.projectCd = t.categoryCd 
        JOIN MAS_Customers AS c ON a.CustId = c.CustId 
        left JOIN MAS_Cards AS b ON a.CardId = b.CardId 
      --left join MAS_CardVehicle_H ah on a.CardVehicleId = ah.CardVehicleId
    WHERE
        (@VehicleTypeId = -1 or a.VehicleTypeId = @VehicleTypeId)
        and ((@Statuses is null or @Statuses = -1) or case when a.[Status] = 1 and dateadd(day,1,a.EndTime) < getdate() then 2 else a.[Status] end = @Statuses) --in (select Id from @tbIsUse)
        and ((b.CardTypeId = 1 or b.CardTypeId = 3))
        AND e.projectCd = @projectCd
        and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = e.projectCd)
        and (@filter = '' or b.CardCd =  @filter or e.RoomCode =  @filter
            or c.Phone =  @filter or b.CardCd like '%' + @filter + '%' 
            or a.VehicleNo like '%' + @filter + '%')
        and (@IsFilterDate = 0 or a.EndTime <= convert(datetime,@EndDate,103))

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
    END;
    
    
    -- Data
    SELECT
        a.CardVehicleId
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
                , EditName = COALESCE(editMas.FullName, uEdit.fullName, '')
        , CONVERT(NVARCHAR(10), a.Edit_Dt, 103) AS EditDate
        , AuthName = COALESCE(mkr.FullName, uMkr.fullName, '')
        , CONVERT(NVARCHAR(10), a.Mkr_Dt, 103) AS AuthDate
				,case when a.[Status] = 1 and dateadd(day,1,a.EndTime) < getdate() then 2 else a.[Status] end as [Status]
				--,case when a.[Status] = 1 and dateadd(day,1,a.EndTime) < getdate() then N'<span class="bg-dark noti-number ml5">Quá hạn</span>' 
				--	ELSE s.StatusNameLable
				--END as StatusNameLabel
                , s.StatusNameLable as StatusNameLabel
				,case when a.[Status] < 2 then 0 else 1 end as IsLock
				,k.CardTypeName 
				,isnull(mkr.FullName,'') + ' / '+ isnull(aut.FullName,'')  as CreateByName,
        CancelDate = FORMAT(cc.CancelDate, 'dd/MM/yyyy')
				--,isnull(mkt.UserLogin,'') + '/[' + convert(nvarchar(20),format(ah.SaveDate,'dd/MM/yyyy')) + ']' as DeleteBy 
    FROM  MAS_CardVehicle AS a 
				JOIN MAS_Apartments AS e ON a.ApartmentId = e.ApartmentId 
				--join @tbCats t on e.projectCd = t.categoryCd 
				join MAS_VehicleStatus s on a.[Status] = s.StatusId
				JOIN MAS_Customers AS c ON a.CustId = c.CustId 
				JOIN MAS_VehicleTypes g ON a.VehicleTypeId = g.VehicleTypeId
        left JOIN MAS_Cards AS b ON a.CardId = b.CardId 
				LEFT JOIN [MAS_CardTypes] k On b.CardTypeId = k.CardTypeId
				LEFT JOIN MAS_Users mkr       ON a.Mkr_Id  = mkr.UserId
        LEFT JOIN dbo.Users  uMkr     ON uMkr.userId = a.Mkr_Id
        LEFT JOIN MAS_Users editMas   ON a.Edit_Id = editMas.UserId
        LEFT JOIN dbo.Users  uEdit    ON uEdit.userId = a.Edit_Id
        LEFT JOIN MAS_Users aut       ON a.Auth_id = aut.userId
        LEFT JOIN mas_cancel_vehicle_card cc ON cc.CardVehicleId = a.CardVehicleId
    WHERE ((b.CardTypeId = 1 or b.CardTypeId = 3))
				and ((@Statuses is null or @Statuses = -1 ) or case when a.[Status] = 1 and dateadd(day,1,a.EndTime) < getdate() then 2 else a.[Status] end = @Statuses) --in (select Id from @tbIsUse)
                and e.projectCd = @projectCd
				and (@filter = '' or b.CardCd =  @filter or e.RoomCode =  @filter
            or c.Phone =  @filter or b.CardCd like '%' + @filter + '%' 
            or a.VehicleNo like '%' + @filter + '%')
				AND (@VehicleTypeId = -1 or a.VehicleTypeId = @VehicleTypeId)
                and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = e.projectCd)
                and (@IsFilterDate = 0 or a.EndTime <= convert(datetime,@EndDate,103))
		ORDER BY b.CardCd, a.CardVehicleId offset @Offset rows 
    fetch next @PageSize rows only

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_vehicle_resident_page' + ERROR_MESSAGE();
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