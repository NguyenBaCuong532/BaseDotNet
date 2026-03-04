











CREATE procedure [dbo].[sp_User_Get_Category_ByUserId]
		@UserId nvarchar(450)

as
	begin try
	
	--1
	  SELECT b.CategoryCd
			,b.CategoryName
			,b.CategoryLevel
			,case when b.CategoryLevel = 0 then b.CategoryName else '--' + b.CategoryName end as ShowName
			,b.CategoryMail
	  FROM MAS_Category b 
	  WHERE Exists (select userid from MAS_Category_User a 
				  WHERE a.[UserId] = @UserId and 
				  (a.CategoryCd = b.CategoryCd or a.CategoryCd = b.ParentCd)
				  )
				and b.IsActive = 1
			Order by intOrder
		
	


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Get_Category_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CustCategory', 'GET', @SessionID, @AddlInfo
	end catch