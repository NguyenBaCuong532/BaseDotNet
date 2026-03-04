





CREATE procedure [dbo].[sp_Hom_Card_Resident_Vehicle_ByManager]
	@UserId		nvarchar(450),
	@clientId	nvarchar(50),
	@ProjectCd	nvarchar(30),
	@filter		nvarchar(30),
	@Statuses			int = null,
	--@monthlyType		int = -1,
	@VehicleTypeId		int = -1,
	@dateFilter			int	= 0,
	@endDate			nvarchar(20)	= null,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
	--@TotalUsed			int out
as
	begin try
		
		declare @webId nvarchar(50) --= (select id from [dbAppManager].[dbo].[ClientWebs] where clientId = @clientId or clientIdDev = @clientId)
		declare @tbCats TABLE 
		(
			categoryCd [nvarchar](50) not null INDEX IX1_category NONCLUSTERED
		)
		set		@projectCd				= isnull(@projectCd,'')
		INSERT INTO @tbCats
		select distinct u.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 0 
			and (@ProjectCd = '' or u.categoryCd = @ProjectCd)
			and not exists(select CategoryCd from @tbCats where categoryCd = u.CategoryCd)
		INSERT INTO @tbCats
		select distinct n.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u join [dbSHome].[dbo].MAS_Category n on n.base_type = u.base_type 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 1
			and (@ProjectCd = '' or n.categoryCd = @ProjectCd)
			and not exists(select CategoryCd from @tbCats where categoryCd = n.CategoryCd)

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		set		@ProjectCd				= isnull(@ProjectCd,'')
		set		@VehicleTypeId			= isnull(@VehicleTypeId,-1)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	 @Total	= count(a.CardVehicleId)
			FROM MAS_CardVehicle AS a 
				JOIN MAS_Apartments AS e ON a.ApartmentId = e.ApartmentId 
				join @tbCats t on e.projectCd = t.categoryCd 
                JOIN MAS_Customers AS c ON a.CustId = c.CustId 
				left JOIN MAS_Cards AS b ON a.CardId = b.CardId 
				--left join MAS_CardVehicle_H ah on a.CardVehicleId = ah.CardVehicleId
			WHERE (@VehicleTypeId = -1 or a.VehicleTypeId = @VehicleTypeId)
				and ((@Statuses is null or @Statuses = -1) or case when a.[Status] = 1 and dateadd(day,1,a.EndTime) < getdate() then 2 else a.[Status] end = @Statuses) --in (select Id from @tbIsUse)
				and ((b.CardTypeId = 1 or b.CardTypeId = 3) 
						)
				and (@filter = '' or CardCd =  @filter or e.RoomCode =  @filter
					or c.Phone =  @filter or b.CardCd like '%' + @filter + '%' 
					or a.VehicleNo like '%' + @filter + '%')
				and (@dateFilter = 0 or a.EndTime <= convert(datetime,@endDate,103))

		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end
	
	--1
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
				,case when a.[Status] = 1 and dateadd(day,1,a.EndTime) < getdate() then N'Quá hạn TT' else s.StatusName end as StatusName
				,case when a.[Status] < 2 then 0 else 1 end as IsLock
				,k.CardTypeName 
				,isnull(mkr.loginName,'') + '/'+isnull(aut.loginName,'')  as CreateByName
				--,isnull(mkt.UserLogin,'') + '/[' + convert(nvarchar(20),format(ah.SaveDate,'dd/MM/yyyy')) + ']' as DeleteBy 
			FROM  MAS_CardVehicle AS a 
				JOIN MAS_Apartments AS e ON a.ApartmentId = e.ApartmentId 
				join @tbCats t on e.projectCd = t.categoryCd 
				join MAS_VehicleStatus s on a.[Status] = s.StatusId
				JOIN MAS_Customers AS c ON a.CustId = c.CustId 
				JOIN MAS_VehicleTypes g ON a.VehicleTypeId = g.VehicleTypeId
                left JOIN MAS_Cards AS b ON a.CardId = b.CardId 
				LEFT JOIN [MAS_CardTypes] k On b.CardTypeId = k.CardTypeId
				left join Users mkr on a.Mkr_Id = mkr.UserId
				left join Users aut on a.Auth_id = aut.UserId
				--left join MAS_CardVehicle_H ah on a.CardVehicleId = ah.CardVehicleId
				--left join Users mkt on ah.SaveId = mkt.UserId
			WHERE (@VehicleTypeId = -1 or a.VehicleTypeId = @VehicleTypeId)
				and ((@Statuses is null or @Statuses = -1 ) or case when a.[Status] = 1 and dateadd(day,1,a.EndTime) < getdate() then 2 else a.[Status] end = @Statuses) --in (select Id from @tbIsUse)
				and ((b.CardTypeId = 1 or b.CardTypeId = 3) 
						)
				and (@filter = '' or CardCd =  @filter or e.RoomCode =  @filter
					or c.Phone =  @filter or b.CardCd like '%' + @filter + '%' 
					or a.VehicleNo like '%' + @filter + '%')
				and (@dateFilter = 0 or a.EndTime <= convert(datetime,@endDate,103))
		ORDER BY [CardCd] 
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
		set @ErrorMsg					= 'sp_Hom_Card_Resident_Vehicle_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardVehicle', 'GET', @SessionID, @AddlInfo
	end catch