




CREATE procedure [dbo].[sp_User_Login_userId_Set]
	@UserLogin nvarchar(50),
	@userId nvarchar(450),
	@loginSecret nvarchar(50)
as
	begin try	
	
		UPDATE [dbo].[MAS_Users]
		   SET [UserId] = isnull(@UserId,[UserId])
			  ,UserPassword = isnull(@loginSecret,UserPassword)
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
			,isnull(IsCreatePassword,0) as IsCreatePassword
			,isnull(Is_Agreed_Term,0) as Is_Agreed_Term
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
		set @ErrorMsg					= 'sp_User_Login_userId_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin ' + @UserLogin 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'UserLogin', 'Update', @SessionID, @AddlInfo
	end catch