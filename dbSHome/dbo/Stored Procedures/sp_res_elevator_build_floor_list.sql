-- Oid = mã chính; BuildCd/BuildZone = phụ (tương thích ngược, bỏ sau migrate). Lấy ds tầng theo khu vực.
CREATE procedure [dbo].[sp_res_elevator_build_floor_list]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@ProjectCd nvarchar(50) = null
	,@BuildCd nvarchar(50) = null
	,@BuildZone nvarchar(30) = null
	,@buildingOid uniqueidentifier = null
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
		if @buildingOid is not null
			set @BuildCd = (select BuildingCd from MAS_Buildings where oid = @buildingOid);

		select FloorName as name,
			   FloorNumber as value
		from ELE_Floor
		where (@ProjectCd is null or ProjectCd = @ProjectCd)
		and   (@BuildCd is null or BuildCd = @BuildCd)
		--and   (@BuildZone is null or BuildZone = @BuildZone)
		order by FloorNumber
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_ELE_Floor_GetByBuildCd ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ELE_Floor', 'GET', @SessionID, @AddlInfo
	end catch