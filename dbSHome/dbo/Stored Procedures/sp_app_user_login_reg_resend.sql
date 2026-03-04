

-- =============================================
-- Author:		hoanpv -
-- Create date: 20/09/2024
-- Description:	Resend tài khoản
-- =============================================
CREATE   procedure [dbo].[sp_app_user_login_reg_resend]
	@userId uniqueidentifier,
	@acceptLanguage nvarchar(50) = null,
	@reg_id		nvarchar(50)

as
	begin try	

		 UPDATE [dbo].UserInfo
		   SET [verifyOtp] = isnull(verifyOtp,0) + 1
		 WHERE [regOid] = @reg_id

		  -- profile
		  SELECT cast(regOid as nvarchar(50)) as reg_id
				,u.[loginName]
				,u.[FullName]
				,[Phone]	= u.phone
				,[Email]	= u.email
				,[verifyType]
				,case when [verifyOtp] <= 5 then 1 else 0 end as valid
				,case when [verifyOtp] <= 5 then '' else N'Đã quá số lần gửi OTP cho phép!' end as [messages]
				,u.userId
				,modified_dt = getdate()
			FROM [dbo].UserInfo u
				--left join cust_info g on u.custId = g.custId
			WHERE [regOid] = @reg_id

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_user_login_reg_resend ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Set', @SessionID, @AddlInfo
	end catch