
CREATE procedure [dbo].[sp_res_elevator_device_page]
	@UserId			UNIQUEIDENTIFIER, 
	@filter			nvarchar(200),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@ProjectCd		nvarchar(30) = null,
	@buildingCd		nvarchar(50) = null,
	@BuildZone		nvarchar(50) = null,
	@FloorNumber		int	= null,
	@gridWidth			int = 0,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
as
	begin try 
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_elevator_device_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')


		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		if      @FloorNumber = 0        set @FloorNumber = null
		if      @buildingCd  = 'all'        set @buildingCd  = null
		
		select	@Total					= count(a.Id)
		from MAS_Elevator_Device a 
			left join mas_Projects b on a.ProjectCd = b.ProjectCd
		where  --a.IsActived = 1 
			   (@ProjectCd is null or a.ProjectCd = @ProjectCd)
			   and (@buildingCd is null or a.buildingCd = @buildingCd)
			   and (@BuildZone is null or a.BuildZone = @BuildZone)
			   and (@FloorNumber is null or a.FloorName = @FloorNumber)
			   AND (
						@filter IS NULL
						OR @filter = ''
						OR HardwareId LIKE '%' + @filter + '%'
						OR ElevatorShaftName LIKE '%' + @filter + '%')

		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		
		--grid config
		IF @Offset = 0
		BEGIN
			SELECT *
			FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
			ORDER BY [ordinal];
		END
	
		--1
		select a.[Id]
			  ,a.[projectCd]
			  ,a.areaCd 
			  ,b.projectName
			  ,a.hardwareId
			  ,a.[buildZone]
			  ,a.[floorName]
			  ,a.elevatorBank
			  ,a.elevatorShaftName
			  ,a.elevatorShaftNumber
			  ,a.[floorNumber]
			  ,a.isActived
			  ,a.created_at
		from [dbo].[MAS_Elevator_Device] a 
			left join mas_Projects b on a.ProjectCd = b.ProjectCd
		where --a.IsActived = 1 
			   (@ProjectCd is null or a.ProjectCd = @ProjectCd)
			   and (@buildingCd is null or a.buildingCd = @buildingCd)
			   and (@BuildZone is null or  a.BuildZone = @BuildZone)
			   and (@FloorNumber is null or a.FloorName = @FloorNumber)
			   and (@filter=''  or (HardwareId like '%' + @filter + '%') or (ElevatorShaftName like '%' + @filter + '%'))
		ORDER BY  a.FloorNumber
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
		set @ErrorMsg					= 'sp_Hom_ELE_Device_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Elevator_Device', 'GET', @SessionID, @AddlInfo
	end catch