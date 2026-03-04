-- =============================================
-- Author:		hoanpv@sunshinegroup.vn
-- Description:	Lấy thông tin tòa theo dự án
-- =============================================
CREATE procedure [dbo].[sp_res_elevator_building_by_projectCd_get]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@ProjectCd nvarchar(30)
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
		select AreaCd BuildCd,
			   AreaName BuildName
		from ELE_BuildArea
		where @ProjectCd is null or ProjectCd = @ProjectCd
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_ELE_BuildArea_GetByProjectCd ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ELE_BuildArea', 'GET', @SessionID, @AddlInfo
	end catch