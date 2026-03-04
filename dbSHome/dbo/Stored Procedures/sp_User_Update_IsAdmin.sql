





CREATE procedure [dbo].[sp_User_Update_IsAdmin]
	@userId	nvarchar(450),
	@IsAdmin bit
as
	begin try		
	
	if @IsAdmin = 1
	begin	 
		UPDATE t
			SET UserId = @userId
		FROM [MAS_Employees] t 
			inner join MAS_Users t1 on t.CustId = t1.CustId 
		WHERE t1.UserId = @userId

		update t
			set IsManager = 0
		FROM MAS_Users t 
			inner join MAS_Users t1 on t.CustId = t1.CustId 
		WHERE t1.UserId = @userId and not t.UserId = @userId

		update t1
			set IsManager = 1
		FROM MAS_Users t1
		WHERE t1.UserId = @userId
	end
	else
	begin

		UPDATE t
			SET UserId = null
		FROM [MAS_Employees] t 
			inner join MAS_Users t1 on t.CustId = t1.CustId 
		WHERE t1.UserId = @userId

		update t1
			set IsManager = 0
		FROM MAS_Users t1
		WHERE t1.UserId = @userId

	end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Update_IsAdmin ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' +@userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'UserAdmin', 'Update', @SessionID, @AddlInfo
	end catch