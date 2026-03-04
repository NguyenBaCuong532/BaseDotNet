





CREATE procedure [dbo].[sp_User_Insert_Register]
	@UserLogin nvarchar(50),
	@phone nvarchar(20),
	@loginType int,
	@fullName nvarchar(250),
	@loginId nvarchar(300),
	
	@CustId nvarchar(50),
	@UserId nvarchar(450),
	@Email nvarchar(200),
	@IsVerify int,
	@loginSecret nvarchar(50),
	@avatarUrl nvarchar(300),
	@userType	int
as
	begin try	
	--declare @userType int = 9
	--if @UserLogin like 'shrm_%'
	--	set @userType = 1
	--else if @UserLogin like 'ssupapp_%'
	--	set @userType = 2

	IF not Exists(SELECT RegUserId FROM [MAS_Users] WHERE UserLogin = @UserLogin)
	BEGIN
		IF not Exists(SELECT CustId FROM UserInfo WHERE (CustId = @CustId and @CustId <> '' and @CustId is not null) --or Phone like @phone
		)
			INSERT INTO [dbo].[MAS_Users]
				   ([CustId]
				   ,[UserId]
				   ,[UserLogin]
				   ,[LoginType]
				   ,LoginId
				   ,[FullName]
				   ,[Phone]
				   ,[Email]
				   ,StartDt
				   ,[LastDt]
				   ,[IsLock]
				   ,IsVerify
				   ,UserPassword
				   ,AvatarUrl
				   ,userType
				   )
			 VALUES
				   (@CustId
				   ,@UserId
				   ,@UserLogin
				   ,@LoginType
				   ,@loginId
				   ,@FullName
				   ,@Phone
				   ,@Email
				   ,getdate()
				   ,null
				   ,0
				   ,@IsVerify
				   ,@loginSecret
				   ,@avatarUrl
				   ,@userType
				   )
			ELSE
				INSERT INTO [dbo].[MAS_Users]
				   ([CustId]
				   ,[UserId]
				   ,[UserLogin]
				   ,[LoginType]
				   ,LoginId
				   ,[FullName]
				   ,[Phone]
				   ,[Email]
				   ,StartDt
				   ,[LastDt]
				   ,[IsLock]
				   ,IsVerify
				   ,UserPassword
				   ,AvatarUrl
				   ,userType
				   )
			 SELECT @CustID
				   ,@UserId
				   ,@UserLogin
				   ,@LoginType
				   ,@loginId
				   ,@FullName
				   ,@Phone
				   ,@Email
				   ,getdate()
				   ,null
				   ,0
				   ,@IsVerify
				   ,@loginSecret
				   ,@avatarUrl
				   ,@userType
			 FROM UserInfo
			 WHERE (CustId = @CustId and @CustId <> '' and @CustId is not null) --or Phone like @phone
	END
	ELSE
	BEGIN
		UPDATE [dbo].[MAS_Users]
		   SET [CustId] = case when @CustId is not null and @CustId <> '' then @CustId else [CustId] end
			  ,[UserId] = isnull(@UserId,[UserId])
			  ,Phone = isnull(@phone,Phone)
			  ,[LoginType] = isnull(@LoginType,[LoginType])
			  ,LoginId = isnull(@loginId,loginId)
			  ,[FullName] = isnull(@FullName,[FullName])
			  ,[Email] = isnull(@Email,[Email])
			  ,[LastDt] = getdate()
			  ,IsVerify = isnull(@IsVerify, @IsVerify)
			  ,IsActived = isnull(IsCreatePassword, @IsVerify)
			  ,UserPassword = isnull(@loginSecret,UserPassword)
			  ,AvatarUrl = isnull(@AvatarUrl,AvatarUrl)
		 WHERE UserLogin = @UserLogin
	END

	-- profile
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
			,userType
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
		set @ErrorMsg					= 'sp_User_Insert_Register ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin ' + @UserLogin 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'UserRegister', 'Insert', @SessionID, @AddlInfo
	end catch