



-- =============================================
-- Author:		hoanpv - sp_user_profile_set
-- Create date: 20/09/2024
-- Description:	Cập nhật thông tin hồ sơ cá nhân
-- =============================================
CREATE   procedure [dbo].[sp_app_user_profile_set]
	@userId uniqueidentifier = null,
	@acceptLanguage nvarchar(50) = null,
	@loginName nvarchar(250) = null,
	@fullName nvarchar(250) = null,
	@email nvarchar(50) = null,
	@sex int = null,
	@birthday nvarchar(50) = null,
	@avatarUrl nvarchar(500) = null,
	@summary	nvarchar(max) = null,
	@job	nvarchar(500) = null
as
	begin try	
	
	BEGIN
	    declare @valid bit = 1
        declare @messages nvarchar(100) = N'Cập nhật thông tin profile thành công' 

		UPDATE [dbo].UserInfo
		   SET fullName = @fullName
		      ,email = @email
			  ,avatarUrl = @avatarUrl
			  ,sex = @sex
			  ,birthday = convert(datetime,@birthday,103)
			  --,summary = @summary
			  --,job = @job
		 WHERE userId = @userId

		 --if exists(select 1 from UserInfo where userid = @userId and (referralCd is null or referralCd = ''))
		 --begin
			--DECLARE @referralCd nvarchar(100)
			---- TODO: Set parameter values here.
			--EXECUTE [dbo].[sp_gen_new_referal_code] 
			--   1
			--  ,@referralCd OUTPUT

			--UPDATE [dbo].UserInfo
			--   SET referralCd = @referralCd
			-- WHERE userId = @userId
		 --end

	END

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_user_profile_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Set', @SessionID, @AddlInfo
	end catch
	 FINAL:
	    select @valid as valid
		       ,@messages as [messages]