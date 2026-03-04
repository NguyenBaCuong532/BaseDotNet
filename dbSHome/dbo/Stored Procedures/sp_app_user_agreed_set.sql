





CREATE   procedure [dbo].[sp_app_user_agreed_set]    
	@userId uniqueidentifier =null,
	@acceptLanguage nvarchar(50) = 'vi-VN',
    @agreed_st bit
as
	begin try
        update t1
		set  agreed_St = @agreed_st
			,agreed_Dt = getdate()
		FROM UserAgree t1
		WHERE t1.userId = @userId
			       
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_app_user_agreed_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'user_agree', 'Insert', @SessionID, @AddlInfo
	end catch