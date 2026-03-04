


CREATE procedure [dbo].[sp_res_vehicle_guest_page]
	@UserId	UNIQUEIDENTIFIER,
	@clientId	nvarchar(50) = null,
	@ProjectCd nvarchar(30) = null,
	@filter nvarchar(30),
	@Status int = null,
	@VehicleTypeId int = -1,
	@partnerid			int = -1,
	@dateFilter			int	= 0,
	@endDate			nvarchar(20)	= null,
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
as
	begin try
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_vehicle_guest_page'

		declare @tbIsUse TABLE 
		(
			Id [Int] null
		)
		
		if	@Status is null or @Status = -1 
			insert into @tbIsUse (Id) SELECT [StatusId] FROM [MAS_VehicleStatus]
		else
		begin
			insert into @tbIsUse (Id) select @Status
		end

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		set		@Status					= isnull(@Status,-1)
		set		@VehicleTypeId			= isnull(@VehicleTypeId,-1)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(b.CardId)
			FROM MAS_CardVehicle b
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
			and (@partnerid = -1 or exists(select 1 from MAS_Cards where cardid = b.CardId and partner_id = @partnerid))

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
		END
	
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
			and (@partnerid = -1 or exists(select 1 from MAS_Cards where cardid = b.CardId and partner_id = @partnerid))
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