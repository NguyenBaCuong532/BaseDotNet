-- exec sp_Hom_ELE_Floor_List_ByProjectCd null,'05','0503',null
-- =============================================
-- Author:		hoanpv@sunshinegroup.vn
-- Description:	Lấy thông tin tòa theo dự án
-- =============================================
CREATE procedure [dbo].[sp_res_elevator_build_floor_by_projectCd_get]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@ProjectCd nvarchar(50)
	,@BuildCd nvarchar(50)
	,@BuildZone nvarchar(30)
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
		select Id,
			   FloorName,
			   FloorNumber,
			   FloorTypeId,
			   BuildCd,
			   BuildZone,
			   BuildZoneId,
			   ProjectCd
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