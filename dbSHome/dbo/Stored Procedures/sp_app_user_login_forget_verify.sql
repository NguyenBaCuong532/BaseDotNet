



-- =============================================
-- Author:		hoanpv - sp_COR_User_Login_Forget_Verify
-- Create date: 20/09/2024
-- Description:	Xác nhận quên mật khẩu
-- =============================================
CREATE   procedure [dbo].[sp_app_user_login_forget_verify]
     @userId		uniqueidentifier = null,
	 @acceptLanguage nvarchar(50) = null,
	 @reg_id		nvarchar(50)
	,@user_type		int = 0
as
	begin try		
		
		UPDATE u
		   SET last_St		= 1
			  ,last_Dt		= getdate()
			  ,[verifyOtp]	= case when verifyOtp < 2 then 0 else verifyOtp end
			  --,phone		= isnull(u.phone,g.phone_1)
			  --,email		= isnull(u.email,g.mail_to)
			  ,userType		= @user_type
			  ,modified_dt = getdate()
		from UserInfo u
		 WHERE regOid = @reg_id

		 SELECT cast([regOid] as nvarchar(50)) as reg_id
				,[loginName]
				,[FullName]
				,[Phone]
				,[Email]
				,[verifyType]
				,case when [verifyOtp] <= 5 then 1 else 0 end as valid
				,case when [verifyOtp] <= 5 then '' else N'Đã quá số lần gửi OTP cho phép!' end as [messages]
			FROM UserInfo
			 WHERE regOid = @reg_id

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_user_login_forget_verify ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Set', @SessionID, @AddlInfo
	end catch