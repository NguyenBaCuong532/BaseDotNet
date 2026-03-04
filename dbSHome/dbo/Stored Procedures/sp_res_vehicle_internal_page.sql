



CREATE procedure [dbo].[sp_res_vehicle_internal_page]
	@UserId			UNIQUEIDENTIFIER,
	@ProjectCd		nvarchar(50)	= null,
	@filter			nvarchar(30) = null,
	@status		int				= null,
	--@workplaceId	uniqueidentifier	= null,
	@CardCd		nvarchar(50)		= null,
	---
	@gridWidth		int				= 0,
	@Offset			int				= 0,
	@PageSize		int				= 10,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
	--@Total			int out,
	--@TotalFiltered	int out,
	--@GridKey		nvarchar(100) out
	---
as
	begin try
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_vehicle_internal_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= rtrim(ltrim(isnull(@filter,'')))
		--set		@GridKey				= 'view_hrm_employees_vehicle_page'

		set		@status				= isnull(@status,-1)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.CardId)
			FROM [MAS_CardVehicle] a 
			left join Users users on users.userId = a.Mkr_Id
			left JOIN mas_employee b On a.CustId = b.CustId
			left join UserInfo u on b.userId = u.userId 
			join mas_VehicleTypes e On a.VehicleTypeId = e.VehicleTypeId
			join mas_VehicleStatus s ON a.[Status] = s.StatusId
			--left join Organizes o on o.orgDepId = b.orgDepId
			--left join Organize_Param og on b.organizeId = og.organizeId
			left join [mas_Cards] d on a.CardId = d.CardId AND d.CustId = b.custId
			--left join Workplaces w ON b.workplaceId = w.workplaceId
			--left join positionTypes po on b.positionType = po.positionType and b.organizeId = po.orgId
			--join Users uo ON uo.orgId = b.organizeId
		  WHERE (@ProjectCd is null or a.ProjectCd = @ProjectCd)
                --and d.CardTypeId <> 1
				and (@filter is null or u.FullName like '%' + @filter + '%' or u.phone like '%' + @filter + '%' or d.CardCd like '%' + @filter + '%' or a.[VehicleNo] like '%' + @filter + '%' or a.CardVehicleId like '%' + @filter + '%' or b.code like '%' + @filter + '%')
				--and (uo.userId = @UserId)

		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		--grid config

		if @Offset = 0
		begin
			select * from dbo.fn_config_list_gets_lang(@GridKey,@gridWidth, @acceptLanguage)
		end
		
		--1
		SELECT a.cardVehicleId
			  ,convert(nvarchar(10),a.[AssignDate],103) [assignDate]
			  ,a.[vehicleNo]
			  ,a.[vehicleTypeID]
			  ,e.vehicleTypeName
			  ,a.[vehicleName]
			  ,convert(nvarchar(10),a.[StartTime],103) [startTime]
			  ,convert(nvarchar(10),a.[EndTime],103) [endTime]
			  ,a.[Status]
			  ,s.StatusNameLable statusName 
			  ,case a.[Status] when 3 then 1 else 0 end isLock 
			  ,d.[cardCd]
			  ,a.isVehicleNone
			  ,a.auth_id 
			  ,a.auth_Dt
			  ,a.reason
			  ,case when d.CardName is null then N'Thẻ ' + e.VehicleTypeName else N' Thẻ nhân viên, thẻ ' + e.VehicleTypeName end as cardName
			  ,CONCAT(u.fullName, ' - ',b.code) AS fullName
			  --,departmentName = o.org_name
			  ,a.vehicleTypeId
			  ,u.custId
			  ,statusId		= a.[Status]
			  ,a.VehicleColor
			  ,a.note
			  --,w.workplaceName
			  --,orgName		= og.organizationName
			  --,position		= po.positionTypeName 
			  ,b.empId
			  ,created_dt = format(a.Mkr_Dt,'dd/MM/yyyy')
			  ,created_by = users.fullName
			  --,ci.ImageLink
	  FROM [MAS_CardVehicle] a 
			left join Users users on users.userId = a.Mkr_Id
			left JOIN mas_employee b On a.CustId = b.CustId
			left join UserInfo u on b.userId = u.userId 
			join mas_VehicleTypes e On a.VehicleTypeId = e.VehicleTypeId
			join mas_VehicleStatus s ON a.[Status] = s.StatusId
			--left join Organizes o on o.orgDepId = b.orgDepId
			--left join Organize_Param og on b.organizeId = og.organizeId
			left join [mas_Cards] d on a.CardId = d.CardId AND d.CustId = b.custId
			--left join Workplaces w ON b.workplaceId = w.workplaceId
			--left join positionTypes po on b.positionType = po.positionType and b.organizeId = po.orgId
			--join Users uo ON uo.orgId = b.organizeId
		  WHERE (@ProjectCd is null or a.ProjectCd = @ProjectCd)
			and ((@status is null or @status = -1 ) Or a.[Status] = @status)
			--and (@workplaceId is null or b.workplaceId = @workplaceId)
			--and (@positionType = 'all' or b.positionType = @positionType)
            --and d.CardTypeId <> 1
			and (@filter is null or u.FullName like '%' + @filter + '%' or u.phone like '%' + @filter + '%' or d.CardCd like '%' + @filter + '%' or a.[VehicleNo] like '%' + @filter + '%' or a.CardVehicleId like '%' + @filter + '%' or b.code like '%' + @filter + '%')
			--and uo.userId = @UserId
			ORDER BY a.Status, a.[StartTime] DESC
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
		set @ErrorMsg					= 'sp_res_vehicle_internal_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_hrm_employee_vehicle_page', 'GET', @SessionID, @AddlInfo
	end catch