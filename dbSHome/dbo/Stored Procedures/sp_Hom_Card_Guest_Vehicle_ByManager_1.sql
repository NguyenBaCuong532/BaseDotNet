

CREATE procedure [dbo].[sp_Hom_Card_Guest_Vehicle_ByManager]
	@UserId	nvarchar(450),
	@clientId	nvarchar(50),
	@ProjectCd nvarchar(30),
	@filter nvarchar(30),
	@Statuses int = null,
	@VehicleTypeId int = -1,
	@partner_id			int = -1,
	@dateFilter			int	= 0,
	@endDate			nvarchar(20)	= null,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
		declare @webId nvarchar(50) --= (select id from [dbAppManager].[dbo].[ClientWebs] where clientId = @clientId or clientIdDev = @clientId)
		--set @webId = 'E10C3ADE-EC16-4511-B467-4848241D52C7'
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

		declare @tbIsUse TABLE 
		(
			Id [Int] null
		)
		--declare @tbVehicleType TABLE 
		--(
		--	Id [Int] null
		--)
		if	@Statuses is null or @Statuses = -1 
			insert into @tbIsUse (Id) SELECT [StatusId] FROM [MAS_VehicleStatus]
		else
		begin
			insert into @tbIsUse (Id) select @Statuses
		end

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		set		@Statuses				= isnull(@Statuses,-1)
		set		@VehicleTypeId			= isnull(@VehicleTypeId,-1)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(b.CardId)
			FROM MAS_CardVehicle b
			join @tbCats ca on ca.categoryCd = b.ProjectCd
			join MAS_Customers c on b.CustId = c.CustId
			join MAS_VehicleTypes d on b.VehicleTypeId = d.VehicleTypeId
			join MAS_VehicleStatus s on b.[Status] = s.StatusId
			join MAS_Projects p on b.ProjectCd = p.ProjectCd
			left join [dbo].[MAS_Cards] a on b.CardId = a.CardId 
			left join Users mkr on b.Mkr_Id = mkr.UserId
			left join Users aut on b.Auth_id = aut.UserId
		WHERE b.[monthlyType] = 2
			and (@VehicleTypeId = -1 or b.VehicleTypeId = @VehicleTypeId)
			and (b.VehicleNo  like '%' + @filter + '%' or c.Phone like '%' + @filter + '%' or c.FullName like '%' + @filter + '%' or a.CardCd like '%' + @filter + '%')
			and case when b.[Status] = 1 and dateadd(day,1,b.EndTime) < getdate() then 2 else b.[Status] end in (select Id from @tbIsUse)
			and (@dateFilter = 0 or b.EndTime <= convert(datetime,@endDate,103))
			and (@partner_id = -1 or exists(select 1 from MAS_Cards where cardid = b.CardId and partner_id = @partner_id))

		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end
	
		--1
		SELECT b.CardVehicleId
			  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
			  ,c.FullName
			  ,b.VehicleNo 
			  ,b.VehicleName 
			  ,c.Phone
			  ,convert(nvarchar(10),dateadd(day,1,b.EndTime),103) as StartTimeRen
			  ,convert(nvarchar(10),b.StartTime,103) as StartTime
			  ,convert(nvarchar(10),b.EndTime,103) as EndTime
			  ,a.CardName as CardTypeName
			  ,a.CardCd
			  ,b.CustId
			  ,d.VehicleTypeName
			  ,case when b.[Status] = 1 and dateadd(day,1,b.EndTime) < getdate() then 2 else b.[Status] end as [Status]
			  ,case when b.[Status] < 3 and dateadd(day,1,b.EndTime) < getdate() then N'Quá hạn TT' else s.StatusName end as StatusName
			  ,case when b.[Status] < 2 then 0 else 1 end as IsLock
			  ,b.AssignDate
			  ,b.VehicleTypeId
			  ,isnull(p.ProjectName,N'Tất cả các dự án') as ProjectName
			  ,isnull(mkr.loginName,'') + '/'+isnull(aut.loginName,'')  as CreateByName
	  FROM MAS_CardVehicle b
			join @tbCats ca on ca.categoryCd = b.ProjectCd
			join MAS_Customers c on b.CustId = c.CustId
			join MAS_VehicleTypes d on b.VehicleTypeId = d.VehicleTypeId
			join MAS_VehicleStatus s on b.[Status] = s.StatusId
			join MAS_Projects p on b.ProjectCd = p.ProjectCd
			left join [dbo].[MAS_Cards] a on b.CardId = a.CardId
			left join Users mkr on b.Mkr_Id = mkr.UserId
			left join Users aut on b.Auth_id = aut.UserId
		WHERE b.[monthlyType] = 2
			and (@VehicleTypeId = -1 or b.VehicleTypeId = @VehicleTypeId)
			and (b.VehicleNo  like '%' + @filter + '%' or c.Phone like '%' + @filter + '%' or c.FullName like '%' + @filter + '%'or a.CardCd like '%' + @filter + '%')
			and case when b.[Status] = 1 and dateadd(day,1,b.EndTime) < getdate() then 2 else b.[Status] end in (select Id from @tbIsUse)
			and (@dateFilter = 0 or b.EndTime <= convert(datetime,@endDate,103))
			and (@partner_id = -1 or exists(select 1 from MAS_Cards where cardid = b.CardId and partner_id = @partner_id))
		ORDER BY b.AssignDate DESC
		  offset @Offset rows	
			fetch next @PageSize rows only
	  
	--2
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Card_Guest_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardGuest', 'GET', @SessionID, @AddlInfo
	end catch