




CREATE procedure [dbo].[sp_res_insert_user]
	@UserID	nvarchar(450),
	@CustId	nvarchar(50),
	@UserLogin nvarchar(50),
	@UserPassword nvarchar(50),
	@AvatarUrl nvarchar(250),
	@IsAdmin bit
as
	begin try		

		if not exists(select CustId from [MAS_Users] where UserID = @UserID)
		begin

			INSERT INTO [dbo].[MAS_Users]
				   ([UserId]
				   ,[UserLogin]
				   ,[UserPassword]
				   ,[IsManager]
				   ,[CustId]
				   ,[AvatarUrl]
				   ,[StartDt]
				   ,[IsActived]
				   ,FullName
				   ,Email
				   ,Phone
				   )
				SELECT
				   @UserId
				  ,@UserLogin
				  ,@UserPassword
				  ,@IsAdmin
				  ,@custId
				  ,null
				  ,getdate()
				  ,1
				  ,FullName
				  ,Email
				  ,Phone 
				FROM MAS_Customers
				WHERE CustId = @CustId

		end
		ELSE
		begin

			UPDATE t 
			SET  UserLogin = isnull(@UserLogin,UserLogin)
				,AvatarUrl = isnull(@AvatarUrl,AvatarUrl)
				,IsManager = isnull(@IsAdmin,IsManager)
				,UserPassword = isnull(@UserPassword,UserPassword)
				,CustId = @CustId
			FROM MAS_Users t 
			WHERE t.UserId  = @UserID 

		end

		UPDATE t 
		SET 
			AvatarUrl = isnull(@AvatarUrl,t.AvatarUrl)
		FROM MAS_Customers t 
			inner join MAS_Users t2 on t.CustId = t2.CustId
		WHERE t2.UserId  = @UserID 

		--UPDATE MAS_Employees 
		--	set IsUser = 1
		--WHERE CustId = @CustId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Usr_Insert_EmpUser ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'User', 'Insert', @SessionID, @AddlInfo
	end catch