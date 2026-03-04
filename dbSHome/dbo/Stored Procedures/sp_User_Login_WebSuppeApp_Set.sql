




CREATE procedure [dbo].[sp_User_Login_WebSuppeApp_Set]
	@UserID	nvarchar(450),
	@UserLogin nvarchar(50),
	@UserPassword nvarchar(50)
as
	begin try		

		if not exists(select CustId from [MAS_Users] where UserID = @UserID)
		begin

			insert into [dbo].[MAS_Users]
				   ([UserId]
				   ,[UserLogin]
				   ,[UserPassword]
				   ,[AvatarUrl]
				   ,[StartDt]
				   ,[IsActived])
				values
					(
				   @UserId
				  ,@UserLogin
				  ,@UserPassword
				  ,null
				  ,getdate()
				  ,1 
					)

		end
		else
			begin

				UPDATE t 
				SET  UserLogin = isnull(@UserLogin,UserLogin)
					,UserPassword = isnull(@UserPassword,UserPassword)
				FROM MAS_Users t 
				WHERE t.UserId  = @UserID 

			end


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Login_WebSuppeApp_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_User_Login_WebSuppeApp_Set', 'Insert', @SessionID, @AddlInfo
	end catch