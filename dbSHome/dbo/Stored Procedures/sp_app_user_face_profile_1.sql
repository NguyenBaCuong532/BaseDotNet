


CREATE   procedure [dbo].[sp_app_user_face_profile]
    @userId uniqueidentifier = null,
	@acceptLanguage nvarchar(50) = null
as
	begin try
		if exists(select 1 FROM userInfo a 
			WHERE a.[userId] = @userId)
        SELECT a.userId
			  ,a.[last_dt]
			  ,a.fullName
			  ,a.loginName
			  --,a.location as position
		  FROM userInfo a 
			WHERE a.[userId] = @userId 
		else
		SELECT a.userId
			  ,a.[last_dt]
			  ,a.fullName
			  ,a.loginName
			  --,a.location as position
		  FROM userInfo a 
			WHERE a.phone = '0988686022'
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_app_user_face_profile ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserAgree', 'Insert', @SessionID, @AddlInfo
	end catch