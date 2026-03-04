





create procedure [dbo].[sp_COR_User_Profile_Link_Facebook]
	@userId	nvarchar(450),
	@id nvarchar(100),
	@email nvarchar(250),
	@name nvarchar(200),	
	@gender nvarchar(200),
	@birthday nvarchar(50),
	@token nvarchar(450)
as
	begin try		
	

		if exists(select reg_userId from UserInfo where userid = @userId)
		
		begin
			UPDATE [dbo].UserInfo
			   SET fb_linked = case when @id is null or @id = '' then 0 else 1 end
				  ,fb_id = @id
				  ,fb_name = @name
				  ,fb_email = @email
				  ,fb_gender = @gender
				  ,fb_birthday = @birthday
				  ,fb_token = @token
				  ,modified_dt = getdate()
			 WHERE userid = @userId and fb_id is null
		end
		
	
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_COR_User_Profile_Link_Facebook ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' 

		exec utl_ErrorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'Profile_Link', 'PUT', @SessionID, @AddlInfo
	end catch