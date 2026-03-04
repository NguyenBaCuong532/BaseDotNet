

-- =============================================
-- Author:		duongpx
-- Create date: 11/20/2025 3:51:10 PM
-- Description:	Giới thiệu ứng dụng
-- =============================================
CREATE   procedure [dbo].[sp_app_security_about_get]
	@userId uniqueidentifier = null,
	@acceptLanguage	nvarchar(50) = 'vi-VN'
as
	begin try	
		
			begin
				SELECT cast(a.Oid as nvarchar(50)) as value
					  ,a.name as name
					  ,a.[content]
					  ,aboutUrl = N'https://unicloud.com.vn/vi/ecosystem/digital-transformation/bizzone-homes'
				FROM security_policy a
				where a.code = 'about'
			end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_app_security_about_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_app_security_about_get', 'Get', @SessionID, @AddlInfo
	end catch