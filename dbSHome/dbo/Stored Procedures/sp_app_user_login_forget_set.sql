

-- =============================================
-- Author:		hoanpv 
-- Create date: 20/09/2024
-- Description:	Quên mật khẩu
-- =============================================
CREATE   procedure [dbo].[sp_app_user_login_forget_set]
    @userId		uniqueidentifier = null,
	@acceptLanguage nvarchar(50) = null,
	@clientId	nvarchar(100),
	@loginName	nvarchar(100),
	@idcard_no	nvarchar(100) = NULL,
	@phone		nvarchar(20),
	@birthday	nvarchar(10),
	@verifyType	int,
	@udid		nvarchar(100) = null
as
begin
	declare @valid bit
	declare @messages nvarchar(300)

	begin try	
		if not exists(select 1 from UserInfo where loginName = @loginName)
		begin
			set @valid = 0
			set @messages = N'Không tin thấy thông tin đăng nhập, vui lòng kiểm tra lại!'
			goto FINAL
		end

		 UPDATE UserInfo
		   SET [verifyOtp] = case when last_dt < dateadd(hour,-1,getdate()) then 0 else isnull(verifyOtp,0) + 1 end
			  ,verifyType = @verifyType
			  ,last_dt = case when last_dt < dateadd(hour,-1,getdate()) or last_dt is null then getdate() else last_dt end
			  ,modified_dt = getdate()
		 WHERE [loginName] = @loginName

		  -- profile
		  SELECT cast(regOid as nvarchar(50)) as reg_id
				,u.[loginName]
				,u.[FullName]
				,[Phone]	= u.phone
				,[Email]	= u.email
				,[verifyType]
				,case when [verifyOtp] <= 10 then 1 else 0 end as valid
				,case when [verifyOtp] <= 10 then '' else N'Đã quá số lần gửi OTP cho phép!' end as [messages]
				,userId = u.userId
			FROM UserInfo u 
			 WHERE u.[loginName] = @loginName

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_app_user_login_forget_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Set', @SessionID, @AddlInfo
	end catch
	FINAL:
	select @valid as valid
	      ,@messages as [messages]
end