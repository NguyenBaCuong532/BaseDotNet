









CREATE procedure [dbo].[sp_User_Get_RoleCategory]
		@UserId nvarchar(450)

as
	begin try
	
	--1
	SELECT [CategoryCd]
		  ,[CategoryName]
		  ,case [CategoryLevel] when 0 then '' when 1 then '|--' else '|----' end + [CategoryName] as CategoryShow
		  ,[CategoryLevel]
		  ,[CategoryMail]
		  ,[ParentCd]
		  ,[CreatedBy]
		  ,[CreatedTime]
		  ,[IsActive]
		  ,[intOrder]
	  FROM [dbo].[MAS_Category]
		ORDER BY [intOrder]
	


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Get_RoleCategory ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RoleCategory', 'GET', @SessionID, @AddlInfo
	end catch