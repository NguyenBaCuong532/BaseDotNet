

CREATE procedure [dbo].[sp_User_Update_RoleCategory]
	@UserId nvarchar(450),
	@cats nvarchar(400)
as
	begin try	
	declare @tbRoles TABLE 
	(
		CategoryCd [nvarchar](50) null
	)

	if @cats is null or @cats = ''
		DELETE FROM [dbo].MAS_Category_User
      WHERE UserId = @UserId
	else
	begin
		INSERT INTO @tbRoles SELECT [part] FROM [dbo].[SplitString](@cats,',')

		DELETE FROM [dbo].MAS_Category_User
		WHERE UserId = @UserId 
			and not CategoryCd in (select CategoryCd From @tbRoles)

		INSERT INTO [dbo].MAS_Category_User
			   (CategoryCd
			   ,[UserId]
			   ,[CreationTime])
		SELECT a.CategoryCd
			   ,@UserId
			   ,getdate()
		FROM @tbRoles a 
			inner join MAS_Category c on a.CategoryCd = c.CategoryCd 
		WHERE not exists(select CategoryCd FROM MAS_Category_User r 
				where r.CategoryCd = a.CategoryCd and r.UserId = @UserId)

	end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Update_RoleCategory ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_User_Update_RoleCategory', 'Insert', @SessionID, @AddlInfo
	end catch