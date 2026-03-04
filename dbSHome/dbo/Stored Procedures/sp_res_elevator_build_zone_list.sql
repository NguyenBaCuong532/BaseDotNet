
-- =============================================
-- Author:		hoanpv@sunshinegroup.vn
-- Description:	Lấy thông tin tòa theo dự án
-- =============================================
CREATE procedure [dbo].[sp_res_elevator_build_zone_list]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@ProjectCd nvarchar(30)
	,@AreaCd nvarchar(30)
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
		select BuildZone as value,
			   BuildZone as name
		from ELE_BuildZone
		where --@ProjectCd is null or ProjectCd = @ProjectCd
				AreaCd = @AreaCd

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