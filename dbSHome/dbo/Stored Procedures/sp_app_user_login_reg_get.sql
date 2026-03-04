



-- =============================================
-- Author:		hoanpv - sp_COR_User_Login_RegGet
-- Create date: 20/09/2024
-- Description:	Lấy thông tin tài khoản đăng ký
-- =============================================
CREATE   procedure [dbo].[sp_app_user_login_reg_get]
	@reg_id		nvarchar(50),
	@userId uniqueidentifier = null,
	@acceptLanguage nvarchar(50) = null
as
	begin try	
		  -- profile
		  SELECT cast(regOid as nvarchar(50)) as reg_id
				,[loginName]
				,[FullName]
				,[Phone]
				,[Email]
				,[verifyType]
				,1 as valid
				,'' as [messages]
				,userId 
			FROM [dbo].UserInfo
			WHERE [regOid] = @reg_id

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_app_user_login_reg_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Set', @SessionID, @AddlInfo
	end catch