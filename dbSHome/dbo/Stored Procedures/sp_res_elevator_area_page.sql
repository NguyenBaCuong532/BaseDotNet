-- Oid = mã chính; BuildingCd = phụ (tương thích ngược, bỏ sau migrate).
CREATE procedure [dbo].[sp_res_elevator_area_page]
	@UserId			UNIQUEIDENTIFIER	= null, 
	@filter			nvarchar(50)	= NULL,
	@Offset			int				= 0,
	@PageSize		int				= 10,
	@ProjectCd		nvarchar(30)	= null,
	@BuildingCd		nvarchar(50)	= null,
	@buildingOid		uniqueidentifier = null,
	@gridWidth				int		= 0,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
as
	begin try 
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_elevator_area_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		if		@buildingOid is not null
			set		@BuildingCd			= (select BuildingCd from MAS_Buildings where oid = @buildingOid)

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		select	@Total					= count(a.Id)
		from ELE_BuildArea a 
			left join MAS_Buildings c on a.BuildingId = c.Id
		where (@ProjectCd is null or a.ProjectCd = @ProjectCd)
			   and (@BuildingCd is null or c.BuildingCd = @BuildingCd)

		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1

		--gridflexs
		IF @Offset = 0
		BEGIN
			SELECT *
			FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
			ORDER BY [ordinal];
		END;
	
		--1
		select a.[id]
			  ,a.[projectCd]
			  ,b.projectName
			  ,a.areaCd
			  ,a.areaName
			  ,c.buildingCd
		from [dbo].ELE_BuildArea a 
			left join mas_Projects b on a.ProjectCd = b.ProjectCd
			left join MAS_Buildings c on a.BuildingId = c.Id
		where (@ProjectCd is null or a.ProjectCd = @ProjectCd)
			   and (@BuildingCd is null or c.BuildingCd = @BuildingCd)
		ORDER BY a.AreaCd desc
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
		set @ErrorMsg					= 'sp_res_elevator_area_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'elevator_area', 'GET', @SessionID, @AddlInfo
	end catch