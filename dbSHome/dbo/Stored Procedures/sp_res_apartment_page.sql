CREATE procedure [dbo].[sp_res_apartment_page]
	@userId UNIQUEIDENTIFIER,
	@clientId nvarchar(50) = null,
	@acceptLanguage NVARCHAR(50) = N'vi-VN',
	@ProjectCd	nvarchar(40) = '01',
	@Received int = -1,
	@setupStatus int = -1,
	@Debt			int = -1,
	@Rent int = -1,
	@buildingCd nvarchar(30),
	@filter nvarchar(100) = '',
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10
	--@Total				int out,
	--@TotalFiltered		int OUT,
	--@GridKey		nvarchar(100) out,
as
begin try
		-- =============================================
		-- LẤY TENANT_OID TỪ USERS
		-- =============================================
		DECLARE @tenantOid UNIQUEIDENTIFIER = NULL;
		
		IF @userId IS NOT NULL
		BEGIN
			SELECT @tenantOid = tenant_oid
			FROM Users
			WHERE userId = @userId;
		END
		
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_apartment_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@buildingCd				= isnull(@buildingCd,'all')
		set		@filter					= isnull(@filter,'')
		--set		@projectCd				= isnull(@projectCd,'')
		set		@Received				= isnull(@Received,-1)
		set		@Rent					= isnull(@Rent,-1)
		set		@setupStatus			= isnull(@setupStatus,-1)

		if @PageSize	= 0
        set @PageSize	= 10
		if @Offset < 0
        set @Offset = 0

		select	@Total = count(a.[ApartmentId])
    FROM
        [MAS_Apartments] a 
        left JOIN MAS_Buildings b On a.buildingOid = b.oid
        left JOIN MAS_Elevator_Floor ef On a.floorOid = ef.oid 
        LEFT JOIN UserInfo m on a.UserLogin = m.loginName 
        LEFT JOIN MAS_Customers c ON m.CustId = c.CustId 	
    WHERE
        (@ProjectCd ='-1' or a.projectCd = @ProjectCd) 
        AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid)
        and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
        and (@buildingCd= 'all' or b.BuildingCd = @buildingCd OR a.buildingCd = @buildingCd)
        and (@Received = -1 Or IsReceived = @Received)
        and (@Rent = -1 Or IsRent = @Rent)
        --and ((@Debt is null or @Debt = -1) Or (@Debt = 0 and a.CurrBal = 0) or (@Debt = 1 and a.CurrBal > 0) or (@Debt = 2 and a.CurrBal < 0))
        and (@setupStatus = -1 
            or (@setupStatus = 0 and (a.IsReceived = 0 or a.isFeeStart = 0 or a.isFeeStart is null or not exists(select a2.LivingId
                          from MAS_Apartment_Service_Living a2
                          where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 1 )
                          or not exists(select a2.LivingId
                          from MAS_Apartment_Service_Living a2
                          where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 2 ))) 
            or (@setupStatus = 1 and (a.IsReceived = 1 and a.isFeeStart = 1 and exists(select a2.LivingId
                          from MAS_Apartment_Service_Living a2
                          where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 1 )
                          and exists(select a2.LivingId
                          from MAS_Apartment_Service_Living a2
                          where a2.ApartmentId = a.ApartmentId and a2.LivingTypeId = 2 )))
            )
      and (a.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%' or c.Phone like '%' + @filter +'%' OR a.RoomCodeView LIKE '%'+@filter+'%')
				
		--root	
		select
        recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		
    --grid config
		if @Offset = 0
		begin
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
		end
		
		--SELECT @TotalFiltered
	--1 list
		SELECT '' ProjectName
			  ,a.oid
			  --,a.id as ApartmentId
			   ,a.ApartmentId
			  ,BuildingName
			  --,a.[RoomCode]
			  ,ISNULL(a.RoomCodeView, a.[RoomCode]) AS RoomCode
			  ,a.RoomCode AS FirstRoomCode
              ,c.CustId
			  ,h.FullName FullName 
			  ,c.AvatarUrl
			  ,ISNULL(ef.FloorNumber, a.[Floor]) AS [Floor]
			  ,ISNULL(ef.FloorName, a.[floorNo]) AS floorNo
			  ,a.floorOid
			  ,a.WaterwayArea
			  ,b.ProjectCd
			  ,a.[UserLogin]
			  ,b.[BuildingCd]
			  ,a.buildingOid
			  ,[FamilyImageUrl]
			  ,MemberCount = (Select count(CustId) from MAS_Apartment_Member where apartOid = a.oid )
			  ,HouseholdCount = (select count(ch.custid) FROM [MAS_Customer_Household] ch join MAS_Apartment_Member am on ch.apartOid = am.apartOid where am.apartOid = a.oid)
			  ,CardCount = (Select count(cc.CardId) from MAS_Apartment_Card cc join MAS_Cards mc on cc.CardId = mc.CardId  where cc.apartOid = a.oid) 
			  ,c.Phone 
			  ,c.Email
			  ,isnull(IsReceived,0) as IsReceived
			  ,CASE WHEN ISNULL(IsReceived,0) = 1 
			  THEN  N'<span class="bg-primary noti-number ml5">Đã nhận</span>' 
			  ELSE N'<span class="bg-dark noti-number ml5">Chưa nhận</span>'
			  end
			  as IsReceivedName
			  ,convert(nvarchar(10),ReceiveDt,103) as ReceiveDate
			  ,isnull(IsRent,0) as IsRent
			  ,CASE WHEN ISNULL(IsRent,0) = 1 
			  THEN N'<span class="bg-info noti-number ml5">Có</span>'
			  ELSE N'<span class="bg-secondary noti-number ml5">Không</span>'
			  END AS IsRentName
			  ,isLinkApp  AS IsLinkApp
			  ,CASE WHEN isLinkApp = 1 
			  THEN N'<i class="pi pi-check text-blue-500 font-bold"></i>'
			  ELSE N'<i class="pi pi-times text-red-500 font-bold"></i>'
			  END AS IsLinkAppName
			  ,VehicleCount = (Select count(vh.CardVehicleId) 
					from MAS_CardVehicle vh --on cc.CardId = vh.CardId
					where vh.apartOid = a.oid --and cc.Card_St < 3
					) 
			  ,SetUpStatus = (case when (((select count(a1.CardVehicleId) 
											  from [dbo].[MAS_CardVehicle] a1 left join MAS_Apartment_Card ac on a1.CardId = ac.CardId 
											  where  ac.apartOid = a.oid) > 0)
										  and (select count(a2.LivingId) 
											  from MAS_Apartment_Service_Living a2
											  where a2.apartOid = a.oid )>0)
										  and (a.IsFree is not null) 	
								   then 1 else 0 end) 
			  ,ServerChargeStatus = (case when a.IsFree is not null then 1 else 0 end) 
			  ,ServerVihicleStatus = (case when ((select count(a1.CardVehicleId) 
											  from [dbo].[MAS_CardVehicle] a1 left join MAS_Apartment_Card ac on a1.CardId = ac.CardId 
											  where  ac.apartOid = a.oid) > 0)	
								   then 1 else 0 end) 
			  ,ServerLivingStatus = (case when ((select count(a2.LivingId) 
											  from MAS_Apartment_Service_Living a2
											  where a2.apartOid = a.oid )>0)	
								   then 1 else 0 end)
				,a.DebitAmt as CurrBal
				,CASE
            WHEN a.DebitAmt = 1 THEN N'<span class="bg-info noti-number ml5">Có</span>'
            ELSE N'<span class="bg-secondary noti-number ml5">Không</span>'
				END AS CurrBalName
				,isnull(c.IsForeign,0) AS IsForeign
				,CASE
            WHEN ISNULL(c.IsForeign,0) = 1 THEN N'<i class="pi pi-check text-blue-500 font-bold"></i>'
            ELSE  N'<i class="pi pi-times text-red-500 font-bold"></i>' 
				END AS IsForeignName,
        o_to = (Select count(vh.CardVehicleId) from MAS_CardVehicle vh where vh.apartOid = a.oid and VehicleTypeId=1),
        xe_may =  (Select count(vh.CardVehicleId) from MAS_CardVehicle vh where vh.apartOid = a.oid and (VehicleTypeId=3 OR VehicleTypeId=2)),
       -- xe_may_dien =  (Select count(vh.CardVehicleId) from MAS_CardVehicle vh where vh.apartOid = a.oid and VehicleTypeId=3),
        xe_dap =  (Select count(vh.CardVehicleId) from MAS_CardVehicle vh where vh.apartOid = a.oid and VehicleTypeId=5),
        xe_dap_dien =  (Select count(vh.CardVehicleId) from MAS_CardVehicle vh where vh.apartOid = a.oid and VehicleTypeId=4)
    FROM
        [MAS_Apartments] a 
				 left join MAS_Buildings b On a.buildingOid = b.oid
				 left join MAS_Elevator_Floor ef On a.floorOid = ef.oid 
				 --left JOIN dbo.MAS_Apartment_Member me ON me.ApartmentId = a.ApartmentId
				 --JOIN dbo.MAS_Customers c ON c.CustId = me.CustId
				 left join UserInfo m on a.UserLogin = m.loginName 
				 left JOIN MAS_Customers c ON m.CustId = c.CustId 	
				 OUTER APPLY (SELECT TOp(1) t.*
                      FROM
                          MAS_Customers t 
                          join MAS_Apartment_Member b on t.CustId = b.CustId 
                          left join MAS_Customer_Relation d on b.RelationId = d.RelationId
                      WHERE b.apartOid = a.oid and b.RelationId = 0) h
	  WHERE
        (@ProjectCd ='-1' or a.projectCd = @ProjectCd) 
        AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid)
				and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
                and (@buildingCd= 'all' or b.BuildingCd = @buildingCd OR a.buildingCd = @buildingCd)
				and (@Received = -1 Or IsReceived = @Received)
				and (@Rent = -1 Or IsRent = @Rent)
				--and ((@Debt is null or @Debt = -1) Or (@Debt = 0 and a.CurrBal = 0) or (@Debt = 1 and a.CurrBal > 0) or (@Debt = 2 and a.CurrBal < 0))
				and (@setupStatus = -1 
					or (@setupStatus = 0 and (a.IsReceived = 0 or a.isFeeStart = 0 or a.isFeeStart is null or not exists(select a2.LivingId
											  from MAS_Apartment_Service_Living a2
											  where a2.apartOid = a.oid and a2.LivingTypeId = 1 )
												or not exists(select a2.LivingId
											  from MAS_Apartment_Service_Living a2
											  where a2.apartOid = a.oid and a2.LivingTypeId = 2 ))) 
					or (@setupStatus = 1 and (a.IsReceived = 1 and a.isFeeStart = 1 and exists(select a2.LivingId
											  from MAS_Apartment_Service_Living a2
											  where a2.apartOid = a.oid and a2.LivingTypeId = 1 )
												and exists(select a2.LivingId
											  from MAS_Apartment_Service_Living a2
											  where a2.apartOid = a.oid and a2.LivingTypeId = 2 )))
					)
				and (a.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%' or c.Phone like '%' + @filter +'%' OR a.RoomCodeView LIKE '%'+@filter+'%')
				--AND (me.RelationId = '0' OR me.RelationId IS NULL)
		ORDER BY  a.[RoomCode] 
				  offset @Offset rows	
					fetch next @PageSize rows only
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_apartment_page' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartments', 'GET', @SessionID, @AddlInfo
	end catch