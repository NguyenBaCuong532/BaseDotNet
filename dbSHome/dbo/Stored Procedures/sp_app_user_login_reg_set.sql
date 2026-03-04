


-- =============================================
-- Author:		hoanpv - sp_app_user_login_reg_set
-- Create date: 20/09/2024
-- Description:	Verifi tài khoản
-- =============================================
CREATE   procedure [dbo].[sp_app_user_login_reg_set]
	 @userId uniqueidentifier = null
	,@acceptLanguage nvarchar(50) = null
	
	,@reg_id		nvarchar(50) = null
	,@userId_set	nvarchar(50)
	,@code			nvarchar(10) = null
	,@secret_cd		nvarchar(100)
as
	begin try	
		declare @last_st bit
		declare @verifyType int

		SELECT @last_st = last_st
			  ,@verifyType = verifyType
		FROM [dbo].[UserInfo]
		WHERE regOid = @reg_id

		UPDATE [dbo].UserInfo
		   SET last_st			= 1
			  ,last_Dt			= getdate()
			  ,userId			= @userId_set
			  ,verifyOtp		= 1
			  ,verifyCode		= @code	
			  ,verify_by		= @secret_cd
			  ,phone_confirmed	= case when @verifyType = 0 then 1 else phone_confirmed end
			  ,email_confirmed	= case when @verifyType = 1 then 1 else email_confirmed end
			  ,modified_dt		= getdate()			  
		 WHERE regOid = @reg_id
		 	 

		SELECT loginName
			  ,1 as IsCreatePassword
		FROM [dbo].[UserInfo]
		WHERE regOid = @reg_id

		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_user_login_reg_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Set', @SessionID, @AddlInfo
	end catch