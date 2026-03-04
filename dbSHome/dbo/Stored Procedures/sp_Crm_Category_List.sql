










CREATE procedure [dbo].[sp_Crm_Category_List] 
	@userId				nvarchar(450),
	@base_type	int

as
	begin try 
		 
		SELECT [CategoryCd]
			  ,[base_type]
			  ,[CategoryName]
			  ,[ShowName]
			  ,[CategoryLevel]
			  ,[CategoryMail]
			  ,[ParentCd]
			  ,[CreatedBy]
			  ,[CreatedTime]
			  ,[IsActive]
			  ,[intOrder]
			  ,value	= [CategoryCd]
			  ,name		= [CategoryName]
		  FROM [dbo].[MAS_Category]
		  where base_type = @base_type
			and CategoryLevel = 1 
			order by intOrder

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Category_List' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'BaseType', 'GET', @SessionID, @AddlInfo
	end catch