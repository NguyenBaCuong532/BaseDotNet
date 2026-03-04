-- Oid = mã chính; areaCd/BuildZone = phụ (tương thích ngược, bỏ sau migrate).
CREATE procedure [dbo].[sp_res_elevator_floor_page]
	@UserId			UNIQUEIDENTIFIER = NULL, 
	@acceptLanguage NVARCHAR(50) = N'vi-VN',
	@filter			nvarchar(50) = NULL,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@ProjectCd		nvarchar(30) = null,
	@areaCd			nvarchar(50) = null,
	@BuildZone		nvarchar(50) = null,
	@gridWidth			int = 0,
	@buildingOid		uniqueidentifier = null
as
	begin try 
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_elevator_floor_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		if		@buildingOid is not null
			set	@areaCd	= (select BuildingCd from MAS_Buildings where oid = @buildingOid)
		--set		@filter					= isnull(@filter,'')

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		select	@Total					= count(a.Id)
		from MAS_Elevator_Floor a 
		where (@ProjectCd is null or a.ProjectCd = @ProjectCd)
			   and (@areaCd is null or a.areaCd = @areaCd)
			   and (@BuildZone is null or a.BuildZone = @BuildZone)

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
		select [Id]
			  ,a.[ProjectCd]
			  ,b.ProjectName
			  ,a.[areaCd]
			  ,a.[BuildZone]
			  ,a.[FloorName]
			  ,a.[FloorType]
			  ,a.[FloorNumber]
			  ,a.created_at
		from [dbo].[MAS_Elevator_Floor] a 
			left join mas_Projects b on a.ProjectCd = b.ProjectCd
		where (@ProjectCd is null or a.ProjectCd = @ProjectCd)
			   and (@areaCd is null or a.areaCd = @areaCd)
			   and (@BuildZone is null or a.BuildZone = @BuildZone)
		--ORDER BY FloorNumber
		ORDER BY created_at desc
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
		set @ErrorMsg					= 'sp_res_elevator_floor_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Elevator_Floor', 'GET', @SessionID, @AddlInfo
	end catch