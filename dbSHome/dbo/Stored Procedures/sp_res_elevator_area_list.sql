
-- =============================================
-- Author:		duongpx
-- Description:	Lấy thông tin tòa - ds khu vực
-- =============================================
CREATE procedure [dbo].[sp_res_elevator_area_list]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@buildingCd nvarchar(30) = null
	,@projectCd nvarchar(30) = null
	,@isAll nvarchar(30) = null
	,@buildingOid uniqueidentifier = null
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
		select AreaCd as value,
			   AreaName as name
		from ELE_BuildArea a
		where (@buildingCd is null or a.AreaCd = @buildingCd)
		and (@projectCd is null or a.ProjectCd = @projectCd)
		and (@buildingOid is null or exists (select 1 from MAS_Buildings c where c.oid = @buildingOid and a.BuildingId = cast(c.Id as nvarchar(50))))
		union all
		select null as value,
			   N'Tất cả' as name
		where @isAll is not null

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_elevator_area_list ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ELE_BuildArea', 'GET', @SessionID, @AddlInfo
	end catch