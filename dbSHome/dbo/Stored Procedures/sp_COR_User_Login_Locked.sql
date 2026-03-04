







CREATE procedure [dbo].[sp_COR_User_Login_Locked]
		 @userId	nvarchar(450)
		,@isLocked		bit
		
as
	begin try		
	declare @valid bit = 1
	declare @messages nvarchar(50) = 'Khóa thành công'

		update t
			set lock_st = @isLocked
			   ,lock_dt = getdate()
		from UserInfo t
		where userId = @userId
			and isnull(lock_st,0) <> @isLocked

		select @valid as valid
			  ,@messages as [messages]
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_COR_User_Login_Locked ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' 

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'Login_Locked', 'Set', @SessionID, @AddlInfo
	end catch