











CREATE procedure [dbo].[sp_COR_User_Login_RegResend]
	@reg_id	bigint

as
	begin try	

		 UPDATE [dbo].UserInfo
		   SET [verifyOtp] = isnull(verifyOtp,0) + 1
		 WHERE [reg_UserId] = @reg_id

		  -- profile
		  SELECT [reg_UserId] as reg_id
				,[loginName]
				,u.[FullName]
				,[Phone]	= isnull(u.phone,g.phone)
				,[Email]	= isnull(u.email,g.email)
				,[verifyType]
				,case when [verifyOtp] <= 5 then 1 else 0 end as valid
				,case when [verifyOtp] <= 5 then '' else N'Đã quá số lần gửi OTP cho phép!' end as [messages]
				,userId
				,modified_dt = getdate()
			FROM [dbo].UserInfo u
				left join MAS_Customers g on u.custId = g.custId
			WHERE [reg_UserId] = @reg_id

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_COR_User_Login_RegGet ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserRegGet', 'Set', @SessionID, @AddlInfo
	end catch