








CREATE procedure [dbo].[sp_User_Update_AgreedTerm]
	@loginName	nvarchar(100),
	@is_Agreed_Term bit
as
	begin try		
	if @is_Agreed_Term = 1
		update t1
			set  Is_Agreed_Term = @is_Agreed_Term
				,Agreed_Dt = getdate()
		FROM MAS_Users t1
		WHERE t1.UserLogin = @loginName


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Update_AgreedTerm ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'UserAgreedTerm', 'Update', @SessionID, @AddlInfo
	end catch