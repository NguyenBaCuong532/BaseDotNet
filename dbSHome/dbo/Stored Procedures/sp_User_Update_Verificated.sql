





CREATE procedure [dbo].[sp_User_Update_Verificated]
	@UserLogin nvarchar(20),
	@tokenType int
as
	begin try	
	
		UPDATE [dbo].MAS_Users
		   SET IsVerify = 1
			  ,IsActived = 1
			  ,IsCreatePassword = case when @tokenType = 2 then IsCreatePassword else 0 end
		 WHERE UserLogin = @UserLogin

		 SELECT [regUserId]
			,[UserId]
			,[CustId]
			,[AvatarUrl]
			,[UserLogin]
			,[UserPassword]
			,[IsActived]
			,[FullName]
			,[Phone]
			,[Email]
			,[IsVerify]
			,[LoginType]
			,[LoginId]
			,[LastDt]
			,0 as IsCreatePassword
		FROM [dbo].[MAS_Users]
		WHERE UserLogin = @UserLogin

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

		set @AddlInfo					= '@UserLogin ' + @UserLogin 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'UserProfile', 'Update', @SessionID, @AddlInfo
	end catch