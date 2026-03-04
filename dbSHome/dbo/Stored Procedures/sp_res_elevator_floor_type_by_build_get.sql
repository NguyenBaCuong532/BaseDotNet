-- =============================================
-- Author:		hoanpv@sunshinegroup.vn
-- Description:	Lấy thông tin tòa theo dự án
-- =============================================
CREATE procedure [dbo].[sp_res_elevator_floor_type_by_build_get]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@BuildCd nvarchar(30)
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
		select Id,
			   FloorTypeName,
			   BuildCd
		from ELE_FloorType
		where (@BuildCd is null or BuildCd = @BuildCd)
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_ELE_FloorType_GetByBuildCd ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ELE_FloorType', 'GET', @SessionID, @AddlInfo
	end catch