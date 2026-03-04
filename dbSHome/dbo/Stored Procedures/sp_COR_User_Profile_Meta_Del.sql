






CREATE procedure [dbo].[sp_COR_User_Profile_Meta_Del]
	@userId	nvarchar(450),
	@Id uniqueidentifier
as
	begin try		
		
		DELETE FROM [dbo].[UserMeta]
		WHERE id = @Id
	
		Update t
			set idcard_Verified = 0
			   ,work_st = 0
		from UserInfo t
			join UserMeta b on t.reg_userId = b.reg_userId 
			where b.id = @Id 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_COR_User_Profile_Meta_Del ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' 

		exec utl_ErrorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserMeta', 'Del', @SessionID, @AddlInfo
	end catch