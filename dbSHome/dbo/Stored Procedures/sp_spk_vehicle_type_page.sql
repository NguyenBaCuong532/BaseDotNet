

CREATE procedure [dbo].[sp_spk_vehicle_type_page]
	@userId	nvarchar(430),
	@filter nvarchar(100),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out,
	@GridKey		nvarchar(200) out
as
	begin try		
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		
		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		/****** Script for SelectTopNRows command from SSMS  ******/
		select	@Total					= count(a.VehicleTypeId)
			FROM [MAS_VehicleTypes] a 
			WHERE VehicleTypeName like '%' + @filter + '%' 

		set	@TotalFiltered = @Total
		set	@gridKey	= 'view_spk_vehicle_page'
		if @Offset = 0
			begin
				select * from [dbo].fn_config_list_gets (@gridKey, 0) 
				order by [ordinal]
			end

		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end

		SELECT a.vehicleTypeid
			  ,a.vehicleTypeName
		FROM [MAS_VehicleTypes] a 
		WHERE VehicleTypeName like '%' + @filter + '%' 
		ORDER BY VehicleTypeid asc
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
		set @ErrorMsg					= 'sp_spk_vehicle_type_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'SPK_Vehicles', 'GET', @SessionID, @AddlInfo
	end catch