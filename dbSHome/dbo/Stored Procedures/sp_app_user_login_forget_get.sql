



-- =============================================
-- Author:		hoanpv - sp_app_user_login_forget_get
-- Create date: 20/09/2024
-- Description:	Lấy thông tin quên mật khẩu
-- =============================================
CREATE   procedure [dbo].[sp_app_user_login_forget_get]
    @userId uniqueidentifier = null,
	@acceptLanguage nvarchar(50) = null,
	@clientId	nvarchar(100),
	@loginName	nvarchar(150),
	@udid		nvarchar(100) = null

as
	begin try	
		declare @lognote nvarchar(100)
		declare @forename nvarchar(100)
		if not exists(select 1 FROM UserInfo
			WHERE [loginName] = @loginName)
		begin
			if len(@loginName) = 10
				set @lognote = (select top 1 loginName FROM UserInfo 
					WHERE phone = @loginName and (userType = 3 or userType = 9) order by userType)

			if @lognote is not null
			begin
				if len(@lognote) <= 6
					set @forename = left(@lognote,3) + '***'+right(@lognote,1)
				else if len(@lognote) <= 8
					set @forename = left(@lognote,3) + '***'+right(@lognote,2)
				else
					set @forename = left(@lognote,3) + '***'+right(@lognote,3)
			end
			select 0 as valid
			      ,N'Chúng tôi không tìm thấy tên truy cập là ['+@loginName+'].' 
				  + case when @lognote is not null then N'Gợi ý tên đăng nhập của Quý khách có thể [' + @forename +']' else N' Vui lòng kiểm tra và thử lại!' end
				  
				  as [messages]
		end
		else
		  -- profile
		  SELECT case when len(isnull([Phone],'')) > 0 then left(phone,3) + '*****' + right(phone,2) 
					else 'invalid' end as phone
				,case when [Email] is not null and email <> '' and CHARINDEX('@',email)>0 then left(email,3) + '*****' + SUBSTRING(email,CHARINDEX('@',email),len(email)) 
					else 'invalid' end as email
				,[verifyType]
				,idcard_verified = case when exists(select 1 FROM UserDevice t join UserInfo u on t.userId = u.userId
					WHERE udid = @udid and u.loginName = @loginName and [clientId] = @clientId and etokenDevice = 1) then 1 else 0 end 
				,1 as valid
				,N'Tên đăng nhâp hợp lệ' as [messages]
			FROM UserInfo a
			WHERE [loginName] = @loginName

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_app_user_login_forget_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Set', @SessionID, @AddlInfo
	end catch