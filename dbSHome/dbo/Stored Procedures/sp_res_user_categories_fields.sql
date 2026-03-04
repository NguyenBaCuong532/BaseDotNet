










CREATE procedure [dbo].[sp_res_user_categories_fields]
		@UserId nvarchar(450) ='a537eb94-6a1e-401c-b61d-4b2c03187f38',
		@isProject bit = 1
as
	begin try
	
	--1
	if @isProject = 1
		SELECT CategoryCd
		  FROM MAS_Category_User a
			join [dbo].MAS_Projects b on a.CategoryCd = b.sub_projectCd 
			  WHERE [UserId] = @UserId 
	else
			SELECT CategoryCd
		  FROM MAS_Category_User
			  WHERE [UserId] = @UserId 
	


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Get_RoleCategory_ByUserID ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RoleCategory', 'GET', @SessionID, @AddlInfo
	end catch