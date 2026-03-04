



CREATE procedure [dbo].[sp_COR_User_Login_RegGet]
	@reg_id	bigint

as
	begin try	
		  -- profile
		  SELECT [reg_UserId] as reg_id
				,[loginName]
				,[FullName]
				,[Phone]
				,[Email]
				,[verifyType]
				,1 as valid
				,'' as [messages]
				,userId
			FROM [dbo].UserInfo
			WHERE [reg_UserId] = @reg_id

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_COR_User_Login_RegGet ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserRegGet', 'Set', @SessionID, @AddlInfo
	end catch