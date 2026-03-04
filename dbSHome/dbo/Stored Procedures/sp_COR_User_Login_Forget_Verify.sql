







CREATE procedure [dbo].[sp_COR_User_Login_Forget_Verify]
	 @reg_id	bigint
	,@user_type int = 0
as
	begin try		
		
		UPDATE u
		   SET last_St		= 1
			  ,last_Dt		= getdate()
			  ,[verifyOtp]	= 0
			  ,phone		= isnull(u.phone,g.phone)
			  ,email		= isnull(u.email,g.email)
			  ,userType		= @user_type
			  ,modified_dt = getdate()
		from UserInfo u
		left join MAS_Customers g on u.custId = g.custId
		 WHERE reg_userId = @reg_id

		 SELECT [reg_UserId] as reg_id
				,[loginName]
				,[FullName]
				,[Phone]
				,[Email]
				,[verifyType]
				,case when [verifyOtp] <= 5 then 1 else 0 end as valid
				,case when [verifyOtp] <= 5 then '' else N'Đã quá số lần gửi OTP cho phép!' end as [messages]
			FROM UserInfo
			 WHERE reg_userId = @reg_id

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Update_Verificated ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin '  

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserLog', 'Update', @SessionID, @AddlInfo
	end catch